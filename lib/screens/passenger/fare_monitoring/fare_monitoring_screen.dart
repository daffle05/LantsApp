
import 'package:flutter/material.dart';

class FareMonitoringScreen extends StatelessWidget {
  const FareMonitoringScreen({super.key});

  static const Color midnightTeal = Color(0xFF073B40);
  static const Color oceanTeal = Color(0xFF087EAB);
  static const Color iceMint = Color(0xFFDDF4F1);
  static const Color mutedText = Color(0xFF71817F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: midnightTeal,
          ),
        ),
        title: const Text(
          'Fare Monitoring',
          style: TextStyle(
            color: midnightTeal,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: midnightTeal,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.payments_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                  SizedBox(height: 18),
                  Text(
                    'Monitor Boat Fares',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Check passenger fares and compare available boat routes before traveling.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'Fare Information',
              style: TextStyle(
                color: midnightTeal,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 13),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    color: oceanTeal,
                    size: 48,
                  ),
                  SizedBox(height: 14),
                  Text(
                    'No Fare Records Yet',
                    style: TextStyle(
                      color: midnightTeal,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Registered boat fares will appear here once fare information is available in the system.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: mutedText,
                      fontSize: 12,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: iceMint,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: midnightTeal,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Fare information is intended to help passengers plan their travel. Please verify applicable discounts and current fares with the authorized boat operator.',
                      style: TextStyle(
                        color: midnightTeal,
                        fontSize: 11,
                        height: 1.6,
                      ),
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
}
