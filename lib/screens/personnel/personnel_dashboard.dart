
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../auth/login_screen.dart';
import '../../services/vessel_tracking_service.dart';
import 'add_vessel_screen.dart';
import 'manage_schedules_screen.dart';
import 'manage_routes_screen.dart';
import 'manage_advisories_screen.dart';

import 'manage_fares_screen.dart';


class PersonnelDashboard extends StatefulWidget {
  final String fullName;
  final int personnelId;

  const PersonnelDashboard({
    super.key,
    required this.fullName,
    required this.personnelId,
  });

  @override
  State<PersonnelDashboard> createState() =>
      _PersonnelDashboardState();
}

class _PersonnelDashboardState extends State<PersonnelDashboard> {
  static const Color deepOcean = Color(0xFF073B4C);
  static const Color oceanTeal = Color(0xFF0B7285);
  static const Color mint = Color(0xFF80EDC7);
  static const Color lightMint = Color(0xFFCAF0E3);
  static const Color backgroundColor = Color(0xFFF7FBFC);

  // Teal used by the redesigned Manage Vessels page
  static const Color headerTeal = Color(0xFF0B7285);

  int selectedIndex = 0;

  List<dynamic> vessels = [];
  bool isLoadingVessels = false;
  String? vesselError;

  // LIVE VESSEL TRACKING
  VesselTrackingService? trackingService;
  int? trackingVesselId;
  String? trackingVesselName;

  bool isTracking = false;
  bool isStartingTracking = false;

  String get fullName => widget.fullName;

