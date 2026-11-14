
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ManageSchedulesScreen extends StatefulWidget {
  final int personnelId;

  const ManageSchedulesScreen({
    super.key,
    required this.personnelId,
  });

  @override
  State<ManageSchedulesScreen> createState() =>
      _ManageSchedulesScreenState();
}

class _ManageSchedulesScreenState extends State<ManageSchedulesScreen> {
  final Color deepOcean = const Color(0xFF073B4C);
  final Color oceanTeal = const Color(0xFF0B7285);
  final Color lightMint = const Color(0xFFE8F5F2);

  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost/lantsapp_api';
    }
    return 'http://10.0.2.2/lantsapp_api';
  }

  bool isLoading = true;
  bool isSaving = false;

  List<dynamic> vessels = [];
  List<dynamic> schedules = [];

  int? selectedVesselId;
  TimeOfDay? departureTime;
  TimeOfDay? arrivalTime;

  final List<String> weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final Set<String> selectedDays = {};

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
          '$baseUrl/get_my_vessels.php?personnel_id=${widget.personnelId}',
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
          '$baseUrl/get_my_schedules.php?personnel_id=${widget.personnelId}',
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

  String formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';

    return '$hour:$minute $period';
  }

  String formatDatabaseTime(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return 'Not specified';
    }

    try {
      final parts = value.toString().split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      return formatTime(TimeOfDay(hour: hour, minute: minute));
    } catch (_) {
      return value.toString();
    }
  }

  Future<void> chooseDepartureTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null && mounted) {
      setState(() => departureTime = time);
    }
  }

  Future<void> chooseArrivalTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: departureTime ?? TimeOfDay.now(),
    );

    if (time != null && mounted) {
      setState(() => arrivalTime = time);
    }
  }

  void showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : oceanTeal,
      ),
    );
  }

  Future<void> saveSchedule() async {
    if (selectedVesselId == null) {
      showMessage('Please select a vessel.', error: true);
      return;
    }

    if (departureTime == null) {
      showMessage('Please select a departure time.', error: true);
      return;
    }

    if (selectedDays.isEmpty) {
      showMessage('Please select at least one operating day.',
          error: true);
      return;
    }

    setState(() => isSaving = true);

    final departure =
        '${departureTime!.hour.toString().padLeft(2, '0')}:'
        '${departureTime!.minute.toString().padLeft(2, '0')}:00';

    final arrival = arrivalTime == null
        ? null
        : '${arrivalTime!.hour.toString().padLeft(2, '0')}:'
            '${arrivalTime!.minute.toString().padLeft(2, '0')}:00';

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add_schedule.php'),
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

      if (response.statusCode == 200 && data['success'] == true) {
        if (!mounted) return;

        setState(() {
          departureTime = null;
          arrivalTime = null;
          selectedDays.clear();
        });

        showMessage('Schedule added successfully!');
        await fetchMySchedules();
      } else {
        showMessage(
          data['message'] ?? 'Unable to save schedule.',
          error: true,
        );
      }
    } catch (e) {
      showMessage('Connection error. Please try again.', error: true);
      debugPrint('Save schedule error: $e');
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  Widget sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: oceanTeal),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: deepOcean,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget buildScheduleCard(dynamic schedule) {
    final vesselName = schedule['vessel_name'] ?? 'Unknown vessel';
    final days = schedule['operating_days'] ?? 'Not specified';
    final status = schedule['status'] ?? 'Unknown';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  vesselName.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: deepOcean,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: status.toString().toLowerCase() == 'active'
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toString().toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: status.toString().toLowerCase() == 'active'
                        ? Colors.green.shade700
                        : Colors.orange.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.departure_board,
                  color: oceanTeal, size: 19),
              const SizedBox(width: 8),
              const Text('Departure: '),
              Text(
                formatDatabaseTime(schedule['departure_time']),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, color: oceanTeal, size: 19),
              const SizedBox(width: 8),
              const Text('Arrival: '),
              Text(
                formatDatabaseTime(schedule['arrival_time']),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.calendar_month, color: oceanTeal, size: 19),
              const SizedBox(width: 8),
              const Text('Operating days: '),
              Expanded(
                child: Text(
                  days.toString(),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildAddScheduleForm() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<int>(
            value: selectedVesselId,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Select Vessel',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.directions_boat),
            ),
            items: vessels.map<DropdownMenuItem<int>>((vessel) {
              return DropdownMenuItem<int>(
                value: int.parse(vessel['id'].toString()),
                child: Text(vessel['vessel_name'].toString()),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => selectedVesselId = value);
            },
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: chooseDepartureTime,
            icon: const Icon(Icons.departure_board),
            label: Text(
              departureTime == null
                  ? 'Select Departure Time'
                  : 'Departure: ${formatTime(departureTime!)}',
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              foregroundColor: oceanTeal,
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: chooseArrivalTime,
            icon: const Icon(Icons.access_time),
            label: Text(
              arrivalTime == null
                  ? 'Select Arrival Time (Optional)'
                  : 'Arrival: ${formatTime(arrivalTime!)}',
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              foregroundColor: oceanTeal,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Operating Days',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: weekdays.map((day) {
              final selected = selectedDays.contains(day);

              return FilterChip(
                label: Text(day.substring(0, 3)),
                selected: selected,
                selectedColor: lightMint,
                checkmarkColor: oceanTeal,
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
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isSaving ? null : saveSchedule,
              style: ElevatedButton.styleFrom(
                backgroundColor: oceanTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isSaving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Save Schedule',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F8),
      appBar: AppBar(
        title: const Text('Manage Schedules'),
        backgroundColor: deepOcean,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: oceanTeal),
            )
          : RefreshIndicator(
              onRefresh: loadData,
              color: oceanTeal,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  sectionTitle('Add New Schedule', Icons.add_circle_outline),
                  const SizedBox(height: 12),
                  if (vessels.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'You do not have an approved vessel yet. '
                        'Your vessel must be verified by the administrator '
                        'before you can add a schedule.',
                      ),
                    )
                  else
                    buildAddScheduleForm(),
                  const SizedBox(height: 28),
                  sectionTitle(
                    'Your Saved Schedules',
                    Icons.calendar_month,
                  ),
                  const SizedBox(height: 12),
                  if (schedules.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 40,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'No schedules available yet.',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Schedules you save will appear here.',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  else
                    ...schedules.map(buildScheduleCard),
                ],
              ),
            ),
    );
  }
}
