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

// Represents road condition data
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
  final String tomTomApiKey = 'YpeVPq4ZHaQL5EXwVVyTUG8GoxpkOi7x';
  List<LatLng> routePoints = [];
  bool isNavigating = false;
  StreamSubscription<Position>? positionStreamSubscription;
  bool _showTraffic = false;
  bool _showWeather = false;
  List<LatLng> waypoints = [];
  List<String> searchResults = [];
  String? _searchQuery;

  // Road condition data
  List<RoadCondition> roadConditions = [];
  bool _showRoadConditions = false; // Control road condition visibility

  @override
  void initState() {
    super.initState();
    // Simulate fetching road conditions when the map loads
    _loadRoadConditions();
  }

  @override
  void dispose() {
    positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> showCurrentLocation() async {
    setState(() {
      isLoading = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        myLocation = LatLng(position.latitude, position.longitude);
        isLoading = false;
      });
      mapController.move(myLocation!, 15);
      await _getNearbyLocations(myLocation!);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get location: $e')),
      );
    }
  }

  Future<void> _getNearbyLocations(LatLng center) async {
    setState(() {
      isLoading = true;
    });

    try {
      final double maxDistance = 0.05;
      final int numberOfLocations = 20;
      final random = math.Random();

      for (int i = 0; i < numberOfLocations; i++) {
        final double distance = random.nextDouble() * maxDistance;
        final double angle = random.nextDouble() * 2 * math.pi;
        final double xOffset = distance * math.cos(angle);
        final double yOffset = distance * math.sin(angle);
        final LatLng location =
            LatLng(center.latitude + xOffset, center.longitude + yOffset);

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

  Future<void> calculateRoute(LatLng start, LatLng end) async {
    setState(() {
      isLoading = true;
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
        final route = response.data['routes'][0]['legs'][0]['points'];
        setState(() {
          routePoints = route.map<LatLng>((point) {
            return LatLng(point['latitude'], point['longitude']);
          }).toList();
          isLoading = false;
        });
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

  void startNavigation(LatLng destination) {
    if (myLocation == null) return;

    setState(() {
      isNavigating = true;
    });

    calculateRoute(myLocation!, destination);

    positionStreamSubscription =
        Geolocator.getPositionStream().listen((position) {
      final currentLocation = LatLng(position.latitude, position.longitude);
      setState(() {
        myLocation = currentLocation;
      });

      for (final prediction in predictions) {
        final distance = Geolocator.distanceBetween(
          currentLocation.latitude,
          currentLocation.longitude,
          prediction.latitude,
          prediction.longitude,
        );

        if (distance < 100) {
          _showAlert('Warning: You are approaching an accident-prone area!');
        }
      }
    });
  }

  void stopNavigation() {
    setState(() {
      isNavigating = false;
      routePoints.clear();
    });
    positionStreamSubscription?.cancel();
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Alert'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
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

  // Simulate fetching road conditions (replace with API call)
  Future<void> _loadRoadConditions() async {
    //Simulating data fetch, replace with actual data source
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
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
              MaterialPageRoute(builder: (context) => const SettingsPageWeb()),
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
              if (routePoints.isNotEmpty)
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
                  if (myLocation != null)
                    Marker(
                      point: myLocation!,
                      width: 40,
                      height: 40,
                      child:
                          _buildCustomMarker(Icons.location_pin, Colors.blue),
                    ),
                  ...predictions.map(
                    (prediction) => Marker(
                      point: LatLng(prediction.latitude, prediction.longitude),
                      width: 40,
                      height: 40,
                      child: _buildCustomMarker(
                        Icons.warning_amber_rounded,
                        _getPredictionColor(prediction.prediction),
                      ),
                    ),
                  ),
                  // Road condition markers
                  if (_showRoadConditions)
                    ...roadConditions.map((condition) => Marker(
                          point: condition.location,
                          width: 40,
                          height: 40,
                          child: _buildRoadConditionMarker(condition),
                        )),
                ],
              ),
            ],
          ),
          if (isLoading) _buildLoadingIndicator(),
          _buildControlPanel(isLargeScreen),
          if (_searchQuery != null && searchResults.isNotEmpty)
            _buildSearchResultsList(),
        ],
      ),
    );
  }

  // Build road condition marker
  Widget _buildRoadConditionMarker(RoadCondition condition) {
    Color color;
    IconData icon;

    switch (condition.condition) {
      case "Good":
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case "Moderate":
        color = Colors.orange;
        icon = Icons.warning;
        break;
      case "Poor":
        color = Colors.red;
        icon = Icons.error;
        break;
      default:
        color = Colors.grey;
        icon = Icons.info;
    }

    return GestureDetector(
      onTap: () {
        _showRoadConditionDetails(condition);
      },
      child: Container(
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
      ),
    );
  }

  // Road Condition Details Popup
  void _showRoadConditionDetails(RoadCondition condition) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Road Condition"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Condition: ${condition.condition}",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Description: ${condition.description}"),
              SizedBox(height: 8),
              Text(
                  "Location: (${condition.location.latitude.toStringAsFixed(4)}, ${condition.location.longitude.toStringAsFixed(4)})"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
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

  Widget _buildSearchResultsList() {
    return Positioned(
      top: 100,
      left: 20,
      right: 20,
      child: Card(
        elevation: 4,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: searchResults.length,
          itemBuilder: (context, index) {
            final result = searchResults[index];
            return ListTile(
              title: Text(result),
              onTap: () async {
                LatLng? coordinates = await _getCoordinatesFromAddress(result);
                if (coordinates != null) {
                  mapController.move(coordinates, 15);
                  setState(() {
                    myLocation = coordinates;
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Failed to find coordinates for this location.')),
                  );
                }

                setState(() {
                  searchResults.clear();
                  _searchQuery = null;
                });
              },
            );
          },
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
              _buildControlButton(
                icon: Icons.list,
                label: 'Predictions',
                onPressed: _showPredictionsBottomSheet,
                isLargeScreen: isLargeScreen,
              ),
              //Add road conditions button

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
}
