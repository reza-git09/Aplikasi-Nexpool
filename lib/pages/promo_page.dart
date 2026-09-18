import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tiket_page.dart';

class PromoPage extends StatefulWidget {
  const PromoPage({super.key});

  @override
  State<PromoPage> createState() => _PromoPageState();
}

class _PromoPageState extends State<PromoPage> {
  final Set<int> expandedPromos = {};

  final List<Map<String, dynamic>> promos = [
    {
      'gradient': [
        const Color(0xFF0077A8),
        const Color(0xFF00B4D8),
      ],
      'category': 'PAKET',
      'smallTitle': 'Paket Keluarga',
      'smallDesc': 'Berlaku 1–30 September 2025',
      'emoji': '👨‍👩‍👧‍👦',
      'title': 'Paket Keluarga Hemat 30%',
      'description':
          'Beli 4 tiket sekaligus dan dapatkan diskon 30% untuk kunjungan keluarga Anda!',
      'validity': 'Berakhir 30 Sep 2025',
      'voucher': 'TWS-FAM30',
      'terms': [
        'Min. pembelian 4 tiket sekaligus',
        'Berlaku 1–30 September 2025',
        'Tidak bisa digabung promo lain',
      ],
    },
    {
      'gradient': [
        const Color(0xFF06D6A0),
        const Color(0xFF0077A8),
      ],
      'category': 'WEEKDAY',
      'smallTitle': 'Promo Tengah Pekan',
      'smallDesc': 'Senin – Rabu',
      'emoji': '🌊',
      'title': 'Beli 2 Gratis 1 — Weekday',
      'description':
          'Khusus hari Senin hingga Rabu, beli 2 tiket dewasa dan dapatkan 1 tiket gratis!',
      'validity': 'Senin–Rabu saja',
      'voucher': 'TWS-WEEKDAY',
      'terms': [
        'Hanya berlaku Senin, Selasa, Rabu',
        'Tiket gratis untuk 1 orang dewasa',
        'Berlaku hingga akhir Agustus 2025',
      ],
    },
    {
      'gradient': [
        const Color(0xFF7B61FF),
        const Color(0xFF4A36C8),
      ],
      'category': 'GRUP',
      'smallTitle': 'Paket Grup 10+',
      'smallDesc': 'Min. 10 orang',
      'emoji': '👥',
      'title': 'Diskon 20% untuk Grup',
      'description':
          'Ajak teman, keluarga, atau komunitas! Minimal 10 orang dalam 1 transaksi, diskon 20% langsung.',
      'validity': 'Min. 10 orang',
      'voucher': 'TWS-GRP20',
      'terms': [
        'Min. 10 tiket dalam 1 transaksi',
        'Berlaku weekday & weekend',
        'Diskon dihitung dari total tagihan',
        'Reservasi minimal H-3',
      ],
    },
  ];

  void _togglePromo(int index) {
    setState(() {
      if (expandedPromos.contains(index)) {
        expandedPromos.remove(index);
      } else {
        expandedPromos.add(index);
      }
    });
  }

  void _copyVoucher(String code) {
    Clipboard.setData(ClipboardData(text: code));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kode voucher $code berhasil disalin'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _gunakanPromo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TiketPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
                children: [
                  _buildSectionTitle(),

                  const SizedBox(height: 14),

                  ...List.generate(
                    promos.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: _buildPromoCard(
                        index,
                        promos[index],
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  _buildUpcomingPromo(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFD166),
            Color(0xFFF4B942),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 5,
            top: -5,
            child: Opacity(
              opacity: 0.20,
              child: Text(
                '🎁',
                style: TextStyle(
                  fontSize: 80,
                ),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              const Text(
                'Promo & Diskon 🎁',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF263238),
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Penawaran spesial dari Tiaraswim',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF5D4E22),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Row(
      children: [
        const Icon(
          Icons.local_fire_department,
          color: Colors.deepOrange,
          size: 25,
        ),
        const SizedBox(width: 7),
        const Text(
          'Promo Aktif',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF172B4D),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE9A8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            '3 Aktif',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8A6810),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromoCard(
    int index,
    Map<String, dynamic> promo,
  ) {
    final bool isExpanded = expandedPromos.contains(index);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildPromoTop(index, promo),

          Padding(
            padding: const EdgeInsets.fromLTRB(17, 16, 17, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  promo['title'],
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172B4D),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  promo['description'],
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.45,
                    color: Color(0xFF667085),
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: index == 0
                          ? Colors.redAccent
                          : const Color(0xFF0077A8),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        promo['validity'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: index == 0
                              ? Colors.redAccent
                              : const Color(0xFF0077A8),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _gunakanPromo,
                        icon: const Icon(
                          Icons.confirmation_number_outlined,
                          size: 18,
                        ),
                        label: const Text('Gunakan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0077A8),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    OutlinedButton(
                      onPressed: () {
                        _togglePromo(index);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0077A8),
                        side: const BorderSide(
                          color: Color(0xFFB8DCE8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                      ),
                    ),
                  ],
                ),

                if (isExpanded) ...[
                  const SizedBox(height: 16),
                  _buildPromoDetail(promo),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoTop(
    int index,
    Map<String, dynamic> promo,
  ) {
    return Container(
      height: 125,
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: promo['gradient'],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    promo['category'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  promo['smallTitle'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  promo['smallDesc'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Text(
            promo['emoji'],
            style: const TextStyle(
              fontSize: 55,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoDetail(Map<String, dynamic> promo) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F9FC),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFD9EAF0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_offer_outlined,
                color: Color(0xFF0077A8),
                size: 20,
              ),
              const SizedBox(width: 7),
              const Text(
                'Voucher',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF172B4D),
                ),
              ),
              const Spacer(),

              InkWell(
                onTap: () {
                  _copyVoucher(promo['voucher']);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.content_copy,
                    size: 17,
                    color: Color(0xFF0077A8),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFD9EAF0),
              ),
            ),
            child: Text(
              promo['voucher'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: Color(0xFF0077A8),
              ),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Syarat & Ketentuan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF172B4D),
            ),
          ),

          const SizedBox(height: 8),

          ...List.generate(
            promo['terms'].length,
            (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(
                        color: Color(0xFF0077A8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        promo['terms'][index],
                        style: const TextStyle(
                          fontSize: 12.5,
                          height: 1.4,
                          color: Color(0xFF667085),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingPromo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE4EAF0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3D6),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Center(
              child: Text(
                '🎉',
                style: TextStyle(
                  fontSize: 27,
                ),
              ),
            ),
          ),

          const SizedBox(width: 13),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Segera Hadir',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8A6810),
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Promo Hari Kemerdekaan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172B4D),
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Mulai 17 Agustus 2025',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF667085),
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3D6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Segera',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8A6810),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: 3,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF0077A8),
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (index == 0) {
          Navigator.popUntil(
            context,
            (route) => route.isFirst,
          );
        } else if (index == 1) {
          Navigator.pop(context);
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TiketPage(),
            ),
          );
        } else if (index == 3) {
          // Sudah berada di halaman Promo
        } else if (index == 4) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Halaman Profil akan dibuat berikutnya.'),
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
          icon: Icon(Icons.confirmation_number_outlined),
          activeIcon: Icon(Icons.confirmation_number),
          label: 'Tiket',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_offer_outlined),
          activeIcon: Icon(Icons.local_offer),
          label: 'Promo',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}