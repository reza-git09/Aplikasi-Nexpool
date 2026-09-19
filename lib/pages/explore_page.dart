import 'package:flutter/material.dart';
import 'home_page.dart';
import 'tiket_page.dart';
import 'peta_page.dart';
import 'review_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String selectedCategory = 'Semua';
  String searchText = '';

  final List<Map<String, dynamic>> facilities = [
    {
      'name': 'Kolam Utama',
      'category': 'Kolam',
      'meta': '🏊 Kedalaman 1.2m–1.5m',
      'image': 'assets/images/pool_main.png',
      'icon': '🏊',
      'description':
          'Kolam renang utama dengan kedalaman 1,2m hingga 1,5m. Cocok untuk berenang bebas dan olahraga air.',
      'detail1': 'Kedalaman: 1.2m – 1.5m',
      'detail2': 'Usia: Dewasa',
    },
    {
      'name': 'Kolam Keluarga',
      'category': 'Kolam',
      'meta': '👨‍👩‍👧‍👦 Cocok semua usia',
      'image': 'assets/images/family_pool.png',
      'icon': '👨‍👩‍👧‍👦',
      'description':
          'Kolam keluarga dengan kedalaman dangkal, aman untuk anak-anak dan orang tua. Area yang luas dan nyaman.',
      'detail1': 'Kedalaman: 0.5m – 1m',
      'detail2': 'Semua usia',
    },
    {
      'name': 'Cangkir Tumpah',
      'category': 'Wahana',
      'meta': '💧 Wahana unik',
      'image': null,
      'icon': '🍵',
      'description':
          'Wahana unik berbentuk cangkir raksasa yang menumpahkan air. Pengalaman seru dan tak terlupakan untuk anak-anak!',
      'detail1': 'Wahana Air',
      'detail2': 'Anak-anak',
    },
    {
      'name': 'Kolam Mini Kecek',
      'category': 'Kolam',
      'meta': '🐣 Khusus balita',
      'image': null,
      'icon': '🐣',
      'description':
          'Kolam dangkal khusus untuk si kecil! Dilengkapi mainan air seru dan kedalaman hanya 30cm untuk keamanan maksimal.',
      'detail1': 'Kedalaman: 30cm',
      'detail2': 'Balita & Anak',
    },
    {
      'name': 'Balap Pelampung',
      'category': 'Wahana',
      'meta': '🏆 Arena kompetisi',
      'image': 'assets/images/waterslide_fun.png',
      'icon': '🏆',
      'description':
          'Adu cepat dengan pelampung! Arena perlombaan air yang seru untuk remaja dan dewasa.',
      'detail1': 'Lintasan balap air',
      'detail2': 'Remaja & Dewasa',
    },
    {
      'name': 'Kolam Olahraga',
      'category': 'Kolam',
      'meta': '🏅 4 lintasan renang',
      'image': null,
      'icon': '🏅',
      'description':
          'Kolam khusus untuk latihan renang dengan lintasan yang jelas. Ideal untuk olahraga pagi dan sore hari.',
      'detail1': '4 lintasan renang',
      'detail2': 'Semua usia',
    },
    {
      'name': 'Kolam Busa Salju',
      'category': 'Wahana',
      'meta': '❄️ Sensasi unik',
      'image': 'assets/images/foam_party.png',
      'icon': '❄️',
      'description':
          'Sensasi bermain di kolam penuh busa seperti salju! Wahana favorit saat musim liburan dan event khusus.',
      'detail1': 'Kolam busa',
      'detail2': 'Semua usia',
    },
    {
      'name': 'Gazebo',
      'category': 'Fasilitas',
      'meta': '🏠 20 unit tersedia',
      'image': 'assets/images/gazebo_view.png',
      'icon': '🏠',
      'description':
          'Gazebo nyaman untuk bersantai bersama keluarga. Tersedia berbagai ukuran dengan pemandangan kolam yang indah.',
      'detail1': 'Tersedia 20 unit',
      'detail2': 'Kapasitas 4–10 orang',
    },
    {
      'name': 'Mushola',
      'category': 'Fasilitas',
      'meta': '🕌 Kapasitas 30 orang',
      'image': null,
      'icon': '🕌',
      'description':
          'Fasilitas ibadah yang bersih dan nyaman. Tersedia perlengkapan sholat, tempat wudhu terpisah putra-putri.',
      'detail1': 'Kapasitas 30 orang',
      'detail2': 'Perlengkapan tersedia',
    },
    {
      'name': 'Kantin',
      'category': 'Fasilitas',
      'meta': '🍽️ Buka 07.00–17.00',
      'image': null,
      'icon': '🍽️',
      'description':
          'Area makan dengan berbagai pilihan makanan dan minuman. Harga terjangkau dan menu beragam untuk semua selera.',
      'detail1': 'Buka 07.00–17.00',
      'detail2': 'Menu lengkap',
    },
    {
      'name': 'Ruang Bilas',
      'category': 'Fasilitas',
      'meta': '🚿 Loker tersedia',
      'image': null,
      'icon': '🚿',
      'description':
          'Kamar ganti dan ruang bilas yang bersih dan nyaman. Terpisah antara pria dan wanita dengan loker penyimpanan.',
      'detail1': 'Bersih & nyaman',
      'detail2': 'Loker tersedia',
    },
    {
      'name': 'Area Parkir',
      'category': 'Fasilitas',
      'meta': '🅿️ Motor, Mobil, Bus',
      'image': null,
      'icon': '🅿️',
      'description':
          'Area parkir luas dan aman dengan petugas. Tersedia untuk motor, mobil, dan bus pariwisata.',
      'detail1': 'Kapasitas besar',
      'detail2': 'Dijaga 24 jam',
    },
  ];

  List<Map<String, dynamic>> get filteredFacilities {
    return facilities.where((facility) {
      final matchCategory = selectedCategory == 'Semua' ||
          facility['category'] == selectedCategory;

      final name = facility['name'].toString().toLowerCase();
      final meta = facility['meta'].toString().toLowerCase();
      final query = searchText.toLowerCase();

      final matchSearch =
          query.isEmpty || name.contains(query) || meta.contains(query);

      return matchCategory && matchSearch;
    }).toList();
  }

  void showFacilityDetail(Map<String, dynamic> facility) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.82,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                if (facility['image'] != null)
                  Image.asset(
                    facility['image'],
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _placeholder(facility);
                    },
                  )
                else
                  _placeholder(facility),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F9FC),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                facility['icon'],
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              facility['name'],
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF172B4D),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Text(
                        facility['description'],
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 16),

                      _detailRow(
                        '📐',
                        'Info',
                        facility['detail1'],
                      ),

                      _detailRow(
                        '👥',
                        'Pengunjung',
                        facility['detail2'],
                      ),

                      const SizedBox(height: 18),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(sheetContext);
                              },
                              icon: const Icon(
                                Icons.close,
                                size: 17,
                              ),
                              label: const Text('Tutup'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(sheetContext);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PetaPage(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.location_on,
                                size: 17,
                              ),
                              label: const Text('Lihat di Peta'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF00B4D8),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(0, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(
    String icon,
    String label,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              icon,
              style: const TextStyle(fontSize: 17),
            ),
          ),

          const SizedBox(width: 8),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF172B4D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      ('Semua', Icons.waves),
      ('Kolam', Icons.pool),
      ('Fasilitas', Icons.apartment),
      ('Wahana', Icons.attractions),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),

      body: SafeArea(
        child: Column(
          children: [
            // =========================
            // HEADER
            // =========================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0077A8),
                    Color(0xFF00B4D8),
                  ],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 4),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Explore Fasilitas 🏊',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Semua wahana & fasilitas Tiaraswim',
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
            // SEARCH
            // =========================
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Cari fasilitas atau wahana...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF00B4D8),
                    ),
                  ),
                ),
              ),
            ),

            // =========================
            // CATEGORY
            // =========================
            SizedBox(
              height: 62,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isActive =
                      selectedCategory == category.$1;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = category.$1;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF00B4D8)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: isActive
                              ? const Color(0xFF00B4D8)
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            category.$2,
                            size: 15,
                            color: isActive
                                ? Colors.white
                                : Colors.grey.shade600,
                          ),

                          const SizedBox(width: 6),

                          Text(
                            category.$1,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? Colors.white
                                  : Colors.grey.shade700,
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
            // FACILITY GRID
            // =========================
            Expanded(
              child: filteredFacilities.isEmpty
                  ? const Center(
                      child: Text(
                        'Fasilitas tidak ditemukan',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        8,
                        20,
                        20,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.82,
                      ),
                      itemCount: filteredFacilities.length,
                      itemBuilder: (context, index) {
                        final facility =
                            filteredFacilities[index];

                        return _facilityCard(facility);
                      },
                    ),
            ),
          ],
        ),
      ),

      // =========================
      // BOTTOM NAVIGATION
      // =========================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF123C73),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,

        onTap: (index) {
          // HOME
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          }

          // EXPLORE
          if (index == 1) {
            return;
          }

          // PETA
          if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const PetaPage(),
              ),
            );
          }

          // TIKET
          if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const TiketPage(),
              ),
            );
          }

          // ULASAN
          if (index == 4) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ReviewPage(),
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

  Widget _facilityCard(
    Map<String, dynamic> facility,
  ) {
    return GestureDetector(
      onTap: () => showFacilityDetail(facility),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                if (facility['image'] != null)
                  Image.asset(
                    facility['image'],
                    width: double.infinity,
                    height: 105,
                    fit: BoxFit.cover,
                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return _placeholder(facility);
                    },
                  )
                else
                  _placeholder(facility),

                Positioned(
                  top: 8,
                  right: 8,
                  child: _FavoriteButton(),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                12,
                10,
                12,
                12,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    facility['name'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF172B4D),
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    facility['meta'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
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

  Widget _placeholder(
    Map<String, dynamic> facility,
  ) {
    return Container(
      width: double.infinity,
      height: 105,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFAEE6F7),
            Color(0xFF00B4D8),
          ],
        ),
      ),
      child: Center(
        child: Text(
          facility['icon'],
          style: const TextStyle(fontSize: 36),
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
class _FavoriteButton extends StatefulWidget {
  const _FavoriteButton();

  @override
  State<_FavoriteButton> createState() =>
      _FavoriteButtonState();
}

class _FavoriteButtonState
    extends State<_FavoriteButton> {
  bool favorite = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          favorite = !favorite;
        });
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(
          favorite
              ? Icons.favorite
              : Icons.favorite_border,
          size: 16,
          color: const Color(0xFFEF476F),
        ),
      ),
    );
  }
}