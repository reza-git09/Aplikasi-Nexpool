import 'package:flutter/material.dart';
import 'home_page.dart';
import 'explore_page.dart';
import 'tiket_page.dart';
import 'review_page.dart';

class PetaPage extends StatefulWidget {
  const PetaPage({super.key});

  @override
  State<PetaPage> createState() => _PetaPageState();
}

class _PetaPageState extends State<PetaPage> {
  String selectedFilter = 'Semua';
  String? navigationTarget;

  final List<Map<String, dynamic>> filters = [
    {'name': 'Semua', 'icon': Icons.location_on},
    {'name': 'Kolam', 'icon': Icons.pool},
    {'name': 'Gazebo', 'icon': Icons.deck},
    {'name': 'Toilet', 'icon': Icons.wc},
    {'name': 'Mushola', 'icon': Icons.mosque},
    {'name': 'Kantin', 'icon': Icons.restaurant},
    {'name': 'Parkir', 'icon': Icons.local_parking},
  ];

  final List<Map<String, dynamic>> locations = [
    {
      'name': 'Kolam Utama',
      'status': 'Kedalaman 1.2m – 1.5m · Buka',
      'icon': Icons.pool,
      'color': const Color(0xFF00B4D8),
      'bg': const Color(0x1F00B4D8),
    },
    {
      'name': 'Area Gazebo',
      'status': '20 unit · 5 unit tersedia',
      'icon': Icons.deck,
      'color': const Color(0xFF7B61FF),
      'bg': const Color(0x1F7B61FF),
    },
    {
      'name': 'Toilet & Ruang Bilas',
      'status': 'Terpisah Pria/Wanita · Bersih',
      'icon': Icons.wc,
      'color': const Color(0xFF06D6A0),
      'bg': const Color(0x1F06D6A0),
    },
    {
      'name': 'Mushola',
      'status': 'Kapasitas 30 orang',
      'icon': Icons.mosque,
      'color': const Color(0xFF558B2F),
      'bg': const Color(0x1F558B2F),
    },
    {
      'name': 'Kantin',
      'status': 'Buka 07.00–17.00 WIB',
      'icon': Icons.restaurant,
      'color': const Color(0xFFE65100),
      'bg': const Color(0x1FE65100),
    },
    {
      'name': 'Area Parkir',
      'status': 'Motor, Mobil, Bus pariwisata',
      'icon': Icons.local_parking,
      'color': const Color(0xFF3F51B5),
      'bg': const Color(0x1F3F51B5),
    },
    {
      'name': 'Loket & Pintu Masuk',
      'status': 'Buka 07.00–16.30 WIB',
      'icon': Icons.confirmation_number,
      'color': const Color(0xFFEF476F),
      'bg': const Color(0x1FEF476F),
    },
  ];

  void navigateTo(String name) {
    setState(() {
      navigationTarget = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // =========================
            // TOP BAR
            // =========================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0077A8),
                    Color(0xFF00B4D8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🗺️ Peta Tiaraswim',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Navigasi area wisata interaktif',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // =========================
            // FILTER
            // =========================
            SizedBox(
              height: 62,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = filters[index];
                  final active =
                      selectedFilter == filter['name'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedFilter = filter['name'];
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0xFF0077A8)
                            : Colors.white,
                        borderRadius:
                            BorderRadius.circular(999),
                        border: Border.all(
                          color: active
                              ? const Color(0xFF0077A8)
                              : const Color(0xFFE0E0E0),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            filter['icon'],
                            size: 14,
                            color: active
                                ? Colors.white
                                : const Color(0xFF607D8B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            filter['name'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.w600,
                              color: active
                                  ? Colors.white
                                  : const Color(
                                      0xFF607D8B,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // =========================
            // NAVIGATION BANNER
            // =========================
            if (navigationTarget != null)
              Container(
                margin:
                    const EdgeInsets.fromLTRB(20, 4, 20, 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x14EF476F),
                  borderRadius:
                      BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0x33EF476F),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.navigation,
                      size: 20,
                      color: Color(0xFFEF476F),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '🧭 Menuju: $navigationTarget',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFEF476F),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          navigationTarget = null;
                        });
                      },
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Color(0xFFEF476F),
                      ),
                    ),
                  ],
                ),
              ),

