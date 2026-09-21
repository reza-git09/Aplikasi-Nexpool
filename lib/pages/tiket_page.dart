import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'home_page.dart';
import 'explore_page.dart';
import 'peta_page.dart';
import 'review_page.dart';

const kBlue = Color(0xff00b4d8);
const kDarkBlue = Color(0xff0077b6);
const kAqua = Color(0xff00a0c0);
const kSoft = Color(0xffe8f9fc);
const kGreen = Color(0xff06d6a0);
const kGold = Color(0xffffd166);
const kPurple = Color(0xff6c52d9);
const kPurpleSoft = Color(0xffeeeaff);
const kYellowSoft = Color(0xfffff8df);
const kGradient = LinearGradient(colors: [kDarkBlue, kBlue]);
const kDayShort = ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'];

class TiketPage extends StatefulWidget {
  /// Pool yang dipilih.
  ///
  /// Default:
  /// pool_id_01 = Tiara Park
  const TiketPage({
    super.key,
    this.poolId = 'pool_id_01',
    this.poolName = 'Tiara Park',
  });

  final String poolId;
  final String poolName;

  @override
  State<TiketPage> createState() => _TiketPageState();
}

class _TiketPageState extends State<TiketPage> {
  // ============================ STATE ============================

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

  int weekdayPrice = 0;
  int weekendPrice = 0;

  bool isPriceLoading = true;
  String priceError = '';

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

  final namaController = TextEditingController();
  final teleponController = TextEditingController();
  final alamatController = TextEditingController();
  final keteranganController = TextEditingController();

  @override
  void initState() {
    super.initState();

    debugPrint('====================================');
    debugPrint('TIKET PAGE INIT');
    debugPrint('Pool ID   : ${widget.poolId}');
    debugPrint('Pool Name : ${widget.poolName}');
    debugPrint('====================================');

    loadHargaTiket();
  }

  @override
  void dispose() {
    namaController.dispose();
    teleponController.dispose();
    alamatController.dispose();
    keteranganController.dispose();
    super.dispose();
  }

  // ======================= LOAD HARGA API ========================

  Future<void> loadHargaTiket() async {
    try {
      if (mounted) {
        setState(() {
          isPriceLoading = true;
          priceError = '';
        });
      }

      debugPrint('====================================');
      debugPrint('MENGAMBIL HARGA TIKET DARI API');
      debugPrint('API: ${ApiService.baseUrl}/harga-tiket');
      debugPrint('Pool ID yang dipilih: ${widget.poolId}');
      debugPrint('====================================');

      final data = await ApiService.getHargaTiket();

      debugPrint('=== DATA HARGA TIKET API ===');
      debugPrint('$data');
      debugPrint('Jumlah data harga: ${data.length}');
      debugPrint('====================================');

      int weekday = 0;
      int weekend = 0;

      for (final item in data) {
        final poolId = item['pool_id']?.toString() ?? '';
        final kategori = item['kategori']?.toString().toLowerCase() ?? '';
        final jenisHari =
            item['jenis_hari']?.toString().toLowerCase() ?? '';

        final hargaString = item['harga']?.toString() ?? '0';

        final harga = double.tryParse(hargaString)?.round() ?? 0;

        debugPrint(
          'Pool: $poolId | '
          'Kategori: ${item['kategori']} | '
          'Hari: ${item['jenis_hari']} | '
          'Harga: Rp$harga',
        );

        // Hanya ambil harga untuk pool yang sedang dipilih.
        if (poolId != widget.poolId) {
          continue;
        }

        // Saat ini halaman tiket menggunakan harga Dewasa.
        if (kategori != 'dewasa') {
          continue;
        }

        if (jenisHari == 'weekday') {
          weekday = harga;
        }

        if (jenisHari == 'weekend') {
          weekend = harga;
        }
      }

      debugPrint('====================================');
      debugPrint('HASIL FILTER HARGA');
      debugPrint('Pool      : ${widget.poolName}');
      debugPrint('Pool ID   : ${widget.poolId}');
      debugPrint('Weekday   : Rp$weekday');
      debugPrint('Weekend   : Rp$weekend');
      debugPrint('====================================');

      if (!mounted) return;

      setState(() {
        weekdayPrice = weekday;
        weekendPrice = weekend;
        isPriceLoading = false;

        if (weekday == 0 && weekend == 0) {
          priceError =
              'Harga tiket untuk ${widget.poolName} belum tersedia.';
        } else {
          priceError = '';
        }
      });
    } catch (e) {
      debugPrint('====================================');
      debugPrint('❌ GAGAL MENGAMBIL HARGA TIKET');
      debugPrint('$e');
      debugPrint('====================================');

      if (!mounted) return;

      setState(() {
        isPriceLoading = false;
        priceError = 'Gagal mengambil harga tiket dari server.';
      });
    }
  }

