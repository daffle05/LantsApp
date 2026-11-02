
import 'package:flutter/material.dart';
import 'screens/auth/welcome_screen.dart';

void main() {
  runApp(const LantsApp());
}

class LantsApp extends StatelessWidget {
  const LantsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LantsApp',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1677B8),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}
