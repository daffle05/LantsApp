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

class ManageRoutesScreen extends StatefulWidget {
  final int personnelId;

  /// Called by the header back button (e.g. go back to the Home tab).
  final VoidCallback? onBack;

  const ManageRoutesScreen({
    super.key,
    required this.personnelId,
    this.onBack,
  });

  @override
  State<ManageRoutesScreen> createState() => _ManageRoutesScreenState();
}

class _ManageRoutesScreenState extends State<ManageRoutesScreen> {
  List<dynamic> vessels = [];
  List<dynamic> routes = [];

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
      fetchVerifiedVessels(),
      fetchMyRoutes(),
    ]);

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchVerifiedVessels() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/get_my_vessels.php?personnel_id=${widget.personnelId}',
        ),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List<dynamic> allVessels = data['vessels'] ?? [];

        if (mounted) {
          setState(() {
            vessels = allVessels
                .where((vessel) =>
                    vessel['status'].toString().toLowerCase() ==
                    'verified')
                .toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching vessels: $e');
    }
  }

  Future<void> fetchMyRoutes() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/get_my_routes.php?personnel_id=${widget.personnelId}',
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
      debugPrint('Error fetching routes: $e');
    }
  }

  void showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : _oceanTeal,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // OPEN THE FLOATING ADD ROUTE SHEET
  Future<void> openAddRoute() async {
    if (vessels.isEmpty) {
      showMessage(
        'You need an approved vessel before you can add a route.',
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
      builder: (_) => _AddRouteSheet(
        personnelId: widget.personnelId,
        vessels: vessels,
      ),
    );

    if (!mounted) return;

    if (saved == true) {
      showMessage('Route added successfully!');
      await fetchMyRoutes();
    }
  }

  Widget _headerCircleButton(
    IconData icon,
    String tooltip,
    VoidCallback? onTap,
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

  Widget buildRouteCard(dynamic route) {
    final status =
        (route['status'] ?? 'Unknown').toString().toLowerCase();
    final travelTime = route['estimated_travel_time'];
    final bool active = status == 'active';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _lightMint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.route_rounded,
                  color: _oceanTeal,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      route['route_name']?.toString() ?? 'Unnamed Route',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _deepOcean,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      route['vessel_name']?.toString() ?? 'Unknown Vessel',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _subText,
                        fontSize: 13,
                      ),
                    ),
                  ],
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
                      : const Color(0xFFFFF1CF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.isEmpty
                      ? 'Unknown'
                      : status[0].toUpperCase() + status.substring(1),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: active
                        ? const Color(0xFF1F6B45)
                        : const Color(0xFF8A5A00),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.trip_origin, color: _oceanTeal, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  route['origin']?.toString() ?? '',
                  style: const TextStyle(
                    color: _deepOcean,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(left: 0),
            child: Icon(Icons.more_vert, color: _subText, size: 18),
          ),
          Row(
            children: [
              const Icon(Icons.location_on, color: _oceanTeal, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  route['destination']?.toString() ?? '',
                  style: const TextStyle(
                    color: _deepOcean,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time, color: _oceanTeal, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  travelTime == null
                      ? 'Travel time not specified'
                      : 'Estimated travel time: $travelTime minutes',
                  style: const TextStyle(color: _subText, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.of(context).padding.top;
    final double headerHeight = topInset + 230;
    final double bodyTop = headerHeight - 50;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFC),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // TEAL HEADER
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight,
            child: Container(
              color: _oceanTeal,
              padding: EdgeInsets.fromLTRB(24, topInset + 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _headerCircleButton(
                        Icons.chevron_left_rounded,
                        'Back to Home',
                        widget.onBack,
                      ),
                      const Text(
                        'Personnel',
                        style: TextStyle(
                          color: _headerSub,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      _headerCircleButton(
                        Icons.refresh_rounded,
                        'Refresh routes',
                        loadData,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Manage Routes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Set vessel origins and destinations',
                    style: TextStyle(color: _headerSub, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),

          // WHITE BODY WITH LARGE TOP-LEFT RADIUS
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
                  // FIXED HEADING
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 50, 30, 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text(
                          'My routes',
                          style: TextStyle(
                            color: _deepOcean,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!isLoading)
                          Text(
                            '${routes.length} total',
                            style: const TextStyle(
                              color: _oceanTeal,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // ONLY THE ROUTE CARDS SCROLL
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: loadData,
                      color: _oceanTeal,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(22, 4, 22, 30),
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
                          else ...[
                            if (vessels.isEmpty)
                              Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF1CF),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'You do not have an approved vessel yet. '
                                  'Your vessel must be verified by the '
                                  'administrator before you can add a route.',
                                  style: TextStyle(
                                    color: Color(0xFF8A5A00),
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            if (routes.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(25),
                                decoration: BoxDecoration(
                                  color: _fieldFill,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Column(
                                  children: [
                                    Icon(
                                      Icons.route,
                                      color: _oceanTeal,
                                      size: 48,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'No routes available yet.',
                                      style: TextStyle(
                                        color: _deepOcean,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Tap the + button to add your first route.',
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
                              ...routes.map(buildRouteCard),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // CIRCULAR FLOATING ADD ROUTE BUTTON (right, on the split)
          Positioned(
            right: 24,
            top: bodyTop - 32,
            child: Tooltip(
              message: 'Add route',
              child: Material(
                color: _mint,
                elevation: 10,
                shadowColor: _deepOcean.withOpacity(0.45),
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: openAddRoute,
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

// -------------------------------------------------------------------
// FLOATING ADD ROUTE SHEET
// -------------------------------------------------------------------
class _AddRouteSheet extends StatefulWidget {
  final int personnelId;
  final List<dynamic> vessels;

  const _AddRouteSheet({
    required this.personnelId,
    required this.vessels,
  });

  @override
  State<_AddRouteSheet> createState() => _AddRouteSheetState();
}

class _AddRouteSheetState extends State<_AddRouteSheet> {
  final TextEditingController routeNameController =
      TextEditingController();
  final TextEditingController originController = TextEditingController();
  final TextEditingController destinationController =
      TextEditingController();
  final TextEditingController travelTimeController =
      TextEditingController();

  int? selectedVesselId;
  bool isSaving = false;
  String? errorText;

  @override
  void dispose() {
    routeNameController.dispose();
    originController.dispose();
    destinationController.dispose();
    travelTimeController.dispose();
    super.dispose();
  }

  Future<void> saveRoute() async {
    final routeName = routeNameController.text.trim();
    final origin = originController.text.trim();
    final destination = destinationController.text.trim();
    final travelTimeText = travelTimeController.text.trim();

    if (selectedVesselId == null) {
      setState(() => errorText = 'Please select a vessel.');
      return;
    }

    if (routeName.isEmpty || origin.isEmpty || destination.isEmpty) {
      setState(
          () => errorText = 'Please complete all required route fields.');
      return;
    }

    int? travelTime;

    if (travelTimeText.isNotEmpty) {
      travelTime = int.tryParse(travelTimeText);

      if (travelTime == null || travelTime <= 0) {
        setState(() => errorText =
            'Travel time must be a positive number of minutes.');
        return;
      }
    }

    setState(() {
      isSaving = true;
      errorText = null;
    });

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/add_route.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'personnel_id': widget.personnelId,
          'vessel_id': selectedVesselId,
          'route_name': routeName,
          'origin': origin,
          'destination': destination,
          'estimated_travel_time': travelTime,
        }),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200 && data['success'] == true) {
        Navigator.pop(context, true);
      } else {
        setState(() {
          errorText = data['message'] ?? 'Unable to save route.';
        });
      }
    } catch (e) {
      debugPrint('Save route error: $e');

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

  InputDecoration _decoration(String label, IconData icon, {String? hint}) {
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
        borderSide: const BorderSide(color: _oceanTeal, width: 2),
      ),
    );
  }

  Widget _field({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: _decoration(label, icon, hint: hint),
      ),
    );
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
            color: _oceanTeal,
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
                              'Add Route',
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
                              onPressed: isSaving
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

                // WHITE FORM AREA WITH LARGE TOP-LEFT RADIUS
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
                      padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Route Details',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: _deepOcean,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Choose a verified vessel and set where it '
                            'departs from and arrives at.',
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
                              value: selectedVesselId,
                              isExpanded: true,
                              borderRadius: BorderRadius.circular(16),
                              decoration: _decoration(
                                'Select Vessel',
                                Icons.directions_boat,
                              ),
                              items: widget.vessels
                                  .map<DropdownMenuItem<int>>((vessel) {
                                return DropdownMenuItem<int>(
                                  value: int.parse(vessel['id'].toString()),
                                  child: Text(
                                    vessel['vessel_name'].toString(),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => selectedVesselId = value);
                              },
                            ),
                          ),

                          _field(
                            label: 'Route Name',
                            icon: Icons.route,
                            controller: routeNameController,
                            hint: 'Example: Matagok - Naval',
                          ),
                          _field(
                            label: 'Origin Port',
                            icon: Icons.trip_origin,
                            controller: originController,
                            hint: 'Example: Matagok',
                          ),
                          _field(
                            label: 'Destination Port',
                            icon: Icons.location_on,
                            controller: destinationController,
                            hint: 'Example: Naval',
                          ),
                          _field(
                            label: 'Estimated Travel Time (Minutes)',
                            icon: Icons.access_time,
                            controller: travelTimeController,
                            keyboardType: TextInputType.number,
                            hint: 'Example: 20',
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
                              onPressed: isSaving ? null : saveRoute,
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
                                      'Save Route',
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