            // =========================
            // MAP
            // =========================
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          width: double.infinity,
                          decoration:
                              const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFE8F5E9),
                                Color(0xFFE3F2FD),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Stack(
                            children: [
                              CustomPaint(
                                size: Size(
                                  constraints.maxWidth,
                                  constraints.maxHeight,
                                ),
                                painter: MapGridPainter(),
                              ),

                              _poolShape(
                                left: 30,
                                top: 60,
                                width: 160,
                                height: 80,
                                color:
                                    const Color(0x8000B4D8),
                                label:
                                    'Kolam\nOlahraga',
                              ),

                              _poolShape(
                                left: 200,
                                top: 40,
                                width: 120,
                                height: 60,
                                color:
                                    const Color(0x800077A8),
                                label:
                                    'Kolam\nUtama',
                              ),

                              _poolShape(
                                left: 30,
                                top: 160,
                                width: 80,
                                height: 60,
                                color:
                                    const Color(0x6606D6A0),
                                label:
                                    'Kolam\nMini',
                                circle: true,
                              ),

                              _poolShape(
                                left: 130,
                                top: 150,
                                width: 100,
                                height: 70,
                                color:
                                    const Color(0x667B61FF),
                                label:
                                    'Kolam\nKeluarga',
                              ),

                              _poolShape(
                                left: 250,
                                top: 130,
                                width: 80,
                                height: 50,
                                color:
                                    const Color(0x80FFD166),
                                label:
                                    'Cangkir\nTumpah',
                              ),

                              _poolShape(
                                left: 30,
                                top: 240,
                                width: 110,
                                height: 55,
                                color:
                                    const Color(0x59EF476F),
                                label:
                                    'Kolam\nBalap',
                              ),

                              _poolShape(
                                left: 160,
                                top: 240,
                                width: 90,
                                height: 50,
                                color:
                                    const Color(0x5900B4D8),
                                label:
                                    'Kolam\nBusa',
                                circle: true,
                              ),

                              _mapPin(
                                left: 285,
                                top: 62,
                                color:
                                    const Color(0xFF0077A8),
                                icon: Icons.pool,
                                label: 'Kolam Utama',
                                onTap: () =>
                                    navigateTo(
                                  'Kolam Utama',
                                ),
                              ),

                              _mapPin(
                                left: 50,
                                top: 245,
                                color:
                                    const Color(0xFF7B61FF),
                                icon: Icons.deck,
                                label: 'Gazebo',
                                onTap: () =>
                                    navigateTo(
                                  'Area Gazebo',
                                ),
                              ),

                              _mapPin(
                                left: 320,
                                top: 200,
                                color:
                                    const Color(0xFF00B4D8),
                                icon: Icons.wc,
                                label: 'Toilet',
                                onTap: () =>
                                    navigateTo(
                                  'Toilet & Ruang Bilas',
                                ),
                              ),

                              _mapPin(
                                left: 200,
                                top: 305,
                                color:
                                    const Color(0xFF06D6A0),
                                icon: Icons.mosque,
                                label: 'Mushola',
                                onTap: () =>
                                    navigateTo(
                                  'Mushola',
                                ),
                              ),

                              _mapPin(
                                left: 310,
                                top: 290,
                                color:
                                    const Color(0xFFFF9A3C),
                                icon: Icons.restaurant,
                                label: 'Kantin',
                                onTap: () =>
                                    navigateTo(
                                  'Kantin',
                                ),
                              ),

                              _mapPin(
                                left: 50,
                                top: 315,
                                color:
                                    const Color(0xFF5C6BC0),
                                icon:
                                    Icons.local_parking,
                                label: 'Parkir',
                                onTap: () =>
                                    navigateTo(
                                  'Area Parkir',
                                ),
                              ),

                              _mapPin(
                                left: 175,
                                top: 380,
                                color:
                                    const Color(0xFFEF476F),
                                icon: Icons
                                    .confirmation_number,
                                label: 'Loket',
                                onTap: () =>
                                    navigateTo(
                                  'Loket & Pintu Masuk',
                                ),
                              ),

                              // YOU ARE HERE
                              Positioned(
                                left: 175,
                                top: 360,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration:
                                      BoxDecoration(
                                    color:
                                        const Color(
                                      0xFFEF476F,
                                    ),
                                    shape:
                                        BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        blurRadius: 8,
                                        color:
                                            Colors.black26,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // COMPASS
                              Positioned(
                                right: 12,
                                top: 12,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration:
                                      BoxDecoration(
                                    color: Colors.white
                                        .withOpacity(0.9),
                                    borderRadius:
                                        BorderRadius
                                            .circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.explore,
                                    size: 20,
                                    color:
                                        Color(0xFF263238),
                                  ),
                                ),
                              ),

                              // SCALE
                              Positioned(
                                left: 10,
                                bottom: 8,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 3,
                                      decoration:
                                          BoxDecoration(
                                        color:
                                            Colors.black54,
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                          2,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      '50m',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color:
                                            Colors.black54,
                                        fontWeight:
                                            FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // =========================
                  // LOCATION LIST
                  // =========================
                  Container(
                    constraints: const BoxConstraints(
                      maxHeight: 260,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 20,
                          offset: Offset(0, -4),
                        ),
                      ],
                    ),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        16,
                        20,
                        20,
                      ),
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFFE0E0E0),
                              borderRadius:
                                  BorderRadius.circular(2),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 15,
                              color:
                                  Color(0xFFEF476F),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Semua Lokasi',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight:
                                    FontWeight.w700,
                                color:
                                    Color(0xFF263238),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        ...locations.map(
                          (location) =>
                              _locationItem(location),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // =========================
      // BOTTOM NAVIGATION
      // =========================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        type: BottomNavigationBarType.fixed,
        selectedItemColor:
            const Color(0xFF123C73),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,

        onTap: (index) {
          // HOME
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const HomePage(),
              ),
            );
          }

          // EXPLORE
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const ExplorePage(),
              ),
            );
          }

          // PETA
          if (index == 2) {
            return;
          }

          // TIKET
          if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const TiketPage(),
              ),
            );
          }

          // ULASAN
          if (index == 4) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const ReviewPage(),
              ),
            );
          }
        },

        items: [
          BottomNavigationBarItem(
            icon: _navIcon(Icons.home_rounded, const Color(0xFF00B4D8), false),
            activeIcon: _navIcon(Icons.home_rounded, const Color(0xFF00B4D8), true),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: _navIcon(Icons.pool_rounded, const Color(0xFF7B61FF), false),
            activeIcon: _navIcon(Icons.pool_rounded, const Color(0xFF7B61FF), true),
            label: 'Explore',
          ),

          BottomNavigationBarItem(
            icon: _navIcon(Icons.map_rounded, const Color(0xFF06D6A0), false),
            activeIcon: _navIcon(Icons.map_rounded, const Color(0xFF06D6A0), true),
            label: 'Peta',
          ),

          BottomNavigationBarItem(
            icon: _navIcon(Icons.confirmation_number_rounded, const Color(0xFFFFB703), false),
            activeIcon: _navIcon(Icons.confirmation_number_rounded, const Color(0xFFFFB703), true),
            label: 'Tiket',
          ),

          BottomNavigationBarItem(
            icon: _navIcon(Icons.star_rounded, const Color(0xFFEF476F), false),
            activeIcon: _navIcon(Icons.star_rounded, const Color(0xFFEF476F), true),
            label: 'Ulasan',
          ),
        ],
      ),
    );
  }

  // =========================
  // POOL SHAPE
  // =========================
  Widget _poolShape({
    required double left,
    required double top,
    required double width,
    required double height,
    required Color color,
    required String label,
    bool circle = false,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(
            circle ? 50 : 16,
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.6),
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 2,
                color: Colors.black45,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // MAP PIN
  // =========================
  Widget _mapPin({
    required double left,
    required double top,
    required Color color,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Positioned(
      left: left - 18,
      top: top - 36,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Transform.rotate(
              angle: -0.785398,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius:
                      const BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Transform.rotate(
                  angle: 0.785398,
                  child: Icon(
                    icon,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius:
                    BorderRadius.circular(4),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // LOCATION ITEM
  // =========================
  Widget _locationItem(
    Map<String, dynamic> location,
  ) {
    return GestureDetector(
      onTap: () =>
          navigateTo(location['name']),
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFE0E0E0),
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: location['bg'],
                borderRadius:
                    BorderRadius.circular(11),
              ),
              child: Icon(
                location['icon'],
                size: 18,
                color: location['color'],
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    location['name'],
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF263238),
                    ),
                  ),

                  const SizedBox(height: 1),

                  Text(
                    location['status'],
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF78909C),
                    ),
                  ),
                ],
              ),
            ),

            const Text(
              'Arahkan →',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF0077A8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navIcon(IconData icon, Color color, bool active) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: active ? color.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        size: 22,
        color: active ? color : Colors.grey.shade400,
      ),
    );
  }
}

// =========================
// GRID MAP PAINTER
// =========================
class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x0D00B4D8)
      ..strokeWidth = 1;

    const double gridSize = 30;

    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}