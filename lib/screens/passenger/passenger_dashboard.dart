
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'boat_map_screen.dart';
import '../auth/login_screen.dart';

class PassengerDashboard extends StatefulWidget {
  const PassengerDashboard({super.key});

  @override
  State<PassengerDashboard> createState() => _PassengerDashboardState();
}

class _PassengerDashboardState extends State<PassengerDashboard> {
  int selectedIndex = 0;
  int selectedExploreIndex = -1;
  int selectedCategoryIndex = 0;

  static const Color oceanTeal = Color(0xFF087EAB);
  static const Color midnightTeal = Color(0xFF073B40);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color iceMint = Color(0xFFDDF4F1);
  static const Color softBackground = Color(0xFFF5F9F8);
  static const Color mutedText = Color(0xFF71817F);

  final TextEditingController searchController = TextEditingController();
  final List<Map<String, dynamic>> registeredVessels = [];

final List<Map<String, dynamic>> advisories = [];

final List<Map<String, dynamic>> passengerFares = [];

bool isLoadingFares = false;
bool hasCalculatedFare = false;
String? fareError;

String? selectedVesselId;
String? selectedFareRouteId;
String? selectedPassengerType;

int passengerCount = 1;
bool isLoadingAdvisories = false;
String? advisoryError;
  bool isLoadingVessels = false;
  String? vesselError;

  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost/lantsapp_api';
    }
    return 'http://10.0.2.2/lantsapp_api';
  }

 @override
    void initState() {
      super.initState();
      fetchRegisteredVessels();
      fetchPassengerAdvisories();
      fetchPassengerFares();
    }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchRegisteredVessels() async {
    if (!mounted) return;

    setState(() {
      isLoadingVessels = true;
      vesselError = null;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_registered_vessels.php'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final List<dynamic> vessels = data['vessels'] ?? [];

          if (!mounted) return;

          setState(() {
            registeredVessels.clear();
            registeredVessels.addAll(
              vessels.map(
                (vessel) => Map<String, dynamic>.from(vessel),
              ),
            );
            isLoadingVessels = false;
          });
        } else {
          throw Exception(
            data['message'] ?? 'Unable to retrieve vessels.',
          );
        }
      } else {
        throw Exception(
          'Server returned status ${response.statusCode}.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingVessels = false;
        vesselError = e.toString();
      });
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: midnightTeal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pureWhite,
      body: SafeArea(
        child: IndexedStack(
          index: selectedIndex,
          children: [
  homePage(),
  const BoatMapScreen(),
  advisoriesPage(),
  fareMonitoringPage(),
],
        ),
      ),
      bottomNavigationBar: bottomNavigation(),
    );
  }
  
Future<void> fetchPassengerFares() async {
  if (!mounted) return;

  setState(() {
    isLoadingFares = true;
    fareError = null;
  });

  try {
    final response = await http.get(
      Uri.parse('$baseUrl/get_passenger_fare_options.php'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Server returned status ${response.statusCode}.',
      );
    }

    final data = jsonDecode(response.body);

    if (data['success'] != true) {
      throw Exception(
        data['message'] ?? 'Unable to retrieve fare options.',
      );
    }

    final List<dynamic> fetchedFares =
        data['fare_options'] ?? [];

    if (!mounted) return;

    setState(() {
      passengerFares.clear();

      passengerFares.addAll(
        fetchedFares.map(
          (item) => Map<String, dynamic>.from(item),
        ),
      );

      isLoadingFares = false;
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      isLoadingFares = false;
      fareError = e.toString();
    });
  }
}


  Future<void> fetchPassengerAdvisories() async {
  if (!mounted) return;

  setState(() {
    isLoadingAdvisories = true;
    advisoryError = null;
  });

  try {
    final response = await http.get(
      Uri.parse('$baseUrl/get_passenger_advisories.php'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        final List<dynamic> fetchedAdvisories =
            data['advisories'] ?? [];

        if (!mounted) return;

        setState(() {
          advisories.clear();
          advisories.addAll(
            fetchedAdvisories.map(
              (item) => Map<String, dynamic>.from(item),
            ),
          );

          isLoadingAdvisories = false;
        });
      } else {
        throw Exception(
          data['message'] ?? 'Unable to retrieve advisories.',
        );
      }
    } else {
      throw Exception(
        'Server returned status ${response.statusCode}.',
      );
    }
  } catch (e) {
    if (!mounted) return;

    setState(() {
      isLoadingAdvisories = false;
      advisoryError = e.toString();
    });
  }
}
IconData getAdvisoryIcon(String type) {
  switch (type.toLowerCase()) {
    case 'weather':
      return Icons.cloud_rounded;
    case 'delay':
      return Icons.access_time_rounded;
    case 'cancellation':
      return Icons.cancel_rounded;
    case 'suspension':
      return Icons.warning_amber_rounded;
    default:
      return Icons.campaign_rounded;
  }
}

Color getAdvisoryColor(String type) {
  switch (type.toLowerCase()) {
    case 'weather':
      return const Color(0xFF3979B9);
    case 'delay':
      return const Color(0xFFD18A28);
    case 'cancellation':
      return const Color(0xFFC94C4C);
    case 'suspension':
      return const Color(0xFFAD781C);
    default:
      return oceanTeal;
  }
}

