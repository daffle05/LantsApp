
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterVesselsScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onVesselTap;

  const RegisterVesselsScreen({
    super.key,
    required this.onVesselTap,
  });

  @override
  State<RegisterVesselsScreen> createState() =>
      _RegisterVesselsScreenState();
}

class _RegisterVesselsScreenState
    extends State<RegisterVesselsScreen> {
  static const Color midnightTeal = Color(0xFF073B40);
  static const Color oceanTeal = Color(0xFF087EAB);
  static const Color iceMint = Color(0xFFDDF4F1);
  static const Color mutedText = Color(0xFF71817F);

  final TextEditingController searchController =
      TextEditingController();

  List<Map<String, dynamic>> vessels = [];

  bool isLoading = true;
  String? errorMessage;

  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost/lantsapp_api';
    }
    return 'http://10.0.2.2/lantsapp_api';
  }

  @override
  void initState() {
    super.initState();
    fetchVessels();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchVessels() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_registered_vessels.php'),
      );

      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);

      if (data['success'] != true) {
        throw Exception(
          data['message'] ?? 'Unable to load vessels.',
        );
      }

      final List<dynamic> result = data['vessels'] ?? [];

      if (!mounted) return;

      setState(() {
        vessels = result
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get filteredVessels {
    final query = searchController.text.toLowerCase().trim();

    return vessels.where((vessel) {
      final name =
          (vessel['vessel_name'] ?? '').toString().toLowerCase();
      final route =
          (vessel['route'] ?? '').toString().toLowerCase();
      final type =
          (vessel['vessel_type'] ?? '').toString().toLowerCase();

      return name.contains(query) ||
          route.contains(query) ||
          type.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: midnightTeal,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Register Vessels',
          style: TextStyle(
            color: midnightTeal,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Passenger Vessel Directory',
                  style: TextStyle(
                    color: midnightTeal,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Explore registered passenger vessels and their information.',
                  style: TextStyle(
                    color: mutedText,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 17),
                TextField(
                  controller: searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search vessel or route...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: oceanTeal,
                    ),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close),
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF3F7F6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: buildVesselList(),
          ),
        ],
      ),
    );
  }

  Widget buildVesselList() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: oceanTeal),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 45,
              color: mutedText,
            ),
            const SizedBox(height: 12),
            const Text('Unable to load registered vessels.'),
            TextButton(
              onPressed: fetchVessels,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    final results = filteredVessels;

    if (results.isEmpty) {
      return const Center(
        child: Text(
          'No registered vessels found.',
          style: TextStyle(color: mutedText),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchVessels,
      child: ListView.builder(
        padding: const EdgeInsets.all(18),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final vessel = results[index];

          final name =
              (vessel['vessel_name'] ?? 'Unnamed Vessel').toString();
          final route =
              (vessel['route'] ?? 'Route not provided').toString();
          final type =
              (vessel['vessel_type'] ?? 'Passenger Boat').toString();
          final capacity =
              (vessel['passenger_capacity'] ?? 'N/A').toString();

          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: midnightTeal.withOpacity(0.07),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => widget.onVesselTap(vessel),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    Container(
                      width: 75,
                      height: 75,
                      decoration: BoxDecoration(
                        color: iceMint,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.directions_boat_filled_rounded,
                        size: 37,
                        color: midnightTeal,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: midnightTeal,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            route,
                            style: const TextStyle(
                              color: mutedText,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '$type • $capacity passengers',
                            style: const TextStyle(
                              color: mutedText,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: oceanTeal,
                      size: 17,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
