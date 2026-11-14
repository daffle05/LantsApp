
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VesselApprovals extends StatefulWidget {
  final int adminId;

  const VesselApprovals({
    super.key,
    required this.adminId,
  });

  @override
  State<VesselApprovals> createState() => _VesselApprovalsState();
}

class _VesselApprovalsState extends State<VesselApprovals> {
  static const Color primaryColor = Color(0xFF075E54);

  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost/lantsapp_api';
    }
    return 'http://10.0.2.2/lantsapp_api';
  }

  List<dynamic> vessels = [];
  bool isLoading = true;
  String? errorMessage;
  int? processingVesselId;

  @override
  void initState() {
    super.initState();
    fetchPendingVessels();
  }

  Future<void> fetchPendingVessels() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_pending_vessels.php'),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          vessels = data['vessels'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = data['message'] ?? 'Unable to load vessels.';
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

  Future<void> updateVesselStatus(
    int vesselId,
    String status,
  ) async {
    setState(() {
      processingVesselId = vesselId;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update_vessel_status.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'admin_id': widget.adminId,
          'vessel_id': vesselId,
          'status': status,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Vessel status updated.'),
            backgroundColor: primaryColor,
          ),
        );

        await fetchPendingVessels();
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Unable to update vessel.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to connect to the server.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          processingVesselId = null;
        });
      }
    }
  }

  Future<void> confirmDecision(
    int vesselId,
    String vesselName,
    String status,
  ) async {
    final bool approving = status == 'verified';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(approving ? 'Approve Vessel?' : 'Reject Vessel?'),
        content: Text(
          approving
              ? 'Are you sure you want to approve $vesselName?'
              : 'Are you sure you want to reject $vesselName?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: approving ? primaryColor : Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(approving ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await updateVesselStatus(vesselId, status);
    }
  }

  Widget buildVesselCard(Map<String, dynamic> vessel) {
    final int vesselId = int.tryParse(
          vessel['id'].toString(),
        ) ??
        0;

    final String vesselName =
        vessel['vessel_name']?.toString() ?? 'Unnamed Vessel';

    final bool isProcessing = processingVesselId == vesselId;

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE5ECEA)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFE5F2EF),
                  child: Icon(
                    Icons.directions_boat,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    vesselName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF183B3A),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Pending',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            detailRow('Registration Number',
                vessel['registration_number']),
            detailRow('Vessel Type', vessel['vessel_type']),
            detailRow('Passenger Capacity',
                vessel['passenger_capacity']),
            detailRow('Route', vessel['route']),
            detailRow('Submitted By', vessel['personnel_name']),
            detailRow('Personnel Email', vessel['personnel_email']),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isProcessing
                        ? null
                        : () => confirmDecision(
                              vesselId,
                              vesselName,
                              'rejected',
                            ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isProcessing
                        ? null
                        : () => confirmDecision(
                              vesselId,
                              vesselName,
                              'verified',
                            ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: isProcessing
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget detailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 135,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'Not provided',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F8),
      body: RefreshIndicator(
        onRefresh: fetchPendingVessels,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? ListView(
                    children: [
                      const SizedBox(height: 100),
                      Center(child: Text(errorMessage!)),
                      Center(
                        child: TextButton(
                          onPressed: fetchPendingVessels,
                          child: const Text('Try Again'),
                        ),
                      ),
                    ],
                  )
                : vessels.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 130),
                          Icon(
                            Icons.directions_boat_outlined,
                            size: 55,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Center(
                            child: Text(
                              'No pending vessel applications.',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                        ],
                      )
                    : ListView(
                        padding: const EdgeInsets.all(18),
                        children: [
                          Text(
                            'Pending Vessels (${vessels.length})',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF183B3A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Review vessel information before approving or rejecting an application.',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 18),
                          ...vessels.map(
                            (vessel) => buildVesselCard(
                              Map<String, dynamic>.from(vessel),
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }
}
