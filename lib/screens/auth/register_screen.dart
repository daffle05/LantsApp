
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

  // REGISTER ACCOUNT.
  Future<void> register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

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

    // SHOW ERROR MESSAGE.
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // SUCCESS MESSAGE BASED ON ACCOUNT TYPE.
    final message = selectedRole == 'personnel'
        ? 'Your personnel account is pending approval.'
        : 'You can now log in to your account.';

    // SHOW SUCCESS POP-UP.
    
await showDialog(
  context: context,
  barrierDismissible: true,
  builder: (dialogContext) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 310,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF16A085),
                size: 65,
              ),
              const SizedBox(height: 15),
              const Text(
                'Registration Successful!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF075E54),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A085),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(110, 40),
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  },
);


    // GO TO LOGIN AFTER THE POP-UP CLOSES.
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  // REUSABLE INPUT DECORATION.
  InputDecoration inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 13,
        color: Colors.grey,
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF075E54),
        size: 20,
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withOpacity(0.94),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFF16A085),
          width: 1.5,
        ),
      ),
    );
  }

  // REUSABLE FIELD LABEL.
  Widget fieldLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: Colors.white,
        ),
      ),
    );
  }

  // ACCOUNT ROLE SELECTION.
  Widget roleCard({
    required String role,
    required String title,
    required String description,
    required IconData icon,
  }) {
    const primaryColor = Color(0xFF16A085);

    final isSelected = selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = role;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(0.28)
              : Colors.white.withOpacity(0.12),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : Colors.white.withOpacity(0.45),
            width: 1.3,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 25,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: role,
              groupValue: selectedRole,
              activeColor: const Color(0xFF16A085),
              fillColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? const Color(0xFF16A085)
                    : Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  selectedRole = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // VESSEL BACKGROUND.
          Positioned.fill(
            child: Image.asset(
              'assets/images/Lantsapp.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // DARK OVERLAY.
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.30),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 390,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // BACK BUTTON.
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 5),

                        // TRANSPARENT INFORMATION HOLDER.
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF073F3A)
                                .withOpacity(0.68),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.30),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.20),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // CIRCULAR LOGO.
                              Container(
                                height: 78,
                                width: 78,
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.white70,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
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

                              const SizedBox(height: 10),

                              const Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(height: 4),

                              const Text(
                                'Join LantsApp and stay updated on your journey.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white70,
                                ),
                              ),

                              const SizedBox(height: 20),

                              // FULL NAME.
                              fieldLabel('Full Name'),
                              const SizedBox(height: 5),

                              TextFormField(
                                controller: fullNameController,
                                textCapitalization:
                                    TextCapitalization.words,
                                style: const TextStyle(fontSize: 13),
                                decoration: inputDecoration(
                                  hint: 'Enter your full name',
                                  icon: Icons.person_outline,
                                ),
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return 'Please enter your full name.';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 12),

                              // EMAIL.
                              fieldLabel('Email Address'),
                              const SizedBox(height: 5),

                              TextFormField(
                                controller: emailController,
                                keyboardType:
                                    TextInputType.emailAddress,
                                style: const TextStyle(fontSize: 13),
                                decoration: inputDecoration(
                                  hint: 'Enter your email',
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

                              const SizedBox(height: 12),

                              // PASSWORD.
                              fieldLabel('Password'),
                              const SizedBox(height: 5),

                              TextFormField(
                                controller: passwordController,
                                obscureText: hidePassword,
                                style: const TextStyle(fontSize: 13),
                                decoration: inputDecoration(
                                  hint: 'Create a password',
                                  icon: Icons.lock_outline,
                                  suffix: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        hidePassword = !hidePassword;
                                      });
                                    },
                                    icon: Icon(
                                      hidePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      size: 19,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty) {
                                    return 'Please create a password.';
                                  }

                                  if (value.length < 8) {
                                    return 'Password must have at least 8 characters.';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 12),

                              // CONFIRM PASSWORD.
                              fieldLabel('Confirm Password'),
                              const SizedBox(height: 5),

                              TextFormField(
                                controller: confirmPasswordController,
                                obscureText: hideConfirmPassword,
                                style: const TextStyle(fontSize: 13),
                                decoration: inputDecoration(
                                  hint: 'Confirm your password',
                                  icon: Icons.lock_outline,
                                  suffix: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        hideConfirmPassword =
                                            !hideConfirmPassword;
                                      });
                                    },
                                    icon: Icon(
                                      hideConfirmPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      size: 19,
                                    ),
                                  ),
                                ),
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

                              const SizedBox(height: 17),

                              // ACCOUNT TYPE.
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Select Account Type',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 9),

                              roleCard(
                                role: 'passenger',
                                title: 'Passenger',
                                description:
                                    'View boat schedules and trip updates.',
                                icon: Icons.person,
                              ),

                              const SizedBox(height: 9),

                              roleCard(
                                role: 'personnel',
                                title: 'Boat Personnel',
                                description:
                                    'Manage boat trips and schedules.',
                                icon: Icons.directions_boat,
                              ),

                              const SizedBox(height: 20),

                              // CREATE ACCOUNT.
                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: ElevatedButton(
                                  onPressed:
                                      isLoading ? null : register,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFF16A085),
                                    foregroundColor: Colors.white,
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child:
                                              CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'CREATE ACCOUNT',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 15),

                              // LOGIN NAVIGATION.
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Already have an account? ',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Login',
                                      style: TextStyle(
                                        color: Color(0xFF6DE3C4),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 15),

                        const Text(
                          'LantsApp - Your Journey Starts Here',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 5,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
