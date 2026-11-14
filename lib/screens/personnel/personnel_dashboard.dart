
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../auth/login_screen.dart';
import 'add_vessel_screen.dart';
import 'manage_schedules_screen.dart';
import 'manage_routes_screen.dart';
import 'manage_advisories_screen.dart';

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

  int selectedIndex = 0;

  List<dynamic> vessels = [];
  bool isLoadingVessels = false;
  String? vesselError;

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

  // OPEN ADD VESSEL SCREEN
  Future<void> openAddVesselScreen() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddVesselScreen(
          personnelId: widget.personnelId,
        ),
      ),
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
            ),
            ManageRoutesScreen(
              personnelId: widget.personnelId,
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
              () => showFeatureMessage(
                context,
                'GIS & Vessel Tracking',
              ),
              horizontal: true,
            ),

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

  // MANAGE VESSELS PAGE
  Widget _buildManageVesselsPage() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: fetchMyVessels,
        color: oceanTeal,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manage Vessels',
                        style: TextStyle(
                          color: deepOcean,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'View your registered vessels',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  onPressed: fetchMyVessels,
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: oceanTeal,
                    size: 27,
                  ),
                  tooltip: 'Refresh vessels',
                ),

                const SizedBox(width: 4),

                ElevatedButton.icon(
                  onPressed: openAddVesselScreen,
                  icon: const Icon(
                    Icons.add,
                    size: 19,
                  ),
                  label: const Text('Add Vessel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: oceanTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            if (isLoadingVessels)
              const Padding(
                padding: EdgeInsets.all(35),
                child: Center(
                  child: CircularProgressIndicator(
                    color: oceanTeal,
                  ),
                ),
              )
            else if (vesselError != null)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: lightMint),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.directions_boat_outlined,
                      color: oceanTeal,
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
                      'Your registered vessels will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              Text(
                'My Registered Vessels (${vessels.length})',
                style: const TextStyle(
                  color: deepOcean,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 13),

              ...vessels.map((vessel) {
                final status = (vessel['status'] ?? 'pending')
                    .toString()
                    .toLowerCase();

                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: lightMint),
                    boxShadow: [
                      BoxShadow(
                        color: deepOcean.withOpacity(0.04),
                        blurRadius: 10,
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
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: lightMint,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Icon(
                              Icons.directions_boat_filled,
                              color: oceanTeal,
                              size: 26,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              vessel['vessel_name']?.toString() ??
                                  'Unnamed Vessel',
                              style: const TextStyle(
                                color: deepOcean,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      _vesselDetail(
                        'Registration Number',
                        vessel['registration_number']?.toString() ??
                            'N/A',
                      ),

                      _vesselDetail(
                        'Vessel Type',
                        vessel['vessel_type']?.toString() ?? 'N/A',
                      ),

                      _vesselDetail(
                        'Passenger Capacity',
                        '${vessel['passenger_capacity'] ?? 'N/A'} passengers',
                      ),

                      _vesselDetail(
                        'Route',
                        vessel['route']?.toString() ?? 'N/A',
                      ),

                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: status == 'verified'
                              ? Colors.green.withOpacity(0.10)
                              : status == 'rejected'
                                  ? Colors.red.withOpacity(0.10)
                                  : Colors.orange.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: status == 'verified'
                                ? Colors.green.shade700
                                : status == 'rejected'
                                    ? Colors.red
                                    : Colors.orange.shade800,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
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
                color: Colors.black54,
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
}
