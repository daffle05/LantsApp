
import 'package:flutter/material.dart';
import 'boat_map_screen.dart';

class PassengerDashboard extends StatefulWidget {
  const PassengerDashboard({super.key});

  @override
  State<PassengerDashboard> createState() =>
      _PassengerDashboardState();
}

class _PassengerDashboardState extends State<PassengerDashboard> {
  int selectedIndex = 0;

  static const Color deepTeal = Color(0xFF073B4C);
  static const Color oceanTeal = Color(0xFF0B7285);
  static const Color mint = Color(0xFF80EDC7);
  static const Color lightMint = Color(0xFFCAF0E3);
  static const Color backgroundColor = Color(0xFFF7FBFC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: IndexedStack(
          index: selectedIndex,
          children: [
              homePage(),
              const BoatMapScreen(),
              simplePage('Search', Icons.search_rounded),
              simplePage('Advisories', Icons.campaign_outlined),
              simplePage('My Profile', Icons.person_outline),
            ],
        ),
      ),
      bottomNavigationBar: bottomNavigation(),
    );
  }

  // FIVE-ITEM FLOATING BOTTOM NAVIGATION
  Widget bottomNavigation() {
    return Container(
      color: deepTeal,
      padding: const EdgeInsets.fromLTRB(15, 25, 15, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.22),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                navItem(Icons.home_rounded, 'Home', 0),
                navItem(Icons.map_rounded, 'Routes', 1),
                navItem(Icons.search_rounded, 'Search', 2),
                navItem(Icons.campaign_rounded, 'Advisories', 3),
                navItem(Icons.person_rounded, 'Profile', 4),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // BOTTOM GESTURE INDICATOR
          Container(
            width: 110,
            height: 5,
            decoration: BoxDecoration(
              color: mint,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
    );
  }

  // INDIVIDUAL NAVIGATION ITEM
  Widget navItem(IconData icon, String label, int index) {
    final bool isSelected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
        },
        child: SizedBox(
          height: 76,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // ACTIVE RAISED CIRCLE
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                top: isSelected ? -20 : 8,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  height: isSelected ? 48 : 38,
                  width: isSelected ? 48 : 38,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? oceanTeal
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: oceanTeal.withOpacity(0.30),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(
                    icon,
                    size: isSelected ? 25 : 23,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF68737D),
                  ),
                ),
              ),

              // NAVIGATION LABEL
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: isSelected ? 10 : 9,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.w500,
                    color: isSelected
                        ? deepTeal
                        : const Color(0xFF9AA3AA),
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // PASSENGER HOME PAGE
  Widget homePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [oceanTeal, deepTeal],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.directions_boat_filled,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LantsApp',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: deepTeal,
                      ),
                    ),
                    Text(
                      'Your Sea Travel Companion',
                      style: TextStyle(
                        fontSize: 12,
                        color: oceanTeal,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: deepTeal.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      selectedIndex = 3;
                    });
                  },
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: deepTeal,
                    size: 27,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // WELCOME
          const Text(
            'Hello, Passenger!',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: deepTeal,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Plan your sea journey with confidence.',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 23),

          // TRIP INFORMATION BANNER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(21),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [oceanTeal, deepTeal],
              ),
              borderRadius: BorderRadius.circular(23),
              boxShadow: [
                BoxShadow(
                  color: deepTeal.withOpacity(0.18),
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
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.directions_boat_filled,
                        color: mint,
                        size: 25,
                      ),
                    ),
                    const SizedBox(width: 11),
                    const Text(
                      'TRIP INFORMATION',
                      style: TextStyle(
                        color: mint,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Check Before You Travel!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Stay updated with boat schedules, trip statuses, '
                  'and important announcements before going to the port.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // QUICK ACCESS GRID
          sectionTitle('Explore LantsApp'),
          const SizedBox(height: 14),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 13,
            mainAxisSpacing: 13,
            childAspectRatio: 1.65,
            children: [
              shortcutCard(
                'Boat Routes',
                'Explore travel routes',
                Icons.map_outlined,
                oceanTeal,
                () => setState(() => selectedIndex = 1),
              ),
              shortcutCard(
                'Trip Advisories',
                'Check latest updates',
                Icons.campaign_outlined,
                const Color(0xFF269B78),
                () => setState(() => selectedIndex = 3),
              ),
              shortcutCard(
                'Schedules',
                'View boat schedules',
                Icons.calendar_month_outlined,
                oceanTeal,
                () => setState(() => selectedIndex = 1),
              ),
              shortcutCard(
                'My Profile',
                'Manage your account',
                Icons.person_outline_rounded,
                const Color(0xFF269B78),
                () => setState(() => selectedIndex = 4),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // TRIP STATUS
          sectionTitle('Trip Status Overview'),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: statusCard(
                  'Available',
                  '5',
                  const Color(0xFF269B78),
                  Icons.check_circle_outline_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: statusCard(
                  'Delayed',
                  '2',
                  const Color(0xFFE3A23B),
                  Icons.access_time_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: statusCard(
                  'Cancelled',
                  '1',
                  const Color(0xFFD65D65),
                  Icons.cancel_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 29),

          // SCHEDULES
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              sectionTitle('Upcoming Schedules'),
              TextButton(
                onPressed: () => setState(() => selectedIndex = 1),
                child: const Text(
                  'See All',
                  style: TextStyle(
                    color: oceanTeal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          scheduleCard(
            'MV Island Express',
            'Port A',
            'Port B',
            '08:00 AM',
            'Available',
            const Color(0xFF269B78),
          ),
          const SizedBox(height: 13),
          scheduleCard(
            'MV Sea Traveler',
            'Port A',
            'Port C',
            '10:30 AM',
            'Delayed',
            const Color(0xFFE3A23B),
          ),

          const SizedBox(height: 29),

          // ROUTE MAP
          sectionTitle('Explore Boat Routes'),
          const SizedBox(height: 14),

          Container(
            height: 175,
            width: double.infinity,
            decoration: BoxDecoration(
              color: lightMint.withOpacity(0.55),
              borderRadius: BorderRadius.circular(21),
              border: Border.all(
                color: mint.withOpacity(0.7),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 20,
                  left: 35,
                  child: Icon(
                    Icons.location_on,
                    color: oceanTeal.withOpacity(0.85),
                    size: 33,
                  ),
                ),
                Positioned(
                  bottom: 28,
                  right: 45,
                  child: Icon(
                    Icons.location_on,
                    color: deepTeal.withOpacity(0.85),
                    size: 33,
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.map_outlined,
                        color: deepTeal,
                        size: 43,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Boat Route Map',
                        style: TextStyle(
                          color: deepTeal,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Explore ports and passenger boat routes',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(21),
                      onTap: () => setState(() => selectedIndex = 1),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 29),

          // ADVISORIES
          sectionTitle('Latest Advisories'),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(19),
              border: Border.all(
                color: const Color(0xFFE7C77B).withOpacity(0.7),
              ),
              boxShadow: [
                BoxShadow(
                  color: deepTeal.withOpacity(0.05),
                  blurRadius: 13,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4D8),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFB98220),
                    size: 27,
                  ),
                ),
                const SizedBox(width: 13),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weather Advisory',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: deepTeal,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Please check the latest weather conditions '
                        'before traveling.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // SECTION TITLE
  Widget sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.bold,
        color: deepTeal,
      ),
    );
  }

  // QUICK ACCESS CARD
  Widget shortcutCard(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: lightMint.withOpacity(0.8),
            ),
            boxShadow: [
              BoxShadow(
                color: deepTeal.withOpacity(0.045),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: lightMint.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: deepTeal,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black54,
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

  // STATUS CARD
  Widget statusCard(
    String title,
    String count,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: lightMint.withOpacity(0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: deepTeal.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 27),
          const SizedBox(height: 9),
          Text(
            count,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: deepTeal,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // BOAT SCHEDULE CARD
  Widget scheduleCard(
    String vessel,
    String departure,
    String destination,
    String time,
    String status,
    Color statusColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: lightMint.withOpacity(0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: deepTeal.withOpacity(0.05),
            blurRadius: 13,
            offset: const Offset(0, 5),
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
                  color: lightMint.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.directions_boat_filled,
                  color: deepTeal,
                  size: 22,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  vessel,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: deepTeal,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 19),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DEPARTURE',
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      departure,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: deepTeal,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: oceanTeal,
                size: 21,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DESTINATION',
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      destination,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: deepTeal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'TIME',
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    time,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: deepTeal,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // OTHER PASSENGER PAGES (TEMPORARY PLACEHOLDERS)
  Widget simplePage(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: const BoxDecoration(
              color: lightMint,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 55,
              color: oceanTeal,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: deepTeal,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'We will build this page next.',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
