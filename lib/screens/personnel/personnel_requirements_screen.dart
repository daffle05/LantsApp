import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  static const Color primaryColor = Color(0xFF075E54);
  static const Color accentGreen = Color(0xFF9ACD32);
  static const Color accentBlue = Color(0xFF2878D0);
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color textColor = Color(0xFF1E293B);
  static const Color mutedColor = Color(0xFF64748B);

  static const int maxFileSizeBytes = 10 * 1024 * 1024;

  final _formKey = GlobalKey<FormState>();

  final vesselNameController = TextEditingController();
  final registrationController = TextEditingController();
  final capacityController = TextEditingController();
  final routeController = TextEditingController();

  int currentStep = 2;

  String? selectedVesselType;

  bool isSaving = false;
  bool isSubmitted = false;

  // Selected files remain in memory until final submission.
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

  // ---------------------------------------------------------
  // WIZARD NAVIGATION
  // ---------------------------------------------------------

  void goBack() {
    if (isSaving || isSubmitted) return;

    if (currentStep > 2) {
      setState(() => currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> goNext() async {
    if (isSaving || isSubmitted) return;

    if (currentStep == 2) {
      if (!_formKey.currentState!.validate()) return;

      if (selectedVesselType == null) {
        showMessage('Please select a vessel type.', isError: true);
        return;
      }

      setState(() => currentStep = 3);
      return;
    }

    if (currentStep == 3) {
      setState(() => currentStep = 4);
      return;
    }

    if (currentStep == 4) {
      await submitAllRequirements();
    }
  }

  void showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ---------------------------------------------------------
  // DOCUMENT SELECTION
  // ---------------------------------------------------------

  String selectionKey(String documentType, String? crewPosition) {
    return crewPosition == null
        ? documentType
        : '${documentType}_$crewPosition';
  }

  Future<PlatformFile?> chooseDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;

    if (file.size > maxFileSizeBytes) {
      showMessage(
        'The selected file exceeds the 500 MB limit.',
        isError: true,
      );
      return null;
    }

    if (file.bytes == null) {
      showMessage(
        'Unable to read this file. Please choose it again.',
        isError: true,
      );
      return null;
    }

    return file;
  }

  String readableFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';

    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }

    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // ---------------------------------------------------------
  // UPLOAD MODAL
  // This only selects the file. It does NOT upload it.
  // ---------------------------------------------------------

  Future<void> showUploadDialog({
    required String documentType,
    required String documentGroup,
    String? crewPosition,
  }) async {
    if (isSaving || isSubmitted) return;

    final key = selectionKey(documentType, crewPosition);
    PlatformFile? dialogFile = selectedDocuments[key];

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return Dialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Padding(
                  padding: const EdgeInsets.all(26),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF3FF),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Icon(
                              Icons.cloud_upload_outlined,
                              color: accentBlue,
                              size: 25,
                            ),
                          ),
                          const SizedBox(width: 13),
                          const Expanded(
                            child: Text(
                              'Select a file',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Close',
                            onPressed: () =>
                                Navigator.pop(dialogContext),
                            icon: const Icon(
                              Icons.close,
                              color: Color(0xFF718096),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        crewPosition == null
                            ? documentLabels[documentType]!
                            : '$crewPosition - ${documentLabels[documentType]}',
                        style: const TextStyle(
                          color: mutedColor,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 22),
                      CustomPaint(
                        painter: DashedBorderPainter(
                          color: const Color(0xFF9BBDE8),
                          radius: 16,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 27,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FBFF),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 58,
                                height: 58,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEAF3FF),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.drive_folder_upload_outlined,
                                  color: accentBlue,
                                  size: 31,
                                ),
                              ),
                              const SizedBox(height: 15),
                              const Text(
                                'Choose a file or drag & drop it here',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF27364B),
                                ),
                              ),
                              const SizedBox(height: 7),
                              const Text(
                                'PDF, JPG, JPEG or PNG',
                                style: TextStyle(
                                  color: Color(0xFF718096),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'Maximum 500 MB file size',
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 18),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  final file = await chooseDocument();

                                  if (file != null) {
                                    dialogSetState(() {
                                      dialogFile = file;
                                    });
                                  }
                                },
                                icon: const Icon(
                                  Icons.folder_open,
                                  size: 18,
                                ),
                                label: const Text('Choose file'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: accentBlue,
                                  side: const BorderSide(
                                    color: accentBlue,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (dialogFile != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.insert_drive_file_outlined,
                                color: accentBlue,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dialogFile!.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      readableFileSize(dialogFile!.size),
                                      style: const TextStyle(
                                        color: mutedColor,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: 'Remove file',
                                onPressed: () {
                                  dialogSetState(() {
                                    dialogFile = null;
                                  });
                                },
                                icon: const Icon(
                                  Icons.close,
                                  color: mutedColor,
                                  size: 19,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext),
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    const Color(0xFF475569),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: const BorderSide(
                                  color: Color(0xFFCBD5E1),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: dialogFile == null
                                  ? null
                                  : () {
                                      setState(() {
                                        selectedDocuments[key] =
                                            dialogFile;
                                      });

                                      Navigator.pop(dialogContext);

                                      showMessage(
                                        'File selected. It will be submitted with your other requirements.',
                                      );
                                    },
                              icon: const Icon(
                                Icons.check_circle_outline,
                                size: 18,
                              ),
                              label: const Text('Save selection'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentBlue,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    const Color(0xFFCBD5E1),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------
  // FINAL SUBMISSION
  // Sends vessel information and every selected document
  // through ONE multipart request.
  // ---------------------------------------------------------

  Future<void> submitAllRequirements() async {
    if (isSaving || isSubmitted) return;

    if (selectedVesselType == null) {
      setState(() => currentStep = 2);
      showMessage('Please select a vessel type.', isError: true);
      return;
    }

    final requiredDocuments = <Map<String, String>>[
      {
        'document_type': 'crew_license',
        'document_group': 'crew',
        'crew_position': 'Patron',
      },
      {
        'document_type': 'MBST',
        'document_group': 'crew',
        'crew_position': 'Patron',
      },
      {
        'document_type': 'crew_license',
        'document_group': 'crew',
        'crew_position': 'Motorman',
      },
      {
        'document_type': 'MBST',
        'document_group': 'crew',
        'crew_position': 'Motorman',
      },
      {
        'document_type': 'CPC',
        'document_group': 'vessel',
      },
      {
        'document_type': 'CO',
        'document_group': 'vessel',
      },
      {
        'document_type': 'CPR',
        'document_group': 'vessel',
      },
      {
        'document_type': 'safety_inspection',
        'document_group': 'vessel',
      },
      {
        'document_type': 'safety_equipment',
        'document_group': 'vessel',
      },
    ];

    final missingDocuments = <String>[];

    for (final document in requiredDocuments) {
      final key = selectionKey(
        document['document_type']!,
        document['crew_position'],
      );

      final file = selectedDocuments[key];

      if (file == null || file.bytes == null) {
        final position = document['crew_position'];
        final label = documentLabels[document['document_type']]!;

        missingDocuments.add(
          position == null ? label : '$position - $label',
        );
      }
    }

    if (missingDocuments.isNotEmpty) {
      showMessage(
        'Please select all required documents before submitting.',
        isError: true,
      );

      return;
    }

    setState(() => isSaving = true);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${baseUrl}submit_personnel_requirements.php'),
      );

      // Personnel and vessel information.
      request.fields['personnel_id'] = widget.personnelId.toString();
      request.fields['vessel_name'] =
          vesselNameController.text.trim();
      request.fields['registration_number'] =
          registrationController.text.trim();
      request.fields['vessel_type'] = selectedVesselType!;
      request.fields['passenger_capacity'] =
          capacityController.text.trim();
      request.fields['route'] = routeController.text.trim();

      // Document information tells PHP which file belongs to
      // which requirement.
      final documentMetadata = <Map<String, String>>[];

      int fileIndex = 0;

      for (final document in requiredDocuments) {
        final documentType = document['document_type']!;
        final documentGroup = document['document_group']!;
        final crewPosition = document['crew_position'];

        final key = selectionKey(documentType, crewPosition);
        final file = selectedDocuments[key]!;

        final fieldName = 'document_$fileIndex';

        documentMetadata.add({
          'field_name': fieldName,
          'document_type': documentType,
          'document_group': documentGroup,
          'crew_position': crewPosition ?? '',
          'original_name': file.name,
        });

        request.files.add(
          http.MultipartFile.fromBytes(
            fieldName,
            file.bytes!,
            filename: file.name,
          ),
        );

        fileIndex++;
      }

      request.fields['documents_metadata'] =
          jsonEncode(documentMetadata);

      final streamedResponse = await request
          .send()
          .timeout(const Duration(minutes: 10));

      final response =
          await http.Response.fromStream(streamedResponse);

      dynamic data;

      try {
        data = jsonDecode(response.body);
      } catch (_) {
        throw Exception(
          'The server returned an invalid response. '
          'Please check the PHP endpoint.',
        );
      }

      if (!mounted) return;

      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          isSubmitted = true;
        });

        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              contentPadding: const EdgeInsets.all(25),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF16805D),
                    size: 62,
                  ),
                  const SizedBox(height: 17),
                  const Text(
                    'Submission successful!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Your vessel information and personnel documents have been submitted for administrator review.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        Navigator.pop(context, true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Continue'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      } else {
        showMessage(
          data['message']?.toString() ??
              'Submission failed. Please try again.',
          isError: true,
        );
      }
    } catch (error) {
      if (!mounted) return;

      showMessage(
        'Unable to submit your requirements. Please check your connection and try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  // ---------------------------------------------------------
  // REUSABLE UI COMPONENTS
  // ---------------------------------------------------------

  Widget buildWelcomeHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 19,
          backgroundColor: Color(0xFFE6F2F0),
          child: Icon(
            Icons.person_outline,
            size: 21,
            color: primaryColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, ${widget.fullName}',
                style: const TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Complete your personnel requirements',
                style: TextStyle(
                  color: mutedColor,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4D9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.pending_outlined,
                size: 14,
                color: Color(0xFFB7791F),
              ),
              SizedBox(width: 5),
              Text(
                'Pending',
                style: TextStyle(
                  color: Color(0xFF946313),
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildProgressHeader() {
    final progress = currentStep / 4;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EDF2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'PERSONNEL ONBOARDING',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Text(
                'Step $currentStep/4',
                style: const TextStyle(
                  color: mutedColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFE8EEE9),
              valueColor: const AlwaysStoppedAnimation<Color>(
                accentGreen,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _stepLabel('Account', 1),
              _stepLabel('Vessel', 2),
              _stepLabel('Crew', 3),
              _stepLabel('Documents', 4),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepLabel(String label, int step) {
    final isCurrent = currentStep == step;
    final isCompleted = currentStep > step;

    return Expanded(
      child: Row(
        children: [
          if (isCompleted)
            const Icon(
              Icons.check_circle,
              size: 13,
              color: primaryColor,
            )
          else
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCurrent
                    ? accentGreen
                    : const Color(0xFFCBD5E1),
              ),
            ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    isCurrent ? FontWeight.w700 : FontWeight.w500,
                color: isCurrent || isCompleted
                    ? textColor
                    : const Color(0xFF94A3B8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPageHeading({
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 26, bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: textColor,
              fontSize: 25,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: mutedColor,
              fontSize: 13,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFE8EDF2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF334155),
        ),
      ),
    );
  }

  Widget buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildFieldLabel(label),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF9AA5B1),
              fontSize: 13,
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: primaryColor,
                width: 1.5,
              ),
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

  // ---------------------------------------------------------
  // STEP 2: VESSEL INFORMATION
  // ---------------------------------------------------------

  Widget buildVesselTypeOption(String type, IconData icon) {
    final selected = selectedVesselType == type;

    return InkWell(
      onTap: isSaving
          ? null
          : () {
              setState(() => selectedVesselType = type);
            },
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFEAF4E6)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected
                ? accentGreen
                : const Color(0xFFE2E8F0),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 17,
              color: selected ? primaryColor : mutedColor,
            ),
            const SizedBox(width: 7),
            Text(
              type,
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? primaryColor : textColor,
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.check_circle,
                size: 15,
                color: primaryColor,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildVesselInformationStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildPageHeading(
            title: 'Tell us about your vessel',
            subtitle:
                'Provide the details of the passenger boat you operate. This information will help passengers identify your vessel and its route.',
          ),
          buildSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildFieldLabel('Vessel type'),
                Wrap(
                  spacing: 9,
                  runSpacing: 10,
                  children: [
                    buildVesselTypeOption(
                      'Passenger Boat',
                      Icons.directions_boat_outlined,
                    ),
                    buildVesselTypeOption(
                      'Motor Boat',
                      Icons.speed_outlined,
                    ),
                    buildVesselTypeOption(
                      'Ferry',
                      Icons.directions_ferry_outlined,
                    ),
                    buildVesselTypeOption(
                      'Other',
                      Icons.sailing_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 23),
                buildTextField(
                  label: 'Vessel name',
                  hint: 'e.g. MB Alexander',
                  controller: vesselNameController,
                ),
                const SizedBox(height: 19),
                buildTextField(
                  label: 'Registration number',
                  hint: 'Enter your vessel registration number',
                  controller: registrationController,
                ),
                const SizedBox(height: 19),
                buildTextField(
                  label: 'Passenger capacity',
                  hint: 'e.g. 30',
                  controller: capacityController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 19),
                buildTextField(
                  label: 'Operating route',
                  hint: 'e.g. Matagok to Naval',
                  controller: routeController,
                ),
              ],
            ),
          ),
          const SizedBox(height: 17),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                color: mutedColor,
                size: 18,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your vessel information will be saved together with all your documents when you submit your requirements at the final step.',
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // DOCUMENT LIST ITEM
  // ---------------------------------------------------------

  Widget buildDocumentCard({
    required String documentType,
    required String documentGroup,
    String? crewPosition,
  }) {
    final key = selectionKey(documentType, crewPosition);
    final file = selectedDocuments[key];

    final title = crewPosition == null
        ? documentLabels[documentType]!
        : '$crewPosition - ${documentLabels[documentType]}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5EAF0)),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: accentBlue,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: Color(0xFF27364B),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  file == null ? 'No file selected yet' : file.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: file == null
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF16805D),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: isSaving || isSubmitted
                ? null
                : () {
                    showUploadDialog(
                      documentType: documentType,
                      documentGroup: documentGroup,
                      crewPosition: crewPosition,
                    );
                  },
            style: OutlinedButton.styleFrom(
              foregroundColor: accentBlue,
              side: const BorderSide(
                color: Color(0xFFB8D2F2),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 11,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
            child: Text(
              file == null ? 'Select' : 'Change',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // STEP 3: CREW DOCUMENTS
  // ---------------------------------------------------------

  Widget buildCrewDocumentsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildPageHeading(
          title: 'Crew requirements',
          subtitle:
              'Select the license and safety training documents for the crew members operating your passenger vessel. These files will be submitted together at the final step.',
        ),
        buildSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Patron',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Select the requirements for the Patron.',
                style: TextStyle(
                  color: mutedColor,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 17),
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
              const SizedBox(height: 15),
              const Divider(color: Color(0xFFE8EDF2)),
              const SizedBox(height: 15),
              const Text(
                'Motorman',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Select the requirements for the Motorman.',
                style: TextStyle(
                  color: mutedColor,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 17),
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
            ],
          ),
        ),
        const SizedBox(height: 16),
        buildUploadNote(),
      ],
    );
  }

  // ---------------------------------------------------------
  // STEP 4: VESSEL DOCUMENTS
  // ---------------------------------------------------------

  Widget buildVesselDocumentsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildPageHeading(
          title: 'Upload vessel documents',
          subtitle:
              'Select the legal and safety documents required for your passenger vessel. All selected files will be submitted together when you press Submit Requirements.',
        ),
        buildSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Required vessel documents',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF4E6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Step 4',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              const Text(
                'Select clear and readable copies of the following requirements.',
                style: TextStyle(
                  fontSize: 12,
                  color: mutedColor,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
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
            ],
          ),
        ),
        const SizedBox(height: 16),
        buildUploadNote(),
        const SizedBox(height: 16),
        buildSectionCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4E6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.fact_check_outlined,
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ready to submit your requirements?',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Check that all vessel information and required documents are correct. Press Submit Requirements below to send everything together for administrator review.',
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildUploadNote() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFF5E4B8)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: Color(0xFFB7791F),
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Only PDF, JPG, JPEG, and PNG files are accepted. Each file must not exceed 500 MB. Your files are selected first and will only be uploaded when you submit all your requirements.',
              style: TextStyle(
                color: Color(0xFF805B20),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // BACK AND NEXT BUTTONS
  // ---------------------------------------------------------

  Widget buildNavigationButtons() {
    final isLastStep = currentStep == 4;

    return Padding(
      padding: const EdgeInsets.only(top: 23, bottom: 28),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isSaving || isSubmitted ? null : goBack,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF475569),
                side: const BorderSide(
                  color: Color(0xFFCBD5E1),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Back',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isSaving || isSubmitted ? null : goNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentGreen,
                foregroundColor: const Color(0xFF18320B),
                disabledBackgroundColor:
                    const Color(0xFFDCE5D2),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primaryColor,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLastStep ? 'Submit Requirements' : 'Next',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isLastStep
                              ? Icons.check_circle_outline
                              : Icons.arrow_forward,
                          size: 17,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // MAIN SCREEN
  // ---------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Personnel Requirements',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: textColor,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: textColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFE8EDF2),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 22,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildWelcomeHeader(),
                const SizedBox(height: 18),
                buildProgressHeader(),
                const SizedBox(height: 16),
                if (currentStep == 2)
                  buildVesselInformationStep()
                else if (currentStep == 3)
                  buildCrewDocumentsStep()
                else
                  buildVesselDocumentsStep(),
                buildNavigationButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// DASHED BORDER PAINTER FOR THE UPLOAD MODAL
// -------------------------------------------------------------

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  DashedBorderPainter({
    required this.color,
    this.radius = 12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 7.0;
    const dashSpace = 5.0;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(
      0,
      0,
      size.width,
      size.height,
    );

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          rect,
          Radius.circular(radius),
        ),
      );

    for (final metric in path.computeMetrics()) {
      double distance = 0;

      while (distance < metric.length) {
        final end =
            (distance + dashWidth).clamp(0.0, metric.length);

        canvas.drawPath(
          metric.extractPath(distance, end),
          paint,
        );

        distance = end + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(
    covariant DashedBorderPainter oldDelegate,
  ) {
    return oldDelegate.color != color ||
        oldDelegate.radius != radius;
  }
}