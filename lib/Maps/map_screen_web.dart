import 'dart:async';
import 'dart:math' as math;
import 'package:accident_hotspot/Maps/Chat_Web.dart';
import 'package:accident_hotspot/Settings_Page_web/settings_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

class AccidentPrediction {
  final double latitude;
  final double longitude;
  final String prediction;
  final String placeName;

  AccidentPrediction({
    required this.latitude,
    required this.longitude,
    required this.prediction,
    required this.placeName,
  });

  @override
  String toString() {
    return 'Location: ($latitude, $longitude) - Prediction: $prediction - Place: $placeName';
  }
}

class RoadCondition {
  final LatLng location;
  final String condition; // e.g., "Good", "Moderate", "Poor"
  final String description; // Detailed description
  RoadCondition(
      {required this.location,
      required this.condition,
      required this.description});
}

class MapScreenWeb extends StatefulWidget {
  const MapScreenWeb({Key? key}) : super(key: key);

  @override
  State<MapScreenWeb> createState() => _MapScreenWebState();
}

class _MapScreenWebState extends State<MapScreenWeb> {
  final MapController mapController = MapController();
  LatLng? myLocation;
  bool isLoading = false;
  List<AccidentPrediction> predictions = [];
  final Dio dio = Dio();
  bool _isSatelliteView = false;
  final String tomTomApiKey =
      'MQ2Z3RdIihToHCcZzg2AK8ewBGuGxM9Q'; // Replace with your actual API key
  List<LatLng> routePoints = [];
  int? selectedRouteIndex; // Index of the currently displayed route
  bool isNavigating = false;
  StreamSubscription<Position>? positionStreamSubscription;
  bool _showTraffic = false;
  bool _showWeather = false;
  List<LatLng> waypoints = [];
  List<String> searchResults = [];
  String? _searchQuery;

  List<RoadCondition> roadConditions = [];
  LatLng? _searchedLocation;
  Map<String, dynamic>? _locationInfo;
  String? _routeInfo; // String to display route information
  String routeDistance = '';
  String routeDuration = '';

  @override
  void initState() {
    super.initState();
    _loadRoadConditions();
    _determinePosition();
  }

