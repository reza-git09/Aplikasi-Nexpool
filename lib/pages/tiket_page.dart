import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' show ImageByteFormat;

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'reschedule_payment_dialog.dart';
import 'ticket_painters.dart';

part 'tiket_page_booking.dart';
part 'tiket_page_payment.dart';
part 'tiket_page_ticket_history.dart';
part 'tiket_page_reschedule.dart';

const kBlue = Color(0xff00b4d8);
const kDarkBlue = Color(0xff0077b6);
const kAqua = Color(0xff00a0c0);
const kSoft = Color(0xffe8f9fc);
const kGreen = Color(0xff06d6a0);
const kGold = Color(0xffffd166);
const kPurple = Color(0xff6c52d9);
const kPurpleSoft = Color(0xffeeeaff);
const kYellowSoft = Color(0xfffff8df);
const kOrange = Color(0xffff9f1c);
const kOrangeSoft = Color(0xfffff3e0);
const kRed = Color(0xffef476f);
const kRedSoft = Color(0xffffeef2);
const kGradient = LinearGradient(colors: [kDarkBlue, kBlue]);
const kDayShort = ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'];

final ButtonStyle primaryStyle = ElevatedButton.styleFrom(
  backgroundColor: kBlue,
  foregroundColor: Colors.white,
  elevation: 2,
  shadowColor: kBlue.withOpacity(0.4),
);

final ButtonStyle successStyle = ElevatedButton.styleFrom(
  backgroundColor: kGreen,
  foregroundColor: Colors.white,
  elevation: 2,
  shadowColor: kGreen.withOpacity(0.4),
);

const Map<String, String> kPoolIdMap = {
  'pool_id_01': 'POOL-01',
  'pool_id_02': 'POOL-02',
  'pool_id_03': 'POOL-03',
  'pool_id_04': 'POOL-04',
  'pool_id_05': 'POOL-05',
  'POOL-01': 'POOL-01',
  'POOL-02': 'POOL-02',
  'POOL-03': 'POOL-03',
  'POOL-04': 'POOL-04',
  'POOL-05': 'POOL-05',
};

const Map<String, String> kPoolNames = {
  'pool_id_01': 'Tiara Jember Park Waterboom',
  'pool_id_02': 'Pemandian Kebon Agung',
  'pool_id_03': 'Annasya Waterpark',
  'pool_id_04': 'Dira Park',
  'pool_id_05': 'Jati Park',
  'POOL-01': 'Tiara Jember Park Waterboom',
  'POOL-02': 'Pemandian Kebon Agung',
  'POOL-03': 'Annasya Waterpark',
  'POOL-04': 'Dira Park',
  'POOL-05': 'Jati Park',
};

final List<Map<String, String>> kAllPoolsList = [
  {
    'id': 'pool_id_01',
    'normalizedId': 'POOL-01',
    'name': 'Tiara Jember Park Waterboom',
    'shortName': 'Tiara Jember Park',
    'icon': '🏊',
    'location': 'Jl. Taman Air No.1, Jember',
  },
  {
    'id': 'pool_id_02',
    'normalizedId': 'POOL-02',
    'name': 'Pemandian Kebon Agung',
    'shortName': 'Kebon Agung',
    'icon': '🌿',
    'location': 'Jl. Kebon Agung, Jember',
  },
  {
    'id': 'pool_id_03',
    'normalizedId': 'POOL-03',
    'name': 'Annasya Waterpark',
    'shortName': 'Annasya Waterpark',
    'icon': '💦',
    'location': 'Jl. Annasya Water Park, Jember',
  },
  {
    'id': 'pool_id_04',
    'normalizedId': 'POOL-04',
    'name': 'Dira Park',
    'shortName': 'Dira Park',
    'icon': '🌴',
    'location': 'Jl. Dira Park, Jember',
  },
  {
    'id': 'pool_id_05',
    'normalizedId': 'POOL-05',
    'name': 'Jati Park',
    'shortName': 'Jati Park',
    'icon': '🌳',
    'location': 'Jl. Jati Park, Jember',
  },
];

String normalizePoolId(String raw) {
  return kPoolIdMap[raw] ?? raw.toUpperCase().replaceAll('_', '-');
}

String poolDisplayName(String rawId, String fallbackName) {
  return kPoolNames[rawId] ??
      kPoolNames[normalizePoolId(rawId)] ??
      fallbackName;
}

