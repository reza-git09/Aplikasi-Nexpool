import 'package:flutter/material.dart';
import 'home_page.dart';
import 'explore_page.dart';
import 'peta_page.dart';
import 'tiket_page.dart';
import 'review_page.dart';
import 'paket_page.dart';

class FavoritPage extends StatefulWidget {
  const FavoritPage({super.key});

  @override
  State<FavoritPage> createState() => _FavoritPageState();
}

class _FavoritPageState extends State<FavoritPage> {
  int selectedTab = 0;

  final List<Map<String, dynamic>> favoritePools = [
    {
      'name': 'Kolam Keluarga',
      'desc': 'Kedalaman 0.5m – 1m · Aman semua usia',
      'rating': '4.9',
      'image': 'assets/images/family_pool.png',
      'color': null,
    },
    {
      'name': 'Kolam Utama',
      'desc': 'Kedalaman 1.2m – 1.5m · Dewasa',
      'rating': '4.8',
      'image': 'assets/images/pool_main.png',
      'color': null,
    },
    {
      'name': 'Kolam Cangkir Tumpah',
      'desc': 'Wahana unik · Semua usia',
      'rating': '4.7',
      'image': null,
      'color': const [
        Color(0xffAEE6F7),
        Color(0xff00B4D8),
      ],
    },
  ];

  final List<Map<String, dynamic>> favoritePackages = [
    {
      'name': 'Paket Keluarga',
      'desc': '4 Tiket + Gazebo + Pelampung',
      'price': 'Rp70.000/paket',
      'icon': Icons.family_restroom,
      'color': const [
        Color(0xff7B61FF),
        Color(0xff0077A8),
      ],
    },
    {
      'name': 'Paket Premium',
      'desc': 'VIP Gazebo + Makan + Foto Profesional',
      'price': 'Rp150.000/paket',
      'icon': Icons.workspace_premium,
      'color': const [
        Color(0xffB7791F),
        Color(0xffFFD166),
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f8fc),

      body: SafeArea(
        child: Column(
          children: [
            // ==============================
            // HEADER
            // ==============================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                20,
                25,
                20,
                24,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xff123c73),
                    Color(0xff00B4D8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
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
                        Row(
                          children: [
                            Text(
                              'Favorit',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 7),
                            Icon(
                              Icons.favorite,
                              size: 22,
                              color: Color(0xffEF476F),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Koleksi favorit Anda',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ==============================
            // TAB
            // ==============================
            Container(
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: _tabButton(
                      title: 'Kolam',
                      icon: Icons.pool,
                      index: 0,
                    ),
                  ),
                  Expanded(
                    child: _tabButton(
                      title: 'Paket',
                      icon: Icons.inventory_2_outlined,
                      index: 1,
                    ),
                  ),
                ],
              ),
            ),

            // ==============================
            // CONTENT
            // ==============================
            Expanded(
              child: selectedTab == 0
                  ? _poolTab()
                  : _packageTab(),
            ),
          ],
        ),
      ),

      // ==============================
      // BOTTOM NAVIGATION
      // ==============================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xff123c73),
        unselectedItemColor: Colors.grey,

        onTap: (index) {
          if (index == 0) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
              (route) => false,
            );
          }

          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ExplorePage(),
              ),
            );
          }

          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PetaPage(),
              ),
            );
          }

          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TiketPage(),
              ),
            );
          }

          if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ReviewPage(),
              ),
            );
          }
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Peta',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number_outlined),
            activeIcon: Icon(Icons.confirmation_number),
            label: 'Tiket',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_border),
            activeIcon: Icon(Icons.star),
            label: 'Ulasan',
          ),
        ],
      ),
    );
  }

  // ==============================
  // TAB BUTTON
  // ==============================
  Widget _tabButton({
    required String title,
    required IconData icon,
    required int index,
  }) {
    final bool active = selectedTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active
                  ? const Color(0xff123c73)
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17,
              color: active
                  ? const Color(0xff123c73)
                  : Colors.grey,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active
                    ? const Color(0xff123c73)
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================
  // TAB KOLAM
  // ==============================
  Widget _poolTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kolam Favorit',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff172b4d),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffe8f1ff),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${favoritePools.length} kolam',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff123c73),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ...favoritePools.map(
            (pool) => _favoritePoolCard(pool),
          ),
        ],
      ),
    );
  }

  // ==============================
  // TAB PAKET
  // ==============================
  Widget _packageTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Paket Favorit',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff172b4d),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffe8f1ff),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${favoritePackages.length} paket',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff123c73),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ...favoritePackages.map(
            (package) => _favoritePackageCard(package),
          ),
        ],
      ),
    );
  }

  // ==============================
  // FAVORITE POOL CARD
  // ==============================
  Widget _favoritePoolCard(
    Map<String, dynamic> pool,
  ) {
    return Dismissible(
      key: Key(pool['name']),
      direction: DismissDirection.endToStart,

      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: const Color(0xffEF476F),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
        ),
      ),

      onDismissed: (_) {
        setState(() {
          favoritePools.remove(pool);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${pool['name']} dihapus dari favorit',
            ),
          ),
        );
      },

      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ExplorePage(),
            ),
          );
        },

        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
              ),
            ],
          ),

          child: Row(
            children: [
              if (pool['image'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    pool['image'],
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return _placeholder(pool['color']);
                    },
                  ),
                )
              else
                _placeholder(pool['color']),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      pool['name'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff172b4d),
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      pool['desc'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffe8f8f1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '⭐ ${pool['rating']}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff14855d),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              GestureDetector(
                onTap: () {
                  setState(() {
                    favoritePools.remove(pool);
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${pool['name']} dihapus dari favorit',
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xffffeaf0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    size: 18,
                    color: Color(0xffEF476F),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================
  // FAVORITE PACKAGE CARD
  // ==============================
  Widget _favoritePackageCard(
    Map<String, dynamic> package,
  ) {
    return Dismissible(
      key: Key(package['name']),
      direction: DismissDirection.endToStart,

      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: const Color(0xffEF476F),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
        ),
      ),

      onDismissed: (_) {
        setState(() {
          favoritePackages.remove(package);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${package['name']} dihapus dari favorit',
            ),
          ),
        );
      },

      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaketPage(),
            ),
          );
        },

        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
              ),
            ],
          ),

          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: package['color'],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  package['icon'],
                  size: 30,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      package['name'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff172b4d),
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      package['desc'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffe8f1ff),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        package['price'],
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff123c73),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              GestureDetector(
                onTap: () {
                  setState(() {
                    favoritePackages.remove(package);
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${package['name']} dihapus dari favorit',
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xffffeaf0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    size: 18,
                    color: Color(0xffEF476F),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================
  // PLACEHOLDER
  // ==============================
  Widget _placeholder(List<Color>? colors) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors ??
              const [
                Color(0xffAEE6F7),
                Color(0xff00B4D8),
              ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(
        Icons.water_drop,
        size: 30,
        color: Colors.white,
      ),
    );
  }
}