  // ===================== PRICE & FORMATTER =======================

  int get adultPrice => isWeekend ? weekendPrice : weekdayPrice;

  int get adminFee => 2000;

  int get totalPrice => (qtyAdult * adultPrice) + adminFee;

  String rupiah(int value) {
    return 'Rp${value.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m.group(1)}.',
        )}';
  }

  static const _days = [
    'Minggu',
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
  ];

  static const _months = [
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
    'Desember',
  ];

  String formatDate(DateTime d) {
    return '${_days[d.weekday % 7]}, '
        '${d.day} ${_months[d.month - 1]} ${d.year}';
  }

  String formatShortDate(DateTime d) {
    return '${d.day} ${_months[d.month - 1].substring(0, 3)} ${d.year}';
  }

  bool isWeekendDate(DateTime d) {
    return d.weekday == DateTime.saturday ||
        d.weekday == DateTime.sunday;
  }

  bool sameDay(DateTime? a, DateTime b) {
    return a != null &&
        a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  List<DateTime> datesFrom(int count, {int offset = 0}) {
    final t = DateTime.now();

    return List.generate(
      count,
      (i) => DateTime(
        t.year,
        t.month,
        t.day + i + offset,
      ),
    );
  }

  List<DateTime> get dates => datesFrom(30);

  // ========================== ACTIONS ============================

  void selectDate(DateTime date) {
    setState(() {
      selectedDate = date;
      selectedDateLabel = formatDate(date);
      isWeekend = isWeekendDate(date);
    });
  }

  void goStep(int step) {
    setState(() {
      currentStep = step;
    });

    if (step == 5) {
      generateReceipt();
    }
  }

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

  String get _newTicketId {
    return 'TWS-${DateTime.now().millisecondsSinceEpoch.toString().substring(4)}';
  }

  void processPayment() {
    if (adultPrice <= 0) {
      showMessage(
        'Harga tiket untuk ${isWeekend ? 'Weekend' : 'Weekday'} belum tersedia.',
      );
      return;
    }

    ticketId = _newTicketId;

    final n = DateTime.now();

    paymentTime = '${n.day}/${n.month}/${n.year} '
        '${n.hour.toString().padLeft(2, '0')}:'
        '${n.minute.toString().padLeft(2, '0')} WIB';

    goStep(5);
  }

  void generateReceipt() {
    if (ticketId.isEmpty) {
      ticketId = _newTicketId;
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ====================== SHARED WIDGETS =========================

  Widget infoBox({
    required Widget child,
    Color color = kSoft,
    double radius = 12,
    double pad = 12,
    Color? border,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: border == null
            ? null
            : Border.all(color: border),
      ),
      child: child,
    );
  }

  Widget pad20(
    Widget child, {
    double top = 0,
    double bottom = 0,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, top, 20, bottom),
      child: child,
    );
  }

  Widget sectionTitle(String title) {
    return pad20(
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      top: 16,
      bottom: 10,
    );
  }

  ButtonStyle get primaryStyle {
    return ElevatedButton.styleFrom(
      backgroundColor: kBlue,
      foregroundColor: Colors.white,
      disabledBackgroundColor: Colors.grey.shade300,
      padding: const EdgeInsets.symmetric(vertical: 15),
    );
  }

  Widget dateChip(
    DateTime date,
    bool selected,
    VoidCallback onTap,
  ) {
    final weekend = isWeekendDate(date);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 58,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? kBlue : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? kBlue
                : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              kDayShort[date.weekday - 1],
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
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
  }

  Widget dateStrip({
    required List<DateTime> list,
    required DateTime? active,
    required ValueChanged<DateTime> onPick,
    double height = 92,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        padding: padding,
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          return dateChip(
            list[i],
            sameDay(active, list[i]),
            () => onPick(list[i]),
          );
        },
      ),
    );
  }

  Widget navButtons(
    int backStep,
    String label,
    VoidCallback? onNext,
  ) {
    return pad20(
      Row(
        children: [
          OutlinedButton(
            onPressed: () => goStep(backStep),
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
              onPressed: onNext,
              style: primaryStyle,
              child: Text(label),
            ),
          ),
        ],
      ),
    );
  }

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

  Widget recapDate() {
    return pad20(
      infoBox(
        pad: 11,
        child: Text(
          selectedDate == null
              ? '📅 —'
              : '📅 $selectedDateLabel — '
                  '${isWeekend ? 'Weekend' : 'Weekday'}',
          style: const TextStyle(
            color: kAqua,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
      top: 12,
    );
  }

  // =========================== BUILD =============================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5fbfd),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                20,
                22,
                20,
                22,
              ),
              decoration: const BoxDecoration(
                gradient: kGradient,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Reservasi Tiket 🎟️',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pesan tiket ${widget.poolName} secara online',
                          style: const TextStyle(
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
            Expanded(
              child: selectedTab == 0
                  ? buildBuyTicket()
                  : buildMyTickets(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavigation(),
    );
  }

  Widget buildBuyTicket() {
    final steps = <int, Widget Function()>{
      1: buildStep1,
      2: buildStep2,
      3: buildStep3,
      4: buildStep4,
      5: buildStep5,
    };

    return SingleChildScrollView(
      child: Column(
        children: [
          buildTabs(),
          const SizedBox(height: 8),
          buildStepIndicator(),
          steps[currentStep]!(),
          const SizedBox(height: 25),
        ],
      ),
    );
  }

  // ============================ TABS =============================

  Widget buildTabs() {
    Widget tab(
      int index,
      String label,
    ) {
      return Expanded(
        child: GestureDetector(
          onTap: () {
            setState(() {
              selectedTab = index;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              gradient: selectedTab == index
                  ? kGradient
                  : null,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selectedTab == index
                    ? Colors.white
                    : Colors.grey,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ),
      );
    }

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
          tab(0, '🎫 Beli Tiket'),
          const SizedBox(width: 4),
          tab(1, '📋 Tiket Saya'),
        ],
      ),
    );
  }

  // ======================= STEP INDICATOR ========================

  Widget buildStepIndicator() {
    const labels = [
      'Tanggal',
      'Data Diri',
      'Tiket',
      'Bayar',
      'Selesai',
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 8),
      child: Row(
        children: List.generate(5, (index) {
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
                              ? kGreen
                              : active
                                  ? kBlue
                                  : Colors.grey.shade300,
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
                              ? kAqua
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
                        ? kBlue
                        : Colors.grey.shade300,
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ============================ STEP 1 ===========================

  Widget buildStep1() {
    return Column(
      children: [
        sectionTitle('📍 Kolam Renang'),

        pad20(
          infoBox(
            color: Colors.white,
            radius: 16,
            pad: 15,
            border: Colors.grey.shade200,
            child: Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: kSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.pool_rounded,
                    color: kAqua,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.poolName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Pool ID: ${widget.poolId}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.verified_rounded,
                  color: kGreen,
                  size: 20,
                ),
              ],
            ),
          ),
          bottom: 4,
        ),

        sectionTitle('📅 Pilih Tanggal Kunjungan'),

        dateStrip(
          list: dates,
          active: selectedDate,
          onPick: selectDate,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
        ),

        pad20(
          infoBox(
            child: Text(
              selectedDate == null
                  ? '📅 Pilih tanggal di atas'
                  : '📅 $selectedDateLabel — '
                      '${isWeekend ? 'Weekend' : 'Weekday'}',
              style: const TextStyle(
                color: kAqua,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          top: 8,
          bottom: 15,
        ),

        pad20(
          infoBox(
            color: Colors.white,
            radius: 16,
            pad: 16,
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
                      kGreen,
                    ),
                    const SizedBox(width: 10),
                    quotaBox(
                      '500',
                      'Total Kuota',
                      kBlue,
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

        pad20(
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedDate == null
                  ? null
                  : () => goStep(2),
              style: primaryStyle.copyWith(
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(vertical: 16),
                ),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
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

  // ============================ STEP 2 ===========================

  Widget buildStep2() {
    return Column(
      children: [
        recapDate(),

        sectionTitle('👤 Data Diri Pemesan'),

        pad20(
          infoBox(
            color: Colors.white,
            radius: 20,
            pad: 18,
            border: Colors.grey.shade200,
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

        pad20(
          infoBox(
            child: const Text(
              '🔒 Data diri Anda hanya digunakan untuk keperluan '
              'reservasi tiket dan tidak akan dibagikan kepada '
              'pihak ketiga.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
          ),
          top: 10,
        ),

        const SizedBox(height: 16),

        navButtons(
          1,
          'Lanjut Pilih Tiket →',
          () {
            if (validateData()) {
              goStep(3);
            }
          },
        ),
      ],
    );
  }

  // ============================ STEP 3 ===========================

  Widget buildStep3() {
    final hargaTersedia = adultPrice > 0;

    return Column(
      children: [
        recapDate(),

        sectionTitle('🎫 Kategori Tiket'),

        if (isPriceLoading)
          pad20(
            const Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Mengambil harga tiket dari server...',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            top: 8,
            bottom: 8,
          ),

        if (!isPriceLoading && priceError.isNotEmpty)
          pad20(
            infoBox(
              color: Colors.red.shade50,
              radius: 10,
              pad: 10,
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.shade700,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      priceError,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            top: 8,
            bottom: 8,
          ),

        if (!isPriceLoading &&
            priceError.isEmpty &&
            !hargaTersedia)
          pad20(
            infoBox(
              color: Colors.orange.shade50,
              radius: 10,
              pad: 10,
              child: const Text(
                '⚠️ Harga tiket untuk tanggal yang dipilih '
                'belum tersedia di server.',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xff9a6c00),
                ),
              ),
            ),
            top: 8,
            bottom: 8,
          ),

        pad20(
          Row(
            children: [
              categoryCard(
                '🏊',
                'Dewasa',
                isPriceLoading
                    ? 'Memuat...'
                    : adultPrice > 0
                        ? rupiah(adultPrice)
                        : 'Belum tersedia',
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

        pad20(
          infoBox(
            color: kYellowSoft,
            radius: 10,
            pad: 10,
            child: Text(
              '⚠️ Harga ${isWeekend ? 'weekend' : 'weekday'} '
              'untuk ${widget.poolName} mengikuti data server. '
              'Anak ≤100cm gratis.',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xff7a5800),
              ),
            ),
          ),
          top: 10,
        ),

        sectionTitle('👥 Jumlah Tiket'),

        buildQuantity(
          'Dewasa',
          'Tinggi > 100cm',
          qtyAdult,
          (v) {
            setState(() {
              qtyAdult =
                  (qtyAdult + v).clamp(0, 20);
            });
          },
        ),

        buildQuantity(
          'Anak-anak',
          'Tinggi ≤ 100cm (Gratis)',
          qtyChild,
          (v) {
            setState(() {
              qtyChild =
                  (qtyChild + v).clamp(0, 20);
            });
          },
        ),

        sectionTitle('📝 Keterangan Tiket (Opsional)'),

        pad20(
          TextField(
            controller: keteranganController,
            maxLength: 200,
            maxLines: 4,
            onChanged: (v) {
              keterangan = v;
            },
            decoration: InputDecoration(
              hintText:
                  'Contoh: Kunjungan ulang tahun, grup keluarga, '
                  'atau catatan khusus...',
              filled: true,
              fillColor: Colors.white,
              border: fieldBorder(),
              enabledBorder: fieldBorder(),
            ),
          ),
        ),

        const SizedBox(height: 4),

        buildSummary(),

        navButtons(
          2,
          'Lanjut Pembayaran →',
          isPriceLoading ||
                  priceError.isNotEmpty ||
                  adultPrice <= 0 ||
                  qtyAdult <= 0
              ? null
              : () => goStep(4),
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
            color: selected ? kSoft : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? kBlue
                  : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 27),
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
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: kAqua,
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
    ValueChanged<int> onChange,
  ) {
    return pad20(
      infoBox(
        color: Colors.white,
        radius: 14,
        pad: 14,
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
      ),
      bottom: 10,
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
              color: kAqua,
            ),
          ),
        ),
      ),
    );
  }

  // =========================== SUMMARY ===========================

  Widget buildSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: kGradient,
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
              'Kolam',
              widget.poolName,
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
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontSize: total ? 14 : 12,
                fontWeight:
                    total ? FontWeight.w700 : null,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: total ? kGold : Colors.white,
              fontSize: total ? 20 : 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ============================ STEP 4 ===========================

  Widget buildStep4() {
    final isBank = payMethod == 'bank';

    return Column(
      children: [
        pad20(
          infoBox(
            pad: 11,
            child: Text(
              '📍 ${widget.poolName}  |  '
              '📅 ${selectedDateLabel.isEmpty ? '—' : selectedDateLabel}  |  '
              '🎟️ $qtyAdult Dewasa'
              '${qtyChild > 0 ? ', $qtyChild Anak' : ''}  |  '
              '💰 ${rupiah(totalPrice)}',
              style: const TextStyle(
                color: kAqua,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          top: 12,
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

        sectionTitle(
          isBank
              ? 'Pilih Bank'
              : 'Pilih Dompet Digital',
        ),

        buildPaymentGrid(
          isBank
              ? [
                  'BRI',
                  'BCA',
                  'Mandiri',
                  'BNI',
                  'BTN',
                  'Permata',
                ]
              : [
                  'GoPay',
                  'OVO',
                  'ShopeePay',
                  'DANA',
                  'LinkAja',
                  'AstraPay',
                ],
        ),

        pad20(
          infoBox(
            radius: 14,
            pad: 15,
            child: Column(
              children: [
                const Text(
                  '📋 Nomor Virtual Account / Kode Bayar',
                  style: TextStyle(
                    color: kAqua,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isBank
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
                  isBank
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
                  'Selesaikan pembayaran dalam 60 menit '
                  'setelah konfirmasi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          top: 10,
        ),

        buildSummary(),

        navButtons(
          3,
          '✅ Konfirmasi Pembayaran',
          adultPrice <= 0 ? null : processPayment,
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

    return pad20(
      GestureDetector(
        onTap: () {
          setState(() {
            payMethod = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? kSoft : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? kBlue
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
                  color: kSoft,
                  borderRadius: BorderRadius.circular(12),
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
                      ? kBlue
                      : Colors.transparent,
                  border: Border.all(
                    color: selected
                        ? kBlue
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
      bottom: 10,
    );
  }

  Widget buildPaymentGrid(
    List<String> items,
  ) {
    final isBank = payMethod == 'bank';

    return pad20(
      GridView.builder(
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
        itemBuilder: (_, index) {
          final item = items[index];

          final selected = isBank
              ? selectedBank == item
              : selectedWallet == item;

          return GestureDetector(
            onTap: () {
              setState(() {
                if (isBank) {
                  selectedBank = item;
                } else {
                  selectedWallet = item;
                }
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: selected
                    ? kSoft
                    : Colors.white,
                borderRadius:
                    BorderRadius.circular(14),
                border: Border.all(
                  color: selected
                      ? kBlue
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Text(
                    isBank ? '🏦' : '📱',
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
                    isBank ? 'VA' : 'QRIS',
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

  // ======================= STEP 5 RECEIPT ========================

  Widget buildStep5() {
    final via = payMethod == 'bank'
        ? 'Transfer $selectedBank'
        : selectedWallet;

    return Column(
      children: [
        const SizedBox(height: 10),

        const Text(
          '🎉',
          style: TextStyle(fontSize: 55),
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
          padding:
              const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(22),
                  decoration: const BoxDecoration(
                    gradient: kGradient,
                    borderRadius:
                        BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '🌊',
                        style:
                            TextStyle(fontSize: 32),
                      ),
                      Text(
                        widget.poolName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight:
                              FontWeight.w800,
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
                          color:
                              kGreen.withOpacity(.2),
                          borderRadius:
                              BorderRadius.circular(50),
                        ),
                        child: const Text(
                          '✅ PEMBAYARAN BERHASIL',
                          style: TextStyle(
                            color: kGreen,
                            fontSize: 10,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding:
                      const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'NOMOR TIKET',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey,
                          fontWeight:
                              FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        ticketId,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight:
                              FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Divider(),

                      receiptRow(
                        'Kolam Renang',
                        widget.poolName,
                      ),

                      receiptRow(
                        'Pool ID',
                        widget.poolId,
                      ),

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
                        alamat.isEmpty
                            ? '-'
                            : alamat,
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
                        'Harga Tiket',
                        rupiah(adultPrice),
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
                          gradient: kGradient,
                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            const Text(
                              'Total Dibayarkan',
                              style: TextStyle(
                                color:
                                    Colors.white70,
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                            Text(
                              rupiah(totalPrice),
                              style:
                                  const TextStyle(
                                color: kGold,
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

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color:
                        kSoft.withOpacity(.5),
                    borderRadius:
                        const BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
                  ),
                  child: const Text(
                    '⚠️ Tunjukkan struk ini kepada petugas '
                    'di pintu masuk.\n'
                    'Tiket berlaku pada tanggal kunjungan '
                    'yang tertera.\n'
                    'Hubungi kami di 0812-3456-7890 '
                    'jika ada kendala.',
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
          padding:
              const EdgeInsets.symmetric(horizontal: 16),
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
                  label:
                      const Text('Unduh Struk'),
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
                  label:
                      const Text('Bagikan'),
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor: kBlue,
                    foregroundColor:
                        Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (myTickets.isNotEmpty) {
                  openReschedule(0);
                }
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor: kPurpleSoft,
                foregroundColor: kPurple,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(
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
      padding:
          const EdgeInsets.symmetric(vertical: 8),
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

  // ========================= TIKET SAYA ==========================

  Widget buildMyTickets() {
    return SingleChildScrollView(
      padding:
          const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          buildTabs(),

          const Padding(
            padding:
                EdgeInsets.fromLTRB(20, 20, 20, 12),
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
            (i) => buildTicketCard(
              i,
              myTickets[i],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTicketCard(
    int index,
    Map<String, dynamic> ticket,
  ) {
    final active =
        ticket['status'] == 'Aktif';

    final resched =
        ticket['reschedule'] as int;

    return pad20(
      infoBox(
        color: Colors.white,
        radius: 18,
        pad: 16,
        border: Colors.grey.shade200,
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
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ticket['name'].toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                badge(
                  active
                      ? '✅ Aktif'
                      : '⬛ Terpakai',
                  active
                      ? const Color(0xff087f65)
                      : Colors.grey,
                  active
                      ? const Color(0xffe3fff7)
                      : Colors.grey.shade100,
                  fontSize: 10,
                ),
              ],
            ),

            if (resched > 0) ...[
              const SizedBox(height: 10),
              badge(
                '🔄 Pernah Reschedule $resched×',
                kPurple,
                kPurpleSoft,
                fontSize: 9,
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
                    onPressed: () =>
                        showReceiptFromTicket(
                      ticket,
                    ),
                    icon: const Icon(
                      Icons.receipt_long,
                      size: 17,
                    ),
                    label: const Text(
                      'Lihat Struk',
                      style:
                          TextStyle(fontSize: 11),
                    ),
                  ),
                ),

                if (active) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child:
                        ElevatedButton.icon(
                      onPressed: () =>
                          openReschedule(index),
                      icon: const Icon(
                        Icons.sync,
                        size: 17,
                      ),
                      label: const Text(
                        'Reschedule',
                        style:
                            TextStyle(fontSize: 11),
                      ),
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            kPurpleSoft,
                        foregroundColor:
                            kPurple,
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
      bottom: 12,
    );
  }

  Widget badge(
    String text,
    Color fg,
    Color bg, {
    double fontSize = 10,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius:
            BorderRadius.circular(50),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
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
      padding:
          const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Text(
            icon,
            style:
                const TextStyle(fontSize: 12),
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
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ====================== RECEIPT BOTTOM SHEET ===================

  void showReceiptFromTicket(
    Map<String, dynamic> ticket,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return sheetShell(
          height: .75,
          radius: 25,
          child: Column(
            children: [
              sheetHandle(),
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
                  style: primaryStyle,
                  child:
                      const Text('Tutup'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget sheetHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius:
              BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget sheetShell({
    required Widget child,
    required double height,
    double radius = 28,
    bool safeArea = false,
  }) {
    final content = Padding(
      padding: const EdgeInsets.all(20),
      child: child,
    );

    return Container(
      height:
          MediaQuery.of(context).size.height *
              height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(radius),
        ),
      ),
      child: safeArea
          ? SafeArea(child: content)
          : content,
    );
  }

  // ========================= RESCHEDULE ==========================

  void openReschedule(int index) {
    final ticket = myTickets[index];

    DateTime? newDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (
            context,
            setModalState,
          ) {
            final availableDates =
                datesFrom(
              29,
              offset: 1,
            );

            final baseWeekday =
                weekdayPrice > 0
                    ? weekdayPrice
                    : 15000;

            final baseWeekend =
                weekendPrice > 0
                    ? weekendPrice
                    : 20000;

            final newPrice =
                newDate != null &&
                        isWeekendDate(
                          newDate!,
                        )
                    ? baseWeekend
                    : baseWeekday;

            final diff =
                (newPrice * 2 + adminFee) -
                    (baseWeekday * 2 +
                        adminFee);

            return sheetShell(
              height: .85,
              safeArea: true,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  sheetHandle(),

                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                    children: [
                      const Text(
                        '🔄 Reschedule Tiket',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            Navigator.pop(
                          context,
                        ),
                        icon: const Icon(
                          Icons.close,
                        ),
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

                  infoBox(
                    radius: 15,
                    pad: 15,
                    border:
                        kBlue.withOpacity(.25),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🎟️ INFO TIKET',
                          style: TextStyle(
                            color: kAqua,
                            fontWeight:
                                FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),

                        const SizedBox(height: 8),

                        infoRow(
                          'Kolam',
                          widget.poolName,
                        ),

                        infoRow(
                          'No. Tiket',
                          ticket['id'].toString(),
                        ),

                        infoRow(
                          'Tanggal Saat Ini',
                          ticket['date']
                              .toString(),
                        ),

                        infoRow(
                          'Kategori',
                          ticket['qty'].toString(),
                        ),

                        infoRow(
                          'Total Terbayar',
                          rupiah(
                            ticket['total']
                                as int,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  infoBox(
                    color: kYellowSoft,
                    radius: 14,
                    pad: 14,
                    border:
                        kGold.withOpacity(.5),
                    child: const Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📜 Ketentuan Reschedule',
                          style: TextStyle(
                            fontWeight:
                                FontWeight.w800,
                            color:
                                Color(0xff9a6c00),
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
                      fontWeight:
                          FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 10),

                  dateStrip(
                    list: availableDates,
                    active: newDate,
                    height: 85,
                    onPick: (d) {
                      setModalState(() {
                        newDate = d;
                      });
                    },
                  ),

                  if (newDate != null) ...[
                    const SizedBox(height: 10),

                    infoBox(
                      color:
                          const Color(0xffe8fff8),
                      child: Text(
                        '📅 ${formatDate(newDate!)}\n'
                        '${diff > 0 ? '⬆️ Harga lebih mahal ${rupiah(diff)}' : diff < 0 ? '⬇️ Harga lebih murah ${rupiah(diff.abs())}' : '✅ Harga sama'}',
                        style: const TextStyle(
                          color:
                              Color(0xff087f65),
                          fontSize: 12,
                          fontWeight:
                              FontWeight.w700,
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
                              Navigator.pop(
                            context,
                          ),
                          style:
                              OutlinedButton
                                  .styleFrom(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              vertical: 15,
                            ),
                          ),
                          child:
                              const Text(
                            'Batal',
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        flex: 2,
                        child:
                            ElevatedButton(
                          onPressed:
                              newDate == null
                                  ? null
                                  : () {
                                      setState(() {
                                        myTickets[
                                                index]
                                            [
                                            'date'] =
                                            formatShortDate(
                                          newDate!,
                                        );

                                        myTickets[
                                                index]
                                            [
                                            'reschedule'] =
                                            (myTickets[index]
                                                    [
                                                    'reschedule']
                                                as int) +
                                                1;
                                      });

                                      Navigator.pop(
                                        context,
                                      );

                                      showMessage(
                                        'Reschedule berhasil ke '
                                        '${formatShortDate(newDate!)}',
                                      );
                                    },
                          style:
                              primaryStyle,
                          child:
                              const Text(
                            '✅ Konfirmasi Reschedule',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ========================== FORM FIELD =========================

  OutlineInputBorder fieldBorder({
    Color? color,
    double width = 1,
  }) {
    return OutlineInputBorder(
      borderRadius:
          BorderRadius.circular(14),
      borderSide: BorderSide(
        color:
            color ?? Colors.grey.shade300,
        width: width,
      ),
    );
  }

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
                          style:
                              const TextStyle(
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
            border: fieldBorder(),
            enabledBorder:
                fieldBorder(),
            focusedBorder: fieldBorder(
              color: kBlue,
              width: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // ====================== BOTTOM NAVIGATION ======================

  Widget buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: 3,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: kAqua,
      unselectedItemColor: Colors.grey,
      selectedFontSize: 10,
      unselectedFontSize: 10,
      onTap: (index) {
        final pages = <int, Widget>{
          0: const HomePage(),
          1: const ExplorePage(),
          2: const PetaPage(),
          4: const ReviewPage(),
        };

        final page = pages[index];

        if (page == null) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => page,
          ),
        );
      },
      items: [
        _navItem(
          Icons.home_rounded,
          const Color(0xFF00B4D8),
          'Home',
        ),
        _navItem(
          Icons.pool_rounded,
          const Color(0xFF7B61FF),
          'Explore',
        ),
        _navItem(
          Icons.map_rounded,
          const Color(0xFF06D6A0),
          'Peta',
        ),
        _navItem(
          Icons.confirmation_number_rounded,
          const Color(0xFFFFB703),
          'Tiket',
        ),
        _navItem(
          Icons.star_rounded,
          const Color(0xFFEF476F),
          'Ulasan',
        ),
      ],
    );
  }

  BottomNavigationBarItem _navItem(
    IconData icon,
    Color color,
    String label,
  ) {
    return BottomNavigationBarItem(
      icon: _navIcon(
        icon,
        color,
        false,
      ),
      activeIcon: _navIcon(
        icon,
        color,
        true,
      ),
      label: label,
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
      decoration: BoxDecoration(
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