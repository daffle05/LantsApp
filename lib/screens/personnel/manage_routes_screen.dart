
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ManageRoutesScreen extends StatefulWidget {
  final int personnelId;

  const ManageRoutesScreen({
    super.key,
    required this.personnelId,
  });

  @override
  State<ManageRoutesScreen> createState() => _ManageRoutesScreenState();
}

class _ManageRoutesScreenState extends State<ManageRoutesScreen> {
  final Color deepOcean = const Color(0xFF073B4C);
  final Color oceanTeal = const Color(0xFF0B7285);
  final Color lightMint = const Color(0xFFE8F5F2);

  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost/lantsapp_api';
    }
    return 'http://10.0.2.2/lantsapp_api';
  }

  final TextEditingController routeNameController =
      TextEditingController();
  final TextEditingController originController =
      TextEditingController();
  final TextEditingController destinationController =
      TextEditingController();
  final TextEditingController travelTimeController =
      TextEditingController();

  List<dynamic> vessels = [];
  List<dynamic> routes = [];

  int? selectedVesselId;

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    routeNameController.dispose();
    originController.dispose();
    destinationController.dispose();
    travelTimeController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    if (mounted) {
      setState(() => isLoading = true);
    }

    await Future.wait([
      fetchVerifiedVessels(),
      fetchMyRoutes(),
    ]);

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchVerifiedVessels() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/get_my_vessels.php?personnel_id=${widget.personnelId}',
        ),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List<dynamic> allVessels = data['vessels'] ?? [];

        if (mounted) {
          setState(() {
            vessels = allVessels
                .where((vessel) =>
                    vessel['status'].toString().toLowerCase() ==
                    'verified')
                .toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching vessels: $e');
    }
  }

  Future<void> fetchMyRoutes() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/get_my_routes.php?personnel_id=${widget.personnelId}',
        ),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        if (mounted) {
          setState(() {
            routes = data['routes'] ?? [];
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching routes: $e');
    }
  }

  void showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : oceanTeal,
      ),
    );
  }

  Future<void> saveRoute() async {
    final routeName = routeNameController.text.trim();
    final origin = originController.text.trim();
    final destination = destinationController.text.trim();
    final travelTimeText = travelTimeController.text.trim();

    if (selectedVesselId == null) {
      showMessage('Please select a vessel.', error: true);
      return;
    }

    if (routeName.isEmpty ||
        origin.isEmpty ||
        destination.isEmpty) {
      showMessage('Please complete all required route fields.',
          error: true);
      return;
    }

    int? travelTime;

    if (travelTimeText.isNotEmpty) {
      travelTime = int.tryParse(travelTimeText);

      if (travelTime == null || travelTime <= 0) {
        showMessage(
          'Travel time must be a positive number of minutes.',
          error: true,
        );
        return;
      }
    }

    setState(() => isSaving = true);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add_route.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'personnel_id': widget.personnelId,
          'vessel_id': selectedVesselId,
          'route_name': routeName,
          'origin': origin,
          'destination': destination,
          'estimated_travel_time': travelTime,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        if (!mounted) return;

        routeNameController.clear();
        originController.clear();
        destinationController.clear();
        travelTimeController.clear();

        showMessage('Route added successfully!');

        await fetchMyRoutes();
      } else {
        showMessage(
          data['message'] ?? 'Unable to save route.',
          error: true,
        );
      }
    } catch (e) {
      showMessage('Connection error. Please try again.',
          error: true);
      debugPrint('Save route error: $e');
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  Widget buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: oceanTeal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: oceanTeal),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: deepOcean,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget buildRouteForm() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<int>(
            value: selectedVesselId,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Select Vessel',
              prefixIcon: Icon(Icons.directions_boat),
              border: OutlineInputBorder(),
            ),
            items: vessels.map<DropdownMenuItem<int>>((vessel) {
              return DropdownMenuItem<int>(
                value: int.parse(vessel['id'].toString()),
                child: Text(vessel['vessel_name'].toString()),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => selectedVesselId = value);
            },
          ),
          const SizedBox(height: 15),
          buildTextField(
            label: 'Route Name',
            icon: Icons.route,
            controller: routeNameController,
            hint: 'Example: Matagok - Naval',
          ),
          const SizedBox(height: 15),
          buildTextField(
            label: 'Origin Port',
            icon: Icons.trip_origin,
            controller: originController,
            hint: 'Example: Matagok',
          ),
          const SizedBox(height: 15),
          buildTextField(
            label: 'Destination Port',
            icon: Icons.location_on,
            controller: destinationController,
            hint: 'Example: Naval',
          ),
          const SizedBox(height: 15),
          buildTextField(
            label: 'Estimated Travel Time (Minutes)',
            icon: Icons.access_time,
            controller: travelTimeController,
            keyboardType: TextInputType.number,
            hint: 'Example: 20',
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isSaving ? null : saveRoute,
              style: ElevatedButton.styleFrom(
                backgroundColor: oceanTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isSaving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Save Route',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRouteCard(dynamic route) {
    final status = route['status'] ?? 'Unknown';
    final travelTime = route['estimated_travel_time'];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  route['route_name']?.toString() ?? 'Unnamed Route',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: deepOcean,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: status.toString().toLowerCase() == 'active'
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toString().toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: status.toString().toLowerCase() == 'active'
                        ? Colors.green.shade700
                        : Colors.orange.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            route['vessel_name']?.toString() ?? 'Unknown Vessel',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.trip_origin, color: oceanTeal, size: 19),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  route['origin']?.toString() ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(left: 7),
            child: Icon(Icons.more_vert, color: Colors.grey, size: 20),
          ),
          Row(
            children: [
              Icon(Icons.location_on, color: oceanTeal, size: 19),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  route['destination']?.toString() ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time, color: oceanTeal, size: 19),
              const SizedBox(width: 8),
              Text(
                travelTime == null
                    ? 'Travel time not specified'
                    : 'Estimated travel time: $travelTime minutes',
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F8),
      appBar: AppBar(
        title: const Text('Manage Routes'),
        backgroundColor: deepOcean,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: oceanTeal),
            )
          : RefreshIndicator(
              onRefresh: loadData,
              color: oceanTeal,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  sectionTitle('Add New Route', Icons.add_road),
                  const SizedBox(height: 12),
                  if (vessels.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'You do not have an approved vessel yet. '
                        'Your vessel must be verified by the administrator '
                        'before you can add a route.',
                      ),
                    )
                  else
                    buildRouteForm(),
                  const SizedBox(height: 28),
                  sectionTitle('Your Saved Routes', Icons.map_outlined),
                  const SizedBox(height: 12),
                  if (routes.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.route,
                            size: 40,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'No routes available yet.',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Routes you save will appear here.',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  else
                    ...routes.map(buildRouteCard),
                ],
              ),
            ),
    );
  }
}
