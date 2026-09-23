import 'package:flutter/material.dart';
import '../services/api_service.dart';

import 'explore_page.dart';
import 'tiket_page.dart';
import 'promo_page.dart';
import 'peta_page.dart';
import 'review_page.dart';
import 'notifikasi_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ============================================================
  // KOLAM YANG DIPILIH
  // 0 = Semua
  // 1 = Tiara
  // 2 = Kebon Agung
  // 3 = Annasya
  // 4 = Dira Park
  // 5 = Jati Park
  // ============================================================
  int selectedPool = 0;

  // ============================================================
  // DATA KOLAM CADANGAN
  // Digunakan untuk gambar, rating, harga, jam, dll
  // yang belum tersedia dari API.
  // ============================================================
  List<Map<String, dynamic>> pools = [
    {
      'name': 'Tiara Jember Park',
      'fullName': 'Tiara Jember Park Waterboom',
      'image': 'assets/images/tiara_park.jpeg',
      'rating': '4.9',
      'reviews': '1.2k',
      'icon': '🏊',
      'sub': 'Kolam terbesar & wahana terlengkap di Jember',
      'weekday': 'Rp15.000',
      'weekend': 'Rp20.000',
      'ratingCount': '1.2k ulasan',
      'bar5': 0.85,
      'location': 'Jl. Taman Air No.1, Kabupaten Jember',
      'hours': '07.00 – 17.00 WIB',
    },
    {
      'name': 'Kebon Agung',
      'fullName': 'Pemandian Kebon Agung',
      'image': 'assets/images/kebon agung_park.jpeg',
      'rating': '4.7',
      'reviews': '980',
      'icon': '🌿',
      'sub': 'Pemandian alam asri & menyegarkan',
      'weekday': 'Rp10.000',
      'weekend': 'Rp15.000',
      'ratingCount': '980 ulasan',
      'bar5': 0.75,
      'location': 'Jl. Kebon Agung, Kabupaten Jember',
      'hours': '07.00 – 17.00 WIB',
    },
    {
      'name': 'Annasya Waterpark',
      'fullName': 'Annasya Waterpark',
      'image': 'assets/images/annasya_park.jpeg',
      'rating': '4.8',
      'reviews': '756',
      'icon': '💦',
      'sub': 'Waterpark keluarga & anak yang nyaman',
      'weekday': 'Rp12.000',
      'weekend': 'Rp18.000',
      'ratingCount': '756 ulasan',
      'bar5': 0.82,
      'location': 'Jl. Annasya Water Park, Kabupaten Jember',
      'hours': '07.00 – 16.30 WIB',
    },
    {
      'name': 'Dira Park',
      'fullName': 'Dira Park',
      'image': 'assets/images/dira_park.jpeg',
      'rating': '4.6',
      'reviews': '612',
      'icon': '🌿',
      'sub': 'Taman wisata air & alam yang indah',
      'weekday': 'Rp15.000',
      'weekend': 'Rp22.000',
      'ratingCount': '612 ulasan',
      'bar5': 0.70,
      'location': 'Jl. Dira Park, Kabupaten Jember',
      'hours': '08.00 – 17.00 WIB',
    },
    {
      'name': 'Jati Park',
      'fullName': 'Jati Park',
      'image': 'assets/images/jati_park.jpeg',
      'rating': '4.8',
      'reviews': '890',
      'icon': '🌳',
      'sub': 'Wisata air di tengah suasana hutan jati',
      'weekday': 'Rp12.000',
      'weekend': 'Rp18.000',
      'ratingCount': '890 ulasan',
      'bar5': 0.83,
      'location': 'Jl. Jati Park, Kabupaten Jember',
      'hours': '07.30 – 17.00 WIB',
    },
  ];

  @override
  void initState() {
    super.initState();

    debugPrint('🔥 HOME PAGE INIT JALAN');

    _loadPools();
  }

  // ============================================================
  // AMBIL DATA KOLAM DARI API LARAVEL
  // ============================================================
  Future<void> _loadPools() async {
    try {
      debugPrint('====================================');
      debugPrint('Mengambil data dari API lewat ApiService...');
      debugPrint('API: ${ApiService.baseUrl}/kolam-renang');
      debugPrint('⏳ Mengirim request ke API...');
      debugPrint('====================================');

      // Ambil data melalui ApiService
      final List<dynamic> data =
          await ApiService.getKolamRenang();

      debugPrint('====================================');
      debugPrint('=== DATA API NEXPOOL ===');
      debugPrint(data.toString());
      debugPrint('Jumlah data API: ${data.length}');
      debugPrint('====================================');

      // Jika API berhasil tetapi data kosong,
      // gunakan data lokal.
      if (data.isEmpty) {
        debugPrint('⚠️ API berhasil tetapi data kosong.');
        debugPrint('Data lokal tetap digunakan.');
        return;
      }

      // Menampung data hasil API + data lokal
      final List<Map<String, dynamic>> apiPools = [];

      for (int i = 0; i < data.length; i++) {
        final Map<String, dynamic> item =
            Map<String, dynamic>.from(data[i]);

        // Ambil data lokal berdasarkan urutan.
        // Data lokal dipakai untuk data yang belum tersedia di API.
        final Map<String, dynamic> local =
            pools[i < pools.length ? i : 0];

        // ======================================================
        // NAMA KOLAM DARI API
        // ======================================================
        final String namaKolam =
            item['nama_kolam'] != null &&
                    item['nama_kolam']
                        .toString()
                        .trim()
                        .isNotEmpty
                ? item['nama_kolam'].toString().trim()
                : local['name'].toString();

        // ======================================================
        // POOL ID
        // ======================================================
        final String poolId =
            item['pool_id']?.toString() ?? '';

        // ======================================================
        // LOKASI
        // ======================================================
        String location =
            local['location']?.toString() ??
                'Kabupaten Jember';

        final String alamat =
            item['alamat']?.toString() ?? '';

        final String kota =
            item['kota']?.toString() ?? '';

        if (alamat.isNotEmpty && alamat != '-') {
          if (kota.isNotEmpty && kota != '-') {
            location = '$alamat, $kota';
          } else {
            location = alamat;
          }
        }

        // ======================================================
        // DESKRIPSI
        // ======================================================
        String sub =
            local['sub']?.toString() ??
                'Wisata kolam renang';

        final String deskripsi =
            item['deskripsi']?.toString() ?? '';

        if (deskripsi.isNotEmpty &&
            deskripsi != 'null') {
          sub = deskripsi;
        }

        // ======================================================
        // GAMBAR
        // ======================================================
        String image =
            local['image']?.toString() ?? '';

        final String gambar =
            item['gambar']?.toString() ?? '';

        // Jika API memiliki gambar,
        // gunakan gambar dari API.
        // Jika kosong/null, gunakan asset lokal.
        if (gambar.isNotEmpty &&
            gambar != 'null') {
          image = gambar;
        }

        // ======================================================
        // GABUNG DATA API + DATA LOKAL
        // ======================================================
        apiPools.add({
          ...local,

          // Data dari API
          'id': item['id'],
          'pool_id': poolId,
          'name': namaKolam,
          'fullName': namaKolam,
          'image': image,
          'location': location,
          'sub': sub,
          'maps_url': item['maps_url'],
          'status': item['status'],
        });

        debugPrint(
          'Kolam: $namaKolam | Pool ID: $poolId',
        );
      }

      // Pastikan widget masih aktif
      if (!mounted) return;

      // Masukkan data API ke Home Page
      setState(() {
        pools = apiPools;

        // Jika pilihan kolam tidak valid,
        // kembali ke Semua Kolam.
        if (selectedPool > pools.length) {
          selectedPool = 0;
        }
      });

      debugPrint('====================================');
      debugPrint(
        '✅ API BERHASIL: ${apiPools.length} kolam diterima.',
      );
      debugPrint('====================================');
    } catch (e) {
      // Jika API gagal,
      // data lokal tetap digunakan.
      debugPrint('====================================');
      debugPrint('❌ GAGAL MENGAMBIL API');
      debugPrint('Error: $e');
      debugPrint('Data lokal tetap digunakan.');
      debugPrint('====================================');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool allPool = selectedPool == 0;

    final Map<String, dynamic>? selected =
        allPool ||
                selectedPool < 1 ||
                selectedPool > pools.length
            ? null
            : pools[selectedPool - 1];

    final Map<String, dynamic> detailPool =
        selected ?? pools[0];

    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _buildHero(selected),

              const SizedBox(height: 20),

              _buildPoolSelector(),

              if (!allPool)
                _buildSelectedPool(selected!),

              const SizedBox(height: 22),

              _buildTitle(
                'Menu Cepat',
                Icons.apps_rounded,
                const Color(0xff123C73),
              ),

              const SizedBox(height: 12),

              _buildQuickMenu(),

              const SizedBox(height: 28),

              _buildPromoSection(),

              const SizedBox(height: 28),

              _buildEventSection(),

              if (!allPool) ...[
                const SizedBox(height: 28),
                _buildPriceSection(detailPool),

                const SizedBox(height: 28),
                _buildWahanaSection(),

                const SizedBox(height: 28),
                _buildFacilitySection(),

                const SizedBox(height: 28),
                _buildOperationalSection(detailPool),

                const SizedBox(height: 28),
                _buildLocationSection(detailPool),

                const SizedBox(height: 28),
                _buildRatingSection(detailPool),
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar:
          _buildBottomNavigation(),
    );
  }

  // ============================================================
  // HERO
  // ============================================================
  Widget _buildHero(
    Map<String, dynamic>? pool,
  ) {
    final bool allPool = pool == null;

    final String image = allPool
        ? 'assets/images/hero_banner.png'
        : (pool['image']?.toString() ??
            'assets/images/hero_banner.png');

    final String title = allPool
        ? 'Selamat Datang di\nNexPool! 🏊'
        : (pool['fullName']?.toString() ??
            'NEXPOOL');

    final String subtitle = allPool
        ? 'Pilih kolam renang favoritmu di bawah'
        : (pool['sub']?.toString() ??
            'Informasi kolam renang NEXPOOL');

    final String badge = allPool
        ? '🌊 ${pools.length} Wisata Kolam Renang Jember'
        : '⭐ Rating ${pool['rating']?.toString() ?? '-'} · '
            '${pool['reviews']?.toString() ?? '0'} Ulasan';

    return SizedBox(
      height: 285,
      child: Stack(
        children: [
          Positioned.fill(
            child: _buildImage(
              image,
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(50, 0, 0, 0),
                    Color.fromARGB(220, 0, 45, 65),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 16,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius:
                        BorderRadius.circular(13),
                  ),
                  child: Image.asset(
                    'assets/images/LOGO_NEXPOOL.png',
                    fit: BoxFit.contain,
                    errorBuilder:
                        (_, __, ___) =>
                            const Icon(
                      Icons.pool,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                const Expanded(
                  child: Text(
                    'NEXPOOL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const NotifikasiPage(),
                      ),
                    );
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color:
                              Colors.white.withOpacity(0.18),
                          borderRadius:
                              BorderRadius.circular(13),
                        ),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.white,
                        ),
                      ),

                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color:
                                const Color(0xffEF476F),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              '3',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight:
                                    FontWeight.bold,
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
          ),

          Positioned(
            left: 20,
            right: 20,
            bottom: 22,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffFFD166)
                        .withOpacity(0.18),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Color(0xffFFD166),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                const SizedBox(height: 9),

                Text(
                  title,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  subtitle,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    color:
                        Colors.white.withOpacity(0.82),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // IMAGE HELPER
  // ============================================================
  Widget _buildImage(
    String image, {
    BoxFit fit = BoxFit.cover,
  }) {
    if (image.startsWith('http://') ||
        image.startsWith('https://')) {
      return Image.network(
        image,
        fit: fit,
        errorBuilder:
            (_, __, ___) => _imageFallback(),
      );
    }

    return Image.asset(
      image,
      fit: fit,
      errorBuilder:
          (_, __, ___) => _imageFallback(),
    );
  }

  Widget _imageFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xff0077A8),
            Color(0xff00B4D8),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.pool,
          size: 70,
          color: Colors.white,
        ),
      ),
    );
  }

  // ============================================================
  // PILIH KOLAM
  // ============================================================
  Widget _buildPoolSelector() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _buildTitle(
          'Pilih Kolam Renang',
          Icons.pool,
          const Color(0xff00A4C6),
        ),

        const SizedBox(height: 5),

        const Padding(
          padding:
              EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Pilih destinasi untuk melihat informasi lengkap',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
        ),

        const SizedBox(height: 13),

        SizedBox(
          height: 125,
          child: ListView.builder(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: pools.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _allPoolCard();
              }

              return _poolCard(
                index,
                pools[index - 1],
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SEMUA KOLAM CARD
  // ============================================================
  Widget _allPoolCard() {
    final bool selected =
        selectedPool == 0;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPool = 0;
        });
        TiketPage.globalSelectedPoolId = 'pool_id_01';
        TiketPage.globalSelectedPoolName = 'Tiara Jember Park Waterboom';
      },
      child: Container(
        width: 120,
        margin:
            const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xff123C73)
              : Colors.white,
          borderRadius:
              BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(0.06),
              blurRadius: 9,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withOpacity(0.15)
                    : const Color(0xffE8F7FB),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.waves,
                color: selected
                    ? Colors.white
                    : const Color(0xff00A4C6),
                size: 28,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Semua Kolam',
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : const Color(0xff172B4D),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              '${pools.length} Wisata',
              style: TextStyle(
                color: selected
                    ? Colors.white70
                    : Colors.grey,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // POOL CARD
  // ============================================================
  Widget _poolCard(
    int index,
    Map<String, dynamic> pool,
  ) {
    final bool selected =
        selectedPool == index;

    final String image =
        pool['image']?.toString() ?? '';

    final String name =
        pool['name']?.toString() ??
            'Kolam Renang';

    final String rating =
        pool['rating']?.toString() ?? '-';

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPool = index;
        });

        final pId = pool['pool_id']?.toString() ?? 'pool_id_0$index';
        final pName = pool['fullName']?.toString() ?? pool['name']?.toString() ?? 'Kolam Renang';
        TiketPage.globalSelectedPoolId = pId;
        TiketPage.globalSelectedPoolName = pName;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '📍 $pName dipilih',
            ),
            duration: const Duration(milliseconds: 1200),
          ),
        );
      },
      child: Container(
        width: 120,
        margin:
            const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xff123C73)
              : Colors.white,
          borderRadius:
              BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(0.06),
              blurRadius: 9,
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),

            ClipRRect(
              borderRadius:
                  BorderRadius.circular(12),
              child: SizedBox(
                width: 104,
                height: 62,
                child: _buildImage(
                  image,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 6),

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 7,
              ),
              child: Text(
                name,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight:
                      FontWeight.w800,
                  color: selected
                      ? Colors.white
                      : const Color(0xff172B4D),
                ),
              ),
            ),

            const SizedBox(height: 2),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                const Text(
                  '★',
                  style: TextStyle(
                    color:
                        Color(0xffFFD166),
                    fontSize: 9,
                  ),
                ),

                const SizedBox(width: 2),

                Text(
                  rating,
                  style: TextStyle(
                    color: selected
                        ? Colors.white70
                        : Colors.grey,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SELECTED POOL
  // ============================================================
  Widget _buildSelectedPool(
    Map<String, dynamic> pool,
  ) {
    final String fullName =
        pool['fullName']?.toString() ??
            'Kolam Renang';

    final String sub =
        pool['sub']?.toString() ??
            'Wisata kolam renang';

    final String icon =
        pool['icon']?.toString() ?? '🏊';

    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        20,
        15,
        20,
        0,
      ),
      padding:
          const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff0077A8),
            Color(0xff00B4D8),
          ],
        ),
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color:
                  Colors.white.withOpacity(0.18),
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: Center(
              child: Text(
                icon,
                style:
                    const TextStyle(
                  fontSize: 23,
                ),
              ),
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  sub,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    color:
                        Colors.white.withOpacity(0.78),
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: () {
              setState(() {
                selectedPool = 0;
              });
            },
            child: const Text(
              '← Semua',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MENU CEPAT
  // ============================================================
  Widget _buildQuickMenu() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Row(
        children: [
          Expanded(
            child: _quickMenu(
              Icons.confirmation_number_outlined,
              'Beli Tiket',
              () {
                String pId = 'pool_id_01';
                String pName = 'Tiara Jember Park Waterboom';
                if (selectedPool > 0 && selectedPool <= pools.length) {
                  final p = pools[selectedPool - 1];
                  pId = p['pool_id']?.toString() ?? 'pool_id_0$selectedPool';
                  pName = p['fullName']?.toString() ?? p['name']?.toString() ?? 'Tiara Jember Park Waterboom';
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TiketPage(poolId: pId, poolName: pName),
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: _quickMenu(
              Icons.local_offer_outlined,
              'Promo',
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const PromoPage(),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: _quickMenu(
              Icons.explore_outlined,
              'Explore',
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const ExplorePage(),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: _quickMenu(
              Icons.map_outlined,
              'Peta',
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const PetaPage(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickMenu(
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 82,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(0.05),
              blurRadius: 9,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color:
                  const Color(0xff123C73),
              size: 25,
            ),

            const SizedBox(height: 7),

            Text(
              title,
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PROMO
  // ============================================================
  Widget _buildPromoSection() {
    final List<Map<String, dynamic>> promos = [
      {
        'title': 'Promo Paket Keluarga',
        'place':
            'Tiara Jember Park Waterboom · Sep 2026',
        'discount': 'Hemat 30%',
        'color1':
            const Color(0xff0077A8),
        'color2':
            const Color(0xff00B4D8),
      },
      {
        'title': 'Diskon Weekday',
        'place':
            'Pemandian Kebon Agung · Senin–Rabu',
        'discount': 'Gratis 1',
        'color1':
            const Color(0xff06D6A0),
        'color2':
            const Color(0xff0077A8),
      },
      {
        'title': 'Flash Sale Weekend',
        'place':
            'Annasya Waterpark · Sabtu–Minggu',
        'discount': 'Diskon 25%',
        'color1':
            const Color(0xffEF476F),
        'color2':
            const Color(0xff7B61FF),
      },
      {
        'title': 'Paket Grup 10+',
        'place':
            'Dira Park · Min. 10 orang',
        'discount': 'Diskon 20%',
        'color1':
            const Color(0xff7B61FF),
        'color2':
            const Color(0xff4A36C8),
      },
      {
        'title': 'Early Bird Masuk',
        'place':
            'Jati Park · Sebelum pukul 09.00',
        'discount': 'Hemat 15%',
        'color1':
            const Color(0xffF7B731),
        'color2':
            const Color(0xffEF476F),
      },
    ];

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _buildTitle(
          'Promo Terbaru',
          Icons.local_offer,
          const Color(0xffD4960A),
          action: 'Lihat Semua',
          onAction: () =>
              Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const PromoPage(),
            ),
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 125,
          child: ListView.separated(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            scrollDirection:
                Axis.horizontal,
            itemCount: promos.length,
            separatorBuilder:
                (_, __) =>
                    const SizedBox(width: 10),
            itemBuilder:
                (context, index) {
              final promo =
                  promos[index];

              final String title =
                  promo['title']?.toString() ??
                      'Promo';

              final String place =
                  promo['place']?.toString() ??
                      '';

              final String discount =
                  promo['discount']?.toString() ??
                      '';

              final Color color1 =
                  promo['color1'] is Color
                      ? promo['color1']
                          as Color
                      : const Color(
                          0xff0077A8,
                        );

              final Color color2 =
                  promo['color2'] is Color
                      ? promo['color2']
                          as Color
                      : const Color(
                          0xff00B4D8,
                        );

              return GestureDetector(
                onTap: () =>
                    Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const PromoPage(),
                  ),
                ),
                child: Container(
                  width: 250,
                  padding:
                      const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    gradient:
                        LinearGradient(
                      colors: [
                        color1,
                        color2,
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Column(
                        mainAxisAlignment:
                            MainAxisAlignment.end,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                const TextStyle(
                              color:
                                  Colors.white,
                              fontSize: 14,
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            place,
                            maxLines: 2,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style: TextStyle(
                              color: Colors
                                  .white
                                  .withOpacity(
                                0.78,
                              ),
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),

                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xffFFD166,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              20,
                            ),
                          ),
                          child: Text(
                            discount,
                            style:
                                const TextStyle(
                              color:
                                  Color(
                                0xff5A3A00,
                              ),
                              fontSize: 9,
                              fontWeight:
                                  FontWeight.w900,
                            ),
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
      ],
    );
  }

  // ============================================================
  // EVENT
  // ============================================================
  Widget _buildEventSection() {
    final List<Map<String, String>> events = [
      {
        'date': '20 Sep 2026',
        'place': 'Tiara Jember Park',
        'title': 'Festival Air Merdeka',
        'desc':
            'Lomba berenang berhadiah jutaan rupiah',
        'badge': 'Segera',
      },
      {
        'date': '25 Sep 2026',
        'place': 'Pemandian Kebon Agung',
        'title': 'Fun Swim Anak-Anak',
        'desc':
            'Senam air & games seru untuk si kecil',
        'badge': 'Gratis',
      },
      {
        'date': '1 Okt 2026',
        'place': 'Annasya Waterpark',
        'title': 'Night Pool Party',
        'desc':
            'Renang malam dengan live music & DJ',
        'badge': 'Hot 🔥',
      },
      {
        'date': '5 Okt 2026',
        'place': 'Dira Park',
        'title': 'Foto Kontes Alam',
        'desc':
            'Hunting foto di taman air alami',
        'badge': 'Hadiah',
      },
      {
        'date': '10 Okt 2026',
        'place': 'Jati Park',
        'title': 'Open Water Tournament',
        'desc':
            'Kompetisi renang antar sekolah Jember',
        'badge': 'Daftar',
      },
    ];

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _buildTitle(
          'Event Mendatang',
          Icons.celebration_outlined,
          const Color(0xffEF476F),
          action: 'Lihat Semua',
          onAction: _eventMessage,
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 140,
          child: ListView.separated(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            scrollDirection:
                Axis.horizontal,
            itemCount: events.length,
            separatorBuilder:
                (_, __) =>
                    const SizedBox(width: 10),
            itemBuilder:
                (context, index) {
              final event =
                  events[index];

              return GestureDetector(
                onTap: _eventMessage,
                child: Container(
                  width: 260,
                  padding:
                      const EdgeInsets.all(15),
                  decoration:
                      BoxDecoration(
                    gradient:
                        const LinearGradient(
                      colors: [
                        Color(0xff023E58),
                        Color(0xff0077A8),
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    mainAxisAlignment:
                        MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${event['date'] ?? '-'} · ${event['place'] ?? '-'}',
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style: TextStyle(
                                color: Colors
                                    .white
                                    .withOpacity(
                                  0.72,
                                ),
                                fontSize: 8.5,
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                          ),

                          Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 7,
                              vertical: 4,
                            ),
                            decoration:
                                BoxDecoration(
                              color: Colors
                                  .white
                                  .withOpacity(
                                0.15,
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                15,
                              ),
                            ),
                            child: Text(
                              event['badge'] ??
                                  '-',
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white,
                                fontSize: 8,
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text(
                        event['title'] ?? '-',
                        style:
                            const TextStyle(
                          color:
                              Colors.white,
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        event['desc'] ?? '-',
                        maxLines: 2,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style: TextStyle(
                          color: Colors
                              .white
                              .withOpacity(
                            0.78,
                          ),
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _eventMessage() {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Halaman Event akan kita buat berikutnya.',
        ),
      ),
    );
  }

  // ============================================================
  // HARGA TIKET
  // ============================================================
  Widget _buildPriceSection(
    Map<String, dynamic> pool,
  ) {
    final String weekday =
        pool['weekday']?.toString() ??
            'Rp0';

    final String weekend =
        pool['weekend']?.toString() ??
            'Rp0';

    final String name =
        pool['fullName']?.toString() ??
            'Kolam Renang';

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _buildTitle(
          'Harga Tiket',
          Icons.payments_outlined,
          const Color(0xffD4960A),
          action: 'Beli Tiket',
          onAction: () =>
              Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const TiketPage(),
            ),
          ),
        ),

        const SizedBox(height: 12),

        Container(
          margin:
              const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          padding:
              const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient:
                const LinearGradient(
              colors: [
                Color(0xff0077A8),
                Color(0xff023E58),
              ],
            ),
            borderRadius:
                BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              Align(
                alignment:
                    Alignment.centerLeft,
                child: Text(
                  name,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors
                        .white
                        .withOpacity(
                      0.75,
                    ),
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Weekday',
                          style: TextStyle(
                            color: Colors
                                .white
                                .withOpacity(
                              0.7,
                            ),
                            fontSize: 10,
                          ),
                        ),

                        const SizedBox(
                          height: 4,
                        ),

                        Text(
                          weekday,
                          style:
                              const TextStyle(
                            color:
                                Color(
                              0xffFFD166,
                            ),
                            fontSize: 19,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),

                        const SizedBox(
                          height: 2,
                        ),

                        const Text(
                          'Senin – Jumat',
                          style:
                              TextStyle(
                            color:
                                Colors.white70,
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 55,
                    color:
                        Colors.white24,
                  ),

                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Weekend',
                          style: TextStyle(
                            color: Colors
                                .white
                                .withOpacity(
                              0.7,
                            ),
                            fontSize: 10,
                          ),
                        ),

                        const SizedBox(
                          height: 4,
                        ),

                        Text(
                          weekend,
                          style:
                              const TextStyle(
                            color:
                                Color(
                              0xffFFD166,
                            ),
                            fontSize: 19,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),

                        const SizedBox(
                          height: 2,
                        ),

                        const Text(
                          'Sabtu – Minggu',
                          style:
                              TextStyle(
                            color:
                                Colors.white70,
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // WAHANA & KOLAM
  // ============================================================
  Widget _buildWahanaSection() {
    final List<Map<String, String>> wahana = [
      {
        'name': 'Kolam Utama',
        'desc': 'Kedalaman 1,2m – 1,5m',
        'image':
            'assets/images/pool_main.png',
        'emoji': '🏊',
      },
      {
        'name': 'Kolam Balap',
        'desc': 'Dengan pelampung seru',
        'image':
            'assets/images/waterslide_fun.png',
        'emoji': '🏆',
      },
      {
        'name': 'Kolam Keluarga',
        'desc': 'Aman untuk semua usia',
        'image':
            'assets/images/family_pool.png',
        'emoji': '👨‍👩‍👧‍👦',
      },
      {
        'name': 'Kolam Cangkir',
        'desc':
            'Wahana unik & mengagumkan',
        'image': '',
        'emoji': '🍵',
      },
    ];

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _buildTitle(
          'Wahana & Kolam',
          Icons.pool,
          const Color(0xff00A4C6),
          action: 'Explore',
          onAction: () =>
              Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const ExplorePage(),
            ),
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 165,
          child: ListView.separated(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            scrollDirection:
                Axis.horizontal,
            itemCount: wahana.length,
            separatorBuilder:
                (_, __) =>
                    const SizedBox(width: 10),
            itemBuilder:
                (context, index) {
              final item =
                  wahana[index];

              final String name =
                  item['name'] ??
                      'Wahana';

              final String desc =
                  item['desc'] ?? '';

              final String image =
                  item['image'] ?? '';

              final String emoji =
                  item['emoji'] ?? '🏊';

              return GestureDetector(
                onTap: () =>
                    Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const ExplorePage(),
                  ),
                ),
                child: Container(
                  width: 150,
                  decoration:
                      BoxDecoration(
                    color:
                        Colors.white,
                    borderRadius:
                        BorderRadius.circular(
                      17,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors
                            .black
                            .withOpacity(
                          0.05,
                        ),
                        blurRadius: 9,
                      ),
                    ],
                  ),
                  clipBehavior:
                      Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      if (image.isNotEmpty)
                        Image.asset(
                          image,
                          width:
                              double.infinity,
                          height: 92,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) =>
                                  _wahanaPlaceholder(
                            emoji,
                          ),
                        )
                      else
                        _wahanaPlaceholder(
                          emoji,
                        ),

                      Padding(
                        padding:
                            const EdgeInsets
                                .all(10),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  const TextStyle(
                                fontSize: 11,
                                fontWeight:
                                    FontWeight
                                        .w900,
                              ),
                            ),

                            const SizedBox(
                              height: 3,
                            ),

                            Text(
                              desc,
                              maxLines: 2,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  const TextStyle(
                                color:
                                    Colors.grey,
                                fontSize: 8.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _wahanaPlaceholder(
    String emoji,
  ) {
    return Container(
      width: double.infinity,
      height: 92,
      decoration:
          const BoxDecoration(
        gradient:
            LinearGradient(
          colors: [
            Color(0xff90E0EF),
            Color(0xff00B4D8),
          ],
        ),
      ),
      child: Center(
        child: Text(
          emoji,
          style:
              const TextStyle(
            fontSize: 34,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FASILITAS
  // ============================================================
  Widget _buildFacilitySection() {
    final List<Map<String, dynamic>>
        facilities = [
      {
        'name': 'Gazebo',
        'desc':
            'Berbagai pilihan gazebo',
        'icon': Icons.deck,
        'color':
            const Color(0xff06D6A0),
      },
      {
        'name': 'Mushola',
        'desc':
            'Tersedia untuk beribadah',
        'icon': Icons.mosque,
        'color':
            const Color(0xff8BC34A),
      },
      {
        'name': 'Kantin',
        'desc':
            'Makanan & minuman',
        'icon': Icons.restaurant,
        'color':
            const Color(0xffff9800),
      },
      {
        'name': 'Ruang Bilas',
        'desc':
            'Bersih & nyaman',
        'icon': Icons.shower,
        'color':
            const Color(0xff00B4D8),
      },
      {
        'name': 'Parkir',
        'desc':
            'Luas & aman',
        'icon':
            Icons.local_parking,
        'color':
            const Color(0xff3F51B5),
      },
      {
        'name': 'Wi-Fi',
        'desc':
            'Internet gratis',
        'icon': Icons.wifi,
        'color':
            const Color(0xff7B61FF),
      },
    ];

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _buildTitle(
          'Fasilitas',
          Icons.apartment,
          const Color(0xff7B61FF),
          action: 'Lihat Semua',
          onAction: () =>
              Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const ExplorePage(),
            ),
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 132,
          child: ListView.separated(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            scrollDirection:
                Axis.horizontal,
            itemCount:
                facilities.length,
            separatorBuilder:
                (_, __) =>
                    const SizedBox(width: 10),
            itemBuilder:
                (context, index) {
              final item =
                  facilities[index];

              final String name =
                  item['name']?.toString() ??
                      'Fasilitas';

              final String desc =
                  item['desc']?.toString() ??
                      '';

              final IconData icon =
                  item['icon'] is IconData
                      ? item['icon']
                          as IconData
                      : Icons.info;

              final Color color =
                  item['color'] is Color
                      ? item['color']
                          as Color
                      : const Color(
                          0xff00B4D8,
                        );

              return Container(
                width: 125,
                padding:
                    const EdgeInsets.all(12),
                decoration:
                    BoxDecoration(
                  color:
                      Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors
                          .black
                          .withOpacity(
                        0.05,
                      ),
                      blurRadius: 9,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration:
                          BoxDecoration(
                        color: color
                            .withOpacity(
                          0.12,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 21,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      name,
                      style:
                          const TextStyle(
                        fontSize: 11,
                        fontWeight:
                            FontWeight
                                .w900,
                      ),
                    ),

                    const SizedBox(
                      height: 2,
                    ),

                    Text(
                      desc,
                      maxLines: 2,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          const TextStyle(
                        color:
                            Colors.grey,
                        fontSize: 8.5,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // JAM OPERASIONAL
  // ============================================================
  Widget _buildOperationalSection(
    Map<String, dynamic> pool,
  ) {
    final String hours =
        pool['hours']?.toString() ??
            '07.00 – 17.00 WIB';

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _buildTitle(
          'Jam Operasional',
          Icons.schedule,
          const Color(0xff0097A7),
        ),

        const SizedBox(height: 12),

        Container(
          margin:
              const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          padding:
              const EdgeInsets.all(15),
          decoration:
              BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withOpacity(
                  0.05,
                ),
                blurRadius: 9,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration:
                    BoxDecoration(
                  color:
                      const Color(0xff06D6A0)
                          .withOpacity(
                    0.12,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    13,
                  ),
                ),
                child:
                    const Icon(
                  Icons.check_circle,
                  color:
                      Color(0xff06A87E),
                  size: 25,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    const Text(
                      'Sedang Buka',
                      style: TextStyle(
                        color:
                            Color(0xff06A87E),
                        fontSize: 10,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      hours,
                      style:
                          const TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(
                      height: 2,
                    ),

                    const Text(
                      'Buka setiap hari',
                      style:
                          TextStyle(
                        color:
                            Colors.grey,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),

              GestureDetector(
                onTap: () =>
                    Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const PetaPage(),
                  ),
                ),
                child: Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 11,
                    vertical: 9,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xff00B4D8,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      11,
                    ),
                  ),
                  child:
                      const Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color:
                            Colors.white,
                        size: 14,
                      ),
                      SizedBox(
                        width: 3,
                      ),
                      Text(
                        'Lokasi',
                        style:
                            TextStyle(
                          color:
                              Colors.white,
                          fontSize: 9,
                          fontWeight:
                              FontWeight
                                  .w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LOKASI
  // ============================================================
  Widget _buildLocationSection(
    Map<String, dynamic> pool,
  ) {
    final String fullName =
        pool['fullName']?.toString() ??
            'Kolam Renang';

    final String location =
        pool['location']?.toString() ??
            'Kabupaten Jember';

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _buildTitle(
          'Lokasi',
          Icons.location_on,
          const Color(0xffEF476F),
        ),

        const SizedBox(height: 12),

        Container(
          margin:
              const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          decoration:
              BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withOpacity(
                  0.05,
                ),
                blurRadius: 9,
              ),
            ],
          ),
          clipBehavior:
              Clip.antiAlias,
          child: Column(
            children: [
              Container(
                height: 110,
                width: double.infinity,
                decoration:
                    const BoxDecoration(
                  gradient:
                      LinearGradient(
                    colors: [
                      Color(0xffE8F4F8),
                      Color(0xffCDEBF2),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.map,
                    size: 58,
                    color:
                        Color(0xff00A4C6),
                  ),
                ),
              ),

              Padding(
                padding:
                    const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      fullName,
                      maxLines: 2,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          const TextStyle(
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 15,
                          color:
                              Color(0xffEF476F),
                        ),

                        const SizedBox(
                          width: 4,
                        ),

                        Expanded(
                          child: Text(
                            '$location\nJawa Timur, Indonesia',
                            style:
                                const TextStyle(
                              color:
                                  Colors.grey,
                              fontSize: 10,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 11,
                    ),

                    SizedBox(
                      width:
                          double.infinity,
                      child:
                          ElevatedButton.icon(
                        onPressed: () =>
                            Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const PetaPage(),
                          ),
                        ),
                        icon:
                            const Icon(
                          Icons.map,
                          size: 15,
                        ),
                        label:
                            const Text(
                          'Buka Peta',
                          style:
                              TextStyle(
                            fontSize: 10,
                            fontWeight:
                                FontWeight
                                    .w800,
                          ),
                        ),
                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              const Color(
                            0xff00B4D8,
                          ),
                          foregroundColor:
                              Colors.white,
                          elevation: 0,
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            vertical: 11,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              11,
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
        ),
      ],
    );
  }

  // ============================================================
  // RATING
  // ============================================================
  Widget _buildRatingSection(
    Map<String, dynamic> pool,
  ) {
    final String rating =
        pool['rating']?.toString() ??
            '0.0';

    final String ratingCount =
        pool['ratingCount']?.toString() ??
            '0 ulasan';

    double bar5 = 0.8;

    if (pool['bar5'] is num) {
      bar5 =
          (pool['bar5'] as num).toDouble();
    }

    bar5 =
        bar5.clamp(0.0, 1.0);

    final String namaKolam =
        pool['fullName']?.toString() ??
            pool['name']?.toString() ??
            'Kolam Renang';

    final String gambarKolam =
        pool['image']?.toString() ??
            '';

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _buildTitle(
          'Rating Pengunjung',
          Icons.star,
          const Color(0xffD4960A),
          action: 'Beri Review',
          onAction: () {
            if (selectedPool == 0) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Silakan pilih kolam renang terlebih dahulu untuk memberikan ulasan.',
                  ),
                  behavior:
                      SnackBarBehavior
                          .floating,
                  duration:
                      Duration(seconds: 2),
                ),
              );
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ReviewPage(
                  namaKolam:
                      namaKolam,
                  gambarKolam:
                      gambarKolam,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 12),

        Container(
          margin:
              const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          padding:
              const EdgeInsets.all(16),
          decoration:
              BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withOpacity(
                  0.05,
                ),
                blurRadius: 9,
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 90,
                child: Column(
                  children: [
                    Text(
                      rating,
                      style:
                          const TextStyle(
                        fontSize: 37,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const Text(
                      '★★★★★',
                      style:
                          TextStyle(
                        color:
                            Color(0xffFFD166),
                        fontSize: 14,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      ratingCount,
                      style:
                          const TextStyle(
                        color:
                            Colors.grey,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  children: [
                    _ratingBar(
                      '5',
                      bar5,
                    ),
                    _ratingBar(
                      '4',
                      0.15,
                    ),
                    _ratingBar(
                      '3',
                      0.04,
                    ),
                    _ratingBar(
                      '2',
                      0.01,
                    ),
                    _ratingBar(
                      '1',
                      0.00,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // RATING BAR
  // ============================================================
  Widget _ratingBar(
    String number,
    double value,
  ) {
    final double safeValue =
        value.clamp(0.0, 1.0);

    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 7,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 10,
            child: Text(
              number,
              style:
                  const TextStyle(
                color: Colors.grey,
                fontSize: 9,
              ),
            ),
          ),

          const SizedBox(width: 5),

          Expanded(
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(5),
              child:
                  LinearProgressIndicator(
                value: safeValue,
                minHeight: 6,
                backgroundColor:
                    const Color(
                  0xffEEEEEE,
                ),
                valueColor:
                    const AlwaysStoppedAnimation<
                        Color>(
                  Color(0xffFFD166),
                ),
              ),
            ),
          ),

          const SizedBox(width: 6),

          SizedBox(
            width: 28,
            child: Text(
              '${(safeValue * 100).round()}%',
              textAlign:
                  TextAlign.right,
              style:
                  const TextStyle(
                color: Colors.grey,
                fontSize: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TITLE
  // ============================================================
  Widget _buildTitle(
    String title,
    IconData icon,
    Color color, {
    String? action,
    VoidCallback? onAction,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: color,
          ),

          const SizedBox(width: 5),

          Expanded(
            child: Text(
              title,
              style:
                  const TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.w900,
                color:
                    Color(0xff172B4D),
              ),
            ),
          ),

          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action,
                style:
                    const TextStyle(
                  color:
                      Color(0xff00A4C6),
                  fontSize: 10,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================
  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: 0,
      type:
          BottomNavigationBarType.fixed,
      selectedItemColor:
          const Color(0xff00a0c0),
      unselectedItemColor:
          Colors.grey,
      selectedFontSize: 10,
      unselectedFontSize: 10,
      onTap: (index) {
        if (index == 0) return;

        if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const ExplorePage(),
            ),
          );
        }

        if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const PetaPage(),
            ),
          );
        }

        if (index == 3) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const TiketPage(),
            ),
          );
        }

        if (index == 4) {
          if (selectedPool == 0) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(
              const SnackBar(
                content: Text(
                  'Silakan pilih kolam renang terlebih dahulu untuk memberikan ulasan.',
                ),
                behavior:
                    SnackBarBehavior
                        .floating,
                duration:
                    Duration(seconds: 2),
              ),
            );
            return;
          }

          final Map<String, dynamic>
              pool =
              pools[selectedPool - 1];

          final String namaKolam =
              pool['fullName']
                      ?.toString() ??
                  pool['name']
                      ?.toString() ??
                  'Kolam Renang';

          final String gambarKolam =
              pool['image']
                      ?.toString() ??
                  '';

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ReviewPage(
                namaKolam:
                    namaKolam,
                gambarKolam:
                    gambarKolam,
              ),
            ),
          );
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: _navIcon(
            Icons.home_rounded,
            const Color(0xFF00B4D8),
            false,
          ),
          activeIcon: _navIcon(
            Icons.home_rounded,
            const Color(0xFF00B4D8),
            true,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: _navIcon(
            Icons.pool_rounded,
            const Color(0xFF7B61FF),
            false,
          ),
          activeIcon: _navIcon(
            Icons.pool_rounded,
            const Color(0xFF7B61FF),
            true,
          ),
          label: 'Explore',
        ),
        BottomNavigationBarItem(
          icon: _navIcon(
            Icons.map_rounded,
            const Color(0xFF06D6A0),
            false,
          ),
          activeIcon: _navIcon(
            Icons.map_rounded,
            const Color(0xFF06D6A0),
            true,
          ),
          label: 'Peta',
        ),
        BottomNavigationBarItem(
          icon: _navIcon(
            Icons.confirmation_number_rounded,
            const Color(0xFFFFB703),
            false,
          ),
          activeIcon: _navIcon(
            Icons.confirmation_number_rounded,
            const Color(0xFFFFB703),
            true,
          ),
          label: 'Tiket',
        ),
        BottomNavigationBarItem(
          icon: _navIcon(
            Icons.star_rounded,
            const Color(0xFFEF476F),
            false,
          ),
          activeIcon: _navIcon(
            Icons.star_rounded,
            const Color(0xFFEF476F),
            true,
          ),
          label: 'Ulasan',
        ),
      ],
    );
  }

  Widget _navIcon(
    IconData icon,
    Color color,
    bool active,
  ) {
    return Container(
      width: 36,
      height: 36,
      decoration:
          BoxDecoration(
        color: active
            ? color.withOpacity(0.15)
            : Colors.transparent,
        borderRadius:
            BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        size: 22,
        color: active
            ? color
            : Colors.grey.shade400,
      ),
    );
  }
}