
import 'package:flutter/material.dart';
import 'boat_map_screen.dart';

class PassengerDashboard extends StatefulWidget {
  const PassengerDashboard({super.key});

  @override
  State<PassengerDashboard> createState() => _PassengerDashboardState();
}

class _PassengerDashboardState extends State<PassengerDashboard> {
  int selectedIndex = 0;

  static const Color sageGreen = Color(0xFFA8C5B5);
  static const Color oceanTeal = Color(0xFF087EAB);
  static const Color midnightTeal = Color(0xFF073B40);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color iceMint = Color(0xFFDDF4F1);
  static const Color softBackground = Color(0xFFF5F9F8);
  static const Color mutedText = Color(0xFF71817F);

  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: midnightTeal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBackground,
      body: SafeArea(
        child: IndexedStack(
          index: selectedIndex,
          children: [
            homePage(),
            const BoatMapScreen(),
            advisoriesPage(),
          ],
        ),
      ),
      bottomNavigationBar: bottomNavigation(),
    );
  }

  // BOTTOM NAVIGATION

  Widget bottomNavigation() {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 8, 18, 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: pureWhite,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: midnightTeal.withOpacity(0.13),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            navItem(Icons.home_rounded, 'Home', 0),
            navItem(Icons.map_rounded, 'Routes', 1),
            navItem(Icons.campaign_rounded, 'Advisories', 2),
          ],
        ),
      ),
    );
  }

  Widget navItem(IconData icon, String label, int index) {
    final bool isSelected = selectedIndex == index;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                height: 43,
                width: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? midnightTeal : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 23,
                  color: isSelected ? pureWhite : mutedText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      isSelected ? FontWeight.w800 : FontWeight.w500,
                  color: isSelected ? midnightTeal : mutedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // HOME PAGE

  Widget homePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header(),
          const SizedBox(height: 27),

          const Text(
            'Your Journey,',
            style: TextStyle(
              color: midnightTeal,
              fontSize: 28,
              height: 1.1,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Text(
            'Made Easier.',
            style: TextStyle(
              color: oceanTeal,
              fontSize: 28,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 9),

          const Text(
            'Find vessels, check schedules, and stay updated before you travel.',
            style: TextStyle(
              color: mutedText,
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          searchBar(),

          const SizedBox(height: 22),

          tripInformationBanner(),

          const SizedBox(height: 27),

          sectionHeading('Explore LantsApp'),

          const SizedBox(height: 14),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 13,
            mainAxisSpacing: 13,
            childAspectRatio: 1.42,
            children: [
              shortcutCard(
                'Register Vessels',
                'Browse registered passenger boats',
                Icons.directions_boat_filled_rounded,
                () => showMessage(
                  'Vessel directory will be available here.',
                ),
              ),
              shortcutCard(
                'Schedules',
                'Check passenger boat schedules',
                Icons.calendar_month_rounded,
                () => setState(() => selectedIndex = 1),
              ),
              shortcutCard(
                'No-Trip Vessels',
                'View vessels with no scheduled trips',
                Icons.event_busy_rounded,
                () => setState(() => selectedIndex = 2),
              ),
              shortcutCard(
                'Fare Monitoring',
                'Check passenger fare information',
                Icons.payments_outlined,
                () => showMessage(
                  'Fare monitoring will be available here.',
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          sectionHeading('Explore Boat Routes'),

          const SizedBox(height: 13),

          routePreview(),

          const SizedBox(height: 28),

          sectionHeading('Latest Advisories'),

          const SizedBox(height: 13),

          advisoryPreview(),
        ],
      ),
    );
  }

  // HEADER

  Widget header() {
    return Row(
      children: [
        ClipOval(
          child: SizedBox(
            width: 52,
            height: 52,
            child: Image.asset(
              'assets/images/lantsapp_logo.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: midnightTeal,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.directions_boat_filled_rounded,
                    color: pureWhite,
                    size: 27,
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(width: 11),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LantsApp',
                style: TextStyle(
                  color: midnightTeal,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Your Sea Travel Companion',
                style: TextStyle(
                  color: oceanTeal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        IconButton(
          tooltip: 'Notifications',
          onPressed: () {
            setState(() => selectedIndex = 2);
          },
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: midnightTeal,
            size: 26,
          ),
        ),

        const SizedBox(width: 3),

        InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PassengerProfilePage(),
              ),
            );
          },
          child: Container(
            width: 43,
            height: 43,
            decoration: const BoxDecoration(
              color: iceMint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: midnightTeal,
              size: 25,
            ),
          ),
        ),
      ],
    );
  }

  // SEARCH BAR

  Widget searchBar() {
    return Container(
      decoration: BoxDecoration(
        color: pureWhite,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFE1ECE8),
        ),
        boxShadow: [
          BoxShadow(
            color: midnightTeal.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: (value) {
          setState(() => selectedIndex = 1);
        },
        decoration: InputDecoration(
          hintText: 'Search vessel or destination...',
          hintStyle: const TextStyle(
            color: mutedText,
            fontSize: 13,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: oceanTeal,
          ),
          suffixIcon: IconButton(
            onPressed: () => searchController.clear(),
            icon: const Icon(
              Icons.close_rounded,
              color: mutedText,
              size: 19,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  // TRIP INFORMATION BANNER

  Widget tripInformationBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [sageGreen, oceanTeal],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: oceanTeal.withOpacity(0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: pureWhite.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.directions_boat_filled_rounded,
                  color: pureWhite,
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'TRIP INFORMATION',
                style: TextStyle(
                  color: pureWhite,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          const Text(
            'Check Before You Travel!',
            style: TextStyle(
              color: pureWhite,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Stay informed about boat schedules, trip statuses, and important announcements before going to the port.',
            style: TextStyle(
              color: pureWhite.withOpacity(0.92),
              fontSize: 13,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 16),

          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: midnightTeal,
              backgroundColor: pureWhite,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              setState(() => selectedIndex = 2);
            },
            icon: const Icon(
              Icons.campaign_outlined,
              size: 18,
            ),
            label: const Text(
              'View advisories',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // SECTION HEADING

  Widget sectionHeading(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: midnightTeal,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  // SHORTCUT CARDS
  // ClipOval forces the icon background to be circular.

  Widget shortcutCard(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: midnightTeal,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(13),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
                child: Container(
                  width: 48,
                  height: 48,
                  color: iceMint,
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    size: 24,
                    color: midnightTeal,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: pureWhite,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: pureWhite.withOpacity(0.76),
                  fontSize: 10,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ROUTE PREVIEW

  Widget routePreview() {
    return Material(
      color: iceMint,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          setState(() => selectedIndex = 1);
        },
        child: SizedBox(
          height: 155,
          width: double.infinity,
          child: Stack(
            children: [
              Positioned(
                top: 18,
                left: 28,
                child: Icon(
                  Icons.location_on_rounded,
                  color: oceanTeal.withOpacity(0.85),
                  size: 32,
                ),
              ),
              Positioned(
                bottom: 20,
                right: 35,
                child: Icon(
                  Icons.location_on_rounded,
                  color: midnightTeal.withOpacity(0.9),
                  size: 32,
                ),
              ),
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map_outlined,
                      color: midnightTeal,
                      size: 39,
                    ),
                    SizedBox(height: 7),
                    Text(
                      'Explore Boat Routes',
                      style: TextStyle(
                        color: midnightTeal,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'View ports and passenger boat routes',
                      style: TextStyle(
                        color: mutedText,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ADVISORY PREVIEW

  Widget advisoryPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: pureWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE8E6D7),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3D8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFAD781C),
              size: 25,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weather Advisory',
                  style: TextStyle(
                    color: midnightTeal,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Please check the latest weather conditions before traveling.',
                  style: TextStyle(
                    color: mutedText,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ADVISORIES PAGE

  Widget advisoriesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trip Advisories',
            style: TextStyle(
              color: midnightTeal,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'Important updates about passenger boat operations.',
            style: TextStyle(
              color: mutedText,
              fontSize: 13,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 20),

          advisoryPreview(),

          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: pureWhite,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFE2ECE8),
              ),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: oceanTeal,
                  size: 25,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'New advisories from boat personnel will appear here when they are connected to the backend.',
                    style: TextStyle(
                      color: midnightTeal,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// PASSENGER PROFILE PAGE

class PassengerProfilePage extends StatelessWidget {
  const PassengerProfilePage({super.key});

  static const Color midnightTeal = Color(0xFF073B40);
  static const Color oceanTeal = Color(0xFF087EAB);
  static const Color iceMint = Color(0xFFDDF4F1);
  static const Color softBackground = Color(0xFFF5F9F8);
  static const Color mutedText = Color(0xFF71817F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBackground,
      appBar: AppBar(
        backgroundColor: softBackground,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: midnightTeal,
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: midnightTeal,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            const SizedBox(height: 25),

            Container(
              width: 105,
              height: 105,
              decoration: const BoxDecoration(
                color: iceMint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: midnightTeal,
                size: 60,
              ),
            ),

            const SizedBox(height: 17),

            const Text(
              'Passenger Account',
              style: TextStyle(
                color: midnightTeal,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Manage your passenger information',
              style: TextStyle(
                color: mutedText,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 30),

            profileInformation(
              Icons.person_outline_rounded,
              'Full Name',
              'Not provided',
            ),

            const SizedBox(height: 13),

            profileInformation(
              Icons.email_outlined,
              'Email Address',
              'Not provided',
            ),

            const SizedBox(height: 13),

            profileInformation(
              Icons.badge_outlined,
              'Account Type',
              'Passenger',
            ),
          ],
        ),
      ),
    );
  }

  Widget profileInformation(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: oceanTeal,
            size: 23,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: mutedText,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: midnightTeal,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
