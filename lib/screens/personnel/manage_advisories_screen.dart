
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ManageAdvisoriesScreen extends StatefulWidget {
  final int personnelId;

  const ManageAdvisoriesScreen({
    super.key,
    required this.personnelId,
  });

  @override
  State<ManageAdvisoriesScreen> createState() =>
      _ManageAdvisoriesScreenState();
}

class _ManageAdvisoriesScreenState
    extends State<ManageAdvisoriesScreen> {
  static const Color deepOcean = Color(0xFF073B4C);
  static const Color oceanTeal = Color(0xFF0B7285);
  static const Color lightMint = Color(0xFFCAF0E3);

  String get baseUrl => kIsWeb
      ? 'http://localhost/lantsapp_api'
      : 'http://10.0.2.2/lantsapp_api';

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  List<dynamic> vessels = [];
  List<dynamic> advisories = [];

  int? selectedVesselId;
  String selectedType = 'General';

  bool isLoading = true;
  bool isPublishing = false;
  String? errorMessage;

  final List<String> advisoryTypes = [
    'Weather',
    'Delay',
    'Cancellation',
    'Suspension',
    'General',
  ];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    await Future.wait([
      fetchVerifiedVessels(),
      fetchAdvisories(),
    ]);

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchVerifiedVessels() async {
    try {
      final url = Uri.parse(
        '$baseUrl/get_my_vessels.php?personnel_id=${widget.personnelId}',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final loadedVessels =
              (data['vessels'] ?? []) as List<dynamic>;

          final verifiedVessels = loadedVessels.where((vessel) {
            return (vessel['status'] ?? '')
                    .toString()
                    .toLowerCase() ==
                'verified';
          }).toList();

          if (mounted) {
            setState(() {
              vessels = verifiedVessels;

              if (selectedVesselId == null ||
                  !vessels.any((v) =>
                      int.tryParse(v['id'].toString()) ==
                      selectedVesselId)) {
                selectedVesselId = vessels.isNotEmpty
                    ? int.tryParse(vessels.first['id'].toString())
                    : null;
              }
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Unable to load your vessels.';
        });
      }
    }
  }

  Future<void> fetchAdvisories() async {
    try {
      final url = Uri.parse(
        '$baseUrl/get_my_advisories.php?personnel_id=${widget.personnelId}',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && mounted) {
          setState(() {
            advisories = data['advisories'] ?? [];
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Unable to load published advisories.';
        });
      }
    }
  }

  Future<void> publishAdvisory() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedVesselId == null) {
      showMessage('Please select a verified vessel.');
      return;
    }

    setState(() {
      isPublishing = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add_advisory.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'personnel_id': widget.personnelId,
          'vessel_id': selectedVesselId,
          'title': _titleController.text.trim(),
          'message': _messageController.text.trim(),
          'advisory_type': selectedType,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _titleController.clear();
        _messageController.clear();

        if (mounted) {
          showMessage('Advisory published successfully!');
        }

        await fetchAdvisories();
      } else {
        showMessage(
          data['message'] ?? 'Unable to publish advisory.',
        );
      }
    } catch (e) {
      showMessage('Unable to connect to the server.');
    } finally {
      if (mounted) {
        setState(() {
          isPublishing = false;
        });
      }
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: deepOcean,
      ),
    );
  }

  Color getTypeColor(String type) {
    switch (type) {
      case 'Weather':
        return Colors.blue;
      case 'Delay':
        return Colors.orange;
      case 'Cancellation':
        return Colors.red;
      case 'Suspension':
        return Colors.deepPurple;
      default:
        return oceanTeal;
    }
  }

  String formatDate(dynamic value) {
    if (value == null) return '';

    try {
      final date = DateTime.parse(value.toString());
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year} • '
          '${date.hour % 12 == 0 ? 12 : date.hour % 12}:'
          '${date.minute.toString().padLeft(2, '0')} '
          '${date.hour >= 12 ? 'PM' : 'AM'}';
    } catch (_) {
      return value.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFC),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: oceanTeal,
                ),
              )
            : RefreshIndicator(
                onRefresh: loadData,
                color: oceanTeal,
                child: ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    const Text(
                      'Publish Advisories',
                      style: TextStyle(
                        color: deepOcean,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Share important trip updates with passengers.',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 22),

                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    _buildForm(),

                    const SizedBox(height: 28),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Published Advisories',
                          style: TextStyle(
                            color: deepOcean,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: loadData,
                          icon: const Icon(
                            Icons.refresh,
                            color: oceanTeal,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    if (advisories.isEmpty)
                      _emptyAdvisories()
                    else
                      ...advisories.map(
                        (advisory) => _advisoryCard(advisory),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: lightMint),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'New Advisory',
              style: TextStyle(
                color: deepOcean,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),

            _fieldLabel('Select Verified Vessel'),
            DropdownButtonFormField<int>(
              value: selectedVesselId,
              isExpanded: true,
              decoration: _inputDecoration(
                'Choose a vessel',
                Icons.directions_boat,
              ),
              items: vessels.map((vessel) {
                final id = int.tryParse(vessel['id'].toString());

                return DropdownMenuItem<int>(
                  value: id,
                  child: Text(
                    vessel['vessel_name']?.toString() ??
                        'Unnamed Vessel',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedVesselId = value;
                });
              },
            ),

            if (vessels.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'You need an administrator-verified vessel before publishing an advisory.',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            _fieldLabel('Advisory Title'),
            TextFormField(
              controller: _titleController,
              decoration: _inputDecoration(
                'Enter advisory title',
                Icons.title,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an advisory title.';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            _fieldLabel('Advisory Message'),
            TextFormField(
              controller: _messageController,
              maxLines: 4,
              decoration: _inputDecoration(
                'Write your passenger announcement',
                Icons.message_outlined,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an advisory message.';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            _fieldLabel('Advisory Type'),
            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: _inputDecoration(
                'Select advisory type',
                Icons.category_outlined,
              ),
              items: advisoryTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedType = value;
                  });
                }
              },
            ),

            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: isPublishing || vessels.isEmpty
                    ? null
                    : publishAdvisory,
                icon: isPublishing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send_rounded),
                label: Text(
                  isPublishing
                      ? 'Publishing...'
                      : 'Publish Advisory',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: oceanTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: const TextStyle(
          color: deepOcean,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String hint,
    IconData icon,
  ) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: oceanTeal,
        size: 20,
      ),
      filled: true,
      fillColor: const Color(0xFFF7FBFC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightMint),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightMint),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: oceanTeal,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _emptyAdvisories() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: lightMint),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.campaign_outlined,
            color: oceanTeal,
            size: 42,
          ),
          SizedBox(height: 10),
          Text(
            'No Published Advisories',
            style: TextStyle(
              color: deepOcean,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Your published announcements will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _advisoryCard(dynamic advisory) {
    final type = advisory['advisory_type']?.toString() ?? 'General';
    final status = advisory['status']?.toString() ?? 'active';
    final color = getTypeColor(type);

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: lightMint),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  advisory['title']?.toString() ?? 'Untitled Advisory',
                  style: const TextStyle(
                    color: deepOcean,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  type,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            advisory['message']?.toString() ?? '',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Vessel: ${advisory['vessel_name'] ?? 'Unknown vessel'}',
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 13,
                color: Colors.black45,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  formatDate(advisory['created_at']),
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
                  ),
                ),
              ),
              Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: status == 'active'
                      ? Colors.green.shade700
                      : Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
