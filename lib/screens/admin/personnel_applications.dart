
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'personnel_application_details.dart';

class PersonnelApplications extends StatefulWidget {
  final int adminId;

  const PersonnelApplications({
    super.key,
    required this.adminId,
  });

  @override
  State<PersonnelApplications> createState() =>
      _PersonnelApplicationsState();
}

class _PersonnelApplicationsState extends State<PersonnelApplications> {
  static const Color primaryColor = Color(0xFF075E54);

  final String baseUrl = 'http://localhost/lantsapp_api/';

  List<dynamic> personnel = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchPersonnel();
  }

  Future<void> fetchPersonnel() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http
          .get(Uri.parse('${baseUrl}get_pending_personnel.php'))
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          personnel = data['personnel'] ?? [];
          isLoading = false;
        });
      } else {
        throw Exception(
          data['message'] ?? 'Unable to load applications.',
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void openApplication(Map<String, dynamic> person) {
    final int? personnelId = int.tryParse(
      person['id'].toString(),
    );

    if (personnelId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid personnel ID.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonnelApplicationDetails(
          adminId: widget.adminId,
          personnelId: personnelId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F8),
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: const Text('Personnel Applications'),
        actions: [
          IconButton(
            onPressed: fetchPersonnel,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchPersonnel,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      );
    }

    if (errorMessage != null) {
      return ListView(
        children: [
          const SizedBox(height: 100),
          const Icon(
            Icons.error_outline,
            size: 55,
            color: Colors.red,
          ),
          const SizedBox(height: 12),
          Center(child: Text(errorMessage!)),
          const SizedBox(height: 12),
          Center(
            child: ElevatedButton(
              onPressed: fetchPersonnel,
              child: const Text('Try Again'),
            ),
          ),
        ],
      );
    }

    if (personnel.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 130),
          Icon(
            Icons.people_outline,
            size: 65,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'No pending applications',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              'New personnel applications will appear here.',
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '${personnel.length} Pending Application(s)',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),

        ...personnel.map((item) {
          final person = Map<String, dynamic>.from(item);

          return Card(
            color: Colors.white,
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE5F2EF),
                      child: Icon(
                        Icons.person,
                        color: primaryColor,
                      ),
                    ),
                    title: Text(
                      person['full_name']?.toString() ?? 'No name',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            person['email']?.toString() ?? 'No email',
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Status: Pending Review',
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Divider(),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => openApplication(person),
                      icon: const Icon(Icons.visibility_outlined),
                      label: const Text('View Application'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
