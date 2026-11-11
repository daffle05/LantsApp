
import 'package:flutter/material.dart';
import 'personnel_applications.dart';

class AdminDashboard extends StatefulWidget {
  final int adminId;

  const AdminDashboard({
    super.key,
    required this.adminId,
  });

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  static const Color primaryColor = Color(0xFF075E54);
  static const Color backgroundColor = Color(0xFFF4F7F8);

  int selectedIndex = 0;

  final List<String> pageTitles = [
    'LantsApp Admin',
    'Personnel Applications',
    'Requirements',
    'Trip Advisories',
  ];

  void showComingSoon(String section) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$section screen is not connected yet.'),
      ),
    );
  }

  // CUSTOM NAVIGATION ITEM
  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final bool isSelected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width: isSelected ? 46 : 38,
              height: isSelected ? 46 : 38,
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor
                    : Colors.transparent,
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.30),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                color: isSelected
                    ? Colors.white
                    : Colors.grey.shade500,
                size: 23,
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
                    ? primaryColor
                    : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      // APP BAR
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Icon(Icons.directions_boat_filled),
            const SizedBox(width: 10),
            Text(
              pageTitles[selectedIndex],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),

      // MAIN CONTENT
      body: IndexedStack(
        index: selectedIndex,
        children: [
          _buildHome(),
          PersonnelApplications(adminId: widget.adminId),
          _buildRequirements(),
          _buildAdvisories(),
        ],
      ),

      // CUSTOM BOTTOM NAVIGATION
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.people_outline,
                  activeIcon: Icons.people,
                  label: 'Personnel',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.folder_outlined,
                  activeIcon: Icons.folder,
                  label: 'Requirements',
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.campaign_outlined,
                  activeIcon: Icons.campaign,
                  label: 'Advisories',
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // HOME DASHBOARD
  Widget _buildHome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome, Administrator!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF183B3A),
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Monitor personnel, vessels, and trip operations.',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 22),

          const Text(
            'Dashboard Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF183B3A),
            ),
          ),

          const SizedBox(height: 12),

          // SMALLER ILLUSTRATED STATISTIC CARDS
          GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 9,
                mainAxisSpacing: 9,
                childAspectRatio: 1.61,
            children: const [
              _DashboardCard(
                title: 'Total Personnel',
                value: '0',
                imagePath:
                    'assets/images/personnel_illustration.png',
                color: Color(0xFF1878D0),
                bottomColor: Color(0xFF1878D0),
              ),

              _DashboardCard(
                title: 'Pending Applications',
                value: '0',
                imagePath:
                    'assets/images/applications_illustration.png',
                color: Color(0xFFF39A18),
                bottomColor: Color(0xFFF39A18),
              ),

              _DashboardCard(
                title: 'Approved Personnel',
                value: '0',
                imagePath:
                    'assets/images/approved_illustration.png',
                color: Color(0xFF079B87),
                bottomColor: Color(0xFF079B87),
              ),

              _DashboardCard(
                title: 'Registered Vessels',
                value: '0',
                imagePath:
                    'assets/images/vessels_illustration.png',
                color: Color(0xFF7450CC),
                bottomColor: Color(0xFF7450CC),
              ),
            ],
          ),

          const SizedBox(height: 26),

          const Text(
            'Quick Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF183B3A),
            ),
          ),

          const SizedBox(height: 12),

          _MenuCard(
            icon: Icons.people_alt_outlined,
            title: 'Personnel Applications',
            subtitle: 'Review and approve personnel accounts',
            onTap: () {
              setState(() {
                selectedIndex = 1;
              });
            },
          ),

          _MenuCard(
            icon: Icons.folder_outlined,
            title: 'Requirements',
            subtitle: 'Review submitted vessel and crew documents',
            onTap: () {
              setState(() {
                selectedIndex = 2;
              });
            },
          ),

          _MenuCard(
            icon: Icons.campaign_outlined,
            title: 'Trip Advisories',
            subtitle: 'Manage vessel trip status updates',
            onTap: () {
              setState(() {
                selectedIndex = 3;
              });
            },
          ),

          const SizedBox(height: 20),

          const Center(
            child: Text(
              'LantsApp • Administrator Panel',
              style: TextStyle(
                color: Colors.black45,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // REQUIREMENTS SECTION
  Widget _buildRequirements() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Requirements Management',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Color(0xFF183B3A),
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Review submitted documents and manage registered vessels.',
            style: TextStyle(color: Colors.black54),
          ),

          const SizedBox(height: 24),

          _MenuCard(
            icon: Icons.directions_boat_outlined,
            title: 'Vessel Requirements',
            subtitle: 'Review CPC, CO, CPR, and safety documents',
            onTap: () {
              showComingSoon('Vessel Requirements');
            },
          ),

          _MenuCard(
            icon: Icons.badge_outlined,
            title: 'Crew Requirements',
            subtitle:
                'Review Patron and Motorman licenses and MBST certificates',
            onTap: () {
              showComingSoon('Crew Requirements');
            },
          ),

          _MenuCard(
            icon: Icons.manage_accounts_outlined,
            title: 'Manage Vessels',
            subtitle: 'View and manage registered vessels',
            onTap: () {
              showComingSoon('Manage Vessels');
            },
          ),
        ],
      ),
    );
  }

  // ADVISORIES SECTION
  Widget _buildAdvisories() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trip Advisories',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Color(0xFF183B3A),
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Monitor and manage trip updates for passengers.',
            style: TextStyle(color: Colors.black54),
          ),

          const SizedBox(height: 24),

          _MenuCard(
            icon: Icons.campaign_outlined,
            title: 'Manage Trip Advisories',
            subtitle: 'Create and update vessel trip announcements',
            onTap: () {
              showComingSoon('Trip Advisories');
            },
          ),
        ],
      ),
    );
  }
}

// ILLUSTRATED DASHBOARD CARD
class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final String imagePath;
  final Color color;
  final Color bottomColor;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.imagePath,
    required this.color,
    required this.bottomColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 9,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // CARTOON ILLUSTRATION BACKGROUND
          Expanded(
            flex: 5,
            child: SizedBox(
              width: double.infinity,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),

          // COLORED STATISTICS SECTION
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              color: bottomColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// MANAGEMENT MENU CARD
class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: Color(0xFFE8EEEE),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 7,
        ),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE5F2EF),
          child: Icon(
            icon,
            color: const Color(0xFF075E54),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 15,
          color: Colors.black45,
        ),
        onTap: onTap,
      ),
    );
  }
}