final List<Map<String, dynamic>> kEWallets = [
  {
    'id': 'gopay',
    'name': 'GoPay',
    'badge': 'Populer',
    'color': const Color(0xFF00AED6),
    'bgColor': const Color(0xFFE5F7FB),
    'icon': Icons.account_balance_wallet_rounded,
  },
  {
    'id': 'dana',
    'name': 'DANA',
    'badge': 'Instan',
    'color': const Color(0xFF118EEA),
    'bgColor': const Color(0xFFE8F4FC),
    'icon': Icons.account_balance_wallet_rounded,
  },
  {
    'id': 'ovo',
    'name': 'OVO',
    'badge': 'Promo',
    'color': const Color(0xFF4C2A86),
    'bgColor': const Color(0xFFF1EDF8),
    'icon': Icons.account_balance_wallet_rounded,
  },
  {
    'id': 'shopeepay',
    'name': 'ShopeePay',
    'badge': 'Coins',
    'color': const Color(0xFFEE4D2D),
    'bgColor': const Color(0xFFFDECE9),
    'icon': Icons.account_balance_wallet_rounded,
  },
  {
    'id': 'linkaja',
    'name': 'LinkAja!',
    'badge': 'BUMN',
    'color': const Color(0xFFED1C24),
    'bgColor': const Color(0xFFFDE8E9),
    'icon': Icons.account_balance_wallet_rounded,
  },
];

final List<Map<String, dynamic>> kBankOptions = [
  {
    'id': 'bri',
    'name': 'Bank BRI',
    'fullName': 'Bank Rakyat Indonesia',
    'vaPrefix': '88012',
    'color': const Color(0xFF005BAA),
    'bgColor': const Color(0xFFE5F0FA),
    'icon': Icons.account_balance_rounded,
  },
  {
    'id': 'bca',
    'name': 'Bank BCA',
    'fullName': 'Bank Central Asia',
    'vaPrefix': '88014',
    'color': const Color(0xFF0066AE),
    'bgColor': const Color(0xFFE6F0F8),
    'icon': Icons.account_balance_rounded,
  },
  {
    'id': 'mandiri',
    'name': 'Bank Mandiri',
    'fullName': 'Bank Mandiri Persero',
    'vaPrefix': '89012',
    'color': const Color(0xFF003366),
    'bgColor': const Color(0xFFE5EDF5),
    'icon': Icons.account_balance_rounded,
  },
  {
    'id': 'bni',
    'name': 'Bank BNI',
    'fullName': 'Bank Negara Indonesia',
    'vaPrefix': '88019',
    'color': const Color(0xFFF15A24),
    'bgColor': const Color(0xFFFEEFE9),
    'icon': Icons.account_balance_rounded,
  },
  {
    'id': 'permata',
    'name': 'Permata Bank',
    'fullName': 'Bank Permata',
    'vaPrefix': '88015',
    'color': const Color(0xFF008A44),
    'bgColor': const Color(0xFFE5F5ED),
    'icon': Icons.account_balance_rounded,
  },
];

class TiketPage extends StatefulWidget {
  /// Pool ID global yang sinkron secara otomatis dengan pilihan di dashboard
  static String globalSelectedPoolId = '';
  static String globalSelectedPoolName = '';

  /// List simpanan tiket yang sudah dipesan pengguna (dimulai dari kosong [])
  /// Tiket hanya akan muncul di Tiket Saya setelah pengguna melakukan pemesanan.
  static List<Map<String, dynamic>> savedTickets = [];

  const TiketPage({
    super.key,
    this.poolId,
    this.poolName,
    this.initialPromo,
    this.initialTab = 0,
    this.onReturnHome,
  });

  final String? poolId;
  final String? poolName;
  final Map<String, dynamic>? initialPromo;
  final int initialTab;
  final VoidCallback? onReturnHome;

  @override
  State<TiketPage> createState() => _TiketPageState();
}

