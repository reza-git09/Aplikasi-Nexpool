import 'package:flutter/material.dart';
import 'home_page.dart';
import 'explore_page.dart';
import 'peta_page.dart';
import 'tiket_page.dart';
import 'review_page.dart';

class PaketPage extends StatelessWidget {
  const PaketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f8fc),

      body: SafeArea(
        child: Column(
          children: [
            // =========================
            // HEADER
            // =========================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 24),
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
                        Text(
                          'Paket Wisata 📦',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Pilih paket terbaik untuk Anda',
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

            // =========================
            // CONTENT
            // =========================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  top: 16,
                  left: 20,
                  right: 20,
                  bottom: 20,
                ),
                child: Column(
                  children: [
                    // =========================
                    // INFO BAR
                    // =========================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffeaf8fc),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        children: [
                          Text(
                            '💡',
                            style: TextStyle(fontSize: 17),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tap paket untuk melihat detail & memesan',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xff0077A8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // =========================
                    // PAKET 1
                    // =========================
                    _packageCard(
                      badge: '🎟️ REGULER',
                      name: 'Paket Harian',
                      tagline: 'Tiket masuk + akses semua kolam',
                      price: 'Rp15.000',
                      unit: '/orang · weekday',
                      gradient: const [
                        Color(0xff0077A8),
                        Color(0xff00B4D8),
                      ],
                      includes: const [
                        ['🏊', 'Akses semua kolam renang'],
                        ['🌊', 'Wahana air dasar'],
                      ],
                      buttonText: 'Pilih Paket',
                      buttonPrimary: false,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TiketPage(),
                          ),
                        );
                      },
                    ),

                    // =========================
                    // PAKET 2
                    // =========================
                    _packageCard(
                      badge: '⭐ TERPOPULER',
                      name: 'Paket Keluarga',
                      tagline: 'Untuk 4 orang + pelampung + wahana',
                      price: 'Rp70.000',
                      originalPrice: 'Rp95.000',
                      unit: '/paket',
                      gradient: const [
                        Color(0xff7B61FF),
                        Color(0xff0077A8),
                      ],
                      featured: true,
                      savingText:
                          '💜 Hemat Rp25.000 dibanding beli satuan!',
                      includes: const [
                        ['🎟️', '4 Tiket masuk'],
                        ['🌴', 'Area bersantai keluarga'],
                        ['🤿', '4 Pelampung gratis'],
                        ['🏊', 'Akses semua kolam & wahana'],
                      ],
                      buttonText: '✨ Pilih Paket Ini',
                      buttonPrimary: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TiketPage(),
                          ),
                        );
                      },
                    ),

                    // =========================
                    // PAKET 3
                    // =========================
                    _packageCard(
                      badge: '👥 GRUP',
                      name: 'Paket Grup',
                      tagline:
                          'Min. 10 orang, cocok untuk piknik & wisata',
                      price: 'Rp12.000',
                      originalPrice: 'Rp15.000',
                      unit: '/orang',
                      gradient: const [
                        Color(0xff06D6A0),
                        Color(0xff0077A8),
                      ],
                      includes: const [
                        ['🎟️', 'Tiket masuk (min. 10 orang)'],
                        ['🌴', 'Akses area bersantai grup'],
                        ['📋', 'Pemandu wisata (opsional)'],
                        ['🚌', 'Parkir bus gratis'],
                      ],
                      buttonText: 'Pesan Paket Grup',
                      buttonPrimary: false,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TiketPage(),
                          ),
                        );
                      },
                    ),

                    // =========================
                    // PAKET 4
                    // =========================
                    _packageCard(
                      badge: '👑 PREMIUM',
                      name: 'Paket Premium',
                      tagline: 'Pengalaman wisata mewah & eksklusif',
                      price: 'Rp150.000',
                      unit: '/paket · max 4 orang',
                      gradient: const [
                        Color(0xffB7791F),
                        Color(0xffFFD166),
                      ],
                      includes: const [
                        ['👑', '4 Tiket masuk + akses prioritas'],
                        ['👑', 'Area santai VIP (seharian penuh)'],
                        ['🍽️', 'Paket makan siang 4 porsi'],
                        ['📸', 'Sesi foto profesional'],
                      ],
                      buttonText: '👑 Pesan Paket Premium',
                      buttonPrimary: true,
                      goldButton: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TiketPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // =========================
      // BOTTOM NAVIGATION
      // =========================
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
                builder: (context) => const HomePage(),
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

  // ==========================================================
  // PACKAGE CARD
  // ==========================================================
  Widget _packageCard({
    required String badge,
    required String name,
    required String tagline,
    required String price,
    String? originalPrice,
    required String unit,
    required List<Color> gradient,
    required List<List<String>> includes,
    required String buttonText,
    required bool buttonPrimary,
    required VoidCallback onTap,
    bool featured = false,
    String? savingText,
    bool goldButton = false,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: featured
            ? Border.all(
                color: const Color(0xff123c73),
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // =========================
            // PACKAGE HEADER
            // =========================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    bottom: -40,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.10),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // BADGE
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.35),
                          ),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // NAME
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 3),

                      // TAGLINE
                      Text(
                        tagline,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // PRICE
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            price,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),

                          if (originalPrice != null) ...[
                            const SizedBox(width: 7),
                            Text(
                              originalPrice,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white54,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],

                          const SizedBox(width: 6),

                          Flexible(
                            child: Text(
                              unit,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // =========================
            // PACKAGE BODY
            // =========================
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SAVING
                  if (savingText != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xfff0edff),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        savingText,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xff4A36C8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],

                  // TITLE
                  const Text(
                    'TERMASUK:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // INCLUDE ITEMS
                  ...includes.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: gradient.first.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item[0],
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              item[1],
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xff172b4d),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          const Icon(
                            Icons.check,
                            size: 16,
                            color: Color(0xff06A77D),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: goldButton
                            ? const Color(0xffB7791F)
                            : buttonPrimary
                                ? const Color(0xff123c73)
                                : Colors.white,
                        foregroundColor: buttonPrimary || goldButton
                            ? Colors.white
                            : const Color(0xff123c73),
                        side: buttonPrimary || goldButton
                            ? BorderSide.none
                            : const BorderSide(
                                color: Color(0xff123c73),
                              ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        buttonText,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
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