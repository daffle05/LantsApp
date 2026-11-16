
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const Color _deepOcean = Color(0xFF073B4C);
const Color _oceanTeal = Color(0xFF0B7285);
const Color _mint = Color(0xFF80EDC7);
const Color _lightMint = Color(0xFFCAF0E3);
const Color _fieldFill = Color(0xFFF1F8F9);
const Color _subText = Color(0xFF4F6B75);
const Color _headerSub = Color(0xFFD7F5EC);

String get _baseUrl {
  if (kIsWeb) {
    return 'http://localhost/lantsapp_api';
  }
  return 'http://10.0.2.2/lantsapp_api';
}

class ManageFaresScreen extends StatefulWidget {
  final int personnelId;

  const ManageFaresScreen({
    super.key,
    required this.personnelId,
  });

  @override
  State<ManageFaresScreen> createState() => _ManageFaresScreenState();
}

class _ManageFaresScreenState extends State<ManageFaresScreen> {
  List<dynamic> routes = [];
  List<dynamic> fares = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    if (mounted) {
      setState(() => isLoading = true);
    }

    await Future.wait([
      fetchRoutes(),
      fetchFares(),
    ]);

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchRoutes() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/get_my_fare_routes.php?personnel_id=${widget.personnelId}',
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
      debugPrint('Fetch fare routes error: $e');
    }
  }

  Future<void> fetchFares() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/get_my_fares.php?personnel_id=${widget.personnelId}',
        ),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        if (mounted) {
          setState(() {
            fares = data['fares'] ?? [];
          });
        }
      }
    } catch (e) {
      debugPrint('Fetch fares error: $e');
    }
  }

  void showMessage(String message, {bool error = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : _oceanTeal,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  
Future<void> openAddFare() async {
  debugPrint('========== CHECKING ROUTES ==========');
  debugPrint('Personnel ID: ${widget.personnelId}');

  // Fetch the latest routes before checking.
  await fetchRoutes();

  if (!mounted) return;

  debugPrint('Routes found: ${routes.length}');
  debugPrint('Route data: $routes');

  if (routes.isEmpty) {
    showMessage(
      'No eligible routes found for Personnel ID ${widget.personnelId}. Please check the terminal.',
      error: true,
    );
    return;
  }

  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.45),
    builder: (context) => _AddFareSheet(
      personnelId: widget.personnelId,
      routes: routes,
    ),
  );

  if (saved == true && mounted) {
    showMessage('Fare successfully added.');
    await loadData();
  }
}


  String formatDate(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return 'No end date';
    }

    final date = DateTime.tryParse(value.toString());
    if (date == null) return value.toString();

    return '${date.month.toString().padLeft(2, '0')}/'
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Widget buildFareCard(dynamic fare) {
    final status = (fare['status'] ?? 'inactive')
        .toString()
        .toLowerCase();

    final active = status == 'active';

    final amount = double.tryParse(
          fare['fare_amount']?.toString() ?? '',
        ) ??
        0;

    final passengerType =
        fare['passenger_type']?.toString() ?? 'Passenger';

    final routeName =
        fare['route_name']?.toString() ?? 'Unnamed Route';

    final origin = fare['origin']?.toString() ?? '';
    final destination = fare['destination']?.toString() ?? '';
    final vesselName =
        fare['vessel_name']?.toString() ?? 'Unknown Vessel';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _fieldFill,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _lightMint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.payments_rounded,
                  color: _oceanTeal,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      passengerType,
                      style: const TextStyle(
                        color: _deepOcean,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      vesselName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _subText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '₱${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: _deepOcean,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            routeName,
            style: const TextStyle(
              color: _deepOcean,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              const Icon(
                Icons.trip_origin,
                color: _oceanTeal,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  origin,
                  style: const TextStyle(
                    color: _subText,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: _oceanTeal,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  destination,
                  style: const TextStyle(
                    color: _subText,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          const Divider(color: Color(0xFFD8E8E9)),
          const SizedBox(height: 7),
          Row(
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                color: _oceanTeal,
                size: 17,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  '${formatDate(fare['effective_from'])} - '
                  '${formatDate(fare['effective_until'])}',
                  style: const TextStyle(
                    color: _subText,
                    fontSize: 11,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFFDFF5E8)
                      : const Color(0xFFFFE5E5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  active ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: active
                        ? const Color(0xFF1F6B45)
                        : Colors.red.shade700,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget headerButton(
    IconData icon,
    String tooltip,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.white.withOpacity(0.16),
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onTap,
        tooltip: tooltip,
        icon: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final headerHeight = topInset + 230;
    final bodyTop = headerHeight - 50;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFC),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight,
            child: Container(
              color: _oceanTeal,
              padding: EdgeInsets.fromLTRB(
                24,
                topInset + 16,
                24,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      headerButton(
                        Icons.chevron_left_rounded,
                        'Back',
                        () => Navigator.pop(context),
                      ),
                      const Text(
                        'Personnel',
                        style: TextStyle(
                          color: _headerSub,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      headerButton(
                        Icons.refresh_rounded,
                        'Refresh fares',
                        loadData,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Fare Monitoring',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 29,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Manage fares for your active vessel routes',
                    style: TextStyle(
                      color: _headerSub,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: bodyTop,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(60),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      30,
                      50,
                      30,
                      14,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text(
                          'My fare records',
                          style: TextStyle(
                            color: _deepOcean,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!isLoading)
                          Text(
                            '${fares.length} total',
                            style: const TextStyle(
                              color: _oceanTeal,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: loadData,
                      color: _oceanTeal,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          22,
                          4,
                          22,
                          30,
                        ),
                        children: [
                          if (isLoading)
                            const Padding(
                              padding: EdgeInsets.all(35),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: _oceanTeal,
                                ),
                              ),
                            )
                          else if (fares.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(25),
                              decoration: BoxDecoration(
                                color: _fieldFill,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Column(
                                children: [
                                  Icon(
                                    Icons.payments_outlined,
                                    color: _oceanTeal,
                                    size: 48,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'No fare records yet.',
                                    style: TextStyle(
                                      color: _deepOcean,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Tap the + button to add fares for one of your routes.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ...fares.map(buildFareCard),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 24,
            top: bodyTop - 32,
            child: Tooltip(
              message: 'Add fare',
              child: Material(
                color: _mint,
                elevation: 10,
                shadowColor: _deepOcean.withOpacity(0.45),
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: openAddFare,
                  customBorder: const CircleBorder(),
                  child: const SizedBox(
                    width: 64,
                    height: 64,
                    child: Icon(
                      Icons.add_rounded,
                      color: _deepOcean,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// ADD FARE BOTTOM SHEET
// ------------------------------------------------------------

class _AddFareSheet extends StatefulWidget {
  final int personnelId;
  final List<dynamic> routes;

  const _AddFareSheet({
    required this.personnelId,
    required this.routes,
  });

  @override
  State<_AddFareSheet> createState() => _AddFareSheetState();
}

class _AddFareSheetState extends State<_AddFareSheet> {
  final TextEditingController amountController =
      TextEditingController();

  int? selectedRouteId;
  String selectedPassengerType = 'Adult';

  DateTime effectiveFrom = DateTime.now();
  DateTime? effectiveUntil;

  bool isSaving = false;
  String? errorText;

  final List<String> passengerTypes = [
    'Adult',
    'Student',
    'Senior Citizen',
    'PWD',
  ];

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  String dateToString(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String dateLabel(DateTime? date) {
    if (date == null) return 'No end date';

    return '${date.month.toString().padLeft(2, '0')}/'
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> selectDate({required bool isStart}) async {
    final initialDate = isStart
        ? effectiveFrom
        : (effectiveUntil ?? effectiveFrom);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _oceanTeal,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: _deepOcean,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null || !mounted) return;

    setState(() {
      if (isStart) {
        effectiveFrom = picked;

        if (effectiveUntil != null &&
            effectiveUntil!.isBefore(effectiveFrom)) {
          effectiveUntil = null;
        }
      } else {
        effectiveUntil = picked;
      }

      errorText = null;
    });
  }

  Future<void> saveFare() async {
    final amount = double.tryParse(amountController.text.trim());

    if (selectedRouteId == null) {
      setState(() => errorText = 'Please select a route.');
      return;
    }

    if (amount == null || amount <= 0) {
      setState(() => errorText = 'Enter a valid fare amount.');
      return;
    }

    if (effectiveUntil != null &&
        effectiveUntil!.isBefore(effectiveFrom)) {
      setState(() {
        errorText = 'The end date cannot be earlier than the start date.';
      });
      return;
    }

    setState(() {
      isSaving = true;
      errorText = null;
    });

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/add_fare.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'personnel_id': widget.personnelId,
          'route_id': selectedRouteId,
          'passenger_type': selectedPassengerType,
          'fare_amount': amount,
          'effective_from': dateToString(effectiveFrom),
          'effective_until': effectiveUntil == null
              ? null
              : dateToString(effectiveUntil!),
        }),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200 && data['success'] == true) {
        Navigator.pop(context, true);
      } else {
        setState(() {
          errorText = data['message'] ?? 'Unable to save fare.';
        });
      }
    } catch (e) {
      debugPrint('Save fare error: $e');

      if (!mounted) return;

      setState(() {
        errorText = 'Connection error. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  InputDecoration decoration(
    String label,
    IconData icon, {
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Colors.black54),
      prefixIcon: Icon(icon, color: _oceanTeal),
      filled: true,
      fillColor: _fieldFill,
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
        borderSide: const BorderSide(
          color: _oceanTeal,
          width: 2,
        ),
      ),
    );
  }

  Widget dateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    bool optional = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: InputDecorator(
          decoration: decoration(
            label,
            Icons.calendar_month_rounded,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateLabel(date),
                style: const TextStyle(
                  color: _deepOcean,
                  fontSize: 14,
                ),
              ),
              if (optional && date != null)
                GestureDetector(
                  onTap: () => setState(() => effectiveUntil = null),
                  child: const Icon(
                    Icons.close_rounded,
                    color: _subText,
                    size: 19,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.of(context).viewInsets.bottom;
    final maxHeight = MediaQuery.of(context).size.height * 0.9;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.fromLTRB(
        12,
        0,
        12,
        12 + keyboard,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Material(
            color: _oceanTeal,
            elevation: 16,
            borderRadius: BorderRadius.circular(32),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                              'Add Fare',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Material(
                            color: Colors.white.withOpacity(0.16),
                            shape: const CircleBorder(),
                            child: IconButton(
                              onPressed: isSaving
                                  ? null
                                  : () => Navigator.pop(context),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fare Details',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: _deepOcean,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Select a route and enter the fare for the passenger type.',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 22),

                          Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: DropdownButtonFormField<int>(
                              value: selectedRouteId,
                              isExpanded: true,
                              borderRadius: BorderRadius.circular(16),
                              decoration: decoration(
                                'Select Route',
                                Icons.route_rounded,
                              ),
                              items: widget.routes.map((route) {
                                final id = int.parse(
                                  route['route_id'].toString(),
                                );

                                final routeName =
                                    route['route_name']?.toString() ??
                                        'Unnamed Route';

                                final vesselName =
                                    route['vessel_name']?.toString() ??
                                        'Unknown Vessel';

                                return DropdownMenuItem<int>(
                                  value: id,
                                  child: Text(
                                    '$routeName - $vesselName',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: isSaving
                                  ? null
                                  : (value) {
                                      setState(() {
                                        selectedRouteId = value;
                                      });
                                    },
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: DropdownButtonFormField<String>(
                              value: selectedPassengerType,
                              isExpanded: true,
                              borderRadius: BorderRadius.circular(16),
                              decoration: decoration(
                                'Passenger Type',
                                Icons.people_alt_rounded,
                              ),
                              items: passengerTypes.map((type) {
                                return DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(type),
                                );
                              }).toList(),
                              onChanged: isSaving
                                  ? null
                                  : (value) {
                                      if (value != null) {
                                        setState(() {
                                          selectedPassengerType = value;
                                        });
                                      }
                                    },
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: TextField(
                              controller: amountController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: decoration(
                                'Fare Amount (₱)',
                                Icons.payments_rounded,
                                hint: 'Example: 100.00',
                              ),
                            ),
                          ),

                          dateField(
                            label: 'Effective From',
                            date: effectiveFrom,
                            onTap: () => selectDate(isStart: true),
                          ),

                          dateField(
                            label: 'Effective Until (Optional)',
                            date: effectiveUntil,
                            optional: true,
                            onTap: () => selectDate(isStart: false),
                          ),

                          if (errorText != null) ...[
                            const SizedBox(height: 2),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.07),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      errorText!,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: isSaving ? null : saveFare,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _oceanTeal,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: isSaving
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : const Text(
                                      'Save Fare',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