  String get firstInitial {
    final name = fullName.trim();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  void initState() {
    super.initState();
    fetchMyVessels();
  }

  // HANDLE DEVICE BACK BUTTON
  void handleBackButton() {
    if (selectedIndex != 0) {
      setState(() {
        selectedIndex = 0;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You are already on the Home dashboard.',
          ),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // FETCH PERSONNEL VESSELS FROM DATABASE
  Future<void> fetchMyVessels() async {
    if (!mounted) return;

    setState(() {
      isLoadingVessels = true;
      vesselError = null;
    });

    try {
      final String baseUrl = kIsWeb
          ? 'http://localhost/lantsapp_api'
          : 'http://10.0.2.2/lantsapp_api';

      final url = Uri.parse(
        '$baseUrl/get_my_vessels.php?personnel_id=${widget.personnelId}',
      );

      final response = await http.get(url);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          setState(() {
            vessels = data['vessels'] ?? [];
            vesselError = null;
          });
        } else {
          setState(() {
            vesselError =
                data['message'] ?? 'Unable to retrieve vessels.';
          });
        }
      } else {
        setState(() {
          vesselError = 'Server error: ${response.statusCode}';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        vesselError =
            'Unable to connect to the server. Check your connection.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoadingVessels = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------
  // LIVE VESSEL GPS TRACKING
  // ---------------------------------------------------------------

  Future<void> startVesselTracking() async {
    if (isTracking || isStartingTracking) return;

    final verifiedVessels = vessels.where((vessel) {
      return (vessel['status'] ?? '')
              .toString()
              .trim()
              .toLowerCase() ==
          'verified';
    }).toList();

    if (verifiedVessels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You need a verified vessel before starting GPS tracking.',
          ),
        ),
      );
      return;
    }

    final selectedVessel = await showDialog<dynamic>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Select Vessel'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: verifiedVessels.length,
              itemBuilder: (context, index) {
                final vessel = verifiedVessels[index];

                return ListTile(
                  leading: const Icon(
                    Icons.directions_boat,
                    color: oceanTeal,
                  ),
                  title: Text(
                    vessel['vessel_name']?.toString() ??
                        'Unnamed Vessel',
                  ),
                  subtitle: const Text('Verified vessel'),
                  onTap: () {
                    Navigator.pop(dialogContext, vessel);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (selectedVessel == null || !mounted) return;

    final int? vesselId = int.tryParse(
      (selectedVessel['id'] ?? selectedVessel['vessel_id'])
          .toString(),
    );

    if (vesselId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid vessel ID.'),
        ),
      );
      return;
    }

    setState(() {
      isStartingTracking = true;
    });

    VesselTrackingService? service;

    try {
      service = VesselTrackingService(
        personnelId: widget.personnelId,
        vesselId: vesselId,
      );

      final success = await service.startTracking();

      if (!mounted) {
        await service.stopTracking();
        return;
      }

      if (success) {
        trackingService = service;

        setState(() {
          trackingVesselId = vesselId;
          trackingVesselName =
              selectedVessel['vessel_name']?.toString() ??
                  'Unnamed Vessel';
          isTracking = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vessel GPS tracking started!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await service.dispose();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to start tracking. Check your GPS permission and location settings.',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Tracking error: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tracking error: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isStartingTracking = false;
        });
      }
    }
  }

  Future<void> stopVesselTracking() async {
    if (trackingService == null) return;

    try {
      await trackingService!.stopTracking();

      if (!mounted) return;

      setState(() {
        trackingService = null;
        trackingVesselId = null;
        trackingVesselName = null;
        isTracking = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vessel tracking stopped.'),
        ),
      );
    } catch (e) {
      debugPrint('Stop tracking error: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to stop tracking: $e'),
          ),
        );
      }
    }
  }

  // LIVE TRACKING CARD
  Widget _buildVesselTrackingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isTracking ? mint : lightMint,
        ),
        boxShadow: [
          BoxShadow(
            color: deepOcean.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: lightMint,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: oceanTeal,
                  size: 25,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Vessel Tracking',
                      style: TextStyle(
                        color: deepOcean,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Share your vessel location with passengers.',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isTracking
                      ? Colors.green.withOpacity(0.12)
                      : Colors.grey.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isTracking ? 'LIVE' : 'OFFLINE',
                  style: TextStyle(
                    color: isTracking
                        ? Colors.green
                        : Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          if (isTracking) ...[
            const SizedBox(height: 15),
            Text(
              'Currently tracking: ${trackingVesselName ?? 'Selected vessel'}',
              style: const TextStyle(
                color: deepOcean,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ] else ...[
            const SizedBox(height: 15),
            const Text(
              'Select a verified vessel to begin sharing its GPS location.',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
          ],

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isStartingTracking
                  ? null
                  : isTracking
                      ? stopVesselTracking
                      : startVesselTracking,
              icon: isStartingTracking
                  ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      isTracking
                          ? Icons.stop_circle_outlined
                          : Icons.my_location_rounded,
                    ),
              label: Text(
                isStartingTracking
                    ? 'Starting Tracking...'
                    : isTracking
                        ? 'Stop Tracking'
                        : 'Start GPS Tracking',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isTracking ? Colors.redAccent : oceanTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // OPEN ADD VESSEL SCREEN
  Future<void> openAddVesselScreen() async {
    final result = await AddVesselScreen.show(
      context,
      widget.personnelId,
    );

    if (!mounted) return;

    if (result == true) {
      setState(() {
        selectedIndex = 1;
      });

      await fetchMyVessels();
    }
  }

  // OPEN MANAGE ADVISORIES SCREEN
  void openManageAdvisoriesScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageAdvisoriesScreen(
          personnelId: widget.personnelId,
        ),
      ),
    );
  }

// OPEN MANAGE FARES SCREEN
void openManageFaresScreen() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ManageFaresScreen(
        personnelId: widget.personnelId,
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        handleBackButton();
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: IndexedStack(
          index: selectedIndex,
          children: [
            _buildHome(context),
            _buildManageVesselsPage(),
            ManageSchedulesScreen(
              personnelId: widget.personnelId,
              onBack: () => setState(() => selectedIndex = 0),
            ),
            ManageRoutesScreen(
              personnelId: widget.personnelId,
              onBack: () => setState(() => selectedIndex = 0),
            ),
            _buildNavigationPage(
              'My Profile',
              'View your personnel account information.',
              Icons.person_rounded,
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  // HOME DASHBOARD
  Widget _buildHome(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 15, 16, 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            profileHeader(context),

            const SizedBox(height: 22),

            welcomeBanner(),

            const SizedBox(height: 28),

            sectionHeader(
              'Operations',
              'Manage your vessel activities',
              centered: true,
            ),

            const SizedBox(height: 15),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 20,
              mainAxisSpacing: 13,
              childAspectRatio: 1.70,
              children: [
                featureCard(
                  'Manage Vessels',
                  'Add and manage vessel details',
                  Icons.directions_boat_filled,
                  oceanTeal,
                  () {
                    setState(() {
                      selectedIndex = 1;
                    });
                    fetchMyVessels();
                  },
                  imagePath: 'assets/images/1.jpg',
                ),

                featureCard(
                  'Manage Schedules',
                  'Set trips and departure times',
                  Icons.calendar_month_rounded,
                  const Color(0xFF269B78),
                  () {
                    setState(() {
                      selectedIndex = 2;
                    });
                  },
                  imagePath: 'assets/images/2.jpg',
                ),

                featureCard(
                  'Manage Routes',
                  'Set vessel origins and destinations',
                  Icons.route_rounded,
                  const Color(0xFF6376C5),
                  () {
                    setState(() {
                      selectedIndex = 3;
                    });
                  },
                  imagePath: 'assets/images/3.jpg',
                ),

                featureCard(
                  'Manage Fares',
                  'Set and update passenger fares for your routes',
                  Icons.payments_rounded,
                  const Color(0xFF269B78),
                  openManageFaresScreen,
                  imagePath: 'assets/images/4.jpg',
                ),

                featureCard(
                  'Update Trip Status',
                  'Update current trip operations',
                  Icons.sync_alt_rounded,
                  const Color(0xFFE3A23B),
                  () => showFeatureMessage(
                    context,
                    'Update Trip Status',
                  ),
                  imagePath: 'assets/images/4.jpg',
                ),

                featureCard(
                  'Publish Advisories',
                  'Send important passenger updates',
                  Icons.campaign_rounded,
                  const Color(0xFF6376C5),
                  openManageAdvisoriesScreen,
                ),
              ],
            ),

            const SizedBox(height: 13),

            featureCard(
              'GIS & Vessel Tracking',
              'Manage vessel locations and route information',
              Icons.map_rounded,
              oceanTeal,
              startVesselTracking,
              horizontal: true,
            ),

            const SizedBox(height: 15),

            _buildVesselTrackingCard(),

            const SizedBox(height: 30),

            sectionHeader(
              'Passenger Updates',
              'Recent information shared with passengers',
            ),

            const SizedBox(height: 15),

            updateCard(
              icon: Icons.directions_boat_filled,
              title: 'Vessel Information',
              description:
                  'Updates about registered vessels will appear here.',
              time: 'No recent updates',
              color: oceanTeal,
            ),

            const SizedBox(height: 12),

            updateCard(
              icon: Icons.calendar_month_rounded,
              title: 'Schedule Updates',
              description:
                  'Published departure times and schedule changes will appear here.',
              time: 'No recent updates',
              color: const Color(0xFF269B78),
            ),

            const SizedBox(height: 12),

            updateCard(
              icon: Icons.campaign_rounded,
              title: 'Trip Advisories',
              description:
                  'Published announcements and passenger alerts will appear here.',
              time: 'No recent updates',
              color: const Color(0xFFE3A23B),
            ),

            const SizedBox(height: 25),

            Center(
              child: Text(
                'LantsApp • Personnel Portal',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // MANAGE VESSELS PAGE (REDESIGNED)
  // Teal header + white body with large top-left radius
  // + fixed "My registered vessels" heading + scrolling list
  // + circular floating "Add vessel" button on the split
  // ---------------------------------------------------------------
  Widget _buildManageVesselsPage() {
    final double topInset = MediaQuery.of(context).padding.top;
    final double headerHeight = topInset + 230;
    final double bodyTop = headerHeight - 50;

    return Stack(
      fit: StackFit.expand,
      children: [
        // TEAL HEADER
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: headerHeight,
          child: Container(
            color: headerTeal,
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
                      () => setState(() => selectedIndex = 0),
                    ),
                    const Text(
                      'Personnel',
                      style: TextStyle(
                        color: Color(0xFFD7F5EC),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    _headerCircleButton(
                      Icons.refresh_rounded,
                      'Refresh vessels',
                      fetchMyVessels,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Manage Vessels',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'View and manage your registered vessels',
                  style: TextStyle(
                    color: Color(0xFFD7F5EC),
                    fontSize: 15,
                  ),
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
                        'My registered vessels',
                        style: TextStyle(
                          color: deepOcean,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!isLoadingVessels && vesselError == null)
                        Text(
                          '${vessels.length} total',
                          style: const TextStyle(
                            color: headerTeal,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),

                // SCROLLING VESSEL LIST
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: fetchMyVessels,
                    color: headerTeal,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(22, 4, 22, 30),
                      children: [
                        if (isLoadingVessels)
                          const Padding(
                            padding: EdgeInsets.all(35),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: headerTeal,
                              ),
                            ),
                          )
                        else if (vesselError != null)
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  color: Colors.red,
                                  size: 35,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  vesselError!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: fetchMyVessels,
                                  child: const Text('Try Again'),
                                ),
                              ],
                            ),
                          )
                        else if (vessels.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(25),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F8F9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.directions_boat_outlined,
                                  color: headerTeal,
                                  size: 48,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'No Vessels Registered',
                                  style: TextStyle(
                                    color: deepOcean,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Tap "Add vessel" below to register your first vessel.',
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
                          ...vessels.map(_vesselCard),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // FLOATING ADD VESSEL BUTTON
        Positioned(
          right: 24,
          top: bodyTop - 32,
          child: Tooltip(
            message: 'Add vessel',
            child: Material(
              color: mint,
              elevation: 10,
              shadowColor: deepOcean.withOpacity(0.45),
              shape: const CircleBorder(),
              child: InkWell(
                onTap: openAddVesselScreen,
                customBorder: const CircleBorder(),
                child: const SizedBox(
                  width: 64,
                  height: 64,
                  child: Icon(
                    Icons.add_rounded,
                    color: deepOcean,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // HEADER CIRCLE BUTTON
  Widget _headerCircleButton(
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

  // VESSEL CARD
  Widget _vesselCard(dynamic vessel) {
    final status =
        (vessel['status'] ?? 'pending').toString().toLowerCase();

    final Color chipBg = status == 'verified'
        ? const Color(0xFFDFF5E8)
        : status == 'rejected'
            ? const Color(0xFFFDE2E2)
            : const Color(0xFFFFF1CF);

    final Color chipText = status == 'verified'
        ? const Color(0xFF1F6B45)
        : status == 'rejected'
            ? const Color(0xFFB42318)
            : const Color(0xFF8A5A00);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8F9),
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
                  color: const Color(0xFFCAF0E3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.directions_boat_filled,
                  color: headerTeal,
                  size: 24,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vessel['vessel_name']?.toString() ??
                          'Unnamed Vessel',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: deepOcean,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      vessel['vessel_type']?.toString() ?? 'N/A',
                      style: const TextStyle(
                        color: Color(0xFF4F6B75),
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
                  color: chipBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status[0].toUpperCase() + status.substring(1),
                  style: TextStyle(
                    color: chipText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          _vesselDetail(
            'Registration Number',
            vessel['registration_number']?.toString() ?? 'N/A',
          ),

          _vesselDetail(
            'Passenger Capacity',
            '${vessel['passenger_capacity'] ?? 'N/A'} passengers',
          ),

          _vesselDetail(
            'Route',
            vessel['route']?.toString() ?? 'N/A',
          ),
        ],
      ),
    );
  }

  // VESSEL DETAILS
  Widget _vesselDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 135,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF4F6B75),
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: deepOcean,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // CUSTOM BOTTOM NAVIGATION BAR
  Widget _buildBottomNavigationBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Container(
          height: 78,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              _navItem(
                Icons.home_outlined,
                Icons.home,
                'Home',
                0,
              ),
              _navItem(
                Icons.directions_boat_outlined,
                Icons.directions_boat,
                'Vessels',
                1,
              ),
              _navItem(
                Icons.calendar_month_outlined,
                Icons.calendar_month,
                'Schedules',
                2,
              ),
              _navItem(
                Icons.route_outlined,
                Icons.route_rounded,
                'Routes',
                3,
              ),
              _navItem(
                Icons.person_outline,
                Icons.person,
                'Profile',
                4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // INDIVIDUAL NAVIGATION ITEM
  Widget _navItem(
    IconData icon,
    IconData activeIcon,
    String label,
    int index,
  ) {
    final bool isSelected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            selectedIndex = index;
          });

          if (index == 1) {
            fetchMyVessels();
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width: isSelected ? 44 : 38,
              height: isSelected ? 44 : 38,
              decoration: BoxDecoration(
                color: isSelected
                    ? oceanTeal
                    : Colors.transparent,
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: oceanTeal.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                color: isSelected
                    ? Colors.white
                    : Colors.grey.shade500,
                size: 22,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: isSelected
                    ? deepOcean
                    : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TEMPORARY NAVIGATION PAGE
  Widget _buildNavigationPage(
    String title,
    String subtitle,
    IconData icon,
  ) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 85,
                height: 85,
                decoration: BoxDecoration(
                  color: mint,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  icon,
                  color: oceanTeal,
                  size: 42,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: deepOcean,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // PERSONNEL PROFILE HEADER
  Widget profileHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: oceanTeal,
            shape: BoxShape.circle,
            border: Border.all(
              color: lightMint,
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            firstInitial,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullName.trim().isEmpty
                    ? 'Boat Personnel'
                    : fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: deepOcean,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 3),

              const Text(
                'Boat Personnel',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        IconButton(
          onPressed: () {},
          tooltip: 'Notifications',
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: deepOcean,
            size: 27,
          ),
        ),

        IconButton(
          onPressed: () => confirmLogout(context),
          tooltip: 'Logout',
          icon: const Icon(
            Icons.logout_rounded,
            color: deepOcean,
            size: 25,
          ),
        ),
      ],
    );
  }

  // LOGOUT CONFIRMATION
  Future<void> confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),

          title: const Text(
            'Confirm Logout',
            style: TextStyle(
              color: deepOcean,
              fontWeight: FontWeight.bold,
            ),
          ),

          content: const Text(
            'Are you sure you want to log out?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: oceanTeal,
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: deepOcean,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true && context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (route) => false,
      );
    }
  }

  // WELCOME BANNER
  Widget welcomeBanner() {
    return Container(
      width: double.infinity,
      height: 140,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: deepOcean.withOpacity(0.16),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/banner.jpg',
            width: double.infinity,
            height: 140,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [oceanTeal, deepOcean],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.waves_rounded,
                  color: Colors.white24,
                  size: 90,
                ),
              );
            },
          ),

          Container(
            color: deepOcean.withOpacity(0.40),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Welcome, ${fullName.trim().isEmpty ? 'Personnel' : fullName.trim()}!',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black38,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // SECTION HEADER
  Widget sectionHeader(
    String title,
    String subtitle, {
    bool centered = false,
  }) {
    return Column(
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(
            title,
            textAlign:
                centered ? TextAlign.center : TextAlign.start,
            style: const TextStyle(
              color: deepOcean,
              fontWeight: FontWeight.bold,
              fontSize: 19,
            ),
          ),
        ),

        const SizedBox(height: 4),

        SizedBox(
          width: double.infinity,
          child: Text(
            subtitle,
            textAlign:
                centered ? TextAlign.center : TextAlign.start,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  // FEATURE CARD
  Widget featureCard(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    VoidCallback onTap, {
    bool horizontal = false,
    String? imagePath,
  }) {
    if (horizontal) {
      return Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: lightMint.withOpacity(0.8),
              ),
              boxShadow: [
                BoxShadow(
                  color: deepOcean.withOpacity(0.035),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                featureIcon(icon, iconColor),

                const SizedBox(width: 14),

                Expanded(
                  child: featureText(title, subtitle),
                ),

                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: oceanTeal,
                  size: 17,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Material(
      color: lightMint,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imagePath != null)
              Image.asset(
                imagePath,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: lightMint,
                    alignment: Alignment.center,
                    child: Icon(
                      icon,
                      color: oceanTeal,
                      size: 45,
                    ),
                  );
                },
              )
            else
              Container(
                color: lightMint,
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  color: oceanTeal,
                  size: 45,
                ),
              ),

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    deepOcean.withOpacity(0.92),
                  ],
                  stops: const [0.25, 1.0],
                ),
              ),
            ),

            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // FEATURE ICON
  Widget featureIcon(IconData icon, Color color) {
    return Container(
      width: 39,
      height: 39,
      decoration: BoxDecoration(
        color: color.withOpacity(0.11),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: color,
        size: 22,
      ),
    );
  }

  // FEATURE TEXT
  Widget featureText(
    String title,
    String subtitle, {
    bool centered = false,
  }) {
    return Column(
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign:
              centered ? TextAlign.center : TextAlign.start,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: deepOcean,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          subtitle,
          textAlign:
              centered ? TextAlign.center : TextAlign.start,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 10,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  // PASSENGER UPDATE CARD
  Widget updateCard({
    required IconData icon,
    required String title,
    required String description,
    required String time,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: lightMint.withOpacity(0.75),
        ),
        boxShadow: [
          BoxShadow(
            color: deepOcean.withOpacity(0.035),
            blurRadius: 9,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.11),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
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
                    color: deepOcean,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  time,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TEMPORARY FEATURE MESSAGE
  void showFeatureMessage(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature will be connected next.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: deepOcean,
      ),
    );
  }

  // CLEAN UP TRACKING WHEN DASHBOARD IS DESTROYED
  @override
  void dispose() {
    trackingService?.dispose();
    super.dispose();
  }
}
