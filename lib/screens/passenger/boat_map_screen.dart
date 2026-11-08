
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class BoatMapScreen extends StatelessWidget {
  const BoatMapScreen({super.key});

  static const Color deepOcean = Color(0xFF073B4C);
  static const Color oceanTeal = Color(0xFF0B7285);
  static const Color mint = Color(0xFF80EDC7);

  // Illustrative location: Dumaguete City
  // We will replace this with actual port coordinates later.
  static const LatLng initialLocation = LatLng(9.3068, 123.3054);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFC),
      appBar: AppBar(
        backgroundColor: deepOcean,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Boat Routes & Map',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: initialLocation,
              initialZoom: 13,
              minZoom: 5,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.lantsapp',
              ),

              // Sample marker for Dumaguete.
              MarkerLayer(
                markers: [
                  Marker(
                    point: initialLocation,
                    width: 110,
                    height: 65,
                    child: Column(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: oceanTeal,
                          size: 38,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Text(
                            'Dumaguete Port',
                            style: TextStyle(
                              color: deepOcean,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Map information card.
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.directions_boat,
                    color: oceanTeal,
                    size: 28,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Passenger Boat Map',
                          style: TextStyle(
                            color: deepOcean,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Explore ports and boat routes',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.map_outlined,
                    color: mint,
                    size: 25,
                  ),
                ],
              ),
            ),
          ),

          // Map controls.
          Positioned(
            right: 16,
            bottom: 24,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'zoom_in',
                  backgroundColor: Colors.white,
                  foregroundColor: deepOcean,
                  onPressed: () {
                    // Zoom control will be added in the next improvement.
                  },
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'my_location',
                  backgroundColor: Colors.white,
                  foregroundColor: deepOcean,
                  onPressed: () {
                    // Current-location feature will be added later.
                  },
                  child: const Icon(Icons.my_location),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