  @override
  void dispose() {
    positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> showCurrentLocation() async {
    setState(() {
      isLoading = true;
      _locationInfo = null;
      predictions.clear();
      routePoints.clear();
      selectedRouteIndex = null;
      _routeInfo = null;
      _searchedLocation = null;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      LatLng currentLocation = LatLng(position.latitude, position.longitude);
      setState(() {
        myLocation = currentLocation;
        isLoading = false;
      });
      mapController.move(myLocation!, 15);
      await _getNearbyLocations(myLocation!);
      await _fetchLocationInfo(currentLocation);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get location: $e')),
      );
    }
  }

  Future<void> _getNearbyLocations(LatLng center,
      {double radiusKm = 5.0}) async {
    if (isNavigating) return; // Do not fetch nearby locations if navigating

    setState(() {
      isLoading = true;
      predictions.clear();
    });

    try {
      final numberOfLocations = 20;
      final random = math.Random();

      final double radiusDegrees = radiusKm / 111.0;

      for (int i = 0; i < numberOfLocations; i++) {
        final double distance = radiusDegrees * math.sqrt(random.nextDouble());
        final double angle = 2 * math.pi * random.nextDouble();

        final double latitudeOffset = distance * math.cos(angle);
        final double longitudeOffset = distance * math.sin(angle);

        final double newLatitude = center.latitude + latitudeOffset;
        final double newLongitude = center.longitude + longitudeOffset;

        final LatLng location = LatLng(newLatitude, newLongitude);

        try {
          final prediction = await predictAccident(location);
          final placeName = await _getPlaceName(location);
          final accidentPrediction = AccidentPrediction(
            latitude: location.latitude,
            longitude: location.longitude,
            prediction: prediction['prediction'] ?? 'Unknown',
            placeName: placeName,
          );

          setState(() {
            predictions.add(accidentPrediction);
          });
        } catch (e) {
          print('Error processing location: $e');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get nearby locations: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String> _getPlaceName(LatLng location) async {
    try {
      final response = await dio.get(
        'https://api.tomtom.com/search/2/reverseGeocode/${location.latitude},${location.longitude}.json',
        queryParameters: {
          'key': tomTomApiKey,
        },
      );

      if (response.statusCode == 200) {
        final address = response.data['addresses'][0]['address'];
        return address['freeformAddress'] ?? 'Unknown Location';
      } else {
        throw Exception('Failed to fetch place name: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch place name: $e');
    }
  }

  Future<Map<String, dynamic>> predictAccident(LatLng location) async {
    try {
      final response = await dio.post(
        'https://jaga001.pythonanywhere.com/predict',
        data: {
          'Latitude': location.latitude,
          'Longitude': location.longitude,
          'Weather': "Rainy",
          'Age': 5,
          'Type_of_Vehicle': "Car",
          'Road_Type': "City Road",
          'Time_of_Day': "Night",
          'Traffic_Density': 1.0,
          'Speed_Limit': 60,
          'Number_of_Vehicles': 3,
          'Driver_Alcohol': 0.0,
          'Accident_Severity': "High",
          'Road_Condition': "Wet",
          'Vehicle_Type': "Car",
          'Driver_Age': 50,
          'Driver_Experience': 10,
          'Road_Light_Condition': "Daylight",
          'Hour': 22,
          'Day': 15,
          'Month': 1,
          'DayOfWeek': 5,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to predict accident: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to predict accident: $e');
    }
  }

  Future<void> calculateRoutes(LatLng start, LatLng end) async {
    setState(() {
      isLoading = true;
      routePoints.clear();
      _routeInfo = null;
      predictions.clear();
    });

    try {
      final response = await dio.get(
        'https://api.tomtom.com/routing/1/calculateRoute/${start.latitude},${start.longitude}:${end.latitude},${end.longitude}/json',
        queryParameters: {
          'key': tomTomApiKey,
          'instructionsType': 'text',
          'travelMode': 'car',
        },
      );

      if (response.statusCode == 200) {
        final routeData =
            response.data['routes'][0]['legs'][0]['points'] as List;

        setState(() {
          routePoints = routeData.map<LatLng>((point) {
            return LatLng(point['latitude'], point['longitude']);
          }).toList();
          isLoading = false;
        });

        _displayRouteInfo(response.data['routes'][0]);

        // Predict accidents along the route
        if (isNavigating) {
          // only predicts if navigation has not stopped
          await _predictAccidentsAlongRoute(routePoints);
        }
      } else {
        throw Exception('Failed to calculate route: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to calculate route: $e')),
      );
    }
  }

  Future<void> _predictAccidentsAlongRoute(List<LatLng> routePoints) async {
    if (!isNavigating) return;

    for (var point in routePoints) {
      try {
        final prediction = await predictAccident(point);
        final placeName = await _getPlaceName(point);
        final accidentPrediction = AccidentPrediction(
          latitude: point.latitude,
          longitude: point.longitude,
          prediction: prediction['prediction'] ?? 'Unknown',
          placeName: placeName,
        );

        setState(() {
          predictions.add(accidentPrediction);
        });
      } catch (e) {
        print('Error predicting accident at point: $e');
      }
    }
  }

  void _displayRouteInfo(dynamic routeData) {
    final summary = routeData['summary'];
    final distanceInMeters = summary['lengthInMeters'];
    final travelTimeInSeconds = summary['travelTimeInSeconds'];

    final distanceInKilometers = distanceInMeters / 1000;
    final travelTimeInMinutes = travelTimeInSeconds / 60;

    setState(() {
      _routeInfo = 'Distance: ${distanceInKilometers.toStringAsFixed(2)} km, '
          'Travel Time: ${travelTimeInMinutes.toStringAsFixed(2)} minutes';
    });
  }

  void startNavigation(LatLng destination) {
    if (myLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Current location not available.')),
      );
      return;
    }

    setState(() {
      isNavigating = true;
      _searchedLocation = null;
      _searchQuery = null;
      searchResults.clear();
      predictions.clear();
    });

    calculateRoutes(myLocation!, destination);

    positionStreamSubscription =
        Geolocator.getPositionStream().listen((position) {
      final currentLocation = LatLng(position.latitude, position.longitude);
      setState(() {
        myLocation = currentLocation;
      });

      if (isNavigating) {
        // only calculates if navigation is enabled
        for (final prediction in predictions) {
          calculateDistance(currentLocation,
              LatLng(prediction.latitude, prediction.longitude));
        }
      }
    });
  }

  double calculateDistance(LatLng point1, LatLng point2) {
    var p = 0.017453292519943295;
    var c = math.cos;
    var a = 0.5 -
        c((point2.latitude - point1.latitude) * p) / 2 +
        c(point1.latitude * p) *
            c(point2.latitude * p) *
            (1 - c((point2.longitude - point1.longitude) * p)) /
            2;
    return 12742 * math.asin(math.sqrt(a));
  }

  void stopNavigation() {
    setState(() {
      isNavigating = false;
      routePoints.clear();
      selectedRouteIndex = null;
      _routeInfo = null;
      predictions.clear();
    });
    positionStreamSubscription?.cancel();
    _getNearbyLocations(myLocation!);
  }

  void _toggleMapView() {
    setState(() {
      _isSatelliteView = !_isSatelliteView;
    });
  }

  void _toggleTraffic() {
    setState(() {
      _showTraffic = !_showTraffic;
    });
  }

  void _showPredictionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Accident Predictions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: predictions.length,
                  itemBuilder: (context, index) {
                    final prediction = predictions[index];
                    return ListTile(
                      title: Text('Place: ${prediction.placeName}'),
                      subtitle: Text(
                          'Location: (${prediction.latitude}, ${prediction.longitude})\nPrediction: ${prediction.prediction}'),
                      trailing: Icon(
                        Icons.warning_amber_rounded,
                        color: _getPredictionColor(prediction.prediction),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _loadRoadConditions() async {
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      roadConditions = [
        RoadCondition(
            location: LatLng(37.7749, -122.4194), // San Francisco
            condition: "Moderate",
            description: "Potholes and minor cracks"),
        RoadCondition(
            location: LatLng(34.0522, -118.2437), // Los Angeles
            condition: "Good",
            description: "Recently resurfaced, smooth road"),
        RoadCondition(
            location: LatLng(40.7128, -74.0060), // New York
            condition: "Poor",
            description: "Heavy traffic and deteriorated surface"),
      ];
    });
  }

  Future<LatLng?> _getCoordinatesFromAddress(String address) async {
    try {
      final response = await Dio().get(
        'https://api.tomtom.com/search/2/geocode/$address.json',
        queryParameters: {'key': tomTomApiKey},
      );

      if (response.statusCode == 200 &&
          response.data['results'] != null &&
          response.data['results'].isNotEmpty) {
        return LatLng(
          response.data['results'][0]['position']['lat'],
          response.data['results'][0]['position']['lon'],
        );
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching coordinates: $e');
      return null;
    }
  }

  Future<void> _fetchLocationInfo(LatLng location) async {
    try {
      final response = await dio.get(
        'https://api.tomtom.com/search/2/reverseGeocode/${location.latitude},${location.longitude}.json',
        queryParameters: {'key': tomTomApiKey},
      );

      if (response.statusCode == 200) {
        setState(() {
          _locationInfo = response.data;
        });
      } else {
        print('Failed to fetch location info: ${response.statusCode}');
        setState(() {
          _locationInfo = null;
        });
      }
    } catch (e) {
      print('Error fetching location info: $e');
      setState(() {
        _locationInfo = null;
      });
    }
  }

  void _searchPlaces(String query) async {
    if (isNavigating) return;

    if (query.isEmpty) {
      setState(() {
        searchResults.clear();
        _searchQuery = null;
      });
      return;
    }

    try {
      final response = await dio.get(
        'https://api.tomtom.com/search/2/geocode/$query.json',
        queryParameters: {'key': tomTomApiKey, 'limit': 5},
      );

      if (response.statusCode == 200) {
        setState(() {
          searchResults = (response.data['results'] as List)
              .map<String>(
                  (result) => result['address']['freeformAddress'] as String)
              .toList();
          _searchQuery = query;
        });
      } else {
        print('Failed to search places: ${response.statusCode}');
        setState(() {
          searchResults.clear();
          _searchQuery = null;
        });
      }
    } catch (e) {
      print('Error searching places: $e');
      setState(() {
        searchResults.clear();
        _searchQuery = null;
      });
    }
  }

  Widget _buildSearchResultsList() {
    return Positioned(
      top: 140,
      left: 20,
      child: Container(
        width: 300,
        constraints: const BoxConstraints(maxHeight: 300),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final result = searchResults[index];
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.location_on_outlined,
                      color: const Color(0xFF005662),
                      size: 20,
                    ),
                    title: Text(
                      result,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    dense: true,
                    onTap: () async {
                      LatLng? coordinates =
                          await _getCoordinatesFromAddress(result);
                      if (coordinates != null) {
                        mapController.move(coordinates, 15);
                        setState(() {
                          myLocation = coordinates;
                          _searchedLocation = coordinates;
                          searchResults.clear();
                          _searchQuery = null;
                          _locationInfo = null;
                        });
                        await _fetchLocationInfo(coordinates);
                        await _getNearbyLocations(coordinates);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Failed to find coordinates for this location.'),
                          ),
                        );
                      }
                    },
                    hoverColor: Colors.grey[100],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomMarker(IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  Widget _buildControlPanel(bool isLargeScreen) {
    return Positioned(
      top: 20,
      right: 20,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(12),
          width: isLargeScreen ? 300 : 60,
          child: Column(
            crossAxisAlignment: isLargeScreen
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLargeScreen)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Map Controls',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              _buildControlButton(
                icon: Icons.location_searching,
                label: 'Current Location',
                onPressed: showCurrentLocation,
                isLargeScreen: isLargeScreen,
              ),
              _buildControlButton(
                icon: Icons.headphones,
                label: 'Assistant',
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ChatBotScreenWeb())),
                isLargeScreen: isLargeScreen,
              ),
              _buildControlButton(
                icon: _isSatelliteView ? Icons.map : Icons.satellite,
                label: _isSatelliteView ? 'Map View' : 'Satellite View',
                onPressed: _toggleMapView,
                isLargeScreen: isLargeScreen,
              ),
              _buildControlButton(
                icon: Icons.traffic,
                label: 'Traffic',
                onPressed: _toggleTraffic,
                isLargeScreen: isLargeScreen,
              ),
              if (!isNavigating) //Conditionally show Predictions
                _buildControlButton(
                  icon: Icons.list,
                  label: 'Predictions',
                  onPressed: _showPredictionsBottomSheet,
                  isLargeScreen: isLargeScreen,
                ),
              if (!isNavigating)
                _buildControlButton(
                  icon: Icons.navigation,
                  label: 'Destination',
                  onPressed: _showSearchDialog,
                  isLargeScreen: isLargeScreen,
                ),
              if (isNavigating)
                _buildControlButton(
                  icon: Icons.stop,
                  label: 'Stop Navigation',
                  onPressed: stopNavigation,
                  isLargeScreen: isLargeScreen,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isLargeScreen,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: isLargeScreen
          ? ListTile(
              leading: Icon(icon, color: const Color(0xFF005662)),
              title: Text(label, style: GoogleFonts.inter()),
              onTap: onPressed,
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            )
          : IconButton(
              icon: Icon(icon),
              onPressed: onPressed,
              color: const Color(0xFF005662),
            ),
    );
  }

  Color _getPredictionColor(String prediction) {
    if (prediction.toLowerCase().contains('high')) {
      return Colors.red[800]!;
    } else if (prediction.toLowerCase().contains('medium')) {
      return Colors.red[800]!;
    }
    return Colors.red[800]!;
  }

  Future<void> _showSearchDialog() async {
    TextEditingController searchController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Search Destination'),
          content: TextField(
            controller: searchController,
            decoration: InputDecoration(hintText: 'Enter destination'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Search'),
              onPressed: () async {
                String destination = searchController.text;
                if (destination.isNotEmpty) {
                  Navigator.of(context).pop();
                  LatLng? destinationCoordinates =
                      await _getCoordinatesFromAddress(destination);
                  if (destinationCoordinates != null) {
                    startNavigation(destinationCoordinates);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Destination not found")));
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition();
    LatLng currentLocation = LatLng(position.latitude, position.longitude);
    setState(() {
      myLocation = currentLocation;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            SizedBox(
              width: 10,
            ),
            Image.network(
              'https://i.ibb.co/dwBJ16GL/iconn-removebg-preview.png',
              height: 40,
            ),
            const SizedBox(width: 12),
            Text(
              'SAFORA',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF005662),
        elevation: 0,
        actions: [
          if (isLargeScreen) ...[],
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPageWeb()),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: myLocation ?? LatLng(0, 0),
              initialZoom: 14,
              interactionOptions: InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: _isSatelliteView
                    ? 'https://api.tomtom.com/map/1/tile/sat/main/{z}/{x}/{y}.jpg?key=$tomTomApiKey'
                    : 'https://api.tomtom.com/map/1/tile/basic/main/{z}/{x}/{y}.png?key=$tomTomApiKey',
                userAgentPackageName: 'com.example.accident_hotspot',
              ),
              if (_showTraffic)
                TileLayer(
                  urlTemplate:
                      'https://api.tomtom.com/traffic/map/4/tile/flow/relative/{z}/{x}/{y}.png?key=$tomTomApiKey',
                ),
              if (_showWeather)
                TileLayer(
                  urlTemplate:
                      'https://api.tomtom.com/weather/map/1/tile/clouds/{z}/{x}/{y}.png?key=$tomTomApiKey',
                ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routePoints,
                    color: Colors.blue,
                    strokeWidth: 4,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  if (myLocation != null && !isNavigating)
                    Marker(
                      point: myLocation!,
                      width: 40,
                      height: 40,
                      child:
                          _buildCustomMarker(Icons.location_pin, Colors.blue),
                    ),
                  if (_searchedLocation != null && !isNavigating)
                    Marker(
                      point: _searchedLocation!,
                      width: 40,
                      height: 40,
                      child:
                          _buildCustomMarker(Icons.location_on, Colors.purple),
                    ),
                  if (isNavigating)
                    Marker(
                      point: myLocation!,
                      width: 40,
                      height: 40,
                      child: _buildCustomMarker(Icons.navigation, Colors.green),
                    ),
                  if (!isNavigating)
                    ...predictions.map(
                      (prediction) => Marker(
                        point:
                            LatLng(prediction.latitude, prediction.longitude),
                        width: 40,
                        height: 40,
                        child: _buildCustomMarker(
                          Icons.warning_amber_rounded,
                          _getPredictionColor(prediction.prediction),
                        ),
                      ),
                    ),
                  if (isNavigating)
                    ...predictions.map((prediction) => Marker(
                          point:
                              LatLng(prediction.latitude, prediction.longitude),
                          width: 40,
                          height: 40,
                          child: _buildCustomMarker(
                            Icons.warning_amber_rounded,
                            _getPredictionColor(prediction.prediction),
                          ),
                        ))
                ],
              ),
            ],
          ),
          if (isLoading) _buildLoadingIndicator(),
          _buildControlPanel(isLargeScreen),
          if (!isNavigating)
            Positioned(
              top: 80,
              left: 20,
              child: _buildSearchInput(),
            ),
          if (_searchQuery != null && searchResults.isNotEmpty && !isNavigating)
            _buildSearchResultsList(),
          if (_locationInfo != null && !isNavigating)
            _buildLocationInfoPanel(_locationInfo!),
          if (_routeInfo != null) _buildRouteInfoPanel(_routeInfo!),
          if (routeDistance.isNotEmpty && routeDuration.isNotEmpty)
            Positioned(
              bottom: 20,
              left: 20,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(routeDistance, style: TextStyle(fontSize: 16)),
                    Text(routeDuration, style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchInput() {
    return Container(
      width: 300, // Increased width
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        style: GoogleFonts.inter(
          fontSize: 15,
          color: Colors.grey[800],
        ),
        decoration: InputDecoration(
          hintText: 'Search locations...',
          hintStyle: GoogleFonts.inter(
            color: Colors.grey[400],
            fontSize: 15,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: const Color(0xFF005662),
            size: 20,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.close_rounded,
              color: Colors.grey[400],
              size: 20,
            ),
            onPressed: () {
              setState(() {
                searchResults.clear();
                _searchQuery = null;
              });
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          fillColor: Colors.white,
          filled: true,
        ),
        onChanged: _searchPlaces,
      ),
    );
  }

  Widget _buildLocationInfoPanel(Map<String, dynamic> locationInfo) {
    final address = locationInfo['addresses'][0]['address'];
    return Positioned(
      bottom: 2,
      left: 20,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Location Information',
                style: GoogleFonts.inter(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Address: ${address['freeformAddress'] ?? 'Unknown'}',
                style: GoogleFonts.inter(),
              ),
              Text(
                'City: ${address['municipality'] ?? 'Unknown'}',
                style: GoogleFonts.inter(),
              ),
              Text(
                'Country: ${address['country'] ?? 'Unknown'}',
                style: GoogleFonts.inter(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteInfoPanel(String routeInfo) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            routeInfo,
            style: GoogleFonts.inter(fontSize: 14),
          ),
        ),
      ),
    );
  }
}
