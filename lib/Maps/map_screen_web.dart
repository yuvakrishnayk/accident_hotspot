import 'dart:async';
import 'dart:math' as math;
import 'package:accident_hotspot/Maps/Chat_Web.dart';
import 'package:accident_hotspot/Settings_Page_web/settings_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';

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

class MapScreenWeb extends StatefulWidget {
  const MapScreenWeb({super.key});

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
                ],
              ),
            ],
          ),
          if (isLoading) _buildLoadingIndicator(),
          _buildControlPanel(isLargeScreen),
        ],
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
                label: 'Voice Assistant',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ChatBotScreenWeb()),
                ),
                isLargeScreen: isLargeScreen,
              ),
              _buildControlButton(
                icon: _isSatelliteView ? Icons.map : Icons.satellite,
                label: _isSatelliteView ? 'Map View' : 'Satellite View',
                onPressed: _toggleMapView,
                isLargeScreen: isLargeScreen,
              ),
              _buildControlButton(
                icon: Icons.list,
                label: 'Predictions',
                onPressed: _showPredictionsBottomSheet,
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
