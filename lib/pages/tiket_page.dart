import 'package:flutter/material.dart';

import 'home_page.dart';
import 'explore_page.dart';
import 'peta_page.dart';
import 'review_page.dart';

class TiketPage extends StatefulWidget {
  const TiketPage({super.key});

  @override
  State<TiketPage> createState() => _TiketPageState();
}

class _TiketPageState extends State<TiketPage> {
  // ============================================================
  // STATE
  // ============================================================

  int currentStep = 1;
  int selectedTab = 0;

  DateTime? selectedDate;
  String selectedDateLabel = '';
  bool isWeekend = false;

  String nama = '';
  String telepon = '';
  String alamat = '';
  String keterangan = '';

  String category = 'dewasa';

  int qtyAdult = 1;
  int qtyChild = 0;

  String payMethod = 'bank';
  String selectedBank = 'BRI';
  String selectedWallet = 'GoPay';

  String ticketId = '';
  String paymentTime = '';

  // Data tiket simulasi
  List<Map<String, dynamic>> myTickets = [
    {
      'id': 'TWS-202600001',
      'name': 'Tiket Dewasa — Weekday',
      'date': '20 Sep 2026',
      'qty': '2 Dewasa',
      'payment': 'Transfer BRI',
      'total': 32000,
      'status': 'Aktif',
      'reschedule': 1,
    },
    {
      'id': 'TWS-202600000',
      'name': 'Tiket Dewasa — Weekend',
      'date': '14 Sep 2026',
      'qty': '1 Dewasa, 2 Anak',
      'payment': 'GoPay',
      'total': 22000,
      'status': 'Terpakai',
      'reschedule': 0,
    },
  ];

  final TextEditingController namaController = TextEditingController();
  final TextEditingController teleponController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController keteranganController = TextEditingController();

  // ============================================================
  // PRICE
  // ============================================================

  int get adultPrice {
    return isWeekend ? 20000 : 15000;
  }

  int get adminFee => 2000;

  int get totalPrice {
    return (qtyAdult * adultPrice) + adminFee;
  }

  // ============================================================
  // FORMAT
  // ============================================================

