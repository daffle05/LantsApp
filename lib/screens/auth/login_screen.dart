
import 'dart:ui';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../admin/admin_dashboard.dart';
import '../passenger/passenger_dashboard.dart';
import '../personnel/personnel_dashboard.dart';
import '../personnel/personnel_requirements_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  static const Color deepTeal = Color(0xFF073B4C);
  static const Color mint = Color(0xFF80EDC7);
  static const Color lightMint = Color(0xFFCAF0E3);

  bool isLoading = false;
  bool hidePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // LOGIN ACCOUNT
  Future<void> login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    final user = await AuthService.login(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AuthService.lastError.isNotEmpty
                ? AuthService.lastError
                : 'Login failed. Please try again.',
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // REDIRECT BASED ON ACCOUNT ROLE
    debugPrint('LOGIN ROLE FROM DATABASE: [${user.role}]');

    switch (user.role.trim().toLowerCase()) {
      case 'passenger':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PassengerDashboard(),
          ),
        );
        break;

      case 'personnel':
        if (user.status.toLowerCase() == 'pending') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PersonnelRequirementsScreen(
                personnelId: user.id,
                fullName: user.fullName,
              ),
            ),
          );
        } else if (user.status.toLowerCase() == 'active') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PersonnelDashboard(
                fullName: user.fullName,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Your account status is ${user.status}. Please contact the administrator.',
              ),
              backgroundColor: Colors.orange.shade800,
            ),
          );
        }
        break;

      case 'admin':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminDashboard(
              adminId: user.id,
            ),
          ),
        );
        break;

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Invalid account role: [${user.role}]',
            ),
            duration: const Duration(seconds: 10),
          ),
        );
    }
  }

  // FROSTED GLASS CONTAINER
  Widget glassContainer({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(20),
    double radius = 23,
    double opacity = 0.19,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 15,
          sigmaY: 15,
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: Colors.white.withOpacity(0.24),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  // FIELD LABEL
  Widget fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  // INPUT DECORATION
  InputDecoration inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.white.withOpacity(0.65),
        fontSize: 16,
      ),
      prefixIcon: Icon(
        icon,
        color: lightMint,
        size: 19,
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withOpacity(0.10),
      contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 20,
        ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.16),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.20),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: mint,
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.3,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepTeal,
      body: Stack(
        children: [
          // BACKGROUND PHOTO
          Positioned.fill(
            child: Image.asset(
              'assets/images/Lantsapp.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // LIGHT OCEAN OVERLAY
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    deepTeal.withOpacity(0.30),
                    const Color(0xFF031F2A).withOpacity(0.62),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // TOP BAR
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    17,
                    5,
                    22,
                    8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'LANTSAPP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 45),
                    ],
                  ),
                ),

                // SCROLLABLE LOGIN CONTENT
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      14,
                      12,
                      14,
                      20,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 600,
                          ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // CIRCULAR LOGO
                              Container(
                                height: 85,
                                width: 85,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.12),
                                  border: Border.all(
                                    color: mint.withOpacity(0.85),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: mint.withOpacity(0.15),
                                      blurRadius: 22,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/lantsapp_logo.jpg',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 17),

                              const Text(
                                'Welcome Back!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 27,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),

                              const SizedBox(height: 7),

                              const Text(
                                'Sign in to continue your journey with LantsApp.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),

                              const SizedBox(height: 26),

                              // GLASS LOGIN CARD
                              glassContainer(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 23,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'WELCOME ABOARD',
                                      style: TextStyle(
                                        color: mint,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.8,
                                      ),
                                    ),

                                    const SizedBox(height: 19),

                                    // EMAIL
                                    fieldLabel('Email Address'),

                                    TextFormField(
                                      controller: emailController,
                                      keyboardType:
                                          TextInputType.emailAddress,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                      ),
                                      decoration: inputDecoration(
                                        hint: 'Enter your email address',
                                        icon: Icons.email_outlined,
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Please enter your email.';
                                        }

                                        if (!RegExp(
                                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                        ).hasMatch(value.trim())) {
                                          return 'Enter a valid email address.';
                                        }

                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 17),

                                    // PASSWORD
                                    fieldLabel('Password'),

                                    TextFormField(
                                      controller: passwordController,
                                      obscureText: hidePassword,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                      decoration: inputDecoration(
                                        hint: 'Enter your password',
                                        icon: Icons.lock_outline_rounded,
                                        suffix: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              hidePassword =
                                                  !hidePassword;
                                            });
                                          },
                                          icon: Icon(
                                            hidePassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            color: lightMint,
                                            size: 19,
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.isEmpty) {
                                          return 'Please enter your password.';
                                        }

                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 25),

                                    // LOGIN BUTTON
                                    SizedBox(
                                      width: double.infinity,
                                      height: 60,
                                      child: ElevatedButton(
                                        onPressed:
                                            isLoading ? null : login,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: mint,
                                          foregroundColor: deepTeal,
                                          disabledBackgroundColor:
                                              mint.withOpacity(0.5),
                                          elevation: 5,
                                          shadowColor:
                                              mint.withOpacity(0.25),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                        ),
                                        child: isLoading
                                            ? const SizedBox(
                                                height: 22,
                                                width: 22,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: deepTeal,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'LOGIN',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: 1.2,
                                                    ),
                                                  ),
                                                  SizedBox(width: 9),
                                                  Icon(
                                                    Icons.arrow_forward_rounded,
                                                    size: 19,
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 23),

                              const Text(
                                "Don't have an account?",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),

                              const SizedBox(height: 10),

                              // FLOATING PILL NAVIGATION
                              ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 12,
                                    sigmaY: 12,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(40),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.30),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: mint,
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: const Text(
                                              'Login',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: deepTeal,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),

                                        Expanded(
                                          child: TextButton(
                                            onPressed: () {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      const RegisterScreen(),
                                                ),
                                              );
                                            },
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 12,
                                              ),
                                            ),
                                            child: const Text(
                                              'Sign Up',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              const Text(
                                'LANTSAPP  •  YOUR SEA TRAVEL COMPANION',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 9,
                                  letterSpacing: 1.3,
                                ),
                              ),

                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
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
