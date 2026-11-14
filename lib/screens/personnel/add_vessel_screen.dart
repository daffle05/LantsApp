
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddVesselScreen extends StatefulWidget {
  final int personnelId;

  const AddVesselScreen({
    super.key,
    required this.personnelId,
  });

  @override
  State<AddVesselScreen> createState() => _AddVesselScreenState();
}

class _AddVesselScreenState extends State<AddVesselScreen> {
  final _formKey = GlobalKey<FormState>();

  final _vesselNameController = TextEditingController();
  final _registrationController = TextEditingController();
  final _capacityController = TextEditingController();
  final _routeController = TextEditingController();

  String? _selectedVesselType;
  bool _isSubmitting = false;

  final Color deepOcean = const Color(0xFF073B4C);
  final Color oceanTeal = const Color(0xFF0B7285);

  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost/lantsapp_api';
    }

    return 'http://10.0.2.2/lantsapp_api';
  }

  Future<void> submitVessel() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add_vessel.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'personnel_id': widget.personnelId,
          'vessel_name': _vesselNameController.text.trim(),
          'registration_number': _registrationController.text.trim(),
          'vessel_type': _selectedVesselType,
          'passenger_capacity':
              int.parse(_capacityController.text.trim()),
          'route': _routeController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vessel submitted successfully for approval!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message'] ?? 'Unable to submit vessel.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Connection failed. Please check your XAMPP server.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: oceanTeal),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: oceanTeal,
              width: 2,
            ),
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter $label.';
          }

          if (keyboardType == TextInputType.number &&
              int.tryParse(value.trim()) == null) {
            return 'Please enter a valid number.';
          }

          if (keyboardType == TextInputType.number &&
              int.tryParse(value.trim())! <= 0) {
            return 'Please enter a number greater than zero.';
          }

          return null;
        },
      ),
    );
  }

  @override
  void dispose() {
    _vesselNameController.dispose();
    _registrationController.dispose();
    _capacityController.dispose();
    _routeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFC),
      appBar: AppBar(
        title: const Text(
          'Add Vessel',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: deepOcean,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vessel Information',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF073B4C),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter the details of your passenger vessel. '
                'Your submission will be reviewed by the administrator.',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              buildTextField(
                label: 'Vessel Name',
                controller: _vesselNameController,
                icon: Icons.directions_boat,
              ),

              buildTextField(
                label: 'Registration Number',
                controller: _registrationController,
                icon: Icons.confirmation_number,
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DropdownButtonFormField<String>(
                  value: _selectedVesselType,
                  decoration: InputDecoration(
                    labelText: 'Vessel Type',
                    prefixIcon: Icon(
                      Icons.sailing,
                      color: oceanTeal,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Passenger Boat',
                      child: Text('Passenger Boat'),
                    ),
                    DropdownMenuItem(
                      value: 'Ferry',
                      child: Text('Ferry'),
                    ),
                    DropdownMenuItem(
                      value: 'Motor Boat',
                      child: Text('Motor Boat'),
                    ),
                    DropdownMenuItem(
                      value: 'Other',
                      child: Text('Other'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedVesselType = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a vessel type.';
                    }
                    return null;
                  },
                ),
              ),

              buildTextField(
                label: 'Passenger Capacity',
                controller: _capacityController,
                icon: Icons.people,
                keyboardType: TextInputType.number,
              ),

              buildTextField(
                label: 'Route (e.g. Matagok to Naval)',
                controller: _routeController,
                icon: Icons.route,
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F4F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Color(0xFF0B7285),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your vessel will remain pending until the '
                        'administrator reviews and approves it.',
                        style: TextStyle(
                          color: Color(0xFF073B4C),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : submitVessel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: oceanTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'Submit Vessel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
