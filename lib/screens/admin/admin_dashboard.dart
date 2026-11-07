
import 'package:flutter/material.dart';
import 'personnel_applications.dart';

class AdminDashboard extends StatelessWidget {
  final int adminId;

  const AdminDashboard({
    super.key,
    required this.adminId,
  });
  

  static const Color primaryColor = Color(0xFF075E54);
  static const Color backgroundColor = Color(0xFFF4F7F8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            Icon(Icons.directions_boat_filled),
            SizedBox(width: 10),
            Text(
              'LantsApp Admin',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Notifications will be added later.
            },
            icon: const Icon(Icons.notifications_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
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
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),

            const Text(
              'Dashboard Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: const [
                _DashboardCard(
                  title: 'Total Personnel',
                  value: '0',
                  icon: Icons.people_alt_outlined,
                  color: Colors.blue,
                ),
                _DashboardCard(
                  title: 'Pending Applications',
                  value: '0',
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                ),
                _DashboardCard(
                  title: 'Approved Personnel',
                  value: '0',
                  icon: Icons.verified_user_outlined,
                  color: Colors.green,
                ),
                _DashboardCard(
                  title: 'Registered Vessels',
                  value: '0',
                  icon: Icons.directions_boat_outlined,
                  color: Colors.teal,
                ),
              ],
            ),

            const SizedBox(height: 28),
            const Text(
              'Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),

            _MenuCard(
  icon: Icons.people_alt_outlined,
  title: 'Personnel Applications',
  subtitle: 'Review and approve personnel accounts',
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonnelApplications(
  adminId: adminId,
)
      ),
    );
  },
),
            _MenuCard(
              icon: Icons.description_outlined,
              title: 'Vessel Requirements',
              subtitle: 'Review CPC, CO, CPR, and safety documents',
              onTap: () {},
            ),
            _MenuCard(
              icon: Icons.badge_outlined,
              title: 'Crew Requirements',
              subtitle: 'Review crew licenses and MBST certificates',
              onTap: () {},
            ),
            _MenuCard(
              icon: Icons.directions_boat_outlined,
              title: 'Manage Vessels',
              subtitle: 'View and manage registered vessels',
              onTap: () {},
            ),
            _MenuCard(
              icon: Icons.campaign_outlined,
              title: 'Trip Advisories',
              subtitle: 'Monitor trip schedules and status updates',
              onTap: () {},
            ),

            const SizedBox(height: 24),
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
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Text(
            value,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

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
        side: const BorderSide(color: Color(0xFFE8EEEE)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 7,
        ),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE5F2EF),
          child: Icon(icon, color: const Color(0xFF075E54)),
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
