
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class PersonnelRequirementsScreen extends StatefulWidget {
  final int personnelId;
  final String fullName;

  const PersonnelRequirementsScreen({
    super.key,
    required this.personnelId,
    required this.fullName,
  });

  @override
  State<PersonnelRequirementsScreen> createState() =>
      _PersonnelRequirementsScreenState();
}

class _PersonnelRequirementsScreenState
    extends State<PersonnelRequirementsScreen> {
  static const String baseUrl = 'http://localhost/lantsapp_api/';

  final _formKey = GlobalKey<FormState>();

  final vesselNameController = TextEditingController();
  final registrationController = TextEditingController();
  final capacityController = TextEditingController();
  final routeController = TextEditingController();

  String? selectedVesselType;

  bool isSaving = false;
  int? savedVesselId;

  final Map<String, PlatformFile?> selectedDocuments = {};

  final Map<String, String> documentLabels = {
    'CPC': 'Certificate of Public Convenience (CPC)',
    'CO': 'Certificate of Ownership (CO)',
    'CPR': 'Certificate of Philippine Registry (CPR)',
    'safety_inspection': 'Safety Inspection Certificate',
    'safety_equipment': 'Safety Equipment Evidence',
    'crew_license': 'Crew License',
    'MBST': 'Modified Basic Safety Training (MBST)',
  };

  @override
  void dispose() {
    vesselNameController.dispose();
    registrationController.dispose();
    capacityController.dispose();
    routeController.dispose();
    super.dispose();
  }

  // SAVE VESSEL INFORMATION
  Future<void> saveVessel() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isSaving = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${baseUrl}add_vessel.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'personnel_id': widget.personnelId,
          'vessel_name': vesselNameController.text.trim(),
          'registration_number': registrationController.text.trim(),
          'vessel_type': selectedVesselType,
          'passenger_capacity':
              int.parse(capacityController.text.trim()),
          'route': routeController.text.trim(),
        }),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200 && data['success'] == true) {
        savedVesselId = int.tryParse(data['vessel_id'].toString());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vessel information saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message'] ?? 'Unable to save vessel information.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot connect to the server. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // SELECT DOCUMENT
  Future<void> pickDocument(
    String documentType, {
    String? crewPosition,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final selectionKey = crewPosition == null
        ? documentType
        : '${documentType}_$crewPosition';

    setState(() {
      selectedDocuments[selectionKey] = result.files.first;
    });
  }

  // UPLOAD DOCUMENT
  Future<void> uploadDocument({
    required String documentType,
    required String documentGroup,
    String? crewPosition,
  }) async {
    if (savedVesselId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please save your vessel information first.'),
        ),
      );
      return;
    }

    final selectionKey = crewPosition == null
        ? documentType
        : '${documentType}_$crewPosition';

    final file = selectedDocuments[selectionKey];

    if (file == null || file.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a document first.'),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${baseUrl}upload_document.php'),
      );

      request.fields['personnel_id'] =
          widget.personnelId.toString();

      request.fields['vessel_id'] = savedVesselId.toString();
      request.fields['document_group'] = documentGroup;
      request.fields['document_type'] = documentType;

      if (crewPosition != null) {
        request.fields['crew_position'] = crewPosition;
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'document',
          file.bytes!,
          filename: file.name,
        ),
      );

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );

      final response = await http.Response.fromStream(
        streamedResponse,
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      final success =
          response.statusCode == 200 && data['success'] == true;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Document uploaded successfully!'
                : data['message'] ?? 'Document upload failed.',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to upload document. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // TEXT FIELD
  Widget buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'This field is required.';
            }

            if (keyboardType == TextInputType.number) {
              final number = int.tryParse(value.trim());

              if (number == null || number < 1) {
                return 'Enter a valid positive whole number.';
              }
            }

            return null;
          },
        ),
      ],
    );
  }

  // DOCUMENT UPLOAD CARD
  Widget buildDocumentCard({
    required String documentType,
    required String documentGroup,
    String? crewPosition,
  }) {
    final selectionKey = crewPosition == null
        ? documentType
        : '${documentType}_$crewPosition';

    final file = selectedDocuments[selectionKey];

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              crewPosition == null
                  ? documentLabels[documentType]!
                  : '$crewPosition - ${documentLabels[documentType]}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(
                  Icons.attach_file,
                  color: Color(0xFF075E54),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    file?.name ?? 'No document selected',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: file == null
                          ? Colors.grey
                          : Colors.black87,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isSaving
                        ? null
                        : () => pickDocument(
                              documentType,
                              crewPosition: crewPosition,
                            ),
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Choose File'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isSaving
                        ? null
                        : () => uploadDocument(
                              documentType: documentType,
                              documentGroup: documentGroup,
                              crewPosition: crewPosition,
                            ),
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF075E54),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF075E54);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personnel Requirements'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, ${widget.fullName}!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Before accessing the Personnel Dashboard, '
                'please provide your vessel information and '
                'submit the required documents for review.',
                style: TextStyle(fontSize: 15),
              ),

              const SizedBox(height: 20),

              const Text(
                'Application Status: Pending',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              // VESSEL INFORMATION
              const Text(
                '1. Vessel Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),

              const SizedBox(height: 20),

              buildTextField(
                label: 'Vessel Name',
                hint: 'Enter vessel name',
                controller: vesselNameController,
              ),

              const SizedBox(height: 18),

              buildTextField(
                label: 'Registration Number',
                hint: 'Enter registration number',
                controller: registrationController,
              ),

              const SizedBox(height: 18),

              const Text(
                'Vessel Type',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: selectedVesselType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                hint: const Text('Select vessel type'),
                items: const [
                  DropdownMenuItem(
                    value: 'Passenger Boat',
                    child: Text('Passenger Boat'),
                  ),
                  DropdownMenuItem(
                    value: 'Motor Boat',
                    child: Text('Motor Boat'),
                  ),
                  DropdownMenuItem(
                    value: 'Ferry',
                    child: Text('Ferry'),
                  ),
                  DropdownMenuItem(
                    value: 'Other',
                    child: Text('Other'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedVesselType = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a vessel type.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 18),

              buildTextField(
                label: 'Passenger Capacity',
                hint: 'Enter maximum passenger capacity',
                controller: capacityController,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 18),

              buildTextField(
                label: 'Route',
                hint: 'Example: Port A to Port B',
                controller: routeController,
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isSaving ? null : saveVessel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: isSaving
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'SAVE VESSEL INFORMATION',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              if (savedVesselId != null) ...[
                const SizedBox(height: 12),
                const Text(
                  'Vessel information saved. You can now upload the required documents.',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              const SizedBox(height: 35),

              // VESSEL DOCUMENTS
              const Text(
                '2. Vessel Documents',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Select and upload the applicable documents for your vessel.',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 15),

              buildDocumentCard(
                documentType: 'CPC',
                documentGroup: 'vessel',
              ),

              buildDocumentCard(
                documentType: 'CO',
                documentGroup: 'vessel',
              ),

              buildDocumentCard(
                documentType: 'CPR',
                documentGroup: 'vessel',
              ),

              buildDocumentCard(
                documentType: 'safety_inspection',
                documentGroup: 'vessel',
              ),

              buildDocumentCard(
                documentType: 'safety_equipment',
                documentGroup: 'vessel',
              ),

              const SizedBox(height: 25),

              // CREW DOCUMENTS
              const Text(
                '3. Crew Documents',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Upload the required license and safety training documents for each crew position.',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 15),

              buildDocumentCard(
                documentType: 'crew_license',
                documentGroup: 'crew',
                crewPosition: 'Patron',
              ),

              buildDocumentCard(
                documentType: 'MBST',
                documentGroup: 'crew',
                crewPosition: 'Patron',
              ),

              buildDocumentCard(
                documentType: 'crew_license',
                documentGroup: 'crew',
                crewPosition: 'Motorman',
              ),

              buildDocumentCard(
                documentType: 'MBST',
                documentGroup: 'crew',
                crewPosition: 'Motorman',
              ),

              const SizedBox(height: 25),

              const Text(
                'Note: Uploading documents does not mean your application is approved. The administrator must review your submitted requirements.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
