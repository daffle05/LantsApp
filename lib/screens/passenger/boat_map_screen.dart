
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class BoatMapScreen extends StatefulWidget {
  const BoatMapScreen({super.key});

  @override
  State<BoatMapScreen> createState() => _BoatMapScreenState();
}

class _BoatMapScreenState extends State<BoatMapScreen> {
  static const Color deepOcean = Color(0xFF073B4C);
  static const Color oceanTeal = Color(0xFF0B7285);
  static const Color mint = Color(0xFF80EDC7);

  // Use localhost for Flutter Web.
  // For an Android emulator, change localhost to 10.0.2.2.
  static const String baseUrl = 'http://localhost/lantsapp_api';

  final MapController mapController = MapController();

  List<dynamic> routes = [];
  bool isLoading = true;
  String? errorMessage;
  int? selectedRouteId;

  @override
  void initState() {
    super.initState();
    fetchPublicRoutes();
  }

  Future<void> fetchPublicRoutes() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_public_routes.php'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          setState(() {
            routes = data['routes'] ?? [];
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage =
                data['message'] ?? 'Unable to retrieve routes.';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Unable to connect to the server.';
        isLoading = false;
      });
    }
  }

  LatLng? getCoordinate(dynamic latitude, dynamic longitude) {
    if (latitude == null || longitude == null) {
      return null;
    }

    final lat = double.tryParse(latitude.toString());
    final lng = double.tryParse(longitude.toString());

    if (lat == null || lng == null) {
      return null;
    }

    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      return null;
    }

    return LatLng(lat, lng);
  }

  List<LatLng> getRouteCoordinates(dynamic route) {
    final List<LatLng> points = [];

    final coordinates = route['route_coordinates'];

    if (coordinates is List) {
      for (final coordinate in coordinates) {
        if (coordinate is Map) {
          final point = getCoordinate(
            coordinate['latitude'],
            coordinate['longitude'],
          );

          if (point != null) {
            points.add(point);
          }
        }
      }
    }

    if (points.isEmpty) {
      final origin = getCoordinate(
        route['origin_latitude'],
        route['origin_longitude'],
      );

      final destination = getCoordinate(
        route['destination_latitude'],
        route['destination_longitude'],
      );

      if (origin != null) points.add(origin);
      if (destination != null) points.add(destination);
    }

    return points;
  }

  List<Marker> buildMarkers() {
    final List<Marker> markers = [];

    for (final route in routes) {
      final coordinates = getRouteCoordinates(route);

      if (coordinates.isEmpty) continue;

      final origin = coordinates.first;
      final destination = coordinates.length > 1
          ? coordinates.last
          : null;

      markers.add(
        Marker(
          point: origin,
          width: 110,
          height: 65,
          child: Column(
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.green,
                size: 36,
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  route['origin']?.toString() ?? 'Origin',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: deepOcean,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      if (destination != null) {
        markers.add(
          Marker(
            point: destination,
            width: 110,
            height: 65,
            child: Column(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 36,
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    route['destination']?.toString() ?? 'Destination',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: deepOcean,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return markers;
  }

  List<Polyline> buildPolylines() {
    final List<Polyline> polylines = [];

    for (final route in routes) {
      final coordinates = getRouteCoordinates(route);

      if (coordinates.length >= 2) {
        polylines.add(
          Polyline(
            points: coordinates,
            strokeWidth: 4,
            color: oceanTeal,
          ),
        );
      }
    }

    return polylines;
  }

  void selectRoute(dynamic route) {
    final coordinates = getRouteCoordinates(route);

    if (coordinates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This route has no map coordinates yet.'),
        ),
      );
      return;
    }

    setState(() {
      selectedRouteId = int.tryParse(route['route_id'].toString());
    });

    mapController.move(coordinates.first, 10);
  }

  Widget buildRouteInformation() {
    if (routes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'No active boat routes are available.',
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return SizedBox(
      height: 150,
      child: ListView.builder(
        itemCount: routes.length,
        itemBuilder: (context, index) {
          final route = routes[index];

          final routeId =
              int.tryParse(route['route_id'].toString());

          final isSelected = selectedRouteId == routeId;

          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 5,
            ),
            color: isSelected ? mint : Colors.white,
            child: ListTile(
              onTap: () => selectRoute(route),
              leading: CircleAvatar(
                backgroundColor: isSelected ? mint : const Color(0xFFE1F5EF),
                child: const Icon(
                  Icons.directions_boat,
                  color: oceanTeal,
                ),
              ),
              title: Text(
                route['route_name'] ?? 'Unnamed Route',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: deepOcean,
                ),
              ),
              subtitle: Text(
                '${route['vessel_name'] ?? 'Unknown Vessel'}\n'
                '${route['origin'] ?? ''} → '
                '${route['destination'] ?? ''}',
              ),
              isThreeLine: true,
              trailing: const Icon(
                Icons.chevron_right,
                color: oceanTeal,
              ),
            ),
          );
        },
      ),
    );
  }

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
        actions: [
          IconButton(
            onPressed: fetchPublicRoutes,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh routes',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: const MapOptions(
                    initialCenter: LatLng(10.3157, 123.8854),
                    initialZoom: 7,
                    minZoom: 5,
                    maxZoom: 18,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.lantsapp',
                    ),
                    PolylineLayer(
                      polylines: buildPolylines(),
                    ),
                    MarkerLayer(
                      markers: buildMarkers(),
                    ),
                  ],
                ),

                if (isLoading)
                  const Center(
                    child: CircularProgressIndicator(
                      color: oceanTeal,
                    ),
                  ),

                if (errorMessage != null)
                  Center(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.wifi_off,
                            color: Colors.red,
                            size: 35,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            errorMessage!,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: fetchPublicRoutes,
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  ),

                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.directions_boat,
                          color: oceanTeal,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Passenger Boat Map',
                          style: TextStyle(
                            color: deepOcean,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 12),
            color: Colors.white,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Available Boat Routes',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: deepOcean,
                ),
              ),
            ),
          ),

          Expanded(
            flex: 3,
            child: isLoading
                ? const Center(
                    child: Text('Loading boat routes...'),
                  )
                : buildRouteInformation(),
          ),
        ],
      ),
    );
  }
}
