
import 'package:flutter/material.dart';

class PassengerDashboard extends StatefulWidget {
  const PassengerDashboard({super.key});

  @override
  State<PassengerDashboard> createState() =>
      _PassengerDashboardState();
}

class _PassengerDashboardState extends State<PassengerDashboard> {
  int selectedIndex = 0;

  static const Color primaryBlue = Color(0xFF1677B8);
  static const Color darkBlue = Color(0xFF123B5D);
  static const Color backgroundColor = Color(0xFFF4F8FC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        child: IndexedStack(
          index: selectedIndex,
          children: [
            homePage(),
            simplePage('Boat Routes', Icons.map_outlined),
            simplePage('Advisories', Icons.campaign_outlined),
            simplePage('My Profile', Icons.person_outline),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Routes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign_outlined),
            label: 'Advisories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // PASSENGER HOME PAGE
  Widget homePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // HEADER
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.directions_boat_filled,
                  color: Colors.white,
                  size: 27,
                ),
              ),

              const SizedBox(width: 10),

              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LantsApp',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: darkBlue,
                    ),
                  ),
                  Text(
                    'Your Sea Travel Companion',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_none,
                  color: darkBlue,
                  size: 28,
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // WELCOME
          const Text(
            'Hello, Passenger!',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: darkBlue,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Plan your sea journey with confidence.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 24),

          // TRIP STATUS BANNER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1677B8),
                  Color(0xFF104C79),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
            ),

            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.directions_boat,
                      color: Colors.white,
                      size: 27,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'TRIP INFORMATION',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 18),

                Text(
                  'Check Before You Travel!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 6),

                Text(
                  'Stay updated with boat schedules, trip '
                  'statuses, and important announcements.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // TRIP STATUS
          const Text(
            'Trip Status Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: darkBlue,
            ),
          ),

          const SizedBox(height: 13),

          Row(
            children: [
              Expanded(
                child: statusCard(
                  'Available',
                  '5',
                  Colors.green,
                  Icons.check_circle_outline,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: statusCard(
                  'Delayed',
                  '2',
                  Colors.orange,
                  Icons.access_time,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: statusCard(
                  'Cancelled',
                  '1',
                  Colors.red,
                  Icons.cancel_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 27),

          // SCHEDULE HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Upcoming Boat Schedules',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkBlue,
                ),
              ),

              TextButton(
                onPressed: () {},
                child: const Text('See All'),
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
            Colors.green,
          ),

          const SizedBox(height: 12),

          scheduleCard(
            'MV Sea Traveler',
            'Port A',
            'Port C',
            '10:30 AM',
            'Delayed',
            Colors.orange,
          ),

          const SizedBox(height: 27),

          // ROUTE MAP
          const Text(
            'Explore Boat Routes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: darkBlue,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFDDECF5),
              borderRadius: BorderRadius.circular(16),
            ),

            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map_outlined,
                  color: primaryBlue,
                  size: 48,
                ),
                SizedBox(height: 8),
                Text(
                  'Boat Route Map',
                  style: TextStyle(
                    color: darkBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Explore ports and passenger boat routes',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 27),

          // ADVISORIES
          const Text(
            'Latest Advisories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: darkBlue,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.orange.shade200,
              ),
            ),

            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 30,
                ),

                SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weather Advisory',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),

                      SizedBox(height: 5),

                      Text(
                        'Please check the latest weather '
                        'conditions before traveling.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),
        ],
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
        vertical: 15,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),

      child: Column(
        children: [
          Icon(icon, color: color, size: 25),
          const SizedBox(height: 8),

          Text(
            count,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: darkBlue,
            ),
          ),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
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
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.directions_boat,
                color: primaryBlue,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  vessel,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: darkBlue,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DEPARTURE',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      departure,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward,
                color: primaryBlue,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DESTINATION',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      destination,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
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
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    time,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
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
          Icon(icon, size: 65, color: primaryBlue),
          const SizedBox(height: 15),
          Text(
            title,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: darkBlue,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'We will build this page next.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
