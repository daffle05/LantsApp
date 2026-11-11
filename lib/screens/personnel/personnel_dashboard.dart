import 'package:flutter/material.dart';
import '../auth/login_screen.dart';

class PersonnelDashboard extends StatelessWidget {
  final String fullName;

  const PersonnelDashboard({
    super.key,
    required this.fullName,
  });

  static const Color deepOcean = Color(0xFF073B4C);
  static const Color oceanTeal = Color(0xFF0B7285);
  static const Color mint = Color(0xFF80EDC7);
  static const Color lightMint = Color(0xFFCAF0E3);
  static const Color backgroundColor = Color(0xFFF7FBFC);

  String get firstInitial {
    final name = fullName.trim();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PERSONNEL PROFILE
              profileHeader(context),

              const SizedBox(height: 22),

              // WELCOME BANNER
              welcomeBanner(),

              const SizedBox(height: 28),

              // OPERATIONS HEADER
              sectionHeader(
                'Operations',
                'Manage your vessel activities',
                centered: true,
              ),

              const SizedBox(height: 15),

              // OPERATION CARDS
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 20,
                mainAxisSpacing: 13,
                childAspectRatio: 1.70,
                children: [
                  // MANAGE VESSELS
                  featureCard(
                    'Manage Vessels',
                    'Add and manage vessel details',
                    Icons.directions_boat_filled,
                    oceanTeal,
                    () => showFeatureMessage(
                      context,
                      'Manage Vessels',
                    ),
                    imagePath: 'assets/images/1.jpg',
                  ),

                  // MANAGE SCHEDULES
                  featureCard(
                    'Manage Schedules',
                    'Set trips and departure times',
                    Icons.calendar_month_rounded,
                    const Color(0xFF269B78),
                    () => showFeatureMessage(
                      context,
                      'Manage Schedules',
                    ),
                    imagePath: 'assets/images/2.jpg',
                  ),

                  // UPDATE TRIP STATUS
                  featureCard(
                    'Update Trip Status',
                    'Update current trip operations',
                    Icons.sync_alt_rounded,
                    const Color(0xFFE3A23B),
                    () => showFeatureMessage(
                      context,
                      'Update Trip Status',
                    ),
                    imagePath: 'assets/images/3.jpg',
                  ),

                  // PUBLISH ADVISORIES
                  featureCard(
                    'Publish Advisories',
                    'Send important passenger updates',
                    Icons.campaign_rounded,
                    const Color(0xFF6376C5),
                    () => showFeatureMessage(
                      context,
                      'Publish Advisories',
                    ),
                    imagePath: 'assets/images/4.jpg',
                  ),
                ],
              ),

              const SizedBox(height: 13),

              // GIS CARD
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

              // PASSENGER UPDATES
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

              // FOOTER
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

        // NOTIFICATION BUTTON
        IconButton(
          onPressed: () {},
          tooltip: 'Notifications',
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: deepOcean,
            size: 27,
          ),
        ),

        // LOGOUT BUTTON
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
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
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
    // ORIGINAL HORIZONTAL DESIGN FOR GIS
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

    // FULL-BACKGROUND IMAGE FOR OPERATIONS CARDS
    return Material(
      color: lightMint,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // BACKGROUND IMAGE
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

            // DARK GRADIENT OVERLAY
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

            // CARD TITLE AND DESCRIPTION
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
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
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