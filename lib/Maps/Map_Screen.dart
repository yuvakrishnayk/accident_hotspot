import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'dart:math' as Math;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // --- Map Variables ---
  final MapController mapController = MapController();
  LatLng? mylocation;
  String? placeName;
  List<LatLng> nearbyLocations = [];

  StreamSubscription<Position>? _positionStreamSubscription;

  // --- Location Functions ---
  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw "Location services are disabled.";
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw "Location permissions are denied.";
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw "Location permissions are permanently denied.";
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _getNearbyLocations(LatLng center) async {
    setState(() {
      nearbyLocations.clear();
    });

    // Modified to use a random generation within a radius
    final double distance = 0.015; // Distance in degrees (approx 20-25km)
    final int numberOfLocations = 20; // Get 20 nearby locations

    final List<LatLng> locations = [];

    for (int i = 0; i < numberOfLocations; i++) {
      //Generate random angle
      final double angle = (i / numberOfLocations) * 2 * 3.141592653589793;

      // Generate a random radius (a distance between 0 and the radius)
      final double randomRadius = distance * 0.8 * (1 - i / numberOfLocations);

      // Calculate the x and y offsets (distance from the center)
      final double xOffset = randomRadius *
          1.0 *
          (0.5 * (i % 2) * 1) *
          (1 * (0.5 + i / numberOfLocations)) *
          (1 * (i % 3 == 0 ? 1 : 0.5)) *
          (0.5 * (i % 4 != 0 ? 1 : 0.5) * (i % 5 == 0 ? 0.5 : 1)) *
          (i % 6 != 0 ? 1 : 0.5) *
          (i % 7 == 0 ? 0.5 : 1) *
          Math.cos(angle);
      final double yOffset = randomRadius *
          1.0 *
          (0.5 * (i % 2) * 1) *
          (1 * (0.5 + i / numberOfLocations)) *
          (1 * (i % 3 == 0 ? 1 : 0.5)) *
          (0.5 * (i % 4 != 0 ? 1 : 0.5) * (i % 5 == 0 ? 0.5 : 1)) *
          (i % 6 != 0 ? 1 : 0.5) *
          (i % 7 == 0 ? 0.5 : 1) *
          Math.sin(angle);

      //Add the locations to the array
      final LatLng nearbyLocation =
          LatLng(center.latitude + xOffset, center.longitude + yOffset);
      locations.add(nearbyLocation);
    }

    setState(() {
      nearbyLocations = locations;
    });

    print("$nearbyLocations");
  }

  Future<void> showCurrentLocation() async {
    try {
      Position position = await _determinePosition();
      _updateLocation(position);
    } catch (e) {
      print("Error getting current location: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error getting current location: $e"),
      ));
    }
  }

  void _updateLocation(Position position) {
    LatLng currentLatLng = LatLng(position.latitude, position.longitude);
    mapController.move(currentLatLng, 15);

    _getNearbyLocations(currentLatLng);
    setState(() {
      mylocation = currentLatLng;
    });
  }

  @override
  void initState() {
    super.initState();

    // Get initial location
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showCurrentLocation();
    });

    // Start listening to location changes
    _positionStreamSubscription = Geolocator.getPositionStream(
            locationSettings: LocationSettings(
                accuracy: LocationAccuracy.high,
                distanceFilter: 20
                ))
        .listen((Position position) {
      _updateLocation(position);
    });
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  // --- UI ---
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
              // --- Tile Layer ---
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              ),

              if (mylocation != null)
                MarkerLayer(
                  markers: [
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
