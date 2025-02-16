import 'dart:async';
import 'dart:math' as math;
import 'package:accident_hotspot/Maps/chat.dart';
import 'package:accident_hotspot/Setting_Page/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';

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
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController mapController = MapController();
  LatLng? myLocation;
  bool isLoading = false;
  List<AccidentPrediction> predictions = [];
  final Dio dio = Dio();
  bool _isSatelliteView = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
                    builder: (context) => SettingsPage(),
                  ));
            },
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
                    ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                    : "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.example.accident_hotspot',
              ),
              MarkerLayer(
                markers: [
                  if (myLocation != null)
                    Marker(
                      point: myLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_pin,
                          color: Colors.blue, size: 40),
                    ),
                  ...predictions.map(
                    (prediction) => Marker(
                      point: LatLng(prediction.latitude, prediction.longitude),
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: _getPredictionColor(prediction.prediction),
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 20,
                right: 20,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      child: const Icon(Icons.add),
                      onPressed: () {
                        mapController.move(
                          mapController.camera.center,
                          mapController.camera.zoom + 1,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      child: const Icon(Icons.remove),
                      onPressed: () {
                        mapController.move(
                          mapController.camera.center,
                          mapController.camera.zoom - 1,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey),
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
                          builder: (context) => const ChatBotScreen()),
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

  Color _getPredictionColor(String prediction) {
    if (prediction.toLowerCase().contains('high')) {
      return Colors.red[800]!;
    } else if (prediction.toLowerCase().contains('medium')) {
      return Colors.red[800]!;
    }
    return Colors.red[800]!;
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
}
