import 'package:flutter/material.dart';
import 'home_page.dart';
import 'explore_page.dart';
import 'peta_page.dart';
import 'tiket_page.dart';
import 'review_page.dart';
import 'promo_page.dart';

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  final List<Map<String, dynamic>> notifikasi = [
    {
      'group': 'Hari Ini',
      'title': 'Reservasi Berhasil!',
      'text':
          'Tiket masuk untuk 2 orang pada Rabu, 27 Agustus 2025 telah terkonfirmasi. Simpan e-ticket Anda.',
      'time': '14 menit lalu',
      'icon': Icons.check_circle,
      'iconColor': const Color(0xff06D6A0),
      'iconBg': const Color(0xffE8FFF8),
      'action': 'Lihat E-Ticket',
      'actionType': 'tiket',
      'unread': true,
    },
    {
      'group': 'Hari Ini',
      'title': 'Pembayaran Berhasil',
      'text':
          'Pembayaran sebesar Rp32.000 via QRIS berhasil diproses. No. transaksi: #TWS-20250827-001',
      'time': '15 menit lalu',
      'icon': Icons.payments,
      'iconColor': const Color(0xff00B4D8),
      'iconBg': const Color(0xffE5FAFE),
      'action': 'Lihat Tiket',
      'actionType': 'tiket',
      'unread': true,
    },
    {
      'group': 'Hari Ini',
      'title': 'Promo Baru! Paket Keluarga',
      'text':
          'Dapatkan diskon 30% untuk Paket Keluarga selama September 2025. Jangan sampai terlewat!',
      'time': '2 jam lalu',
      'icon': Icons.redeem,
      'iconColor': const Color(0xffE65100),
      'iconBg': const Color(0xfffff1e8),
      'action': 'Lihat Promo',
      'actionType': 'promo',
      'unread': true,
    },
    {
      'group': 'Kemarin',
      'title': 'Pengingat Kunjungan Besok',
      'text':
          'Jangan lupa! Kunjungan Anda ke Tiaraswim dijadwalkan besok, Rabu 27 Agustus 2025. Siapkan e-ticket Anda!',
      'time': 'Kemarin 18.00',
      'icon': Icons.calendar_today,
      'iconColor': const Color(0xff7B61FF),
      'iconBg': const Color(0xffF0EDFF),
      'action': null,
      'actionType': null,
      'unread': false,
      'alarm': true,
    },
    {
      'group': 'Kemarin',
      'title': 'Event Baru: Fun Swimming',
      'text':
          'Event Fun Swimming Bersama akan diadakan 6 September 2025. Daftar sekarang sebelum kuota habis!',
      'time': 'Kemarin 10.30',
      'icon': Icons.celebration,
      'iconColor': const Color(0xffEF476F),
      'iconBg': const Color(0xffffedf2),
      'action': 'Lihat Tiket',
      'actionType': 'tiket',
      'unread': false,
    },
    {
      'group': 'Minggu Lalu',
      'title': 'Bagikan Ulasan Anda',
      'text':
          'Bagaimana kunjungan Anda 20 Agustus lalu? Bantu pengunjung lain dengan memberikan ulasan Anda.',
      'time': '22 Agu 2025',
      'icon': Icons.star,
      'iconColor': const Color(0xffD4960A),
      'iconBg': const Color(0xfffff8df),
      'action': 'Tulis Ulasan',
      'actionType': 'review',
      'unread': false,
    },
    {
      'group': 'Minggu Lalu',
      'title': 'Voucher Spesial Untuk Anda!',
      'text':
          'Anda mendapatkan voucher diskon 10% untuk kunjungan berikutnya. Berlaku hingga 31 Oktober 2025.',
      'time': '20 Agu 2025',
      'icon': Icons.confirmation_number,
      'iconColor': const Color(0xff06D6A0),
      'iconBg': const Color(0xffE8FFF8),
      'action': 'Lihat Promo',
      'actionType': 'promo',
      'unread': false,
    },
  ];

  int get unreadCount {
    return notifikasi.where((item) => item['unread'] == true).length;
  }

  void readNotification(int index) {
    setState(() {
      notifikasi[index]['unread'] = false;
    });
  }

  void markAllRead() {
    setState(() {
      for (final item in notifikasi) {
        item['unread'] = false;
      }
    });
  }

  void handleAction(String? type) {
    if (type == 'tiket') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const TiketPage(),
        ),
      );
    } else if (type == 'promo') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PromoPage(),
        ),
      );
    } else if (type == 'review') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ReviewPage(),
        ),
      );
    }
  }

  void showNotificationDetail(
    Map<String, dynamic> data,
    int index,
  ) {
    readNotification(index);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: data['iconBg'],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      data['icon'],
                      color: data['iconColor'],
                      size: 28,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Text(
                      data['title'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Text(
                data['text'],
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 17,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    data['time'],
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              if (data['action'] != null) ...[
                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(bottomSheetContext);
                      handleAction(data['actionType']);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff00B4D8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      data['action'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(bottomSheetContext);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void navigateMenu(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ExplorePage(),
        ),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const PetaPage(),
        ),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const TiketPage(),
        ),
      );
    } else if (index == 4) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ReviewPage(),
        ),
      );
    }
  }

  Widget buildDateGroup(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 7),
      child: Row(
        children: [
          Icon(
            Icons.today,
            size: 15,
            color: Colors.grey.shade500,
          ),
          const SizedBox(width: 6),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNotificationItem(
    Map<String, dynamic> data,
    int index,
  ) {
    final bool unread = data['unread'] == true;

    return Material(
      color: unread
          ? const Color(0xffF0FCFE)
          : Colors.white,
      child: InkWell(
        onTap: () {
          showNotificationDetail(data, index);
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            20,
            14,
            20,
            14,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (unread)
                Container(
                  width: 3,
                  height: 65,
                  margin: const EdgeInsets.only(
                    right: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xff00B4D8),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),

              if (!unread)
                const SizedBox(width: 15),

              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: data['iconBg'],
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  data['icon'],
                  color: data['iconColor'],
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (data['alarm'] == true) ...[
                          const Icon(
                            Icons.alarm,
                            color: Color(0xffE65100),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                        ],

                        Expanded(
                          child: Text(
                            data['title'],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: unread
                                  ? const Color(0xff007C91)
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      data['text'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Wrap(
                      crossAxisAlignment:
                          WrapCrossAlignment.center,
                      spacing: 7,
                      children: [
                        Text(
                          data['time'],
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),

                        if (data['action'] != null) ...[
                          Text(
                            '·',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              readNotification(index);
                              handleAction(
                                data['actionType'],
                              );
                            },
                            child: Text(
                              '${data['action']} →',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xff00A1BF),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              if (unread)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(
                    top: 4,
                    left: 8,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xff00B4D8),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> notificationWidgets = [];

    String? lastGroup;

    for (int i = 0; i < notifikasi.length; i++) {
      final data = notifikasi[i];

      if (lastGroup != data['group']) {
        notificationWidgets.add(
          buildDateGroup(data['group']),
        );

        lastGroup = data['group'];
      }

      notificationWidgets.add(
        buildNotificationItem(data, i),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffF7FAFC),

      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // =========================
            // HEADER
            // =========================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                24,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xff0077A8),
                    Color(0xff00B4D8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Notifikasi',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.notifications,
                              size: 22,
                              color: Colors.white,
                            ),
                          ],
                        ),

                        const SizedBox(height: 3),

                        Text(
                          unreadCount == 0
                              ? 'Semua sudah dibaca'
                              : '$unreadCount notifikasi belum dibaca',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  GestureDetector(
                    onTap: unreadCount == 0
                        ? null
                        : markAllRead,
                    child: Text(
                      'Tandai dibaca',
                      style: TextStyle(
                        fontSize: 12,
                        color: unreadCount == 0
                            ? Colors.white38
                            : Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // =========================
            // ALL READ BANNER
            // =========================
            if (unreadCount == 0)
              Container(
                margin: const EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  0,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffE8FFF8),
                  border: Border.all(
                    color: const Color(0xffB9F1E1),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 15,
                      color: Color(0xff048A69),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Semua notifikasi sudah dibaca',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xff048A69),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            // =========================
            // NOTIFICATION LIST
            // =========================
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(
                  bottom: 16,
                ),
                children: notificationWidgets,
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
        selectedItemColor: const Color(0xff1565C0),
        unselectedItemColor: Colors.grey,
        onTap: navigateMenu,
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
            icon: Icon(
              Icons.confirmation_number_outlined,
            ),
            activeIcon: Icon(
              Icons.confirmation_number,
            ),
            label: 'Tiket',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.rate_review_outlined),
            activeIcon: Icon(Icons.rate_review),
            label: 'Ulasan',
          ),
        ],
      ),
    );
  }
}