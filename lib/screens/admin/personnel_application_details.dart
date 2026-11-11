
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class PersonnelApplicationDetails extends StatefulWidget {
  final int adminId;
  final int personnelId;

  const PersonnelApplicationDetails({
    super.key,
    required this.adminId,
    required this.personnelId,
  });

  @override
  State<PersonnelApplicationDetails> createState() =>
      _PersonnelApplicationDetailsState();
}

class _PersonnelApplicationDetailsState
    extends State<PersonnelApplicationDetails> {
  final String baseUrl = 'http://localhost/lantsapp_api/';

  bool isLoading = true;
  String? errorMessage;

  Map<String, dynamic>? personnel;
  List<dynamic> vessels = [];

  @override
  void initState() {
    super.initState();
    fetchApplicationDetails();
  }

  Future<void> fetchApplicationDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final uri = Uri.parse(
        '${baseUrl}get_personnel_application_details.php',
      ).replace(queryParameters: {
        'admin_id': widget.adminId.toString(),
        'personnel_id': widget.personnelId.toString(),
      });

      final response = await http.get(uri);
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        setState(() {
          personnel = Map<String, dynamic>.from(data['personnel']);
          vessels = List<dynamic>.from(data['vessels'] ?? []);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              data['message'] ?? 'Unable to load application details.';
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

  Future<void> openDocument(String filePath) async {
    final url = Uri.parse('$baseUrl$filePath');

    try {
      final opened = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open this document.')),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open this document.')),
      );
    }
  }

  Future<void> reviewDocument(
    Map<String, dynamic> document,
    String status,
  ) async {
    final remarksController = TextEditingController();

    final remarks = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            status == 'approved' ? 'Approve Document' : 'Reject Document',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                status == 'approved'
                    ? 'Are you sure you want to approve this document?'
                    : 'Please provide a reason for rejecting this document.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: remarksController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Admin remarks',
                  hintText: 'Enter remarks here...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (status == 'rejected' &&
                    remarksController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a rejection reason.'),
                    ),
                  );
                  return;
                }

                Navigator.pop(
                  dialogContext,
                  remarksController.text.trim(),
                );
              },
              child: Text(status == 'approved' ? 'Approve' : 'Reject'),
            ),
          ],
        );
      },
    );

    if (remarks == null) return;

    try {
      final response = await http.post(
        Uri.parse('${baseUrl}review_vessel_document.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'admin_id': widget.adminId,
          'document_id': document['id'],
          'review_status': status,
          'admin_remarks': remarks,
        }),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'approved'
                  ? 'Document approved successfully.'
                  : 'Document rejected successfully.',
            ),
          ),
        );

        await fetchApplicationDetails();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Document review failed.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to connect to the server.')),
      );
    } finally {
      remarksController.dispose();
    }
  }

  Widget buildDocumentCard(Map<String, dynamic> document) {
    final String filePath = document['file_path']?.toString() ?? '';
    final String documentType =
        document['document_type']?.toString() ?? 'Document';
    final String reviewStatus =
        document['review_status']?.toString() ?? 'pending';

    final String extension = filePath.split('.').last.toLowerCase();
    final bool isImage = ['jpg', 'jpeg', 'png'].contains(extension);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.description, color: Color(0xFF075E54)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    documentType.replaceAll('_', ' ').toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                _statusBadge(reviewStatus),
              ],
            ),
            const SizedBox(height: 12),

            if (isImage && filePath.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  '$baseUrl$filePath',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      height: 100,
                      child: Center(
                        child: Text('Unable to display image.'),
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.picture_as_pdf, size: 40, color: Colors.red),
                    SizedBox(height: 6),
                    Text('PDF document'),
                  ],
                ),
              ),

            const SizedBox(height: 10),

            TextButton.icon(
              onPressed: filePath.isEmpty
                  ? null
                  : () => openDocument(filePath),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open full document'),
            ),

            if (document['admin_remarks'] != null &&
                document['admin_remarks'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Admin remarks: ${document['admin_remarks']}',
                  style: const TextStyle(color: Colors.black54),
                ),
              ),

            if (reviewStatus == 'pending') ...[
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          reviewDocument(document, 'rejected'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          reviewDocument(document, 'approved'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF075E54),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Approve'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final bool approved = status == 'approved';
    final bool rejected = status == 'rejected';

    final Color color = approved
        ? Colors.green
        : rejected
            ? Colors.red
            : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildVesselCard(Map<String, dynamic> vessel) {
    final documents = List<dynamic>.from(vessel['documents'] ?? []);

    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              vessel['vessel_name']?.toString() ?? 'Unnamed vessel',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _detailRow('Registration number',
                vessel['registration_number']),
            _detailRow('Vessel type', vessel['vessel_type']),
            _detailRow(
              'Passenger capacity',
              vessel['passenger_capacity'],
            ),
            _detailRow('Route', vessel['route']),
            const Divider(height: 28),
            const Text(
              'Uploaded Requirements',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),

            if (documents.isEmpty)
              const Text('No documents uploaded for this vessel.')
            else
              ...documents.map(
                (doc) => buildDocumentCard(
                  Map<String, dynamic>.from(doc),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 145,
            child: Text(
              label,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
          Expanded(
            child: Text(value?.toString() ?? 'Not provided'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F8),
      appBar: AppBar(
        title: const Text('Application Details'),
        backgroundColor: const Color(0xFF075E54),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(errorMessage!),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: fetchApplicationDetails,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchApplicationDetails,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text(
                        'Personnel Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _detailRow('Full name', personnel?['full_name']),
                              _detailRow('Email', personnel?['email']),
                              _detailRow('Account status', personnel?['status']),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Vessel Information and Documents',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (vessels.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('No vessels registered yet.'),
                          ),
                        )
                      else
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
