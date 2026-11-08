
import 'package:flutter/material.dart';

class PersonnelDashboard extends StatelessWidget {
  const PersonnelDashboard({super.key});

  static const Color deepOcean = Color(0xFF073B4C);
  static const Color oceanTeal = Color(0xFF0B7285);
  static const Color mint = Color(0xFF80EDC7);
  static const Color backgroundColor = Color(0xFFF7FBFC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: deepOcean,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.directions_boat_filled, color: mint),
            SizedBox(width: 10),
            Text(
              'LantsApp Personnel',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 19,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // WELCOME SECTION
            const Text(
              'Welcome, Personnel!',
              style: TextStyle(
                color: deepOcean,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Manage your vessels, schedules, and trip updates.',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 24),

            // DASHBOARD BANNER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(21),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [oceanTeal, deepOcean],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.directions_boat_filled,
                    color: mint,
                    size: 35,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Your Operations Center',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'Keep passengers informed with updated '
                    'vessel information, schedules, and advisories.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 27),

            // OVERVIEW
            const Text(
              'Overview',
              style: TextStyle(
                color: deepOcean,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: overviewCard(
                    'My Vessels',
                    '0',
                    Icons.directions_boat,
                    oceanTeal,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: overviewCard(
                    'Schedules',
                    '0',
                    Icons.calendar_month,
                    const Color(0xFF269B78),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 27),

            // MANAGEMENT
            const Text(
              'Vessel Management',
              style: TextStyle(
                color: deepOcean,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),

            managementCard(
              context,
              'Manage Vessels',
              'Add and update your vessel information.',
              Icons.directions_boat_filled,
              () {},
            ),

            const SizedBox(height: 13),

            managementCard(
              context,
              'Manage Schedules',
              'Set departure times and destinations.',
              Icons.calendar_month_rounded,
              () {},
            ),

            const SizedBox(height: 27),

            // TRIP MANAGEMENT
            const Text(
              'Trip Management',
              style: TextStyle(
                color: deepOcean,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),

            managementCard(
              context,
              'Update Trip Status',
              'Publish available, delayed, or cancelled trips.',
              Icons.sync_alt_rounded,
              () {},
            ),

            const SizedBox(height: 13),

            managementCard(
              context,
              'Publish Advisories',
              'Inform passengers about important updates.',
              Icons.campaign_outlined,
              () {},
            ),

            const SizedBox(height: 27),

            // GIS MANAGEMENT
            const Text(
              'GIS & Vessel Tracking',
              style: TextStyle(
                color: deepOcean,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),

            managementCard(
              context,
              'Vessel Location',
              'Manage vessel coordinates for map tracking.',
              Icons.location_on_outlined,
              () {},
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

            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  // OVERVIEW CARD
  Widget overviewCard(
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: mint.withOpacity(0.6)),
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
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 13),
          Text(
            count,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: deepOcean,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // MANAGEMENT CARD
  Widget managementCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: mint.withOpacity(0.55)),
            boxShadow: [
              BoxShadow(
                color: deepOcean.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFCAF0E3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: oceanTeal,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: deepOcean,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
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
}
