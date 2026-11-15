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

String _formatTime(TimeOfDay time) {
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.period == DayPeriod.am ? 'AM' : 'PM';

  return '$hour:$minute $period';
}

String _formatDatabaseTime(dynamic value) {
  if (value == null || value.toString().isEmpty) {
    return 'Not specified';
  }

  try {
    final parts = value.toString().split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    return _formatTime(TimeOfDay(hour: hour, minute: minute));
  } catch (_) {
    return value.toString();
  }
}

class ManageSchedulesScreen extends StatefulWidget {
  final int personnelId;

  /// Called by the header back button (e.g. go back to the Home tab).
  final VoidCallback? onBack;

  const ManageSchedulesScreen({
    super.key,
    required this.personnelId,
    this.onBack,
  });

  @override
  State<ManageSchedulesScreen> createState() =>
      _ManageSchedulesScreenState();
}

class _ManageSchedulesScreenState extends State<ManageSchedulesScreen> {
  bool isLoading = true;

  List<dynamic> vessels = [];
  List<dynamic> schedules = [];

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
      fetchMySchedules(),
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

  Future<void> fetchMySchedules() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/get_my_schedules.php?personnel_id=${widget.personnelId}',
        ),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        if (mounted) {
          setState(() {
            schedules = data['schedules'] ?? [];
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching schedules: $e');
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

  // OPEN THE FLOATING ADD SCHEDULE SHEET
  Future<void> openAddSchedule() async {
    if (vessels.isEmpty) {
      showMessage(
        'You need an approved vessel before you can add a schedule.',
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
      builder: (_) => _AddScheduleSheet(
        personnelId: widget.personnelId,
        vessels: vessels,
      ),
    );

    if (!mounted) return;

    if (saved == true) {
      showMessage('Schedule added successfully!');
      await fetchMySchedules();
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

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _oceanTeal, size: 18),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: _subText, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: _deepOcean,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildScheduleCard(dynamic schedule) {
    final vesselName = schedule['vessel_name'] ?? 'Unknown vessel';
    final days = schedule['operating_days'] ?? 'Not specified';
    final status =
        (schedule['status'] ?? 'Unknown').toString().toLowerCase();

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
                  Icons.calendar_month_rounded,
                  color: _oceanTeal,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  vesselName.toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _deepOcean,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
          _detailRow(
            Icons.departure_board,
            'Departure',
            _formatDatabaseTime(schedule['departure_time']),
          ),
          _detailRow(
            Icons.access_time,
            'Arrival',
            _formatDatabaseTime(schedule['arrival_time']),
          ),
          _detailRow(
            Icons.event_repeat_rounded,
            'Operating days',
            days.toString(),
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
                        'Refresh schedules',
                        loadData,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Manage Schedules',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Set trips and departure times',
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
                          'My schedules',
                          style: TextStyle(
                            color: _deepOcean,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!isLoading)
                          Text(
                            '${schedules.length} total',
                            style: const TextStyle(
                              color: _oceanTeal,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // ONLY THE SCHEDULE CARDS SCROLL
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
                                  'administrator before you can add a schedule.',
                                  style: TextStyle(
                                    color: Color(0xFF8A5A00),
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            if (schedules.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(25),
                                decoration: BoxDecoration(
                                  color: _fieldFill,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Column(
                                  children: [
                                    Icon(
                                      Icons.event_busy,
                                      color: _oceanTeal,
                                      size: 48,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'No schedules available yet.',
                                      style: TextStyle(
                                        color: _deepOcean,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Tap the + button to add your first schedule.',
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
                              ...schedules.map(buildScheduleCard),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // CIRCULAR FLOATING ADD SCHEDULE BUTTON (right, on the split)
          Positioned(
            right: 24,
            top: bodyTop - 32,
            child: Tooltip(
              message: 'Add schedule',
              child: Material(
                color: _mint,
                elevation: 10,
                shadowColor: _deepOcean.withOpacity(0.45),
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: openAddSchedule,
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
// FLOATING ADD SCHEDULE SHEET
// -------------------------------------------------------------------
class _AddScheduleSheet extends StatefulWidget {
  final int personnelId;
  final List<dynamic> vessels;

  const _AddScheduleSheet({
    required this.personnelId,
    required this.vessels,
  });

  @override
  State<_AddScheduleSheet> createState() => _AddScheduleSheetState();
}

class _AddScheduleSheetState extends State<_AddScheduleSheet> {
  final List<String> weekdays = const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final Set<String> selectedDays = {};

  int? selectedVesselId;
  TimeOfDay? departureTime;
  TimeOfDay? arrivalTime;

  bool isSaving = false;
  String? errorText;

  Future<void> chooseDepartureTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: departureTime ?? TimeOfDay.now(),
    );

    if (time != null && mounted) {
      setState(() => departureTime = time);
    }
  }

  Future<void> chooseArrivalTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: arrivalTime ?? departureTime ?? TimeOfDay.now(),
    );

    if (time != null && mounted) {
      setState(() => arrivalTime = time);
    }
  }

  Future<void> saveSchedule() async {
    if (selectedVesselId == null) {
      setState(() => errorText = 'Please select a vessel.');
      return;
    }

    if (departureTime == null) {
      setState(() => errorText = 'Please select a departure time.');
      return;
    }

    if (selectedDays.isEmpty) {
      setState(
          () => errorText = 'Please select at least one operating day.');
      return;
    }

    setState(() {
      isSaving = true;
      errorText = null;
    });

    final departure =
        '${departureTime!.hour.toString().padLeft(2, '0')}:'
        '${departureTime!.minute.toString().padLeft(2, '0')}:00';

    final arrival = arrivalTime == null
        ? null
        : '${arrivalTime!.hour.toString().padLeft(2, '0')}:'
            '${arrivalTime!.minute.toString().padLeft(2, '0')}:00';

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/add_schedule.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'personnel_id': widget.personnelId,
          'vessel_id': selectedVesselId,
          'departure_time': departure,
          'arrival_time': arrival,
          'operating_days': weekdays
              .where((day) => selectedDays.contains(day))
              .join(', '),
        }),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200 && data['success'] == true) {
        Navigator.pop(context, true);
      } else {
        setState(() {
          errorText = data['message'] ?? 'Unable to save schedule.';
        });
      }
    } catch (e) {
      debugPrint('Save schedule error: $e');

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

  Widget _timeTile({
    required IconData icon,
    required String label,
    required String? value,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: _fieldFill,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: _oceanTeal),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value ?? label,
                    style: TextStyle(
                      color: value == null ? Colors.black54 : _deepOcean,
                      fontSize: 15,
                      fontWeight:
                          value == null ? FontWeight.normal : FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded,
                    color: _subText),
              ],
            ),
          ),
        ),
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
                              'Add Schedule',
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
                            'Trip Details',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: _deepOcean,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Choose a verified vessel, set the times and '
                            'pick the days it operates.',
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
                              decoration: InputDecoration(
                                labelText: 'Select Vessel',
                                labelStyle:
                                    const TextStyle(color: Colors.black54),
                                prefixIcon: const Icon(
                                  Icons.directions_boat,
                                  color: _oceanTeal,
                                ),
                                filled: true,
                                fillColor: _fieldFill,
                                border: OutlineInputBorder(
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

                          _timeTile(
                            icon: Icons.departure_board,
                            label: 'Select Departure Time',
                            value: departureTime == null
                                ? null
                                : 'Departure: ${_formatTime(departureTime!)}',
                            onTap: chooseDepartureTime,
                          ),

                          _timeTile(
                            icon: Icons.access_time,
                            label: 'Select Arrival Time (Optional)',
                            value: arrivalTime == null
                                ? null
                                : 'Arrival: ${_formatTime(arrivalTime!)}',
                            onTap: chooseArrivalTime,
                          ),

                          const SizedBox(height: 4),
                          const Text(
                            'Operating Days',
                            style: TextStyle(
                              color: _deepOcean,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: weekdays.map((day) {
                              final selected = selectedDays.contains(day);

                              return FilterChip(
                                label: Text(day.substring(0, 3)),
                                selected: selected,
                                showCheckmark: true,
                                checkmarkColor: _oceanTeal,
                                selectedColor: _lightMint,
                                backgroundColor: _fieldFill,
                                side: BorderSide.none,
                                shape: const StadiumBorder(),
                                labelStyle: TextStyle(
                                  color: _deepOcean,
                                  fontWeight: selected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                onSelected: (value) {
                                  setState(() {
                                    if (value) {
                                      selectedDays.add(day);
                                    } else {
                                      selectedDays.remove(day);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),

                          if (errorText != null) ...[
                            const SizedBox(height: 16),
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

                          const SizedBox(height: 22),

                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: isSaving ? null : saveSchedule,
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
                                      'Save Schedule',
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
