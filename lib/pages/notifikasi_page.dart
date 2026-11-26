import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'login_page.dart';
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
      'text': 'Tiket masuk untuk 2 orang pada Rabu, 27 Agustus 2025 telah terkonfirmasi. Simpan e-ticket Anda.',
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
      'text': 'Pembayaran sebesar Rp32.000 via QRIS berhasil diproses. No. transaksi: #TWS-20250827-001',
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
      'text': 'Dapatkan diskon 30% untuk Paket Keluarga selama September 2025. Jangan sampai terlewat!',
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
      'text': 'Jangan lupa! Kunjungan Anda ke Tiaraswim dijadwalkan besok, Rabu 27 Agustus 2025. Siapkan e-ticket Anda!',
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
      'text': 'Event Fun Swimming Bersama akan diadakan 6 September 2025. Daftar sekarang sebelum kuota habis!',
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
      'text': 'Bagaimana kunjungan Anda 20 Agustus lalu? Bantu pengunjung lain dengan memberikan ulasan Anda.',
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
      'text': 'Anda mendapatkan voucher diskon 10% untuk kunjungan berikutnya. Berlaku hingga 31 Oktober 2025.',
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

  Future<bool> _ensureLoggedIn() async {
    if (await AuthService.isLoggedIn()) return true;
    if (!mounted) return false;

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
    return false;
  }

  Future<void> handleAction(String? type) async {
    if (!await _ensureLoggedIn()) return;

    if (type == 'tiket') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TiketPage()),
      );
    } else if (type == 'promo') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PromoPage()),
      );
    } else if (type == 'review') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ReviewPage()),
      );
    }
  }

  Future<void> showNotificationDetail(
    Map<String, dynamic> data,
    int index,
  ) async {
    if (!await _ensureLoggedIn()) return;

    readNotification(index);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) => SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: BoxDecoration(
            color: bottomSheetContext.cardBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: bottomSheetContext.mutedText.withOpacity(.35),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: bottomSheetContext.isDark
                            ? bottomSheetContext.softBg
                            : data['iconBg'],
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        data['icon'],
                        color: data['iconColor'],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        data['title'],
                        style: TextStyle(
                          color: bottomSheetContext.textMain,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  data['text'],
                  style: TextStyle(
                    color: bottomSheetContext.mutedText,
                    fontSize: 14,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: bottomSheetContext.mutedText,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      data['time'],
                      style: TextStyle(
                        color: bottomSheetContext.mutedText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                if (data['action'] != null) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(bottomSheetContext);
                        handleAction(data['actionType']);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(bottomSheetContext)
                            .colorScheme
                            .primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        data['action'],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(bottomSheetContext),
                    style: TextButton.styleFrom(
                      foregroundColor: bottomSheetContext.mutedText,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const Text('Tutup'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDateGroup(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 15,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: context.textMain,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Divider(height: 1, color: context.softBg)),
        ],
      ),
    );
  }

  Widget buildNotificationItem(Map<String, dynamic> data, int index) {
    final bool unread = data['unread'] == true;
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 9),
      decoration: BoxDecoration(
        color: unread && !context.isDark
            ? const Color(0xffF8FCFD)
            : context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unread ? primary.withOpacity(.25) : context.softBg,
        ),
        boxShadow: [
          if (!context.isDark)
            BoxShadow(
              color: Colors.black.withOpacity(.025),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => showNotificationDetail(data, index),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: context.isDark ? context.softBg : data['iconBg'],
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(data['icon'], color: data['iconColor'], size: 21),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (data['alarm'] == true) ...[
                            const Icon(
                              Icons.alarm_rounded,
                              color: Color(0xffD97706),
                              size: 15,
                            ),
                            const SizedBox(width: 5),
                          ],
                          Expanded(
                            child: Text(
                              data['title'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: context.textMain,
                              ),
                            ),
                          ),
                          if (unread) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        data['text'],
                        style: TextStyle(
                          fontSize: 12.5,
                          color: context.mutedText,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12,
                        runSpacing: 6,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 13,
                                color: context.mutedText,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                data['time'],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.mutedText,
                                ),
                              ),
                            ],
                          ),
                          if (data['action'] != null)
                            InkWell(
                              onTap: () {
                                readNotification(index);
                                handleAction(data['actionType']);
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      data['action'],
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 13,
                                      color: primary,
                                    ),
                                  ],
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
        notificationWidgets.add(buildDateGroup(data['group']));

        lastGroup = data['group'];
      }

      notificationWidgets.add(buildNotificationItem(data, i));
    }

    return Scaffold(
      backgroundColor: context.pageBg,

      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
              decoration: BoxDecoration(
                color: context.cardBg,
                border: Border(bottom: BorderSide(color: context.softBg)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: context.softBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      tooltip: 'Kembali',
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: context.textMain,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notifikasi',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: context.textMain,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          unreadCount == 0
                              ? 'Semua sudah dibaca'
                              : '$unreadCount notifikasi belum dibaca',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (unreadCount > 0) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      tooltip: 'Tandai semua dibaca',
                      onPressed: markAllRead,
                      icon: Icon(
                        Icons.done_all_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 21,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (unreadCount == 0)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  border: Border.all(color: context.softBg),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: Color(0xff16865B),
                    ),
                    const SizedBox(width: 9),
                    Text(
                      'Semua notifikasi sudah dibaca',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textMain,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 6, bottom: 20),
                children: notificationWidgets,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