  String rupiah(int value) {
    return 'Rp${value.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match.group(1)}.',
        )}';
  }

  String formatDate(DateTime date) {
    const days = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu'
    ];

    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];

    return '${days[date.weekday % 7]}, '
        '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String formatShortDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // ============================================================
  // DATE LIST
  // ============================================================

  List<DateTime> get dates {
    final today = DateTime.now();

    return List.generate(
      30,
      (index) => DateTime(
        today.year,
        today.month,
        today.day + index,
      ),
    );
  }

  // ============================================================
  // SELECT DATE
  // ============================================================

  void selectDate(DateTime date) {
    setState(() {
      selectedDate = date;
      selectedDateLabel = formatDate(date);
      isWeekend =
          date.weekday == DateTime.saturday ||
          date.weekday == DateTime.sunday;
    });
  }

  // ============================================================
  // STEP
  // ============================================================

  void goStep(int step) {
    setState(() {
      currentStep = step;
    });

    if (step == 2) {
      // nothing
    }

    if (step == 3) {
      // nothing
    }

    if (step == 4) {
      // nothing
    }

    if (step == 5) {
      generateReceipt();
    }
  }

  // ============================================================
  // VALIDATE DATA
  // ============================================================

  bool validateData() {
    if (namaController.text.trim().isEmpty) {
      showMessage('Nama lengkap belum diisi');
      return false;
    }

    if (teleponController.text.trim().length < 9) {
      showMessage('Nomor telepon minimal 9 angka');
      return false;
    }

    if (alamatController.text.trim().isEmpty) {
      showMessage('Alamat belum diisi');
      return false;
    }

    setState(() {
      nama = namaController.text.trim();
      telepon = teleponController.text.trim();
      alamat = alamatController.text.trim();
    });

    return true;
  }

  // ============================================================
  // PAYMENT
  // ============================================================

  void processPayment() {
    ticketId =
        'TWS-${DateTime.now().millisecondsSinceEpoch.toString().substring(4)}';

    final now = DateTime.now();

    paymentTime =
        '${now.day}/${now.month}/${now.year} '
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')} WIB';

    goStep(5);
  }

  void generateReceipt() {
    if (ticketId.isEmpty) {
      ticketId =
          'TWS-${DateTime.now().millisecondsSinceEpoch.toString().substring(4)}';
    }
  }

  // ============================================================
  // RESCHEDULE
  // ============================================================

  void openReschedule(int index) {
    final ticket = myTickets[index];

    DateTime? newDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final availableDates = List.generate(
              29,
              (i) {
                final today = DateTime.now();
                return DateTime(
                  today.year,
                  today.month,
                  today.day + i + 1,
                );
              },
            );

            int newPrice = 15000;

            if (newDate != null &&
                (newDate!.weekday == DateTime.saturday ||
                    newDate!.weekday == DateTime.sunday)) {
              newPrice = 20000;
            }

            final currentPrice = 15000 * 2 + 2000;
            final newTotal = newPrice * 2 + 2000;
            final diff = newTotal - currentPrice;

            return Container(
              height: MediaQuery.of(context).size.height * .85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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

                      const SizedBox(height: 18),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '🔄 Reschedule Tiket',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),

                      const Text(
                        'Ubah tanggal kunjungan Anda',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 18),

                      // INFO TIKET
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xffe8f9fc),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: const Color(0xff00b4d8)
                                .withOpacity(.25),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '🎟️ INFO TIKET',
                              style: TextStyle(
                                color: Color(0xff00a0c0),
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 8),
                            infoRow(
                              'No. Tiket',
                              ticket['id'].toString(),
                            ),
                            infoRow(
                              'Tanggal Saat Ini',
                              ticket['date'].toString(),
                            ),
                            infoRow(
                              'Kategori',
                              ticket['qty'].toString(),
                            ),
                            infoRow(
                              'Total Terbayar',
                              rupiah(ticket['total'] as int),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // RULES
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xfffff8df),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xffffd166)
                                .withOpacity(.5),
                          ),
                        ),
                        child: const Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              '📜 Ketentuan Reschedule',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xff9a6c00),
                              ),
                            ),
                            SizedBox(height: 7),
                            Text(
                              '• Hanya dapat dilakukan sebelum tanggal kunjungan.\n'
                              '• Maksimal H-1 dari tanggal kunjungan.\n'
                              '• Tiket yang sudah digunakan tidak dapat di-reschedule.\n'
                              '• Tanggal baru harus memiliki kuota.\n'
                              '• Jika harga lebih mahal, bayar selisih.\n'
                              '• Jika lebih murah, selisih dikembalikan sesuai kebijakan.\n'
                              '• Sistem mencatat riwayat reschedule.',
                              style: TextStyle(
                                fontSize: 11,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        '📅 Pilih Tanggal Baru',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        height: 85,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: availableDates.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, i) {
                            final date = availableDates[i];

                            final weekend =
                                date.weekday ==
                                        DateTime.saturday ||
                                    date.weekday ==
                                        DateTime.sunday;

                            final selected =
                                newDate != null &&
                                    newDate!.year == date.year &&
                                    newDate!.month == date.month &&
                                    newDate!.day == date.day;

                            return GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  newDate = date;
                                });
                              },
                              child: Container(
                                width: 58,
                                padding:
                                    const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? const Color(0xff00b4d8)
                                      : Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(14),
                                  border: Border.all(
                                    color: selected
                                        ? const Color(0xff00b4d8)
                                        : Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      ['SEN', 'SEL', 'RAB', 'KAM',
                                              'JUM', 'SAB', 'MIN']
                                          [date.weekday - 1],
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: selected
                                            ? Colors.white
                                            : weekend
                                                ? Colors.red
                                                : Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${date.day}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: selected
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      if (newDate != null) ...[
                        const SizedBox(height: 10),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xffe8fff8),
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          child: Text(
                            '📅 ${formatDate(newDate!)}\n'
                            '${diff > 0 ? '⬆️ Harga lebih mahal ${rupiah(diff)}' : diff < 0 ? '⬇️ Harga lebih murah ${rupiah(diff.abs())}' : '✅ Harga sama'}',
                            style: const TextStyle(
                              color: Color(0xff087f65),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],

                      const Spacer(),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                              ),
                              child: const Text('Batal'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: newDate == null
                                  ? null
                                  : () {
                                      setState(() {
                                        myTickets[index]['date'] =
                                            formatShortDate(
                                                newDate!);
                                        myTickets[index]
                                                ['reschedule'] =
                                            (myTickets[index]
                                                        ['reschedule']
                                                    as int) +
                                                1;
                                      });

                                      Navigator.pop(context);

                                      showMessage(
                                        'Reschedule berhasil ke ${formatShortDate(newDate!)}',
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xff00b4d8),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                              ),
                              child: const Text(
                                '✅ Konfirmasi Reschedule',
                              ),
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
      },
    );
  }

  // ============================================================
  // HELPER
  // ============================================================

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5fbfd),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                20,
                22,
                20,
                22,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xff0077b6),
                    Color(0xff00b4d8),
                  ],
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.15),
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
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reservasi Tiket 🎟️',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Pesan tiket masuk Tiaraswim secara online',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // CONTENT
            Expanded(
              child: selectedTab == 0
                  ? buildBuyTicket()
                  : buildMyTickets(),
            ),
          ],
        ),
      ),

      // BOTTOM NAV
      bottomNavigationBar: buildBottomNavigation(),
    );
  }

  // ============================================================
  // TAB BELI TIKET
  // ============================================================

  Widget buildBuyTicket() {
    return SingleChildScrollView(
      child: Column(
        children: [
          buildTabs(),

          const SizedBox(height: 8),

          buildStepIndicator(),

          if (currentStep == 1) buildStep1(),
          if (currentStep == 2) buildStep2(),
          if (currentStep == 3) buildStep3(),
          if (currentStep == 4) buildStep4(),
          if (currentStep == 5) buildStep5(),

          const SizedBox(height: 25),
        ],
      ),
    );
  }

  // ============================================================
  // TAB
  // ============================================================

  Widget buildTabs() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedTab = 0;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  gradient: selectedTab == 0
                      ? const LinearGradient(
                          colors: [
                            Color(0xff0077b6),
                            Color(0xff00b4d8),
                          ],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '🎫 Beli Tiket',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selectedTab == 0
                        ? Colors.white
                        : Colors.grey,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 4),

          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedTab = 1;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  gradient: selectedTab == 1
                      ? const LinearGradient(
                          colors: [
                            Color(0xff0077b6),
                            Color(0xff00b4d8),
                          ],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '📋 Tiket Saya',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selectedTab == 1
                        ? Colors.white
                        : Colors.grey,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STEP INDICATOR
  // ============================================================

  Widget buildStepIndicator() {
    final labels = [
      'Tanggal',
      'Data Diri',
      'Tiket',
      'Bayar',
      'Selesai',
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 8),
      child: Row(
        children: List.generate(
          5,
          (index) {
            final step = index + 1;
            final done = currentStep > step;
            final active = currentStep == step;

            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: done
                                ? const Color(0xff06d6a0)
                                : active
                                    ? const Color(0xff00b4d8)
                                    : Colors.grey.shade300,
                            boxShadow: active
                                ? [
                                    BoxShadow(
                                      color: const Color(
                                        0xff00b4d8,
                                      ).withOpacity(.25),
                                      blurRadius: 0,
                                      spreadRadius: 4,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              done ? '✓' : '$step',
                              style: TextStyle(
                                color: active || done
                                    ? Colors.white
                                    : Colors.grey,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          labels[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: active
                                ? const Color(0xff00a0c0)
                                : done
                                    ? const Color(0xff06a77d)
                                    : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (index < 4)
                    Container(
                      width: 15,
                      height: 2,
                      margin: const EdgeInsets.only(
                        bottom: 17,
                      ),
                      color: currentStep > step
                          ? const Color(0xff00b4d8)
                          : Colors.grey.shade300,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // STEP 1
  // ============================================================

  Widget buildStep1() {
    return Column(
      children: [
        sectionTitle('📅 Pilih Tanggal Kunjungan'),

        SizedBox(
          height: 92,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final date = dates[index];

              final weekend =
                  date.weekday == DateTime.saturday ||
                      date.weekday == DateTime.sunday;

              final selected =
                  selectedDate != null &&
                      selectedDate!.year == date.year &&
                      selectedDate!.month == date.month &&
                      selectedDate!.day == date.day;

              return GestureDetector(
                onTap: () => selectDate(date),
                child: Container(
                  width: 58,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xff00b4d8)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? const Color(0xff00b4d8)
                          : Colors.grey.shade300,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.04),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Text(
                        [
                          'SEN',
                          'SEL',
                          'RAB',
                          'KAM',
                          'JUM',
                          'SAB',
                          'MIN'
                        ][date.weekday - 1],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : weekend
                                  ? Colors.red
                                  : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: selected
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            8,
            20,
            15,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xffe8f9fc),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              selectedDate == null
                  ? '📅 Pilih tanggal di atas'
                  : '📅 $selectedDateLabel — ${isWeekend ? 'Weekend' : 'Weekday'}',
              style: const TextStyle(
                color: Color(0xff00a0c0),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // KUOTA
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'INFO KUOTA',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    quotaBox(
                      '320',
                      'Kuota Tersisa',
                      const Color(0xff06d6a0),
                    ),
                    const SizedBox(width: 10),
                    quotaBox(
                      '500',
                      'Total Kuota',
                      const Color(0xff00b4d8),
                    ),
                    const SizedBox(width: 10),
                    quotaBox(
                      '180',
                      'Terjual',
                      const Color(0xffb07b00),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 18),

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedDate == null
                  ? null
                  : () => goStep(2),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xff00b4d8),
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Lanjut Isi Data Diri →',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget quotaBox(
    String number,
    String label,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              number,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 9,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STEP 2 DATA DIRI
  // ============================================================

  Widget buildStep2() {
    return Column(
      children: [
        recapDate(),

        sectionTitle('👤 Data Diri Pemesan'),

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.grey.shade200,
              ),
            ),
            child: Column(
              children: [
                buildTextField(
                  controller: namaController,
                  label: 'Nama Lengkap',
                  hint: 'Masukkan nama lengkap',
                  icon: Icons.person_outline,
                ),

                const SizedBox(height: 14),

                buildTextField(
                  controller: teleponController,
                  label: 'No. Telepon',
                  hint: '812-3456-7890',
                  prefix: '+62',
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 14),

                buildTextField(
                  controller: alamatController,
                  label: 'Alamat',
                  hint:
                      'Jl. Nama Jalan, No. Rumah, Kelurahan...',
                  icon: Icons.location_on_outlined,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            0,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xffe8f9fc),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '🔒 Data diri Anda hanya digunakan untuk keperluan reservasi tiket dan tidak akan dibagikan kepada pihak ketiga.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Row(
            children: [
              OutlinedButton(
                onPressed: () => goStep(1),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 15,
                  ),
                ),
                child: const Text('← Kembali'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (validateData()) {
                      goStep(3);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xff00b4d8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    'Lanjut Pilih Tiket →',
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
  // STEP 3
  // ============================================================

  Widget buildStep3() {
    return Column(
      children: [
        recapDate(),

        sectionTitle('🎫 Kategori Tiket'),

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Row(
            children: [
              categoryCard(
                '🏊',
                'Dewasa',
                rupiah(adultPrice),
                'Tinggi > 100cm',
                category == 'dewasa',
                () {
                  setState(() {
                    category = 'dewasa';
                  });
                },
              ),
              const SizedBox(width: 10),
              categoryCard(
                '👶',
                'Anak-anak',
                'Gratis',
                'Tinggi ≤ 100cm',
                category == 'anak',
                () {
                  setState(() {
                    category = 'anak';
                  });
                },
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            0,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xfffff8df),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '⚠️ Harga weekday & weekend berbeda. Anak ≤ 100cm gratis.',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xff7a5800),
              ),
            ),
          ),
        ),

        sectionTitle('👥 Jumlah Tiket'),

        buildQuantity(
          'Dewasa',
          'Tinggi > 100cm',
          qtyAdult,
          (value) {
            setState(() {
              qtyAdult =
                  (qtyAdult + value).clamp(0, 20);
            });
          },
        ),

        buildQuantity(
          'Anak-anak',
          'Tinggi ≤ 100cm (Gratis)',
          qtyChild,
          (value) {
            setState(() {
              qtyChild =
                  (qtyChild + value).clamp(0, 20);
            });
          },
        ),

        sectionTitle(
          '📝 Keterangan Tiket (Opsional)',
        ),

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: TextField(
            controller: keteranganController,
            maxLength: 200,
            maxLines: 4,
            onChanged: (value) {
              keterangan = value;
            },
            decoration: InputDecoration(
              hintText:
                  'Contoh: Kunjungan ulang tahun, grup keluarga, atau catatan khusus...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 4),

        buildSummary(),

        Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            0,
            20,
            0,
          ),
          child: Row(
            children: [
              OutlinedButton(
                onPressed: () => goStep(2),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 15,
                  ),
                ),
                child: const Text('← Kembali'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => goStep(4),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xff00b4d8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    'Lanjut Pembayaran →',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget categoryCard(
    String icon,
    String name,
    String price,
    String desc,
    bool selected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xffe8f9fc)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? const Color(0xff00b4d8)
                  : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(
                icon,
                style: const TextStyle(
                  fontSize: 27,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xff00a0c0),
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildQuantity(
    String title,
    String subtitle,
    int value,
    Function(int) onChange,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        0,
        20,
        10,
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.04),
              blurRadius: 7,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                quantityButton(
                  '−',
                  () => onChange(-1),
                ),
                SizedBox(
                  width: 38,
                  child: Text(
                    '$value',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                quantityButton(
                  '+',
                  () => onChange(1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget quantityButton(
    String text,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xff00a0c0),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget buildSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xff0077b6),
              Color(0xff00b4d8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '📋 Ringkasan Pesanan',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: 12),

            summaryRow(
              'Tiket Dewasa × $qtyAdult',
              rupiah(qtyAdult * adultPrice),
            ),

            if (qtyChild > 0)
              summaryRow(
                'Tiket Anak × $qtyChild',
                'Gratis',
              ),

            summaryRow(
              'Tanggal',
              selectedDate == null
                  ? '—'
                  : formatShortDate(selectedDate!),
            ),

            summaryRow(
              'Biaya Admin',
              rupiah(adminFee),
            ),

            const Divider(
              color: Colors.white24,
            ),

            summaryRow(
              'Total Pembayaran',
              rupiah(totalPrice),
              total: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget summaryRow(
    String label,
    String value, {
    bool total = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: total ? 14 : 12,
              fontWeight:
                  total ? FontWeight.w700 : null,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: total
                  ? const Color(0xffffd166)
                  : Colors.white,
              fontSize: total ? 20 : 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STEP 4 PAYMENT
  // ============================================================

  Widget buildStep4() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            0,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xffe8f9fc),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '📅 ${selectedDateLabel.isEmpty ? '—' : selectedDateLabel}  |  🎟️ $qtyAdult Dewasa${qtyChild > 0 ? ', $qtyChild Anak' : ''}  |  💰 ${rupiah(totalPrice)}',
              style: const TextStyle(
                color: Color(0xff00a0c0),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        sectionTitle('💳 Metode Pembayaran'),

        paymentMethod(
          '🏦',
          'Transfer Bank',
          'Virtual Account BRI, BCA, Mandiri, BNI, dll',
          'bank',
        ),

        paymentMethod(
          '📱',
          'QRIS / Dompet Digital',
          'GoPay, OVO, ShopeePay, Dana, LinkAja',
          'qris',
        ),

        if (payMethod == 'bank') ...[
          sectionTitle('Pilih Bank'),

          buildPaymentGrid([
            'BRI',
            'BCA',
            'Mandiri',
            'BNI',
            'BTN',
            'Permata',
          ]),
        ] else ...[
          sectionTitle('Pilih Dompet Digital'),

          buildPaymentGrid([
            'GoPay',
            'OVO',
            'ShopeePay',
            'DANA',
            'LinkAja',
            'AstraPay',
          ]),
        ],

        Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            0,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xffe8f9fc),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xff00b4d8)
                    .withOpacity(.25),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  '📋 Nomor Virtual Account / Kode Bayar',
                  style: TextStyle(
                    color: Color(0xff00a0c0),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  payMethod == 'bank'
                      ? '$selectedBank — 5678123456789012'
                      : '📱 Scan QRIS',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  payMethod == 'bank'
                      ? 'Bayar tepat sesuai nominal termasuk kode unik.'
                      : 'Total: ${rupiah(totalPrice)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Selesaikan pembayaran dalam 60 menit setelah konfirmasi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),

        buildSummary(),

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Row(
            children: [
              OutlinedButton(
                onPressed: () => goStep(3),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 15,
                  ),
                ),
                child: const Text('← Kembali'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xff00b4d8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    '✅ Konfirmasi Pembayaran',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget paymentMethod(
    String icon,
    String title,
    String subtitle,
    String value,
  ) {
    final selected = payMethod == value;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        0,
        20,
        10,
      ),
      child: GestureDetector(
        onTap: () {
          setState(() {
            payMethod = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xffe8f9fc)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? const Color(0xff00b4d8)
                  : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xffe8f9fc),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: const TextStyle(
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? const Color(0xff00b4d8)
                      : Colors.transparent,
                  border: Border.all(
                    color: selected
                        ? const Color(0xff00b4d8)
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: selected
                    ? const Icon(
                        Icons.circle,
                        size: 8,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPaymentGrid(List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics:
            const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.25,
        ),
        itemBuilder: (context, index) {
          final item = items[index];

          final selected = payMethod == 'bank'
              ? selectedBank == item
              : selectedWallet == item;

          return GestureDetector(
            onTap: () {
              setState(() {
                if (payMethod == 'bank') {
                  selectedBank = item;
                } else {
                  selectedWallet = item;
                }
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xffe8f9fc)
                    : Colors.white,
                borderRadius:
                    BorderRadius.circular(14),
                border: Border.all(
                  color: selected
                      ? const Color(0xff00b4d8)
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Text(
                    payMethod == 'bank'
                        ? '🏦'
                        : '📱',
                    style: const TextStyle(
                      fontSize: 21,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    payMethod == 'bank'
                        ? 'VA'
                        : 'QRIS',
                    style: const TextStyle(
                      fontSize: 8,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // STEP 5 RECEIPT
  // ============================================================

  Widget buildStep5() {
    final via = payMethod == 'bank'
        ? 'Transfer $selectedBank'
        : selectedWallet;

    return Column(
      children: [
        const SizedBox(height: 10),

        const Text(
          '🎉',
          style: TextStyle(
            fontSize: 55,
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          'Pembayaran Berhasil!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 4),

        const Text(
          'Tiket Anda sudah aktif dan siap digunakan',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 18),

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.12),
                  blurRadius: 25,
                ),
              ],
            ),
            child: Column(
              children: [
                // RECEIPT HEADER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xff0077b6),
                        Color(0xff00b4d8),
                      ],
                    ),
                    borderRadius:
                        BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '🌊',
                        style: TextStyle(
                          fontSize: 32,
                        ),
                      ),
                      const Text(
                        'Tiaraswim',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Water Park • Kolam Renang Premium',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xff06d6a0,
                          ).withOpacity(.2),
                          borderRadius:
                              BorderRadius.circular(50),
                        ),
                        child: const Text(
                          '✅ PEMBAYARAN BERHASIL',
                          style: TextStyle(
                            color: Color(0xff06d6a0),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // RECEIPT BODY
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'NOMOR TIKET',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        ticketId,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Divider(),

                      receiptRow(
                        'Nama Pemesan',
                        nama.isEmpty ? '-' : nama,
                      ),

                      receiptRow(
                        'No. Telepon',
                        telepon.isEmpty
                            ? '-'
                            : '+62 $telepon',
                      ),

                      receiptRow(
                        'Alamat',
                        alamat.isEmpty ? '-' : alamat,
                      ),

                      receiptRow(
                        'Tanggal Kunjungan',
                        selectedDateLabel.isEmpty
                            ? '-'
                            : selectedDateLabel,
                      ),

                      receiptRow(
                        'Kategori',
                        category == 'dewasa'
                            ? 'Dewasa'
                            : 'Anak-anak',
                      ),

                      receiptRow(
                        'Jumlah',
                        '$qtyAdult Dewasa',
                      ),

                      if (qtyChild > 0)
                        receiptRow(
                          'Anak-anak',
                          '$qtyChild Anak (Gratis)',
                        ),

                      if (keterangan.isNotEmpty)
                        receiptRow(
                          'Keterangan',
                          keterangan,
                        ),

                      receiptRow(
                        'Biaya Admin',
                        rupiah(adminFee),
                      ),

                      const SizedBox(height: 10),

                      Container(
                        padding:
                            const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          gradient:
                              const LinearGradient(
                            colors: [
                              Color(0xff0077b6),
                              Color(0xff00b4d8),
                            ],
                          ),
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            const Text(
                              'Total Dibayarkan',
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                            Text(
                              rupiah(totalPrice),
                              style: const TextStyle(
                                color:
                                    Color(0xffffd166),
                                fontSize: 21,
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        'Dibayar via $via',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        'Waktu: $paymentTime',
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                // FOOTER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xffe8f9fc)
                        .withOpacity(.5),
                    borderRadius:
                        const BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
                  ),
                  child: const Text(
                    '⚠️ Tunjukkan struk ini kepada petugas di pintu masuk.\n'
                    'Tiket berlaku pada tanggal kunjungan yang tertera.\n'
                    'Hubungi kami di 0812-3456-7890 jika ada kendala.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 15),

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    showMessage(
                      '📥 Struk berhasil disimpan',
                    );
                  },
                  icon: const Icon(
                    Icons.download_outlined,
                  ),
                  label: const Text('Unduh Struk'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    showMessage(
                      '📤 Struk siap dibagikan',
                    );
                  },
                  icon: const Icon(
                    Icons.share_outlined,
                  ),
                  label: const Text('Bagikan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xff00b4d8),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (myTickets.isNotEmpty) {
                  openReschedule(0);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xffeeeaff),
                foregroundColor:
                    const Color(0xff6c52d9),
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                ),
              ),
              child: const Text(
                '🔄 Reschedule Tiket Ini',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget receiptRow(
    String label,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 9,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TIKET SAYA
  // ============================================================

  Widget buildMyTickets() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        bottom: 25,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          buildTabs(),

          const Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              12,
            ),
            child: Text(
              '📋 Tiket Saya',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          ...List.generate(
            myTickets.length,
            (index) {
              return buildTicketCard(
                index,
                myTickets[index],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildTicketCard(
    int index,
    Map<String, dynamic> ticket,
  ) {
    final active = ticket['status'] == 'Aktif';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        0,
        20,
        12,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.04),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${ticket['id']}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ticket['name'].toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xffe3fff7)
                        : Colors.grey.shade100,
                    borderRadius:
                        BorderRadius.circular(50),
                  ),
                  child: Text(
                    active
                        ? '✅ Aktif'
                        : '⬛ Terpakai',
                    style: TextStyle(
                      color: active
                          ? const Color(0xff087f65)
                          : Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            if ((ticket['reschedule'] as int) > 0) ...[
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffeeeaff),
                  borderRadius:
                      BorderRadius.circular(50),
                ),
                child: Text(
                  '🔄 Pernah Reschedule ${ticket['reschedule']}×',
                  style: const TextStyle(
                    color: Color(0xff6c52d9),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 10),

            ticketInfo(
              '📅',
              'Tanggal Kunjungan',
              ticket['date'].toString(),
            ),

            ticketInfo(
              '👥',
              'Jumlah',
              ticket['qty'].toString(),
            ),

            ticketInfo(
              '💳',
              'Bayar via',
              ticket['payment'].toString(),
            ),

            ticketInfo(
              '💰',
              'Total',
              rupiah(ticket['total'] as int),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      showReceiptFromTicket(ticket);
                    },
                    icon: const Icon(
                      Icons.receipt_long,
                      size: 17,
                    ),
                    label: const Text(
                      'Lihat Struk',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ),
                if (active) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          openReschedule(index),
                      icon: const Icon(
                        Icons.sync,
                        size: 17,
                      ),
                      label: const Text(
                        'Reschedule',
                        style: TextStyle(
                          fontSize: 11,
                        ),
                      ),
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xffeeeaff),
                        foregroundColor:
                            const Color(0xff6c52d9),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget ticketInfo(
    String icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 5,
      ),
      child: Row(
        children: [
          Text(
            icon,
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RECEIPT TICKET
  // ============================================================

  void showReceiptFromTicket(
    Map<String, dynamic> ticket,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height:
              MediaQuery.of(context).size.height * .75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '🧾 Struk Pembayaran',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                receiptRow(
                  'Nomor Tiket',
                  ticket['id'].toString(),
                ),
                receiptRow(
                  'Kategori',
                  ticket['name'].toString(),
                ),
                receiptRow(
                  'Tanggal',
                  ticket['date'].toString(),
                ),
                receiptRow(
                  'Jumlah',
                  ticket['qty'].toString(),
                ),
                receiptRow(
                  'Pembayaran',
                  ticket['payment'].toString(),
                ),
                receiptRow(
                  'Total',
                  rupiah(ticket['total'] as int),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xff00b4d8),
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                    ),
                    child: const Text('Tutup'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // RECAP DATE
  // ============================================================

  Widget recapDate() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        0,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: const Color(0xffe8f9fc),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          selectedDate == null
              ? '📅 —'
              : '📅 $selectedDateLabel — ${isWeekend ? 'Weekend' : 'Weekday'}',
          style: const TextStyle(
            color: Color(0xff00a0c0),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        16,
        20,
        10,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FORM FIELD
  // ============================================================

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    String? prefix,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
            prefixIcon: icon != null
                ? Icon(
                    icon,
                    size: 18,
                    color: Colors.grey,
                  )
                : prefix != null
                    ? Padding(
                        padding:
                            const EdgeInsets.only(
                          left: 14,
                          right: 5,
                        ),
                        child: Text(
                          prefix,
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      )
                    : null,
            prefixIconConstraints:
                prefix != null
                    ? const BoxConstraints(
                        minWidth: 0,
                        minHeight: 0,
                      )
                    : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),
            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),
            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xff00b4d8),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: 3,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xff00a0c0),
      unselectedItemColor: Colors.grey,
      selectedFontSize: 10,
      unselectedFontSize: 10,
      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const HomePage(),
            ),
          );
        }

        if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const ExplorePage(),
            ),
          );
        }

        if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const PetaPage(),
            ),
          );
        }

        if (index == 4) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const ReviewPage(),
            ),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Text('🏠'),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Text('🏊'),
          label: 'Explore',
        ),
        BottomNavigationBarItem(
          icon: Text('🗺️'),
          label: 'Peta',
        ),
        BottomNavigationBarItem(
          icon: Text('🎟️'),
          label: 'Tiket',
        ),
        BottomNavigationBarItem(
          icon: Text('⭐'),
          label: 'Ulasan',
        ),
      ],
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    namaController.dispose();
    teleponController.dispose();
    alamatController.dispose();
    keteranganController.dispose();

    super.dispose();
  }
}