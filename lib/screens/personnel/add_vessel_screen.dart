
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AddVesselScreen extends StatefulWidget {
  final int personnelId;

  const AddVesselScreen({
    super.key,
    required this.personnelId,
  });

  static Future<bool?> show(BuildContext context, int personnelId) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (_) => AddVesselScreen(personnelId: personnelId),
    );
  }

  @override
  State<AddVesselScreen> createState() => _AddVesselScreenState();
}

class _AddVesselScreenState extends State<AddVesselScreen> {
  final _formKey = GlobalKey<FormState>();

  final _vesselNameController = TextEditingController();
  final _registrationController = TextEditingController();
  final _capacityController = TextEditingController();
  final _routeController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  XFile? _vesselImage;

  String? _selectedVesselType;
  bool _isSubmitting = false;

  final Color deepOcean = const Color(0xFF073B4C);
  final Color oceanTeal = const Color(0xFF0B7285);
  final Color fieldFill = const Color(0xFFF1F8F9);

  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost/lantsapp_api';
    }

    return 'http://10.0.2.2/lantsapp_api';
  }

  // SELECT VESSEL PROFILE PHOTO
  Future<void> _pickVesselImage() async {
    try {
      final XFile? selectedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (!mounted || selectedImage == null) return;

      setState(() {
        _vesselImage = selectedImage;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to select the vessel photo.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // REMOVE SELECTED PHOTO
  void _removeVesselImage() {
    setState(() {
      _vesselImage = null;
    });
  }

  // SUBMIT VESSEL WITH OPTIONAL PHOTO
  Future<void> submitVessel() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final uri = Uri.parse('$baseUrl/add_vessel.php');

      final request = http.MultipartRequest('POST', uri);

      request.fields.addAll({
        'personnel_id': widget.personnelId.toString(),
        'vessel_name': _vesselNameController.text.trim(),
        'registration_number': _registrationController.text.trim(),
        'vessel_type': _selectedVesselType!,
        'passenger_capacity': _capacityController.text.trim(),
        'route': _routeController.text.trim(),
      });

      // Attach the image only if the personnel selected one.
      if (_vesselImage != null) {
        final imageBytes = await _vesselImage!.readAsBytes();

        request.files.add(
          http.MultipartFile.fromBytes(
            'vessel_image',
            imageBytes,
            filename: _vesselImage!.name,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Vessel submitted successfully for approval!',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
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
            behavior: SnackBarBehavior.floating,
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
          behavior: SnackBarBehavior.floating,
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

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black54),
      prefixIcon: Icon(icon, color: oceanTeal),
      filled: true,
      fillColor: fieldFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: oceanTeal, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: _decoration(label, icon),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter $label.';
          }

          if (keyboardType == TextInputType.number) {
            final number = int.tryParse(value.trim());

            if (number == null) {
              return 'Please enter a valid number.';
            }

            if (number <= 0) {
              return 'Please enter a number greater than zero.';
            }
          }

          return null;
        },
      ),
    );
  }

  // OPTIONAL VESSEL PHOTO SECTION
  Widget _buildVesselPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vessel Profile Photo',
          style: TextStyle(
            color: deepOcean,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          'Add a photo to help passengers recognize your vessel. '
          'This is optional.',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 12,
            height: 1.4,
          ),
        ),

        const SizedBox(height: 13),

        if (_vesselImage == null)
          InkWell(
            onTap: _isSubmitting ? null : _pickVesselImage,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: double.infinity,
              height: 165,
              decoration: BoxDecoration(
                color: fieldFill,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: oceanTeal.withOpacity(0.35),
                  width: 1.3,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: oceanTeal.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_a_photo_outlined,
                      color: oceanTeal,
                      size: 27,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Choose Vessel Photo',
                    style: TextStyle(
                      color: deepOcean,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Tap here to browse your gallery',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: fieldFill,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: oceanTeal.withOpacity(0.25),
              ),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: FutureBuilder<Uint8List>(
                    future: _vesselImage!.readAsBytes(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Image.memory(
                          snapshot.data!,
                          width: double.infinity,
                          height: 175,
                          fit: BoxFit.cover,
                        );
                      }

                      return Container(
                        width: double.infinity,
                        height: 175,
                        color: Colors.white,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _vesselImage!.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: deepOcean,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    TextButton.icon(
                      onPressed:
                          _isSubmitting ? null : _pickVesselImage,
                      icon: const Icon(Icons.edit_outlined, size: 17),
                      label: const Text('Change'),
                    ),

                    IconButton(
                      onPressed:
                          _isSubmitting ? null : _removeVesselImage,
                      tooltip: 'Remove photo',
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

        const SizedBox(height: 8),

        Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 15,
              color: oceanTeal,
            ),
            const SizedBox(width: 6),
            const Expanded(
              child: Text(
                'You can skip this section if you do not have a photo.',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ],
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
    final double keyboard = MediaQuery.of(context).viewInsets.bottom;
    final double maxHeight = MediaQuery.of(context).size.height * 0.9;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.fromLTRB(12, 0, 12, 12 + keyboard),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Material(
            color: oceanTeal,
            elevation: 16,
            shadowColor: Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(32),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // TEAL HEADER
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 16, 22),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      const SizedBox(height: 14),

                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Add Vessel',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ),

                          Material(
                            color: Colors.white.withOpacity(0.16),
                            shape: const CircleBorder(),
                            child: IconButton(
                              onPressed: _isSubmitting
                                  ? null
                                  : () => Navigator.pop(context),
                              tooltip: 'Close',
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // WHITE FORM AREA
                Flexible(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        22,
                        26,
                        22,
                        24,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vessel Information',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: deepOcean,
                              ),
                            ),

                            const SizedBox(height: 6),

                            const Text(
                              'Enter the details of your passenger vessel. '
                              'Your submission will be reviewed by the administrator.',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),

                            const SizedBox(height: 22),

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
                              padding: const EdgeInsets.only(bottom: 14),
                              child: DropdownButtonFormField<String>(
                                value: _selectedVesselType,
                                decoration: _decoration(
                                  'Vessel Type',
                                  Icons.sailing,
                                ),
                                borderRadius: BorderRadius.circular(16),
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
                                onChanged: _isSubmitting
                                    ? null
                                    : (value) {
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

                            const SizedBox(height: 8),

                            // OPTIONAL PHOTO
                            _buildVesselPhotoSection(),

                            const SizedBox(height: 20),

                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F4F5),
                                borderRadius: BorderRadius.circular(16),
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

                            const SizedBox(height: 22),

                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed:
                                    _isSubmitting ? null : submitVessel,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: oceanTeal,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: _isSubmitting
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 3,
                                        ),
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
