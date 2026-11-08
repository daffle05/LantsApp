
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  static const Color background = Color(0xFF073B4C);
  static const Color gold = Color(0xFF48CAE4);
  static const Color white = Color(0xFFF7FBFC);

  final PageController _pageController = PageController();
  int currentPage = 0;

  // TEMPORARY IMAGES
  // Replace these URLs with your own images later.
  final List<Map<String, String>> slides = [
    {
      'image':
          'assets/images/alex.jpg',
      'title': 'Discover the Sea',
      'description':
          'Explore beautiful sea routes and plan your next journey.',
    },
    {
      'image':
          'assets/images/marisa.jpg',
      'title': 'Know Before You Go',
      'description':
          'Check passenger boat schedules before heading to the port.',
    },
    {
      'image':
          'assets/images/Lantsapp.jpg',
      'title': 'Travel with Confidence',
      'description':
          'Stay updated with trip announcements and travel advisories.',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
                  child: Column(
                    children: [
                      // TOP BRANDING
                      Row(
                        children: [
                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: gold,
                                width: 1.5,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/lantsapp_logo.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'LantsApp',
                            style: TextStyle(
                              color: white,
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 35,
                            height: 2,
                            color: gold,
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      // SMALL INTRODUCTION
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'YOUR JOURNEY STARTS HERE',
                          style: TextStyle(
                            color: gold,
                            fontSize: 10,
                            letterSpacing: 3,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'The sea is calling.',
                          style: TextStyle(
                            color: white,
                            fontSize: 29,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.7,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // SWIPEABLE IMAGE SLIDER
                      SizedBox(
                        height: constraints.maxHeight * 0.47,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: slides.length,
                            onPageChanged: (index) {
                              setState(() {
                                currentPage = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              final slide = slides[index];

                              return Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    slide['image']!,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, progress) {
                                      if (progress == null) return child;

                                      return Container(
                                        color: const Color(0xFF343434),
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            color: gold,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder:
                                        (context, error, stackTrace) {
                                      return Container(
                                        color: const Color(0xFF343434),
                                        child: const Center(
                                          child: Icon(
                                            Icons.image_not_supported_outlined,
                                            color: gold,
                                            size: 45,
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                                  // DARK IMAGE OVERLAY
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.75),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // IMAGE TEXT
                                  Positioned(
                                    left: 22,
                                    right: 22,
                                    bottom: 25,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 3,
                                          width: 40,
                                          color: gold,
                                        ),
                                        const SizedBox(height: 13),
                                        Text(
                                          slide['title']!,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          slide['description']!,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // SLIDE NUMBER
                                  Positioned(
                                    top: 18,
                                    right: 18,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 7,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.4),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        border: Border.all(
                                          color: gold.withOpacity(0.7),
                                        ),
                                      ),
                                      child: Text(
                                        '0${index + 1} / 03',
                                        style: const TextStyle(
                                          color: white,
                                          fontSize: 10,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // PAGE INDICATORS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          slides.length,
                          (index) {
                            final isActive = currentPage == index;

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              height: 5,
                              width: isActive ? 27 : 7,
                              decoration: BoxDecoration(
                                color: isActive ? gold : Colors.white30,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 25),

                      // WOOD-INSPIRED DECORATIVE ACCENT
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: gold.withOpacity(0.5),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(
                              Icons.waves_rounded,
                              color: gold,
                              size: 20,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: gold.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 23),

                      // LOGIN BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: white,
                            foregroundColor: background,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 13),

                      // SIGN UP BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: white,
                            side: BorderSide(
                              color: gold.withOpacity(0.8),
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        'PLAN YOUR JOURNEY WITH LANTSAPP',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 9,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
