import 'dart:async';
import 'dart:math' as math;
import 'package:accident_hotspot/Maps/Chat_Web.dart';
import 'package:accident_hotspot/Settings_Page_web/settings_web.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class AccidentPrediction {
  final double latitude;
  final double longitude;
  final String prediction;

  AccidentPrediction({
    required this.latitude,
    required this.longitude,
    required this.prediction,
  });

  @override
  String toString() {
    return 'Location: ($latitude, $longitude) - Prediction: $prediction';
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? myLocation;
  bool isLoading = false;
  List<AccidentPrediction> predictions = [];
  final Dio dio = Dio();
  bool _isSatelliteView = false;
  double _currentZoom = 15.0;

  CameraPosition get _initialCameraPosition {
    if (myLocation != null) {
      return CameraPosition(target: myLocation!, zoom: _currentZoom);
    }
    return const CameraPosition(target: LatLng(0, 0), zoom: 2);
  }

  Future<void> showCurrentLocation() async {
    setState(() {
      isLoading = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        myLocation = LatLng(position.latitude, position.longitude);
        isLoading = false;
      });

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: myLocation!, zoom: _currentZoom),
        ),
      );
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
      final double maxDistance = 0.05; // Maximum radius from center
      final int numberOfLocations = 20;
      final random = math.Random();

      for (int i = 0; i < numberOfLocations; i++) {
        final double distance = random.nextDouble() * maxDistance;
        final double angle = random.nextDouble() * 2 * math.pi;
        final double xOffset = distance * math.cos(angle);
        final double yOffset = distance * math.sin(angle);
        final LatLng location =
            LatLng(center.latitude + xOffset, center.longitude + yOffset);

        final prediction = await predictAccident(location);
        final accidentPrediction = AccidentPrediction(
          latitude: location.latitude,
          longitude: location.longitude,
          prediction: prediction['prediction'] ?? 'Unknown',
        );

        setState(() {
          predictions.add(accidentPrediction);
        });
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

  void _toggleMapView() {
    setState(() {
      _isSatelliteView = !_isSatelliteView;
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
                      title: Text(
                          'Location: (${prediction.latitude}, ${prediction.longitude})'),
                      subtitle: Text('Prediction: ${prediction.prediction}'),
                      trailing: Icon(
                        Icons.add_alert, // Alert icon
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

  Color _getPredictionColor(String prediction) {
    if (prediction.toLowerCase().contains('high')) {
      return Colors.red[800]!;
    } else if (prediction.toLowerCase().contains('medium')) {
      return Colors.orange;
    }
    return Colors.green;
  }

  Future<void> _zoomIn() async {
    _currentZoom += 1;
    final GoogleMapController controller = await _controller.future;
    if (myLocation != null) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: myLocation!, zoom: _currentZoom),
        ),
      );
    }
  }

  Future<void> _zoomOut() async {
    _currentZoom -= 1;
    final GoogleMapController controller = await _controller.future;
    if (myLocation != null) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: myLocation!, zoom: _currentZoom),
        ),
      );
    }
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    if (myLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: myLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    for (var i = 0; i < predictions.length; i++) {
      final prediction = predictions[i];
      markers.add(
        Marker(
          markerId: MarkerId('prediction_$i'),
          position: LatLng(prediction.latitude, prediction.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'Prediction: ${prediction.prediction}',
            snippet: '(${prediction.latitude}, ${prediction.longitude})',
          ),
        ),
      );
    }
    return markers;
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      shape: const CircleBorder(),
      elevation: 4,
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        style: IconButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.all(16),
        ),
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accident Hotspots',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF007B83),
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPageWeb(),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            mapType: _isSatelliteView ? MapType.satellite : MapType.normal,
            onMapCreated: (GoogleMapController controller) {
              if (!_controller.isCompleted) {
                _controller.complete(controller);
              }
            },
            markers: _buildMarkers(),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey),
              ),
            ),
          Positioned(
            top: 20,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'zoomIn',
                  child: const Icon(Icons.add),
                  onPressed: _zoomIn,
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoomOut',
                  child: const Icon(Icons.remove),
                  onPressed: _zoomOut,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              children: [
                _buildActionButton(
                  icon: Icons.location_searching,
                  color: Colors.blueGrey[900]!,
                  onPressed: showCurrentLocation,
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  icon: Icons.headphones,
                  color: Colors.blueGrey[800]!,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ChatBotScreenWeb()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  icon: _isSatelliteView ? Icons.map : Icons.satellite,
                  color: Colors.blueGrey[700]!,
                  onPressed: _toggleMapView,
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  icon: Icons.list,
                  color: Colors.blueGrey[600]!,
                  onPressed: _showPredictionsBottomSheet,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
