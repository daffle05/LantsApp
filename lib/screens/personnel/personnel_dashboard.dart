
import 'package:flutter/material.dart';

class PersonnelDashboard extends StatelessWidget {
  const PersonnelDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FC),
      appBar: AppBar(
        title: const Text('LantsApp - Personnel'),
        backgroundColor: const Color(0xFF1677B8),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_boat,
              size: 70,
              color: Color(0xFF1677B8),
            ),
            SizedBox(height: 15),
            Text(
              'Personnel Dashboard',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Welcome, Boat Personnel!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