class _TiketPageState extends State<TiketPage>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // LANGKAH PEMESANAN
  // Langkah 2 (Data Diri) sudah dihapus. Nomor langkah internal
  // tetap 1, 3, 4, 5 supaya sisa kode tidak berubah:
  //   1 = Tanggal, 3 = Tiket, 4 = Bayar, 5 = Struk
  // Data pemesan diambil otomatis dari akun yang login.
  // ============================================================
  int currentStep = 1;
  String? currentQrUrl;
  Future<Uint8List>? currentQrImage;
  late int selectedTab;
  String _ticketFilter = 'all';

  late String selectedPoolId;
  late String selectedPoolName;

  DateTime? selectedDate;
  String selectedDateLabel = '';
  bool isWeekend = false;

  // Data pemesan (diambil dari akun yang login)
  bool isLoggedIn = false;
  String nama = '';
  String email = '';
  String telepon = '';
  String alamat = '';
  String keterangan = '';

  String category = 'dewasa';

  int qtyAdult = 1;
  int qtyChild = 0;

  String payMethod = 'qris';
  String selectedWallet = 'gopay';
  String selectedBank = 'bri';
  String paySubStep = 'select';

  String orderId = '';
  String reservationCode = '';
  String ticketId = '';
  String statusPembayaran = 'pending';
  DateTime? paidAt;
  DateTime? reservedAt;
  bool isCreatingPayment = false;
  bool isCheckingPaymentStatus = false;
  final GlobalKey _step5ReceiptKey = GlobalKey();
  final GlobalKey _qrisCardKey = GlobalKey();
  bool _isDownloadingQris = false;
  bool _isDownloadingReceipt = false;

  // ── Timer pembayaran (5 menit tepat sesuai Midtrans) ─────────────
  static const int payDurationSeconds = 300;
  Timer? _payTimer;
  Timer? _paymentStatusTimer;
  int _remainingSeconds = payDurationSeconds;
  bool paymentExpired = false;

  int weekdayPrice = 0;
  int weekendPrice = 0;

  List<Map<String, dynamic>> _availablePromos = [];
  Map<String, dynamic>? _selectedPromo;
  bool _promosLoading = false;
  String _promoError = '';
  int _promoRequestVersion = 0;
  String _confirmedPromoName = '';
  int _confirmedPromoDiscount = 0;

  bool isPriceLoading = true;
  String priceError = '';

  late AnimationController _successAnimController;
  late Animation<double> _scaleAnimation;

  // ── Tiket Saya ──────────────────────────────────────────────────
  // Mengacu ke list global savedTickets. Dimulai kosong (0).
  List<Map<String, dynamic>> get myTickets => TiketPage.savedTickets;

  final keteranganController = TextEditingController();

  @override
  void initState() {
    super.initState();

    selectedTab = widget.initialTab;

    // Otomatis sinkronkan dengan pilihan kolam dari dashboard jika ada
    selectedPoolId = widget.poolId ?? TiketPage.globalSelectedPoolId;
    selectedPoolName = poolDisplayName(
      selectedPoolId,
      widget.poolName ?? TiketPage.globalSelectedPoolName,
    );
    _selectedPromo = widget.initialPromo == null
        ? null
        : Map<String, dynamic>.from(widget.initialPromo!);

    TiketPage.globalSelectedPoolId = selectedPoolId;
    TiketPage.globalSelectedPoolName = selectedPoolName;

    _successAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _successAnimController,
      curve: Curves.elasticOut,
    );

    debugPrint('====================================');
    debugPrint('TIKET PAGE INIT (INTEGRATED WITH DASHBOARD)');
    debugPrint('Selected Pool ID   : $selectedPoolId');
    debugPrint('Selected Pool Name : $selectedPoolName');
    debugPrint('====================================');

    _loadAccount();
    _loadSavedTickets();
    if (selectedPoolId.isNotEmpty) {
      loadHargaTiket();
      _loadAvailablePromos();
    }
  }

  @override
  void dispose() {
    _payTimer?.cancel();
    _paymentStatusTimer?.cancel();
    _successAnimController.dispose();
    keteranganController.dispose();
    super.dispose();
  }

  // ============================================================
  // DATA PEMESAN DARI AKUN YANG LOGIN
  // ============================================================
  Future<void> _loadAccount() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      nama = prefs.getString('user_name') ?? '';
      email = prefs.getString('user_email') ?? '';
      telepon = prefs.getString('user_no_hp') ?? '';
      alamat = prefs.getString('user_alamat') ?? '';
    });
  }

  String _ticketHistoryKey(SharedPreferences prefs) {
    final accountKey =
        prefs.getString('user_email') ??
        prefs.getString('user_username') ??
        prefs.getString('user_no_hp') ??
        'guest';
    return 'saved_tickets_${accountKey.trim().toLowerCase()}';
  }

  Future<void> _loadSavedTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final rawTickets = prefs.getString(_ticketHistoryKey(prefs));
    if (rawTickets == null || rawTickets.isEmpty) return;

    try {
      final decoded = jsonDecode(rawTickets);
      if (decoded is! List) {
        throw const FormatException('Format riwayat tiket bukan daftar.');
      }

      final tickets = decoded
          .whereType<Map>()
          .map((ticket) => Map<String, dynamic>.from(ticket))
          .toList();
      if (!mounted) return;
      setState(() {
        TiketPage.savedTickets = tickets;
      });
    } catch (e) {
      debugPrint('Gagal membaca riwayat tiket tersimpan: $e');
      if (mounted) showMessage('Gagal memuat riwayat tiket tersimpan.');
    }
  }

  Future<void> _persistSavedTickets() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _ticketHistoryKey(prefs),
      jsonEncode(TiketPage.savedTickets),
    );
  }

  /// Nomor HP untuk ditampilkan, contoh: 0858xxx -> +62 858xxx
  String get phoneDisplay {
    final t = telepon.trim();
    if (t.isEmpty) return '—';
    if (t.startsWith('+')) return t;
    if (t.startsWith('0')) return '+62 ${t.substring(1)}';
    if (t.startsWith('62')) return '+$t';
    return '+62 $t';
  }

  Future<void> loadHargaTiket() async {
    if (selectedPoolId.isEmpty) {
      if (!mounted) return;
      setState(() {
        weekdayPrice = 0;
        weekendPrice = 0;
        isPriceLoading = false;
        priceError = 'Pilih kolam renang terlebih dahulu.';
      });
      return;
    }

    try {
      if (mounted) {
        setState(() {
          isPriceLoading = true;
          priceError = '';
        });
      }

      final data = await ApiService.getHargaTiket();

      int weekday = 0;
      int weekend = 0;

      for (final item in data) {
        final poolId = item['pool_id']?.toString() ?? '';
        final jenisHari = item['jenis_hari']?.toString().toLowerCase() ?? '';
        final hargaString = item['harga']?.toString() ?? '0';
        final harga = double.tryParse(hargaString)?.round() ?? 0;

        if (poolId != selectedPoolId &&
            normalizePoolId(poolId) != normalizePoolId(selectedPoolId)) {
          continue;
        }

        if (jenisHari == 'weekday') weekday = harga;
        if (jenisHari == 'weekend') weekend = harga;
      }

      if (!mounted) return;

      setState(() {
        weekdayPrice = weekday;
        weekendPrice = weekend;
        isPriceLoading = false;

        if (weekday == 0 && weekend == 0) {
          priceError =
              'Harga tiket untuk $selectedPoolName belum tersedia di server.';
        } else {
          priceError = '';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isPriceLoading = false;
        if (weekdayPrice == 0 && weekendPrice == 0) {
          weekdayPrice = selectedPoolId == 'pool_id_02' ? 10000 : 15000;
          weekendPrice = selectedPoolId == 'pool_id_02' ? 15000 : 20000;
        }
        priceError = '';
      });
    }
  }

  void selectPool(String id, String name) {
    if (reservationCode.isNotEmpty) {
      showMessage('Kolam tidak dapat diubah setelah reservasi dibuat.');
      return;
    }

    setState(() {
      selectedPoolId = id;
      selectedPoolName = name;
      _selectedPromo = null;
      _confirmedPromoName = '';
      _confirmedPromoDiscount = 0;
    });
    TiketPage.globalSelectedPoolId = id;
    TiketPage.globalSelectedPoolName = name;
    loadHargaTiket();
    _loadAvailablePromos();
  }

  int get adultPrice => isWeekend ? weekendPrice : weekdayPrice;
  int get adminFee => 2000;
  int get ticketSubtotal => qtyAdult * adultPrice;
  int get discountAmount {
    final promo = _selectedPromo;
    if (promo == null) return 0;

    final discountValue =
        double.tryParse(promo['nilai_diskon']?.toString() ?? '') ?? 0;
    final discountType = promo['jenis_diskon']?.toString().toLowerCase() ?? '';
    final requestedDiscount =
        discountType == 'persentase' || discountType.contains('percent')
        ? (ticketSubtotal * discountValue / 100).round()
        : discountValue.round();

    return requestedDiscount.clamp(0, ticketSubtotal).toInt();
  }

  int get totalPrice => ticketSubtotal - discountAmount + adminFee;

  String rupiah(int value) {
    return 'Rp${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m.group(1)}.')}';
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

  String formatDate(DateTime d) =>
      '${_days[d.weekday % 7]}, ${d.day} ${_months[d.month - 1]} ${d.year}';

  String formatShortDate(DateTime d) =>
      '${d.day} ${_months[d.month - 1].substring(0, 3)} ${d.year}';

  String formatDateTime(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')} WIB';
  }

  bool isWeekendDate(DateTime d) =>
      d.weekday == DateTime.saturday || d.weekday == DateTime.sunday;

  bool sameDay(DateTime? a, DateTime b) =>
      a != null && a.year == b.year && a.month == b.month && a.day == b.day;

  List<DateTime> datesFrom(int count, {int offset = 0}) {
    final t = DateTime.now();
    return List.generate(
      count,
      (i) => DateTime(t.year, t.month, t.day + i + offset),
    );
  }

  List<DateTime> get dates => datesFrom(30);

  void selectDate(DateTime date) {
    if (reservationCode.isNotEmpty) {
      showMessage('Tanggal tidak dapat diubah setelah reservasi dibuat.');
      return;
    }

    setState(() {
      selectedDate = date;
      selectedDateLabel = formatDate(date);
      isWeekend = isWeekendDate(date);
      _confirmedPromoName = '';
      _confirmedPromoDiscount = 0;
    });
    _loadAvailablePromos();
  }

  Future<void> _loadAvailablePromos() async {
    if (selectedPoolId.isEmpty) return;

    final requestVersion = ++_promoRequestVersion;
    if (mounted) {
      setState(() {
        _promosLoading = true;
        _promoError = '';
      });
    }

    try {
      final promos = await ApiService.getPromos(
        poolId: selectedPoolId,
        visitDate: selectedDate,
      );
      if (!mounted || requestVersion != _promoRequestVersion) return;

      final selectedPromoId = _selectedPromo?['id']?.toString();
      setState(() {
        _availablePromos = promos;
        _promosLoading = false;
        if (selectedPromoId != null &&
            !promos.any(
              (promo) => promo['id']?.toString() == selectedPromoId,
            )) {
          _selectedPromo = null;
          _confirmedPromoName = '';
          _confirmedPromoDiscount = 0;
        }
      });
    } catch (error) {
      debugPrint('Gagal memuat promo tiket: $error');
      if (!mounted || requestVersion != _promoRequestVersion) return;
      setState(() {
        _availablePromos = [];
        _promoError = 'Promo tidak dapat dimuat. Coba muat ulang.';
        _promosLoading = false;
      });
    }
  }

  Future<void> _choosePromo() async {
    if (reservationCode.isNotEmpty) {
      showMessage('Promo tidak dapat diubah setelah reservasi dibuat.');
      return;
    }
    if (_promosLoading) return;
    if (_availablePromos.isEmpty) {
      showMessage(
        _promoError.isNotEmpty
            ? _promoError
            : 'Belum ada promo aktif untuk kolam dan tanggal ini.',
      );
      return;
    }

    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double sheetHeight = math.min(
      screenHeight * 0.78,
      280.0 + math.min(_availablePromos.length, 4) * 92.0,
    );

    final promo = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: Container(
          height: sheetHeight,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: sheetHandle()),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: kSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.local_offer_rounded,
                      color: kDarkBlue,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pilih Promo',
                          style: TextStyle(
                            color: context.textMain,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Berlaku untuk $selectedPoolName.',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.mutedText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_selectedPromo != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => Navigator.pop(context, {'_clear': true}),
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                    label: const Text('Batalkan promo'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xffB42318),
                      minimumSize: const Size(48, 48),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(top: 2, bottom: 4),
                  itemCount: _availablePromos.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final availablePromo = _availablePromos[index];
                    final String? selectedId = _selectedPromo?['id']
                        ?.toString();
                    final String? promoId = availablePromo['id']?.toString();
                    final bool isSelected =
                        selectedId != null && selectedId == promoId;

                    return Material(
                      color: isSelected
                          ? kBlue.withValues(alpha: 0.08)
                          : context.softBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isSelected
                              ? kBlue.withValues(alpha: 0.55)
                              : Colors.transparent,
                          width: 1.2,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => Navigator.pop(context, availablePromo),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 13,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? kBlue.withValues(alpha: 0.14)
                                      : context.cardBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.local_offer_rounded,
                                  color: isSelected ? kDarkBlue : kAqua,
                                  size: 21,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      availablePromo['nama']?.toString() ??
                                          'Promo',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: context.textMain,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      availablePromo['label_diskon']
                                              ?.toString() ??
                                          'Diskon',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: kAqua,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isSelected
                                    ? Icons.check_circle_rounded
                                    : Icons.chevron_right_rounded,
                                color: isSelected
                                    ? kDarkBlue
                                    : context.mutedText,
                                size: 23,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (promo == null || !mounted) return;
    setState(() {
      _selectedPromo = promo['_clear'] == true ? null : promo;
      _confirmedPromoName = '';
      _confirmedPromoDiscount = 0;
    });
  }

  void goStep(int step) {
    // Keluar dari langkah Bayar -> timer dihentikan
    if (step != 4) _stopPayTimer();

    setState(() {
      currentStep = step;

      // Pembayaran yang kedaluwarsa direset kalau user meninggalkan langkah Bayar
      if (step != 4 && statusPembayaran == 'expired') {
        statusPembayaran = 'pending';
        paymentExpired = false;
      }
    });
  }

  void _openBookingTab() {
    final startNewBooking = statusPembayaran == 'paid';

    if (startNewBooking) {
      _stopPayTimer();
      _paymentStatusTimer?.cancel();
      _successAnimController.reset();
    }

    setState(() {
      selectedTab = 0;

      if (!startNewBooking) return;

      currentStep = 1;
      selectedDate = null;
      selectedDateLabel = '';
      isWeekend = false;
      category = 'dewasa';
      qtyAdult = 1;
      qtyChild = 0;
      keteranganController.clear();
      _selectedPromo = null;
      _confirmedPromoName = '';
      _confirmedPromoDiscount = 0;
      payMethod = 'qris';
      selectedWallet = 'gopay';
      selectedBank = 'bri';
      paySubStep = 'select';
      orderId = '';
      reservationCode = '';
      ticketId = '';
      statusPembayaran = 'pending';
      paidAt = null;
      reservedAt = null;
      currentQrUrl = null;
      currentQrImage = null;
      paymentExpired = false;
      _remainingSeconds = payDurationSeconds;
      isCreatingPayment = false;
      isCheckingPaymentStatus = false;
    });
  }

  /// Kode tiket menyertakan ID Pool kolam yang dipilih user (contoh: pool_id_01_83232942)
  // String _generateTicketId() {
  //   final now = DateTime.now();
  //   final ms = now.millisecondsSinceEpoch.toString();
  //   return '${selectedPoolId}_${ms.substring(ms.length - 8)}';
  // }

  Future<void> _createReservationAndQris() async {
    if (isCreatingPayment) return;
    if (selectedPoolId.isEmpty) {
      showMessage('Silakan pilih wisata kolam renang terlebih dahulu.');
      return;
    }

    if (statusPembayaran == 'paid') {
      showMessage('Transaksi ini sudah terbayar.');
      return;
    }

    if (selectedDate == null) {
      showMessage('Tanggal kunjungan belum dipilih.');
      return;
    }

    // Pastikan data pemesan dari akun sudah terbaca
    if (nama.trim().isEmpty || telepon.trim().isEmpty) {
      await _loadAccount();
      if (!mounted) return;
    }

    if (nama.trim().isEmpty || telepon.trim().isEmpty) {
      showMessage('Data akun belum lengkap. Silakan login ulang.');
      return;
    }

    if (qtyAdult <= 0 && qtyChild <= 0) {
      showMessage('Jumlah tiket minimal 1.');
      return;
    }

    setState(() => isCreatingPayment = true);
    final tanggalKunjungan =
        '${selectedDate!.year}-'
        '${selectedDate!.month.toString().padLeft(2, '0')}-'
        '${selectedDate!.day.toString().padLeft(2, '0')}';

    try {
      if (reservationCode.isEmpty) {
        final response = await ApiService.createReservasi(
          poolId: selectedPoolId,
          namaPengunjung: nama,
          noHp: telepon,
          tanggalKunjungan: tanggalKunjungan,
          jumlahDewasa: qtyAdult,
          jumlahAnak: qtyChild,
          totalHarga: totalPrice.toDouble(),
          promoId: _selectedPromo?['id']?.toString(),
        );

        if (response['success'] != true) {
          throw Exception(
            response['message']?.toString() ?? 'Reservasi gagal dibuat.',
          );
        }

        final responseData = Map<String, dynamic>.from(response['data'] ?? {});
        _confirmedPromoName =
            responseData['nama_promo']?.toString() ??
            _selectedPromo?['nama']?.toString() ??
            '';
        _confirmedPromoDiscount = _receiptInteger(
          responseData['potongan_promo'],
          fallback: discountAmount,
        );
        reservationCode = responseData['kode_reservasi']?.toString() ?? '';
        if (reservationCode.isEmpty) {
          throw Exception('Kode reservasi tidak diterima dari server.');
        }
        reservedAt =
            DateTime.tryParse(responseData['created_at']?.toString() ?? '') ??
            DateTime.now();
      }

      final paymentResponse = await ApiService.createQrisPayment(
        reservationCode: reservationCode,
        customerName: nama,
        customerEmail: email.isEmpty ? 'user@nexpool.test' : email,
      );
      final paymentData = Map<String, dynamic>.from(
        paymentResponse['data'] ?? paymentResponse,
      );
      final returnedStatus =
          paymentData['status_pembayaran']?.toString().toLowerCase() ??
          'pending';

      if (returnedStatus == 'paid') {
        await _completePayment(paymentData);
        return;
      }

      final returnedOrderId = paymentData['order_id']?.toString() ?? '';
      if (returnedOrderId.isEmpty) {
        throw Exception('QRIS belum tersedia dari server pembayaran.');
      }

      final returnedQrUrl = paymentData['qr_url']?.toString();
      final finalQrUrl =
          (returnedQrUrl != null && returnedQrUrl.trim().isNotEmpty)
          ? returnedQrUrl.trim()
          : '';

      // Hitung sisa detik berdasarkan expired_at & server_time dari backend (BUKAN jam lokal HP)
      int remainingSecondsFromBackend = payDurationSeconds;
      if (paymentData['remaining_seconds'] != null) {
        final sec = int.tryParse(paymentData['remaining_seconds'].toString());
        if (sec != null && sec > 0) {
          remainingSecondsFromBackend = sec;
        }
      } else if (paymentData['expired_at'] != null &&
          paymentData['server_time'] != null) {
        final exp = DateTime.tryParse(paymentData['expired_at'].toString());
        final srv = DateTime.tryParse(paymentData['server_time'].toString());
        if (exp != null && srv != null) {
          final diff = exp.difference(srv).inSeconds;
          if (diff > 0) remainingSecondsFromBackend = diff;
        }
      }

      if (!mounted) return;
      setState(() {
        orderId = returnedOrderId;
        ticketId = reservationCode;
        currentQrUrl = finalQrUrl;
        currentQrImage = ApiService.getMidtransQrImage(returnedOrderId);
        statusPembayaran = 'pending';
        paymentExpired = false;
        currentStep = 4;
        paySubStep = 'process';
      });
      _startPayTimer(initialSeconds: remainingSecondsFromBackend);
      _startPaymentStatusPolling();
    } catch (e) {
      debugPrint('GAGAL MEMBUAT RESERVASI/QRIS: $e');
      if (mounted) {
        final errStr = e.toString();
        String message;
        if (errStr.contains('SocketException') ||
            errStr.contains('No route to host') ||
            errStr.contains('Connection refused') ||
            errStr.contains('errno = 113') ||
            errStr.contains('TimeoutException')) {
          message =
              'Tidak dapat terhubung ke server backend (${ApiService.baseUrl}). '
              'Pastikan server Laravel aktif (php artisan serve --host=0.0.0.0 --port=8000) '
              'dan HP terhubung di Wi-Fi yang sama.';
        } else {
          message =
              'Gagal menyiapkan pembayaran: ${errStr.replaceFirst('Exception: ', '')}';
        }
        showMessage(message);
      }
    } finally {
      if (mounted) setState(() => isCreatingPayment = false);
    }
  }

  void _startPaymentStatusPolling() {
    _paymentStatusTimer?.cancel();
    _paymentStatusTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkPaymentStatus(),
    );
    _checkPaymentStatus();
  }

  Future<void> _checkPaymentStatus({bool showPendingMessage = false}) async {
    if (orderId.isEmpty ||
        isCheckingPaymentStatus ||
        statusPembayaran == 'paid') {
      return;
    }

    if (mounted) {
      setState(() => isCheckingPaymentStatus = true);
    } else {
      isCheckingPaymentStatus = true;
    }
    try {
      final paymentStatus = await ApiService.getMidtransPaymentStatus(orderId);
      final status =
          paymentStatus['status_pembayaran']?.toString().toLowerCase() ??
          'pending';

      if ((currentQrUrl == null || currentQrUrl!.isEmpty) &&
          paymentStatus['qr_url'] != null &&
          paymentStatus['qr_url'].toString().isNotEmpty) {
        currentQrUrl = paymentStatus['qr_url'].toString();
      }

      if (status == 'paid') {
        await _completePayment(paymentStatus);
      } else if (status == 'expired' ||
          status == 'cancelled' ||
          status == 'failed' ||
          status == 'refunded') {
        _paymentStatusTimer?.cancel();
        _stopPayTimer();
        if (!mounted) return;
        setState(() {
          statusPembayaran = status;
          paymentExpired = true;
        });
      } else if (showPendingMessage && mounted) {
        showMessage('Pembayaran belum terkonfirmasi. Kami akan cek otomatis.');
      }
    } catch (e) {
      debugPrint('Belum dapat memeriksa status Midtrans: $e');
      if (showPendingMessage && mounted) {
        showMessage('Status belum dapat diperiksa. Coba lagi sebentar.');
      }
    } finally {
      if (mounted) {
        setState(() => isCheckingPaymentStatus = false);
      } else {
        isCheckingPaymentStatus = false;
      }
    }
  }

  Future<void> _completePayment(Map<String, dynamic> paymentData) async {
    if (statusPembayaran == 'paid') return;

    final confirmedOrderId =
        paymentData['order_id']?.toString().isNotEmpty == true
        ? paymentData['order_id'].toString()
        : orderId;
    final paidTime =
        DateTime.tryParse(paymentData['paid_at']?.toString() ?? '') ??
        DateTime.now();
    final ticket = <String, dynamic>{
      'orderId': confirmedOrderId,
      'ticketId': reservationCode,
      'reservationCode': reservationCode,
      'poolId': normalizePoolId(selectedPoolId),
      'rawPoolId': selectedPoolId,
      'poolName': selectedPoolName,
      'name': 'Tiket Masuk',
      'date': selectedDate == null
          ? selectedDateLabel
          : formatShortDate(selectedDate!),
      'visitDate': selectedDate?.toIso8601String(),
      'reservedAt': reservedAt?.toIso8601String(),
      'qty': qtyChild > 0
          ? '$qtyAdult Dewasa, $qtyChild Anak'
          : '$qtyAdult Dewasa',
      'adultQty': qtyAdult,
      'childQty': qtyChild,
      'unitPrice': adultPrice,
      'adminFee': adminFee,
      'promoName': _confirmedPromoName,
      'promoDiscount': _confirmedPromoDiscount,
      'payment': _paymentLabel(),
      'total': totalPrice,
      'status': 'paid',
      'paidAt': formatDateTime(paidTime),
      'paidAtIso': paidTime.toIso8601String(),
      'customerName': nama,
      'customerPhone': telepon,
      'reschedule': 0,
    };

    final existingIndex = myTickets.indexWhere(
      (savedTicket) =>
          savedTicket['reservationCode']?.toString() == reservationCode,
    );
    if (existingIndex < 0) {
      myTickets.insert(0, ticket);
    } else {
      myTickets[existingIndex] = ticket;
    }

    try {
      await _persistSavedTickets();
    } catch (e) {
      debugPrint('Gagal menyimpan tiket lunas ke riwayat lokal: $e');
      if (mounted) {
        showMessage(
          'Pembayaran berhasil, tetapi tiket gagal disimpan ke riwayat lokal.',
        );
      }
    }
    if (!mounted) return;

    _paymentStatusTimer?.cancel();
    _stopPayTimer();
    setState(() {
      statusPembayaran = 'paid';
      paidAt = paidTime;
      ticketId = reservationCode;
      orderId = confirmedOrderId;
      currentStep = 5;
      paymentExpired = false;
    });
    _successAnimController.forward();

    // Transisi langsung ke step 5 (Struk dan tombol download langsung tampil di halaman)
  }

  // void _addTicketToMyTickets() {
  //   final normalizedPoolId = normalizePoolId(selectedPoolId);
  //   final payLabel = _paymentLabel();
  //   final qtyLabel = qtyChild > 0 ? '$qtyAdult Dewasa, $qtyChild Anak' : '$qtyAdult Dewasa';

  //   setState(() {
  //     myTickets.insert(0, {
  //       'orderId': orderId,
  //       'ticketId': ticketId, // e.g. pool_id_02_83232942
  //       'poolId': normalizedPoolId, // e.g. POOL-02
  //       'rawPoolId': selectedPoolId, // e.g. pool_id_02
  //       'poolName': selectedPoolName, // e.g. Pemandian Kebon Agung
  //       'name': 'Tiket Dewasa — ${isWeekend ? 'Weekend' : 'Weekday'}',
  //       'date': selectedDateLabel.isEmpty ? formatShortDate(DateTime.now()) : formatShortDate(selectedDate ?? DateTime.now()),
  //       'qty': qtyLabel,
  //       'payment': payLabel,
  //       'total': totalPrice,
  //       'status': 'paid',
  //       'paidAt': formatDateTime(paidAt ?? DateTime.now()),
  //       'reschedule': 0,
  //     });
  //   });
  // }

  String _paymentLabel() {
    return 'QRIS';
  }

  void cancelTransaction(int ticketIndex) {
    final ticket = myTickets[ticketIndex];
    if (ticket['status'] != 'pending') {
      showMessage(
        'Hanya transaksi dengan status pending yang dapat dibatalkan.',
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            colorfulIcon(
              icon: Icons.cancel_rounded,
              color: kRed,
              bgColor: kRedSoft,
              boxSize: 36,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              'Batalkan Pesanan?',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ID: ${ticket['orderId']}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 10),
            const Text(
              'Pesanan yang dibatalkan tidak dapat dipulihkan. Nexpool tidak memiliki fitur refund.',
              style: TextStyle(fontSize: 13, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                myTickets[ticketIndex]['status'] = 'cancelled';
              });
              showMessage('Pesanan ${ticket['orderId']} telah dibatalkan.');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _updatePageState(VoidCallback callback) {
    setState(callback);
  }

  @override
  Widget build(BuildContext context) {
    if (selectedTab == 0 && selectedPoolId.isEmpty) {
      return Scaffold(
        backgroundColor: context.pageBg,
        appBar: AppBar(
          title: const Text(
            'Pesan Tiket',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(gradient: kGradient),
          ),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: infoBox(
                color: context.cardBg,
                radius: 20,
                pad: 24,
                border: kBlue.withOpacity(.2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    colorfulIcon(
                      icon: Icons.pool_rounded,
                      color: kBlue,
                      bgColor: context.softBg,
                      boxSize: 70,
                      size: 36,
                      isCircle: true,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Pilih kolam renang dulu',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: context.textMain,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tentukan wisata kolam renang dari halaman Semua Kolam sebelum memesan tiket.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst),
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('Kembali dan pilih kolam'),
                        style: primaryStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        title: Text(
          selectedTab == 1 ? 'Tiket Saya' : 'Pesan Tiket Nexpool',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: kGradient),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
        // Tombol kembali ke Pesan Tiket saat di tab Tiket Saya
        leading: selectedTab == 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: _openBookingTab,
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: selectedTab == 0
                  ? SingleChildScrollView(
                      child: Column(
                        children: [
                          buildStepper(),
                          if (currentStep == 1) buildStep1(),
                          if (currentStep == 3) buildStep3(),
                          if (currentStep == 4) buildStep4(),
                          if (currentStep == 5) _buildThermalStep5(),
                          const SizedBox(
                            height: 88,
                          ), // Clearance for floating navbar
                        ],
                      ),
                    )
                  : buildMyTickets(),
            ),
          ],
        ),
      ),
    );
  }
}
