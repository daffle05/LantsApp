
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController =
      TextEditingController();
  final TextEditingController emailController =
      TextEditingController();
  final TextEditingController passwordController =
      TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  static const Color deepTeal = Color(0xFF073B4C);
  static const Color teal = Color(0xFF0B7285);
  static const Color mint = Color(0xFF80EDC7);
  static const Color lightMint = Color(0xFFCAF0E3);

  String selectedRole = 'passenger';

  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // REGISTER ACCOUNT
  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    final error = await AuthService.register(
      fullName: fullNameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text,
      role: selectedRole,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final message = selectedRole == 'personnel'
        ? 'Your personnel account is pending approval.'
        : 'You can now log in to your account.';

    // SUCCESS DIALOG
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 15,
                sigmaY: 15,
              ),
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B4855)
                      .withOpacity(0.96),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: mint.withOpacity(0.5),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: mint,
                      size: 65,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Registration Successful!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 22),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mint,
                        foregroundColor: deepTeal,
                        minimumSize: const Size(120, 43),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  // FROSTED GLASS CONTAINER
  Widget glassContainer({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
    double radius = 18,
    double opacity = 0.15,
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
              color: Colors.white.withOpacity(0.22),
              width: 1,
            ),
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
            fontSize: 12,
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
        fontSize: 12,
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
        horizontal: 14,
        vertical: 13,
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

  // ACCOUNT TYPE SELECTION
  Widget roleCard({
    required String role,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final isSelected = selectedRole == role;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedRole = role;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? teal.withOpacity(0.18)
                : Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? teal
                  : Colors.white.withOpacity(0.2),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 25,
                color: isSelected ? mint : Colors.white70,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? mint : Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 9,
                  height: 1.4,
                  color: Colors.white60,
                ),
              ),
              const SizedBox(height: 8),
              Icon(
                isSelected
                    ? Icons.check_circle
                    : Icons.circle_outlined,
                color: isSelected ? mint : Colors.white38,
                size: 17,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // REUSABLE PASSWORD FIELD
  Widget passwordField({
    required String label,
    required TextEditingController controller,
    required bool hidden,
    required VoidCallback toggle,
    required String hint,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        fieldLabel(label),
        TextFormField(
          controller: controller,
          obscureText: hidden,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
          ),
          decoration: inputDecoration(
            hint: hint,
            icon: Icons.lock_outline_rounded,
            suffix: IconButton(
              onPressed: toggle,
              icon: Icon(
                hidden
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: lightMint,
                size: 19,
              ),
            ),
          ),
          validator: validator,
        ),
      ],
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

          // LIGHTER OCEAN OVERLAY
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    deepTeal.withOpacity(0.30),
                    const Color(0xFF031F2A)
                        .withOpacity(0.62),
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
                        onPressed: () => Navigator.pop(context),
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

                // SCROLLABLE CONTENT
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      14,
                      8,
                      14,
                      20,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 500,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // LOGO
                              Container(
                                height: 75,
                                width: 75,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.12),
                                  border: Border.all(
                                    color: mint.withOpacity(0.8),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: mint.withOpacity(0.12),
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

                              const SizedBox(height: 13),

                              const Text(
                                'Create Your Account',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),

                              const SizedBox(height: 6),

                              const Text(
                                'Your next sea journey starts here.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),

                              const SizedBox(height: 20),

                              // WIDE GLASS FORM CARD
                              glassContainer(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 17,
                                ),
                                radius: 23,
                                opacity: 0.19,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'PERSONAL INFORMATION',
                                      style: TextStyle(
                                        color: mint,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.8,
                                      ),
                                    ),

                                    const SizedBox(height: 14),

                                    // FULL NAME
                                    fieldLabel('Full Name'),
                                    TextFormField(
                                      controller: fullNameController,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                      decoration: inputDecoration(
                                        hint: 'Enter your full name',
                                        icon: Icons.person_outline_rounded,
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Please enter your full name.';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 10),

                                    // EMAIL
                                    fieldLabel('Email Address'),
                                    TextFormField(
                                      controller: emailController,
                                      keyboardType:
                                          TextInputType.emailAddress,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
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

                                    const SizedBox(height: 10),

                                    // PASSWORD
                                    passwordField(
                                      label: 'Password',
                                      controller: passwordController,
                                      hidden: hidePassword,
                                      toggle: () {
                                        setState(() {
                                          hidePassword = !hidePassword;
                                        });
                                      },
                                      hint: 'Create a password',
                                      validator: (value) {
                                        if (value == null ||
                                            value.isEmpty) {
                                          return 'Please create a password.';
                                        }
                                        if (value.length < 8) {
                                          return 'Use at least 8 characters.';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 10),

                                    // CONFIRM PASSWORD
                                    passwordField(
                                      label: 'Confirm Password',
                                      controller:
                                          confirmPasswordController,
                                      hidden: hideConfirmPassword,
                                      toggle: () {
                                        setState(() {
                                          hideConfirmPassword =
                                              !hideConfirmPassword;
                                        });
                                      },
                                      hint: 'Enter your password again',
                                      validator: (value) {
                                        if (value == null ||
                                            value.isEmpty) {
                                          return 'Please confirm your password.';
                                        }
                                        if (value != passwordController.text) {
                                          return 'Passwords do not match.';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 19),

                                    // ACCOUNT TYPE
                                    const Text(
                                      'CHOOSE ACCOUNT TYPE',
                                      style: TextStyle(
                                        color: mint,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.8,
                                      ),
                                    ),

                                    const SizedBox(height: 11),

                                    Row(
                                      children: [
                                        roleCard(
                                          role: 'passenger',
                                          title: 'Passenger',
                                          description:
                                              'View schedules and trip updates',
                                          icon: Icons.person_outline_rounded,
                                        ),
                                        const SizedBox(width: 11),
                                        roleCard(
                                          role: 'personnel',
                                          title: 'Personnel',
                                          description:
                                              'Manage vessels and trips',
                                          icon: Icons.directions_boat_outlined,
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 19),

                                    // CREATE ACCOUNT
                                    SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed:
                                            isLoading ? null : register,
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
                                                    'CREATE ACCOUNT',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: 1,
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

                              const SizedBox(height: 17),

                              const Text(
                                'Already have an account?',
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
                                          child: TextButton(
                                            onPressed: () {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      const LoginScreen(),
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
                                              'Login',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
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
                                              'Sign Up',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: deepTeal,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 18),

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