String formatAdvisoryDate(dynamic dateValue) {
  if (dateValue == null) {
    return 'Date unavailable';
  }

  final parsedDate = DateTime.tryParse(dateValue.toString());

  if (parsedDate == null) {
    return dateValue.toString();
  }

  final date = parsedDate.toLocal();

  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  final hour = date.hour == 0
      ? 12
      : date.hour > 12
          ? date.hour - 12
          : date.hour;

  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour >= 12 ? 'PM' : 'AM';

  return '${months[date.month - 1]} ${date.day}, ${date.year} • $hour:$minute $period';
}


  // BOTTOM NAVIGATION

  Widget bottomNavigation() {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 8, 18, 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: pureWhite,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: midnightTeal.withOpacity(0.13),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            navItem(Icons.home_rounded, 'Home', 0),
            navItem(Icons.map_rounded, 'Routes', 1),
            navItem(Icons.campaign_rounded, 'Advisories', 2),
          ],
        ),
      ),
    );
  }

  Widget navItem(IconData icon, String label, int index) {
    final bool isSelected = selectedIndex == index;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                height: 43,
                width: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? midnightTeal : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 23,
                  color: isSelected ? pureWhite : mutedText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      isSelected ? FontWeight.w800 : FontWeight.w500,
                  color: isSelected ? midnightTeal : mutedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // REDESIGNED HOME PAGE

  Widget homePage() {
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          homeHeader(),
          Container(
            width: double.infinity,
            color: pureWhite,
            padding: const EdgeInsets.fromLTRB(20, 25, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                sectionHeading('Recommended for You'),
                const SizedBox(height: 14),
                recommendedVesselsSection(),
                const SizedBox(height: 28),
                sectionHeading('Explore Boat Routes'),
                const SizedBox(height: 13),
                routePreview(),
                const SizedBox(height: 28),
                sectionHeading('Latest Advisories'),
                const SizedBox(height: 13),
                advisoryPreview(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // IMAGE HEADER

  Widget homeHeader() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(38),
        bottomRight: Radius.circular(38),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/infobg.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: midnightTeal);
                },
              ),
            ),
            Positioned.fill(
              child: Container(
                color: const Color(0xFF064B59).withOpacity(0.72),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 27),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipOval(
                        child: SizedBox(
                          width: 43,
                          height: 43,
                          child: Image.asset(
                            'assets/images/lantsapp_logo.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: pureWhite,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.directions_boat_filled_rounded,
                                  color: oceanTeal,
                                  size: 25,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'LantsApp',
                          style: TextStyle(
                            color: pureWhite,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const PassengerProfilePage(),
                            ),
                          );
                        },
                        child: Container(
                          width: 43,
                          height: 43,
                          decoration: BoxDecoration(
                            color: pureWhite.withOpacity(0.95),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: midnightTeal,
                            size: 25,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Explore LantsApp',
                    style: TextStyle(
                      color: pureWhite,
                      fontSize: 29,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Discover routes, schedules, and travel updates.',
                    style: TextStyle(
                      color: pureWhite.withOpacity(0.88),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  headerSearchBar(),
                  const SizedBox(height: 25),
                  exploreLantsAppSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HEADER SEARCH BAR

  Widget headerSearchBar() {
    return Container(
      height: 49,
      decoration: BoxDecoration(
        color: pureWhite.withOpacity(0.18),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: pureWhite.withOpacity(0.55),
          width: 1,
        ),
      ),
      child: TextField(
        controller: searchController,
        style: const TextStyle(
          color: pureWhite,
          fontSize: 13,
        ),
        cursorColor: pureWhite,
        onChanged: (value) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Search vessels or destinations',
          hintStyle: TextStyle(
            color: pureWhite.withOpacity(0.85),
            fontSize: 12,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: pureWhite,
            size: 21,
          ),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    searchController.clear();
                    setState(() {});
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    color: pureWhite,
                    size: 18,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  // FOUR CIRCULAR EXPLORE ICONS

  Widget exploreLantsAppSection() {
    final List<Map<String, dynamic>> items = [
      {
        'title': 'Vessels',
        'icon': Icons.directions_boat_filled_rounded,
        'action': () {
          showMessage('Vessel directory will be available here.');
        },
      },
      {
        'title': 'Schedules',
        'icon': Icons.calendar_month_rounded,
        'action': () {
          setState(() => selectedIndex = 1);
        },
      },
      {
        'title': 'No-Trip',
        'icon': Icons.event_busy_rounded,
        'action': () {
          setState(() => selectedIndex = 2);
        },
      },
      {
  'title': 'Fare',
  'icon': Icons.payments_outlined,
  'action': () {
    setState(() {
      selectedIndex = 3;
    });
  },
},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(items.length, (index) {
        final bool isSelected = selectedExploreIndex == index;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedExploreIndex = index;
            });

            (items[index]['action'] as VoidCallback)();
          },
          child: SizedBox(
            width: 70,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 59,
                  height: 59,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFBDEBE8)
                        : pureWhite,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF8BE5DF)
                          : pureWhite,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.20),
                        blurRadius: isSelected ? 15 : 9,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    items[index]['icon'] as IconData,
                    size: 26,
                    color: midnightTeal,
                    shadows: const [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(2, 3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  items[index]['title'] as String,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: pureWhite,
                    fontSize: 10,
                    fontWeight: isSelected
                        ? FontWeight.w900
                        : FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // CATEGORY TABS

  Widget categoryTabs() {
    const categories = [
      'All',
      'Popular',
      'Routes',
      'Updates',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(categories.length, (index) {
          final bool isSelected = selectedCategoryIndex == index;

          return Padding(
            padding: const EdgeInsets.only(right: 9),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategoryIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? midnightTeal : softBackground,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  categories[index],
                  style: TextStyle(
                    color: isSelected ? pureWhite : mutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // TWO-COLUMN INFORMATION GRID

  Widget informationGrid() {
    final List<Map<String, dynamic>> cards = [
      {
        'title': 'Registered Vessels',
        'description': 'Explore passenger boats',
        'icon': Icons.directions_boat_filled_rounded,
        'category': 'Popular',
        'action': () {
          showMessage('Explore registered vessels below.');
        },
      },
      {
        'title': 'Boat Routes',
        'description': 'Discover available routes',
        'icon': Icons.alt_route_rounded,
        'category': 'Routes',
        'action': () {
          setState(() => selectedIndex = 1);
        },
      },
      {
        'title': 'Trip Schedules',
        'description': 'Check departure information',
        'icon': Icons.calendar_month_rounded,
        'category': 'Popular',
        'action': () {
          showMessage('Check the schedules in vessel details.');
        },
      },
      {
        'title': 'Travel Advisories',
        'description': 'Read important trip updates',
        'icon': Icons.campaign_rounded,
        'category': 'Updates',
        'action': () {
          setState(() => selectedIndex = 2);
        },
      },
    ];

    final filteredCards = selectedCategoryIndex == 0
        ? cards
        : cards.where((card) {
            const categories = [
              'All',
              'Popular',
              'Routes',
              'Updates',
            ];
            return card['category'] ==
                categories[selectedCategoryIndex];
          }).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredCards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 13,
        mainAxisSpacing: 13,
        childAspectRatio: 1.12,
      ),
      itemBuilder: (context, index) {
        final card = filteredCards[index];

        return Material(
          color: const Color(0xFFF4F8F7),
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: card['action'] as VoidCallback,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 47,
                    height: 47,
                    decoration: const BoxDecoration(
                      color: iceMint,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      card['icon'] as IconData,
                      color: oceanTeal,
                      size: 24,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card['title'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: midnightTeal,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        card['description'] as String,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: mutedText,
                          fontSize: 10,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // SECTION HEADING

  Widget sectionHeading(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: midnightTeal,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  // RECOMMENDED VESSELS

  Widget recommendedVesselsSection() {
    final query = searchController.text.trim().toLowerCase();

    final filteredVessels = registeredVessels.where((vessel) {
      final name =
          (vessel['vessel_name'] ?? '').toString().toLowerCase();
      final route =
          (vessel['route'] ?? '').toString().toLowerCase();
      final type =
          (vessel['vessel_type'] ?? '').toString().toLowerCase();

      return name.contains(query) ||
          route.contains(query) ||
          type.contains(query);
    }).toList();

    if (isLoadingVessels) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(25),
          child: CircularProgressIndicator(color: oceanTeal),
        ),
      );
    }

    if (vesselError != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: pureWhite,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: mutedText,
              size: 35,
            ),
            const SizedBox(height: 10),
            const Text(
              'Unable to load registered vessels.',
              style: TextStyle(
                color: midnightTeal,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: fetchRegisteredVessels,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (filteredVessels.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: pureWhite,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.directions_boat_outlined,
              color: mutedText,
              size: 42,
            ),
            const SizedBox(height: 10),
            Text(
              query.isEmpty
                  ? 'No registered vessels available yet.'
                  : 'No matching vessels found.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: mutedText,
                fontSize: 13,
              ),
            ),
            if (query.isEmpty) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: fetchRegisteredVessels,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ],
        ),
      );
    }

    return SizedBox(
      height: 235,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filteredVessels.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final vessel = filteredVessels[index];

          final vesselName =
              (vessel['vessel_name'] ?? 'Unnamed Vessel').toString();
          final route =
              (vessel['route'] ?? 'Route not provided').toString();
          final capacity =
              (vessel['passenger_capacity'] ?? 'N/A').toString();

          return Container(
            decoration: BoxDecoration(
              color: pureWhite,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: midnightTeal.withOpacity(0.12),
                  blurRadius: 18,
                  spreadRadius: 1,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: pureWhite,
              borderRadius: BorderRadius.circular(18),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SampleVesselDetailsPage(vessel: vessel),
                    ),
                  );
                },
                child: SizedBox(
                  width: 205,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 125,
                        width: double.infinity,
                        color: iceMint,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.directions_boat_filled_rounded,
                          color: midnightTeal,
                          size: 55,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vesselName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: midnightTeal,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  color: oceanTeal,
                                  size: 15,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    route,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: mutedText,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '$capacity Passengers',
                              style: const TextStyle(
                                color: mutedText,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ROUTE PREVIEW

  Widget routePreview() {
    return Container(
      decoration: BoxDecoration(
        color: iceMint,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: midnightTeal.withOpacity(0.12),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: iceMint,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            setState(() => selectedIndex = 1);
          },
          child: SizedBox(
            height: 155,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned(
                  top: 18,
                  left: 28,
                  child: Icon(
                    Icons.location_on_rounded,
                    color: oceanTeal.withOpacity(0.85),
                    size: 32,
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 35,
                  child: Icon(
                    Icons.location_on_rounded,
                    color: midnightTeal.withOpacity(0.9),
                    size: 32,
                  ),
                ),
                const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map_outlined,
                        color: midnightTeal,
                        size: 39,
                      ),
                      SizedBox(height: 7),
                      Text(
                        'Explore Boat Routes',
                        style: TextStyle(
                          color: midnightTeal,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'View ports and passenger boat routes',
                        style: TextStyle(
                          color: mutedText,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ADVISORY PREVIEW

  Widget advisoryPreview() {
  if (isLoadingAdvisories) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: pureWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: iceMint),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  if (advisoryError != null) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: pureWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: iceMint),
      ),
      child: Column(
        children: [
          const Text('Unable to load advisories.'),
          const SizedBox(height: 8),
          TextButton(
            onPressed: fetchPassengerAdvisories,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  if (advisories.isEmpty) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: pureWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: iceMint),
      ),
      child: const Text(
        'No active trip advisories at the moment.',
        textAlign: TextAlign.center,
        style: TextStyle(color: mutedText),
      ),
    );
  }

  final advisory = advisories.first;

  final type = advisory['advisory_type']?.toString() ?? 'General';
  final title = advisory['title']?.toString() ?? 'Trip Advisory';
  final message = advisory['message']?.toString() ?? '';
  final vessel = advisory['vessel_name']?.toString() ?? 'Passenger Vessel';

  final color = getAdvisoryColor(type);

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: pureWhite,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: iceMint),
      boxShadow: [
        BoxShadow(
          color: midnightTeal.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                getAdvisoryIcon(type),
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type.toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      color: midnightTeal,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          message,
          style: const TextStyle(
            color: mutedText,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Vessel: $vessel',
          style: const TextStyle(
            color: midnightTeal,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          formatAdvisoryDate(advisory['created_at']),
          style: const TextStyle(
            color: mutedText,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              setState(() {
                selectedIndex = 2;
              });
            },
            child: const Text('View All Advisories'),
          ),
        ),
      ],
    ),
  );
}

  // ADVISORIES PAGE


// FARE MONITORING PAGE



Widget fareMonitoringPage() {
  // Only show vessels with active fare records.
  final availableVessels = registeredVessels.where((vessel) {
    final vesselId = vessel['id'].toString();

    return passengerFares.any(
      (fare) => fare['vessel_id'].toString() == vesselId,
    );
  }).toList();

  final currentVesselId = availableVessels.any(
    (vessel) => vessel['id'].toString() == selectedVesselId,
  )
      ? selectedVesselId
      : null;

  // Get fares for the selected vessel.
  final vesselFares = currentVesselId == null
      ? <Map<String, dynamic>>[]
      : passengerFares.where((fare) {
          return fare['vessel_id'].toString() == currentVesselId;
        }).toList();

  // Get unique routes.
  final Map<String, Map<String, dynamic>> routeMap = {};

  for (final fare in vesselFares) {
    final routeId = fare['route_id'].toString();
    routeMap.putIfAbsent(routeId, () => fare);
  }

  final routeEntries = routeMap.entries.toList();

  final currentRouteId = routeMap.containsKey(selectedFareRouteId)
      ? selectedFareRouteId
      : null;

  // Get passenger types for the selected route.
  final selectedRouteFares = currentRouteId == null
      ? <Map<String, dynamic>>[]
      : vesselFares.where((fare) {
          return fare['route_id'].toString() == currentRouteId;
        }).toList();

  final passengerTypes = selectedRouteFares
      .map((fare) => fare['passenger_type'].toString())
      .toSet()
      .toList();

  final currentPassengerType =
      passengerTypes.contains(selectedPassengerType)
          ? selectedPassengerType
          : null;

  // Find the selected fare.
  Map<String, dynamic>? selectedFare;

  if (hasCalculatedFare &&
      currentRouteId != null &&
      currentPassengerType != null) {
    for (final fare in selectedRouteFares) {
      if (fare['passenger_type'].toString() ==
          currentPassengerType) {
        selectedFare = fare;
        break;
      }
    }
  }

  final fareAmount = selectedFare == null
      ? 0.0
      : double.tryParse(
            selectedFare['fare_amount'].toString(),
          ) ??
          0.0;

  final totalFare = fareAmount * passengerCount;

  // Reusable input decoration.
  InputDecoration fareInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: mutedText,
        fontSize: 13,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 16,
      ),
      filled: true,
      fillColor: pureWhite,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Color(0xFFE1ECEA),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: oceanTeal,
          width: 1.3,
        ),
      ),
    );
  }

  Widget sectionLabel(String number, String label) {
    return Row(
      children: [
        Container(
          width: 25,
          height: 25,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: iceMint,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: midnightTeal,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 9),
        Text(
          label,
          style: const TextStyle(
            color: midnightTeal,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  return Scaffold(
    backgroundColor: softBackground,

    body: SafeArea(
      child: RefreshIndicator(
        color: oceanTeal,
        onRefresh: () async {
          await fetchRegisteredVessels();
          await fetchPassengerFares();
        },

        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // HEADER IMAGE
            SliverToBoxAdapter(
              child: SizedBox(
                height: 225,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/infobg.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF087EAB),
                                Color(0xFF073B40),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        );
                      },
                    ),

                    // Dark overlay.
                    Container(
                      color: Colors.black.withOpacity(0.30),
                    ),

                    // Header controls.
                    Positioned(
                      top: 10,
                      left: 12,
                      right: 12,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                selectedIndex = 0;
                              });
                            },
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: pureWhite,
                              size: 25,
                            ),
                          ),

                          const Spacer(),

                          IconButton(
                            onPressed: isLoadingFares || isLoadingVessels
                                ? null
                                : () async {
                                    await fetchRegisteredVessels();
                                    await fetchPassengerFares();
                                  },
                            icon: const Icon(
                              Icons.refresh_rounded,
                              color: pureWhite,
                              size: 23,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Centered title.
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 35),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'fare calculator',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: pureWhite,
                                fontSize: 27,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Know your estimated boat fare',
                              style: TextStyle(
                                color: pureWhite,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // MAIN WHITE FORM CARD
            SliverToBoxAdapter(
              child: Transform.translate(
  offset: const Offset(0, -45),
                child: Container(
  width: double.infinity,

  margin: const EdgeInsets.symmetric(horizontal: 15),

  padding: const EdgeInsets.fromLTRB(
    22,
    30,
    22,
    30,
  ),

  decoration: BoxDecoration(
    color: pureWhite,

    borderRadius: BorderRadius.circular(28),

    boxShadow: [
      BoxShadow(
        color: midnightTeal.withOpacity(0.13),
        blurRadius: 25,
        spreadRadius: 1,
        offset: const Offset(0, 10),
      ),
    ],
  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Calculate your trip',
                        style: TextStyle(
                          color: midnightTeal,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        'Enter your travel information below to estimate your total fare.',
                        style: TextStyle(
                          color: mutedText,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 25),

                      // LOADING
                      if (isLoadingFares || isLoadingVessels)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(35),
                            child: CircularProgressIndicator(
                              color: oceanTeal,
                            ),
                          ),
                        )

                      // ERROR
                      else if (fareError != null || vesselError != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: softBackground,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.wifi_off_rounded,
                                color: mutedText,
                                size: 38,
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Unable to load fare information.',
                                style: TextStyle(
                                  color: midnightTeal,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () async {
                                  await fetchRegisteredVessels();
                                  await fetchPassengerFares();
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Try Again'),
                              ),
                            ],
                          ),
                        )

                      // NO AVAILABLE VESSELS
                      else if (availableVessels.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: softBackground,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.directions_boat_outlined,
                                color: mutedText,
                                size: 43,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'No Fare Options Available',
                                style: TextStyle(
                                  color: midnightTeal,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'There are currently no registered vessels with active fare records.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: mutedText,
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        )

                      // FARE FORM
                      else ...[
                        // 1. VESSEL
                        sectionLabel(
                          '1',
                          'SELECTED REGISTERED VESSELS',
                        ),

                        const SizedBox(height: 11),

                        DropdownButtonFormField<String>(
                          value: currentVesselId,
                          isExpanded: true,
                          decoration: fareInputDecoration(
                            'Choose a vessel',
                          ),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: oceanTeal,
                          ),
                          items: availableVessels.map((vessel) {
                            final id = vessel['id'].toString();

                            return DropdownMenuItem<String>(
                              value: id,
                              child: Text(
                                vessel['vessel_name']?.toString() ??
                                    'Unnamed Vessel',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: midnightTeal,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedVesselId = value;
                              selectedFareRouteId = null;
                              selectedPassengerType = null;
                              passengerCount = 1;
                              hasCalculatedFare = false;
                            });
                          },
                        ),

                        if (currentVesselId != null) ...[
                          const SizedBox(height: 10),

                          Builder(
                            builder: (context) {
                              final vessel = availableVessels.firstWhere(
                                (item) =>
                                    item['id'].toString() ==
                                    currentVesselId,
                              );

                              final ownerName =
                                  vessel['owner_name']?.toString() ??
                                      'Registered Personnel';

                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: iceMint,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.person_outline_rounded,
                                      color: oceanTeal,
                                      size: 19,
                                    ),
                                    const SizedBox(width: 9),
                                    Expanded(
                                      child: Text(
                                        'Registered by: $ownerName',
                                        style: const TextStyle(
                                          color: midnightTeal,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],

                        const SizedBox(height: 23),

                        // 2. ROUTE
                        sectionLabel(
                          '2',
                          'SELECT ROUTE',
                        ),

                        const SizedBox(height: 11),

                        DropdownButtonFormField<String>(
                          value: currentRouteId,
                          isExpanded: true,
                          decoration: fareInputDecoration(
                            'Choose your route',
                          ),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: oceanTeal,
                          ),
                          items: routeEntries.map((entry) {
                            final route = entry.value;

                            return DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(
                                '${route['origin']} → ${route['destination']}',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: midnightTeal,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: currentVesselId == null
                              ? null
                              : (value) {
                                  setState(() {
                                    selectedFareRouteId = value;
                                    selectedPassengerType = null;
                                    hasCalculatedFare = false;
                                  });
                                },
                        ),

                        const SizedBox(height: 23),

                        // 3. PASSENGER TYPE
                        sectionLabel(
                          '3',
                          'SELECT PASSENGER TYPE',
                        ),

                        const SizedBox(height: 11),

                        if (currentRouteId == null)
                          const Text(
                            'Please select a route first.',
                            style: TextStyle(
                              color: mutedText,
                              fontSize: 12,
                            ),
                          )
                        else if (passengerTypes.isEmpty)
                          const Text(
                            'No passenger types available for this route.',
                            style: TextStyle(
                              color: mutedText,
                              fontSize: 12,
                            ),
                          )
                        else
                          Wrap(
                            spacing: 9,
                            runSpacing: 10,
                            children: passengerTypes.map((type) {
                              final isSelected =
                                  type == currentPassengerType;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedPassengerType = type;
                                    hasCalculatedFare = false;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(
                                    milliseconds: 180,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 17,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? midnightTeal
                                        : softBackground,
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: isSelected
                                          ? midnightTeal
                                          : const Color(0xFFE1ECEA),
                                    ),
                                  ),
                                  child: Text(
                                    type,
                                    style: TextStyle(
                                      color: isSelected
                                          ? pureWhite
                                          : midnightTeal,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                        const SizedBox(height: 23),

                        // 4. PASSENGER QUANTITY
                        sectionLabel(
                          '4',
                          'NUMBER OF PASSENGERS',
                        ),

                        const SizedBox(height: 11),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: softBackground,
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                              color: const Color(0xFFE1ECEA),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Passenger quantity',
                                      style: TextStyle(
                                        color: midnightTeal,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      'Number of travelers',
                                      style: TextStyle(
                                        color: mutedText,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              IconButton(
                                onPressed: passengerCount > 1
                                    ? () {
                                        setState(() {
                                          passengerCount--;
                                        });
                                      }
                                    : null,
                                icon: const Icon(
                                  Icons.remove_circle_outline_rounded,
                                ),
                                color: oceanTeal,
                              ),

                              Text(
                                '$passengerCount',
                                style: const TextStyle(
                                  color: midnightTeal,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),

                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    passengerCount++;
                                  });
                                },
                                icon: const Icon(
                                  Icons.add_circle_outline_rounded,
                                ),
                                color: oceanTeal,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        // CALCULATED FARE RESULT
                        if (selectedFare != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: midnightTeal,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: midnightTeal.withOpacity(0.13),
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.receipt_long_rounded,
                                      color: Color(0xFF8BE5DF),
                                      size: 22,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Your Fare Estimate',
                                      style: TextStyle(
                                        color: pureWhite,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                Text(
                                  selectedFare['vessel_name']
                                          ?.toString() ??
                                      'Selected Vessel',
                                  style: TextStyle(
                                    color: pureWhite.withOpacity(0.85),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  '${selectedFare['origin']} → ${selectedFare['destination']}',
                                  style: const TextStyle(
                                    color: pureWhite,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                const SizedBox(height: 18),

                                Divider(
                                  color: pureWhite.withOpacity(0.2),
                                ),

                                const SizedBox(height: 13),

                                _fareDetailRow(
                                  'Fare per passenger',
                                  '₱${fareAmount.toStringAsFixed(2)}',
                                ),

                                const SizedBox(height: 12),

                                _fareDetailRow(
                                  'Passenger type',
                                  currentPassengerType ?? '',
                                ),

                                const SizedBox(height: 12),

                                _fareDetailRow(
                                  'Number of passengers',
                                  '$passengerCount',
                                ),

                                const SizedBox(height: 16),

                                Divider(
                                  color: pureWhite.withOpacity(0.2),
                                ),

                                const SizedBox(height: 14),

                                Text(
                                  'TOTAL ESTIMATED FARE',
                                  style: TextStyle(
                                    color: pureWhite.withOpacity(0.75),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1,
                                  ),
                                ),

                                const SizedBox(height: 7),

                                Text(
                                  '₱${totalFare.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Color(0xFF8BE5DF),
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),

                                const SizedBox(height: 13),

                                Text(
                                  'Effective from: ${selectedFare['effective_from'] ?? 'Not specified'}',
                                  style: TextStyle(
                                    color: pureWhite.withOpacity(0.75),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(17),
                            decoration: BoxDecoration(
                              color: softBackground,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              hasCalculatedFare
                                  ? 'No fare found for the selected route and passenger type.'
                                  : 'Your estimated fare will appear here after you complete the selections and tap Calculate.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: mutedText,
                                fontSize: 11,
                                height: 1.5,
                              ),
                            ),
                          ),

                        const SizedBox(height: 20),

                        // INFORMATION NOTE
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: iceMint,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: oceanTeal,
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'This is an estimated fare based on the latest available records provided by registered boat personnel. Please confirm the fare before traveling.',
                                  style: TextStyle(
                                    color: midnightTeal,
                                    fontSize: 10,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Extra bottom space for the fixed button.
            const SliverToBoxAdapter(
  child: SizedBox(height: 40),
),
          ],
        ),
      ),
    ),

    // FIXED BOTTOM CALCULATE BUTTON
    bottomNavigationBar: availableVessels.isNotEmpty &&
            !isLoadingFares &&
            !isLoadingVessels &&
            fareError == null &&
            vesselError == null
        ? Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 15),
            decoration: BoxDecoration(
              color: pureWhite,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 15,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              height: 54,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoadingFares
                    ? null
                    : () async {
                        if (selectedVesselId == null ||
                            selectedFareRouteId == null ||
                            selectedPassengerType == null) {
                          showMessage(
                            'Please select a vessel, route, and passenger type.',
                          );
                          return;
                        }

                        // Fetch the latest fare records.
                        await fetchPassengerFares();

                        if (!mounted) return;

                        // Only show the result if fetching succeeded.
                        if (fareError == null) {
                          setState(() {
                            hasCalculatedFare = true;
                          });
                        } else {
                          showMessage(
                            'Unable to retrieve the latest fare. Please try again.',
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: midnightTeal,
                  foregroundColor: pureWhite,
                  disabledBackgroundColor: mutedText,
                  elevation: 5,
                  shadowColor: midnightTeal.withOpacity(0.25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calculate_rounded,
                      size: 20,
                    ),
                    SizedBox(width: 9),
                    Text(
                      'Calculate',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
  : null,
  );
}


Widget _fareDetailRow(String label, String value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          color: pureWhite.withOpacity(0.8),
          fontSize: 12,
        ),
      ),
      Text(
        value,
        style: const TextStyle(
          color: pureWhite,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}



  // ADVISORIES PAGE

Widget advisoriesPage() {
  return RefreshIndicator(
    color: oceanTeal,
    onRefresh: fetchPassengerAdvisories,
    child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Trip Advisories',
                  style: TextStyle(
                    color: midnightTeal,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: isLoadingAdvisories
                    ? null
                    : fetchPassengerAdvisories,
                tooltip: 'Refresh Advisories',
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: oceanTeal,
                  size: 25,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          const Text(
            'Important updates about passenger boat operations.',
            style: TextStyle(
              color: mutedText,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // LOADING STATE

          if (isLoadingAdvisories)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: CircularProgressIndicator(
                  color: oceanTeal,
                ),
              ),
            )

          // ERROR STATE

          else if (advisoryError != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: pureWhite,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.wifi_off_rounded,
                    color: mutedText,
                    size: 40,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Unable to load trip advisories.',
                    style: TextStyle(
                      color: midnightTeal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: fetchPassengerAdvisories,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            )

          // EMPTY STATE

          else if (advisories.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: pureWhite,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFE2ECE8),
                ),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.campaign_outlined,
                    color: mutedText,
                    size: 45,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No Active Advisories',
                    style: TextStyle(
                      color: midnightTeal,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'There are currently no active trip advisories. '
                    'Please check again later.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: mutedText,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            )

          // DISPLAY ALL ACTIVE ADVISORIES

          else
            ...advisories.map((advisory) {
              final String type =
                  (advisory['advisory_type'] ?? 'General')
                      .toString();

              final String title =
                  (advisory['title'] ?? 'Untitled Advisory')
                      .toString();

              final String message =
                  (advisory['message'] ?? '').toString();

              final String vesselName =
                  (advisory['vessel_name'] ?? 'Unknown Vessel')
                      .toString();

              final Color typeColor =
                  getAdvisoryColor(type);

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: pureWhite,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: typeColor.withOpacity(0.25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: midnightTeal.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: typeColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            getAdvisoryIcon(type),
                            color: typeColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                type.toUpperCase(),
                                style: TextStyle(
                                  color: typeColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.7,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                title,
                                style: const TextStyle(
                                  color: midnightTeal,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      message,
                      style: const TextStyle(
                        color: mutedText,
                        fontSize: 12,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Divider(
                      color: Color(0xFFE8EFED),
                      height: 1,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.directions_boat_rounded,
                          color: oceanTeal,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            vesselName,
                            style: const TextStyle(
                              color: midnightTeal,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          color: mutedText,
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            formatAdvisoryDate(
                              advisory['created_at'],
                            ),
                            style: const TextStyle(
                              color: mutedText,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    ),
  );
}
}

// VESSEL DETAILS PAGE

class SampleVesselDetailsPage extends StatefulWidget {
  final Map<String, dynamic> vessel;

  const SampleVesselDetailsPage({
    super.key,
    required this.vessel,
  });

  @override
  State<SampleVesselDetailsPage> createState() =>
      _SampleVesselDetailsPageState();
}

class _SampleVesselDetailsPageState
    extends State<SampleVesselDetailsPage> {
  static const Color midnightTeal = Color(0xFF073B40);
  static const Color oceanTeal = Color(0xFF087EAB);
  static const Color iceMint = Color(0xFFDDF4F1);
  static const Color softBackground = Color(0xFFF3F6F5);
  static const Color mutedText = Color(0xFF71817F);
  static const Color lightBlue = Color(0xFFE5F3F8);

  int selectedTab = 0;

  String getValue(String key, [String fallback = 'Not provided']) {
    final value = widget.vessel[key];

    if (value == null || value.toString().trim().isEmpty) {
      return fallback;
    }

    return value.toString();
  }

  List<dynamic> get schedules {
    final data = widget.vessel['schedules'];
    return data is List ? data : [];
  }

  List<dynamic> get routes {
    final data = widget.vessel['routes'];
    return data is List ? data : [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBackground,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              vesselHeader(),
              Transform.translate(
                offset: const Offset(0, -35),
                child: vesselInformationCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget vesselHeader() {
    return Container(
      height: 290,
      width: double.infinity,
      color: const Color(0xFFE9F0EF),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/infobg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: const Color(0xFFE9F0EF).withOpacity(0.55),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 14,
            right: 14,
            child: Row(
              children: [
                headerButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          getValue('vessel_name', 'Unnamed Vessel'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: midnightTeal,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.verified_rounded,
                        color: Color(0xFF168BCA),
                        size: 19,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                headerButton(
                  icon: Icons.alt_route_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BoatMapScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget headerButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withOpacity(0.80),
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            color: midnightTeal,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget vesselInformationCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: midnightTeal.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Transform.translate(
            offset: const Offset(0, -36),
            child: Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: iceMint,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: midnightTeal.withOpacity(0.10),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.directions_boat_filled_rounded,
                color: midnightTeal,
                size: 39,
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -24),
            child: Column(
              children: [
                Text(
                  getValue('vessel_name', 'Unnamed Vessel'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: midnightTeal,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  getValue('route', 'Route not provided'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: mutedText,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 13),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    detailPill(
                      Icons.verified_rounded,
                      'Verified Vessel',
                    ),
                    detailPill(
                      Icons.directions_boat_outlined,
                      getValue('vessel_type', 'Passenger Boat'),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                tabSelector(),
                const SizedBox(height: 23),
                if (selectedTab == 0)
                  overviewContent()
                else
                  schedulesContent(),
                const SizedBox(height: 22),
                swipePill(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget detailPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F3),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: oceanTeal),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: midnightTeal,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget tabSelector() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3F2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          tabButton('Overview', 0),
          tabButton('Schedules', 1),
        ],
      ),
    );
  }

  Widget tabButton(String title, int index) {
    final bool isSelected = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: midnightTeal.withOpacity(0.07),
                      blurRadius: 7,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? midnightTeal : mutedText,
              fontSize: 12,
              fontWeight:
                  isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget overviewContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: metadataItem(
                Icons.people_alt_outlined,
                getValue('passenger_capacity', 'N/A'),
                'Capacity',
              ),
            ),
            Expanded(
              child: metadataItem(
                Icons.directions_boat_outlined,
                getValue('vessel_type', 'N/A'),
                'Vessel Type',
              ),
            ),
            Expanded(
              child: metadataItem(
                Icons.confirmation_number_outlined,
                getValue('registration_number', 'N/A'),
                'Registration',
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        sectionTitle('Vessel Details'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: smallInformationCard(
                Icons.route_rounded,
                'Registered Routes',
                routes.length.toString(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: smallInformationCard(
                Icons.schedule_rounded,
                'Available Schedules',
                schedules.length.toString(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 23),
        sectionTitle('Registered Routes'),
        const SizedBox(height: 11),
        if (routes.isEmpty)
          emptyInformation('No registered routes available yet.')
        else
          ...routes.map((route) {
            final item = Map<String, dynamic>.from(route);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: informationCard(
                Icons.map_outlined,
                item['route_name']?.toString() ?? 'Boat Route',
                '${item['origin'] ?? 'Not provided'} to '
                    '${item['destination'] ?? 'Not provided'}\n'
                    'Estimated travel time: '
                    '${item['estimated_travel_time'] ?? 'Not provided'} minutes',
              ),
            );
          }),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: lightBlue,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: oceanTeal,
                size: 21,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Please check the latest trip advisories before traveling. Vessel schedules and operations may change.',
                  style: TextStyle(
                    color: midnightTeal,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget metadataItem(
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: const BoxDecoration(
            color: iceMint,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: midnightTeal,
            size: 21,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: midnightTeal,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: mutedText,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  Widget smallInformationCard(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7F6),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: oceanTeal, size: 22),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: midnightTeal,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: const TextStyle(
              color: mutedText,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget schedulesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle('Vessel Schedules'),
        const SizedBox(height: 8),
        const Text(
          'Check the available departure and arrival information.',
          style: TextStyle(
            color: mutedText,
            fontSize: 12,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 15),
        if (schedules.isEmpty)
          emptyInformation('No schedules available yet.')
        else
          ...schedules.map((schedule) {
            final item = Map<String, dynamic>.from(schedule);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: informationCard(
                Icons.schedule_rounded,
                'Departure: ${item['departure_time'] ?? 'Not provided'}',
                'Arrival: ${item['arrival_time'] ?? 'Not provided'}\n'
                    'Operating days: ${item['operating_days'] ?? 'Not provided'}',
              ),
            );
          }),
      ],
    );
  }

  Widget sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: midnightTeal,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget informationCard(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F7),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: const BoxDecoration(
              color: iceMint,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: oceanTeal,
              size: 20,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: midnightTeal,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    color: mutedText,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget emptyInformation(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F7),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: mutedText,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget swipePill() {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null &&
            details.primaryVelocity! > 0) {
          setState(() {
            selectedTab = 1;
          });
        }
      },
      onTap: () {
        setState(() {
          selectedTab = selectedTab == 0 ? 1 : 0;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: lightBlue,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              selectedTab == 0
                  ? 'Swipe to view schedules'
                  : 'Tap to return to overview',
              style: const TextStyle(
                color: midnightTeal,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 9),
            Icon(
              selectedTab == 0
                  ? Icons.arrow_forward_rounded
                  : Icons.arrow_back_rounded,
              color: oceanTeal,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// PASSENGER PROFILE PAGE

class PassengerProfilePage extends StatelessWidget {
  const PassengerProfilePage({super.key});

  static const Color midnightTeal = Color(0xFF073B40);
  static const Color oceanTeal = Color(0xFF087EAB);
  static const Color iceMint = Color(0xFFDDF4F1);
  static const Color softBackground = Color(0xFFF5F9F8);
  static const Color mutedText = Color(0xFF71817F);

  // LOGOUT CONFIRMATION

  Future<void> confirmLogout(BuildContext context) async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              color: midnightTeal,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout from your passenger account?',
            style: TextStyle(
              color: mutedText,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: mutedText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD9534F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true && context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBackground,
      appBar: AppBar(
        backgroundColor: softBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: midnightTeal),
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: midnightTeal,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            const SizedBox(height: 25),
            Container(
              width: 105,
              height: 105,
              decoration: const BoxDecoration(
                color: iceMint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: midnightTeal,
                size: 60,
              ),
            ),
            const SizedBox(height: 17),
            const Text(
              'Passenger Account',
              style: TextStyle(
                color: midnightTeal,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Manage your passenger information',
              style: TextStyle(
                color: mutedText,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 30),
            profileInformation(
              Icons.person_outline_rounded,
              'Full Name',
              'Not provided',
            ),
            const SizedBox(height: 13),
            profileInformation(
              Icons.email_outlined,
              'Email Address',
              'Not provided',
            ),
            const SizedBox(height: 13),
            profileInformation(
              Icons.badge_outlined,
              'Account Type',
              'Passenger',
            ),
            const SizedBox(height: 30),

            // LOGOUT BUTTON

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => confirmLogout(context),
                icon: const Icon(
                  Icons.logout_rounded,
                  size: 20,
                ),
                label: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD9534F),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget profileInformation(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: oceanTeal, size: 23),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: mutedText,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: midnightTeal,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
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
