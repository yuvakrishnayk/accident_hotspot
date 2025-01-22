import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as Math;

// Add these imports
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  LatLng? mylocation;
  String? placeName;
  List<AccidentPrediction> predictions = [];

  Future<Map<String, dynamic>> predictAccident(LatLng location) async {
    print(
        '\nPredicting for location: (${location.latitude}, ${location.longitude})');
    try {
      final response = await http.post(
        Uri.parse('https://jaga001.pythonanywhere.com/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
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
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('Prediction result: ${result['prediction']}');
        return result;
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to predict accident');
      }
    } catch (e) {
      print('Error making prediction: $e');
      throw Exception('Failed to predict accident: $e');
    }
  }

  Future<void> _getNearbyLocations(LatLng center) async {
    print('\n=== Starting predictions for random locations ===');
    print('Center point: (${center.latitude}, ${center.longitude})');

    setState(() {
      predictions.clear();
    });

    final double maxDistance = 0.05; // Maximum radius from center
    final int numberOfLocations = 20;
    final random = Math.Random();

    for (int i = 0; i < numberOfLocations; i++) {
      print('\nCalculating location ${i + 1} of $numberOfLocations');

      // Generate random distance and angle
      final double distance = random.nextDouble() * maxDistance;
      final double angle = random.nextDouble() * 2 * Math.pi;

      // Convert to lat/lng offsets
      final double xOffset = distance * Math.cos(angle);
      final double yOffset = distance * Math.sin(angle);

      final LatLng location =
          LatLng(center.latitude + xOffset, center.longitude + yOffset);

      try {
        final prediction = await predictAccident(location);
        final accidentPrediction = AccidentPrediction(
          latitude: location.latitude,
          longitude: location.longitude,
          prediction: prediction['prediction'] ?? 'Unknown',
        );

        print('Location ${i + 1} prediction complete:');
        print(accidentPrediction.toString());

        setState(() {
          predictions.add(accidentPrediction);
        });
      } catch (e) {
        print('Error predicting for location $location: $e');
      }
    }

    print('\n=== All predictions complete ===');
    print('Total predictions made: ${predictions.length}');
    print('\nSummary of all predictions:');
    for (int i = 0; i < predictions.length; i++) {
      print('${i + 1}. ${predictions[i]}');
    }
  }

  Future<void> showCurrentLocation() async {
    print('\n=== Getting current location ===');
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    print('Current position: (${position.latitude}, ${position.longitude})');

    setState(() {
      mylocation = LatLng(position.latitude, position.longitude);
    });
    mapController.move(mylocation!, 15);
    await _getNearbyLocations(mylocation!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              ),
              MarkerLayer(
                markers: [
                  if (mylocation != null)
                    Marker(
                      point: mylocation!,
                      width: 80,
                      height: 80,
                      child: Icon(
                        Icons.location_on,
                        color: Colors.green,
                        size: 40,
                      ),
                    ),
                  ...predictions.map(
                    (prediction) => Marker(
                      point: LatLng(prediction.latitude, prediction.longitude),
                      width: 80,
                      height: 80,
                      child: Icon(
                        Icons.warning,
                        color: Colors.red,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.indigo,
                  onPressed: showCurrentLocation,
                  child: Icon(Icons.location_searching_outlined),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
