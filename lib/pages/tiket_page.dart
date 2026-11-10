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
import 'home_page.dart';

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

  const TiketPage({super.key, this.poolId, this.poolName, this.initialTab = 0});

  final String? poolId;
  final String? poolName;
  final int initialTab;

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

  bool isPriceLoading = true;
  String priceError = '';

  late AnimationController _successAnimController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

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

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.15).animate(
      CurvedAnimation(parent: _successAnimController, curve: Curves.easeInOut),
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
    setState(() {
      selectedPoolId = id;
      selectedPoolName = name;
    });
    TiketPage.globalSelectedPoolId = id;
    TiketPage.globalSelectedPoolName = name;
    loadHargaTiket();
  }

  int get adultPrice => isWeekend ? weekendPrice : weekdayPrice;
  int get adminFee => 2000;
  int get totalPrice => (qtyAdult * adultPrice) + adminFee;

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
    setState(() {
      selectedDate = date;
      selectedDateLabel = formatDate(date);
      isWeekend = isWeekendDate(date);
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
        );

        if (response['success'] != true) {
          throw Exception(
            response['message']?.toString() ?? 'Reservasi gagal dibuat.',
          );
        }

        final responseData = Map<String, dynamic>.from(response['data'] ?? {});
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
      final finalQrUrl = (returnedQrUrl != null && returnedQrUrl.trim().isNotEmpty)
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
          message = 'Gagal menyiapkan pembayaran: ${errStr.replaceFirst('Exception: ', '')}';
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

  Widget colorfulIcon({
    required IconData icon,
    required Color color,
    Color? bgColor,
    double size = 20,
    double boxSize = 40,
    double radius = 12,
    bool isCircle = false,
  }) {
    return Container(
      width: boxSize,
      height: boxSize,
      decoration: BoxDecoration(
        color: bgColor ?? color.withOpacity(0.14),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(radius),
      ),
      child: Center(
        child: Icon(icon, color: color, size: size),
      ),
    );
  }

  Widget infoBox({
    required Widget child,
    Color color = kSoft,
    double radius = 14,
    double pad = 14,
    Color? border,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: border == null ? null : Border.all(color: border),
      ),
      child: child,
    );
  }

  Widget pad20(Widget child, {double top = 0, double bottom = 0}) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: top, bottom: bottom),
      child: child,
    );
  }

  Widget sectionTitle(String title, {IconData? icon, Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
      child: Row(
        children: [
          if (icon != null) ...[
            colorfulIcon(
              icon: icon,
              color: iconColor ?? kBlue,
              boxSize: 32,
              size: 18,
            ),
            const SizedBox(width: 10),
          ],
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget navButtons(int backStep, String nextText, VoidCallback? onNext) {
    return pad20(
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => goStep(backStep),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('← Kembali'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: onNext,
              style: primaryStyle.copyWith(
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(vertical: 15),
                ),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              child: Text(
                nextText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      bottom: 20,
    );
  }

  Widget recapDate() {
    return pad20(
      infoBox(
        color: context.softBg,
        radius: 14,
        pad: 14,
        child: Row(
          children: [
            colorfulIcon(
              icon: Icons.calendar_month_rounded,
              color: kBlue,
              boxSize: 38,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedDateLabel.isEmpty
                        ? 'Tanggal belum dipilih'
                        : selectedDateLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${isWeekend ? 'Weekend' : 'Weekday'} • $selectedPoolName',
                    style: const TextStyle(
                      fontSize: 11,
                      color: kAqua,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => goStep(1),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kBlue.withOpacity(0.3)),
                ),
                child: const Text(
                  'Ubah',
                  style: TextStyle(
                    fontSize: 11,
                    color: kBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      top: 14,
      bottom: 4,
    );
  }

  /// Kartu kecil berisi nama & nomor HP pemesan (dari akun yang login)
  Widget pemesanCard() {
    return pad20(
      infoBox(
        color: context.cardBg,
        radius: 14,
        pad: 12,
        border: Colors.grey.shade200,
        child: Row(
          children: [
            colorfulIcon(
              icon: Icons.person_rounded,
              color: kPurple,
              boxSize: 38,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PEMESAN (AKUN KAMU)',
                    style: TextStyle(
                      fontSize: 9,
                      color: context.mutedText,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    nama.isEmpty ? 'Memuat data akun...' : nama,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    phoneDisplay,
                    style: TextStyle(
                      fontSize: 11,
                      color: context.mutedText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            colorfulIcon(
              icon: Icons.verified_user_rounded,
              color: kGreen,
              boxSize: 30,
              size: 16,
            ),
          ],
        ),
      ),
      top: 10,
    );
  }

  Widget dateStrip({
    required List<DateTime> list,
    required DateTime? active,
    required ValueChanged<DateTime> onPick,
    EdgeInsets padding = EdgeInsets.zero,
    double height = 75,
  }) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: list.length,
        itemBuilder: (context, i) {
          final date = list[i];
          final isSel = sameDay(active, date);
          final weekend = isWeekendDate(date);

          return GestureDetector(
            onTap: () => onPick(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 58,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSel
                    ? kBlue
                    : weekend
                    ? kYellowSoft
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSel
                      ? kBlue
                      : weekend
                      ? kGold.withOpacity(0.6)
                      : Colors.grey.shade300,
                  width: isSel ? 2 : 1,
                ),
                boxShadow: isSel
                    ? [
                        BoxShadow(
                          color: kBlue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    kDayShort[date.weekday - 1],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isSel
                          ? Colors.white70
                          : weekend
                          ? const Color(0xff9a6c00)
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isSel
                          ? Colors.white
                          : weekend
                          ? const Color(0xff7a5800)
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _months[date.month - 1].substring(0, 3),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: isSel
                          ? Colors.white70
                          : weekend
                          ? const Color(0xff9a6c00)
                          : Colors.grey,
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
                onPressed: () => setState(() => selectedTab = 0),
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Tab switcher hanya tampil di Tiket Saya agar bisa kembali
            if (selectedTab == 1) buildTabs(),
            Expanded(
              child: selectedTab == 0
                  ? SingleChildScrollView(
                      child: Column(
                        children: [
                          buildStepper(),
                          if (currentStep == 1) buildStep1(),
                          if (currentStep == 3) buildStep3(),
                          if (currentStep == 4) buildStep4(),
                          if (currentStep == 5) buildStep5(),
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

  Widget buildTabs() {
    return pad20(
      Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => selectedTab = 0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: selectedTab == 0 ? kBlue : Colors.transparent,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_shopping_cart_rounded,
                        size: 16,
                        color: selectedTab == 0 ? Colors.white : Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Pesan Tiket',
                        style: TextStyle(
                          color: selectedTab == 0
                              ? Colors.white
                              : Colors.grey.shade700,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => selectedTab = 1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: selectedTab == 1 ? kBlue : Colors.transparent,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.confirmation_number_rounded,
                        size: 16,
                        color: selectedTab == 1 ? Colors.white : Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Tiket Saya (${myTickets.length})',
                        style: TextStyle(
                          color: selectedTab == 1
                              ? Colors.white
                              : Colors.grey.shade700,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      top: 14,
    );
  }

  // ============================================================
  // STEPPER — 4 langkah: Tanggal, Tiket, Bayar, Struk
  // (id langkah internal: 1, 3, 4, 5 — langkah 2 sudah dihapus)
  // ============================================================
  Widget buildStepper() {
    const labels = ['Tanggal', 'Tiket', 'Bayar', 'Struk'];
    const stepIds = [1, 3, 4, 5];

    return pad20(
      Row(
        children: List.generate(labels.length, (index) {
          final step = stepIds[index];
          final done = currentStep > step;
          final active = currentStep == step;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: done
                              ? kGreen
                              : active
                              ? kBlue
                              : Colors.grey.shade300,
                          boxShadow: active
                              ? [
                                  BoxShadow(
                                    color: kBlue.withOpacity(0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: Center(
                          child: done
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 18,
                                )
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: active
                                        ? Colors.white
                                        : Colors.grey.shade700,
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
                          fontWeight: FontWeight.w700,
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
                if (index < labels.length - 1)
                  Container(
                    width: 15,
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 17),
                    color: currentStep > step ? kBlue : Colors.grey.shade300,
                  ),
              ],
            ),
          );
        }),
      ),
      top: 14,
      bottom: 6,
    );
  }

  Widget buildStep1() {
    return Column(
      children: [
        sectionTitle(
          'Kolam Renang Terpilih',
          icon: Icons.pool_rounded,
          iconColor: kAqua,
        ),

        _buildSelectedPoolCard(),

        sectionTitle(
          'Pilih Tanggal Kunjungan',
          icon: Icons.calendar_month_rounded,
          iconColor: kBlue,
        ),

        dateStrip(
          list: dates,
          active: selectedDate,
          onPick: selectDate,
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),

        pad20(
          infoBox(
            child: Row(
              children: [
                colorfulIcon(
                  icon: selectedDate == null
                      ? Icons.info_rounded
                      : Icons.event_available_rounded,
                  color: kAqua,
                  boxSize: 30,
                  size: 16,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    selectedDate == null
                        ? 'Silakan pilih tanggal di atas'
                        : '$selectedDateLabel — ${isWeekend ? 'Weekend' : 'Weekday'}',
                    style: const TextStyle(
                      color: kAqua,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          top: 8,
          bottom: 15,
        ),

        pad20(
          infoBox(
            color: context.cardBg,
            radius: 16,
            pad: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    colorfulIcon(
                      icon: Icons.pie_chart_rounded,
                      color: kPurple,
                      boxSize: 28,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'INFORMASI KUOTA HARI INI',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: context.mutedText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    quotaBox(
                      '320',
                      'Kuota Tersisa',
                      kGreen,
                      Icons.check_circle_rounded,
                    ),
                    const SizedBox(width: 10),
                    quotaBox('500', 'Total Kuota', kBlue, Icons.groups_rounded),
                    const SizedBox(width: 10),
                    quotaBox(
                      '180',
                      'Terjual',
                      const Color(0xffb07b00),
                      Icons.local_activity_rounded,
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
                  : () {
                      // Pemesanan butuh akun. Data pemesan diambil dari akun.
                      if (!isLoggedIn) {
                        showMessage('Silakan login dulu untuk memesan tiket.');
                        return;
                      }
                      goStep(3);
                    },
              style: primaryStyle.copyWith(
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(vertical: 16),
                ),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              child: const Text(
                'Lanjut Pilih Tiket →',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // ── Tombol Lihat Tiket Saya ─────────────────────────────────
        pad20(
          GestureDetector(
            onTap: () => setState(() => selectedTab = 1),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kGold.withOpacity(0.7), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: kGold.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: context.isDark
                          ? const Color(0xFF3B3424)
                          : kYellowSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.confirmation_number_rounded,
                      color: kOrange,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lihat Tiket Saya',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: context.textMain,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${myTickets.length} tiket tersimpan · Tap untuk lihat detail',
                          style: TextStyle(
                            fontSize: 11,
                            color: context.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: kOrange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${myTickets.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: context.mutedText,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  /// Card Single Kolam Renang yang Terintegrasi dari Dashboard
  Widget _buildSelectedPoolCard() {
    final normalizedId = normalizePoolId(selectedPoolId);
    final poolInfo = kAllPoolsList.firstWhere(
      (p) => p['id'] == selectedPoolId || p['normalizedId'] == normalizedId,
      orElse: () => {
        'id': selectedPoolId,
        'normalizedId': normalizedId,
        'name': selectedPoolName,
        'shortName': selectedPoolName,
        'icon': '🏊',
        'location': 'Jember, Jawa Timur',
      },
    );

    return pad20(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [kBlue.withOpacity(0.08), kDarkBlue.withOpacity(0.04)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBlue.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: kBlue.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            colorfulIcon(
              icon: Icons.water_rounded,
              color: kBlue,
              boxSize: 44,
              size: 24,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: kBlue,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          normalizedId,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: kGreen.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.sync_alt_rounded,
                              size: 10,
                              color: kGreen,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Pilihan Dashboard',
                              style: TextStyle(
                                color: kGreen,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    selectedPoolName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: context.textMain,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          poolInfo['location'] ?? 'Jember, Jawa Timur',
                          style: TextStyle(
                            fontSize: 11,
                            color: context.mutedText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
      top: 4,
      bottom: 12,
    );
  }

  Widget quotaBox(String number, String label, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(
              number,
              style: TextStyle(
                fontSize: 20,
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
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStep3() {
    return Column(
      children: [
        recapDate(),

        // Pemesan diambil otomatis dari akun yang login
        pemesanCard(),

        sectionTitle(
          'Kategori & Jumlah Tiket',
          icon: Icons.confirmation_number_rounded,
          iconColor: kOrange,
        ),

        if (isPriceLoading)
          pad20(
            const Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text(
                  'Mengambil harga tiket dari server...',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
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
                  colorfulIcon(
                    icon: Icons.error_rounded,
                    color: kRed,
                    boxSize: 30,
                    size: 16,
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

        pad20(
          Row(
            children: [
              categoryCard(
                Icons.face_rounded,
                kBlue,
                'Dewasa',
                isPriceLoading
                    ? 'Memuat...'
                    : adultPrice > 0
                    ? rupiah(adultPrice)
                    : 'Belum tersedia',
                'Tinggi > 100cm',
                category == 'dewasa',
                () => setState(() => category = 'dewasa'),
              ),
              const SizedBox(width: 10),
              categoryCard(
                Icons.child_care_rounded,
                kGreen,
                'Anak-anak',
                'Gratis',
                'Tinggi ≤ 100cm',
                category == 'anak',
                () => setState(() => category = 'anak'),
              ),
            ],
          ),
        ),

        pad20(
          infoBox(
            color: context.isDark ? const Color(0xFF3B3424) : kYellowSoft,
            radius: 10,
            pad: 10,
            child: Row(
              children: [
                colorfulIcon(
                  icon: Icons.info_rounded,
                  color: context.isDark
                      ? const Color(0xFFFFD166)
                      : const Color(0xff9a6c00),
                  boxSize: 30,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Harga ${isWeekend ? 'weekend' : 'weekday'} untuk $selectedPoolName mengikuti tarif resmi server. Anak ≤100cm gratis.',
                    style: TextStyle(
                      fontSize: 10,
                      color: context.isDark
                          ? const Color(0xFFFFD166)
                          : const Color(0xff7a5800),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          top: 10,
        ),

        sectionTitle(
          'Jumlah Tiket',
          icon: Icons.group_add_rounded,
          iconColor: kAqua,
        ),

        buildQuantity(
          'Dewasa',
          'Tinggi > 100cm',
          qtyAdult,
          Icons.person_rounded,
          kBlue,
          (v) {
            setState(() => qtyAdult = (qtyAdult + v).clamp(0, 20));
          },
        ),

        buildQuantity(
          'Anak-anak',
          'Tinggi ≤ 100cm (Gratis)',
          qtyChild,
          Icons.child_care_rounded,
          kGreen,
          (v) {
            setState(() => qtyChild = (qtyChild + v).clamp(0, 20));
          },
        ),

        sectionTitle(
          'Keterangan Tiket (Opsional)',
          icon: Icons.edit_note_rounded,
          iconColor: kPurple,
        ),

        pad20(
          TextField(
            controller: keteranganController,
            maxLength: 200,
            maxLines: 3,
            onChanged: (v) => keterangan = v,
            decoration: InputDecoration(
              hintText:
                  'Contoh: Kunjungan rombongan keluarga, ulang tahun, dll...',
              filled: true,
              fillColor: context.softBg,
              border: fieldBorder(),
              enabledBorder: fieldBorder(),
              focusedBorder: fieldBorder(color: kBlue, width: 1.5),
            ),
          ),
        ),

        const SizedBox(height: 4),

        buildSummary(),

        // Kembali -> langsung ke langkah Tanggal (langkah 1)
        navButtons(
          1,
          isCreatingPayment ? 'Menyiapkan QRIS...' : 'Lanjut Pembayaran →',
          isPriceLoading ||
                  priceError.isNotEmpty ||
                  adultPrice <= 0 ||
                  qtyAdult <= 0 ||
                  isCreatingPayment
              ? null
              : _createReservationAndQris,
        ),
      ],
    );
  }

  Widget categoryCard(
    IconData icon,
    Color iconColor,
    String name,
    String price,
    String desc,
    bool selected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? kSoft : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? kBlue : Colors.grey.shade300,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              colorfulIcon(icon: icon, color: iconColor, boxSize: 44, size: 24),
              const SizedBox(height: 8),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
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
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
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
    IconData icon,
    Color iconColor,
    ValueChanged<int> onChange,
  ) {
    return pad20(
      infoBox(
        color: context.cardBg,
        radius: 14,
        pad: 12,
        border: Colors.grey.shade200,
        child: Row(
          children: [
            colorfulIcon(icon: icon, color: iconColor, boxSize: 38, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
            ),
            quantityButton(Icons.remove_rounded, () => onChange(-1)),
            SizedBox(
              width: 36,
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            quantityButton(Icons.add_rounded, () => onChange(1)),
          ],
        ),
      ),
      bottom: 10,
    );
  }

  Widget quantityButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: context.softBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kBlue.withOpacity(0.2)),
        ),
        child: Center(child: Icon(icon, size: 18, color: kBlue)),
      ),
    );
  }

  Widget buildSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: kGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: kDarkBlue.withOpacity(0.25),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                colorfulIcon(
                  icon: Icons.receipt_long_rounded,
                  color: Colors.white,
                  bgColor: Colors.white.withOpacity(0.2),
                  boxSize: 32,
                  size: 18,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Ringkasan Pesanan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            summaryRow(
              'Tiket Dewasa × $qtyAdult',
              rupiah(qtyAdult * adultPrice),
            ),
            if (qtyChild > 0) summaryRow('Tiket Anak × $qtyChild', 'Gratis'),
            summaryRow('Kolam Renang', selectedPoolName),
            summaryRow(
              'Tanggal Kunjungan',
              selectedDate == null ? '—' : formatShortDate(selectedDate!),
            ),
            summaryRow('Biaya Layanan Admin', rupiah(adminFee)),
            const Divider(color: Colors.white24, height: 20),
            summaryRow('Total Pembayaran', rupiah(totalPrice), total: true),
          ],
        ),
      ),
    );
  }

  Widget summaryRow(String label, String value, {bool total = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontSize: total ? 13 : 12,
                fontWeight: total ? FontWeight.w700 : null,
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

  Widget buildStep4() {
    if (paymentExpired) return buildPaymentExpired();
    return buildQrisPayment();
  }

  Widget buildPaymentSelect() {
    final activeWallet = kEWallets.firstWhere((w) => w['id'] == selectedWallet);
    final activeBank = kBankOptions.firstWhere((b) => b['id'] == selectedBank);

    return Column(
      children: [
        pad20(_orderStatusBanner(), top: 14),

        sectionTitle(
          'Detail Pesanan',
          icon: Icons.receipt_rounded,
          iconColor: kBlue,
        ),

        pad20(
          infoBox(
            color: context.cardBg,
            radius: 16,
            pad: 16,
            border: Colors.grey.shade200,
            child: Column(
              children: [
                _orderDetailRow(
                  Icons.pool_rounded,
                  kAqua,
                  'Kolam Renang',
                  selectedPoolName,
                ),
                _orderDetailRow(
                  Icons.pin_rounded,
                  kPurple,
                  'Pool ID',
                  normalizePoolId(selectedPoolId),
                ),
                _orderDetailRow(
                  Icons.calendar_month_rounded,
                  kBlue,
                  'Tanggal Kunjungan',
                  selectedDateLabel.isEmpty ? '—' : selectedDateLabel,
                ),
                _orderDetailRow(
                  Icons.group_rounded,
                  kGreen,
                  'Jumlah Tiket',
                  qtyChild > 0
                      ? '$qtyAdult Dewasa, $qtyChild Anak'
                      : '$qtyAdult Dewasa',
                ),
                _orderDetailRow(
                  Icons.person_rounded,
                  kOrange,
                  'Nama Pemesan',
                  nama.isEmpty ? '—' : nama,
                ),
                const Divider(height: 20),
                _orderDetailRow(
                  Icons.monetization_on_rounded,
                  kGold,
                  'Total Pembayaran',
                  rupiah(totalPrice),
                  highlight: true,
                ),
              ],
            ),
          ),
        ),

        sectionTitle(
          'Pilih Metode Pembayaran',
          icon: Icons.account_balance_wallet_rounded,
          iconColor: kAqua,
        ),

        _mainPaymentTypeCard(
          id: 'qris',
          title: 'QRIS & E-Wallet',
          subtitle: 'Bayar instan via GoPay, DANA, OVO, ShopeePay, dll',
          icon: Icons.qr_code_scanner_rounded,
          iconColor: kAqua,
          badge: 'Instan',
          badgeColor: kGreen,
        ),

        if (payMethod == 'qris') _buildEWalletSelectionGrid(),

        const SizedBox(height: 10),

        _mainPaymentTypeCard(
          id: 'bank',
          title: 'Transfer Bank (Virtual Account)',
          subtitle: 'Transfer via BRI, BCA, Mandiri, BNI, Permata',
          icon: Icons.account_balance_rounded,
          iconColor: kBlue,
          badge: 'VA 24/7',
          badgeColor: kBlue,
        ),

        if (payMethod == 'bank') _buildBankSelectionGrid(),

        const SizedBox(height: 20),

        pad20(
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: adultPrice <= 0 ? null : _createReservationAndQris,
              icon: Icon(
                payMethod == 'qris'
                    ? Icons.qr_code_rounded
                    : Icons.account_balance_rounded,
                size: 20,
              ),
              label: Text(
                payMethod == 'qris'
                    ? 'Bayar via ${activeWallet['name']} (QRIS) →'
                    : 'Bayar via ${activeBank['name']} →',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: primaryStyle.copyWith(
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(vertical: 16),
                ),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ),

        pad20(
          OutlinedButton(
            onPressed: () => goStep(3),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('← Kembali ke Pilih Tiket'),
          ),
          top: 8,
          bottom: 20,
        ),
      ],
    );
  }

  Widget _orderStatusBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.isDark ? kOrange.withOpacity(.14) : kOrangeSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kOrange.withOpacity(.4)),
      ),
      child: Row(
        children: [
          colorfulIcon(
            icon: Icons.access_time_filled_rounded,
            color: kOrange,
            bgColor: kOrange.withOpacity(0.15),
            boxSize: 42,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MENUNGGU PEMBAYARAN',
                  style: TextStyle(
                    color: kOrange,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Order ID: $orderId',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Status: Pending — Selesaikan pembayaran Anda',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderDetailRow(
    IconData icon,
    Color iconColor,
    String label,
    String value, {
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          colorfulIcon(icon: icon, color: iconColor, boxSize: 28, size: 15),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: highlight ? 15 : 12,
              fontWeight: FontWeight.w800,
              color: highlight ? kBlue : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _mainPaymentTypeCard({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String badge,
    required Color badgeColor,
  }) {
    final selected = payMethod == id;

    return pad20(
      GestureDetector(
        onTap: () => setState(() => payMethod = id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? kSoft : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? kBlue : Colors.grey.shade300,
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: kBlue.withOpacity(.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              colorfulIcon(
                icon: icon,
                color: iconColor,
                bgColor: selected
                    ? kBlue.withOpacity(0.15)
                    : Colors.grey.shade100,
                boxSize: 46,
                size: 24,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor.withOpacity(.12),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              color: badgeColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Radio<String>(
                value: id,
                groupValue: payMethod,
                activeColor: kBlue,
                onChanged: (val) {
                  if (val != null) setState(() => payMethod = val);
                },
              ),
            ],
          ),
        ),
      ),
      bottom: 4,
    );
  }

  Widget _buildEWalletSelectionGrid() {
    return pad20(
      Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBlue.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.touch_app_rounded, size: 16, color: kBlue),
                const SizedBox(width: 6),
                Text(
                  'Pilih Dompet Digital Anda:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: context.textMain,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: kEWallets.map((wallet) {
                final isSelected = selectedWallet == wallet['id'];
                return GestureDetector(
                  onTap: () => setState(() => selectedWallet = wallet['id']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: (MediaQuery.of(context).size.width - 76) / 2,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: context.isDark
                          ? context.softBg
                          : isSelected
                          ? wallet['bgColor'] as Color
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? wallet['color']
                            : context.isDark
                            ? context.softBg
                            : Colors.grey.shade200,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        colorfulIcon(
                          icon: wallet['icon'] as IconData,
                          color: wallet['color'] as Color,
                          boxSize: 32,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                wallet['name'] as String,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  color: isSelected
                                      ? wallet['color']
                                      : Colors.black87,
                                ),
                              ),
                              Text(
                                wallet['badge'] as String,
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle_rounded,
                            color: wallet['color'] as Color,
                            size: 16,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankSelectionGrid() {
    return pad20(
      Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBlue.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.touch_app_rounded, size: 16, color: kBlue),
                const SizedBox(width: 6),
                Text(
                  'Pilih Bank Tujuan Transfer:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: context.textMain,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Column(
              children: kBankOptions.map((bank) {
                final isSelected = selectedBank == bank['id'];
                return GestureDetector(
                  onTap: () => setState(() => selectedBank = bank['id']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: context.isDark
                          ? context.softBg
                          : isSelected
                          ? bank['bgColor'] as Color
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? bank['color']
                            : context.isDark
                            ? context.softBg
                            : Colors.grey.shade200,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        colorfulIcon(
                          icon: bank['icon'] as IconData,
                          color: bank['color'] as Color,
                          boxSize: 34,
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bank['name'] as String,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: isSelected
                                      ? bank['color']
                                      : Colors.black87,
                                ),
                              ),
                              Text(
                                bank['fullName'] as String,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle_rounded,
                            color: bank['color'] as Color,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildQrisPayment() {
    return Column(
      children: [
        pad20(_paymentInfoHeader(), top: 14),
        pad20(_countdownBanner(), top: 10),

        sectionTitle(
          'Scan QRIS',
          icon: Icons.qr_code_scanner_rounded,
          iconColor: kAqua,
        ),

        pad20(
          RepaintBoundary(
            key: _qrisCardKey,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: context.softBg,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: kAqua.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.qr_code_rounded, size: 14, color: kAqua),
                        const SizedBox(width: 6),
                        Text(
                          currentQrUrl != null && currentQrUrl!.isNotEmpty
                              ? 'QRIS • MIDTRANS'
                              : 'QRIS',
                          style: TextStyle(
                            color: context.textMain,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    width: 220,
                    height: 220,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                    ),
                    child: currentQrImage != null
                        ? FutureBuilder<Uint8List>(
                            future: currentQrImage,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Image.memory(
                                  snapshot.data!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildQrImageError(),
                                );
                              }
                              if (snapshot.hasError) {
                                return _buildQrImageError();
                              }
                              return const Center(
                                child: CircularProgressIndicator(color: kBlue),
                              );
                            },
                          )
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.qr_code_2_rounded,
                                  color: Colors.grey,
                                  size: 36,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'QRIS belum tersedia',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    'NEXPOOL QRIS PAYMENT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                      color: kDarkBlue,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    rupiah(totalPrice),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: kBlue,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Order ID: $orderId',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        pad20(
          Column(
            children: [
              // 1. TOMBOL DOWNLOAD QRIS
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isDownloadingQris ? null : _downloadQrisImage,
                  icon: _isDownloadingQris
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.download_rounded, size: 20),
                  label: Text(
                    _isDownloadingQris
                        ? 'Menyimpan QRIS...'
                        : 'Download QRIS (Simpan ke Galeri)',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: primaryStyle.copyWith(
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(vertical: 16),
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 2. TOMBOL SALIN LINK URL QRIS
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _copyQrisUrl,
                  icon: const Icon(Icons.copy_rounded, size: 20),
                  label: const Text(
                    'Salin Link URL QRIS',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: kDarkBlue,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kDarkBlue,
                    side: const BorderSide(color: kBlue, width: 1.6),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Indikator auto-check status
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: kBlue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Menunggu pembayaran... (status dicek otomatis)',
                    style: TextStyle(
                      fontSize: 11,
                      color: context.mutedText,
                      fontWeight: FontWeight.w600,
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

  Future<void> _downloadQrisImage() async {
    if (_isDownloadingQris) return;
    setState(() => _isDownloadingQris = true);

    try {
      Uint8List? bytes;
      if (currentQrImage != null) {
        try {
          bytes = await currentQrImage;
        } catch (_) {}
      }

      if (bytes == null || bytes.isEmpty) {
        await WidgetsBinding.instance.endOfFrame;
        final renderObject =
            _qrisCardKey.currentContext?.findRenderObject();
        if (renderObject is RenderRepaintBoundary) {
          final image = await renderObject.toImage(pixelRatio: 3);
          final byteData =
              await image.toByteData(format: ImageByteFormat.png);
          image.dispose();
          bytes = byteData?.buffer.asUint8List();
        }
      }

      if (bytes == null || bytes.isEmpty) {
        throw StateError('Gambar QRIS belum tersedia untuk diunduh.');
      }

      final fileName =
          'NexPool-QRIS-${orderId.isNotEmpty ? orderId : 'Pembayaran'}'
              .replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '-');

      final savedPath = await FileSaver.instance.saveAs(
        name: fileName,
        bytes: bytes,
        fileExtension: 'png',
        mimeType: MimeType.png,
        dialogTitle: 'Simpan Gambar QRIS',
      );

      if (savedPath != null && mounted) {
        showMessage('Gambar QRIS berhasil diunduh ke galeri / penyimpanan!');
      }
    } catch (e) {
      debugPrint('Gagal unduh QRIS: $e');
      if (mounted) showMessage('Gagal mengunduh QRIS: $e');
    } finally {
      if (mounted) setState(() => _isDownloadingQris = false);
    }
  }

  Future<void> _copyQrisUrl() async {
    final urlToCopy = (currentQrUrl != null && currentQrUrl!.isNotEmpty)
        ? currentQrUrl!.trim()
        : '';

    if (urlToCopy.isEmpty || !urlToCopy.startsWith('http')) {
      showMessage('Link URL QRIS belum tersedia.');
      return;
    }

    try {
      await Clipboard.setData(ClipboardData(text: urlToCopy));
      if (mounted) {
        showMessage('Link URL QRIS berhasil disalin!\n$urlToCopy');
      }
    } catch (e) {
      if (mounted) showMessage('Gagal menyalin link: $e');
    }
  }

  Future<void> _downloadStep5Receipt() async {
    if (_isDownloadingReceipt) return;
    setState(() => _isDownloadingReceipt = true);

    try {
      await WidgetsBinding.instance.endOfFrame;
      final boundary = _step5ReceiptKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        throw StateError('Tampilan struk belum siap untuk disimpan.');
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ImageByteFormat.png);
      image.dispose();

      final bytes = byteData?.buffer.asUint8List();
      if (bytes == null || bytes.isEmpty) {
        throw StateError('Gagal membuat gambar struk pembayaran.');
      }

      final cleanTicket = (ticketId.isNotEmpty
              ? ticketId
              : (orderId.isNotEmpty ? orderId : 'Pembayaran'))
          .replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '-');
      final fileName = 'NexPool-Struk-$cleanTicket';

      final savedPath = await FileSaver.instance.saveAs(
        name: fileName,
        bytes: bytes,
        fileExtension: 'png',
        mimeType: MimeType.png,
        dialogTitle: 'Simpan Struk Pembayaran',
      );

      if (savedPath != null && mounted) {
        showMessage('Struk pembayaran berhasil disimpan ke galeri!');
      }
    } catch (e) {
      debugPrint('Gagal unduh struk: $e');
      if (mounted) showMessage('Gagal mengunduh struk: $e');
    } finally {
      if (mounted) setState(() => _isDownloadingReceipt = false);
    }
  }

  Widget buildBankTransferPayment() {
    final activeBank = kBankOptions.firstWhere(
      (b) => b['id'] == selectedBank,
      orElse: () => kBankOptions.first,
    );

    final vaNumber =
        '${activeBank['vaPrefix']}-${orderId.replaceAll('NXP-', '')}';

    return Column(
      children: [
        pad20(_paymentInfoHeader(), top: 14),
        pad20(_countdownBanner(), top: 10),

        sectionTitle(
          'Transfer Virtual Account (${activeBank['name']})',
          icon: Icons.account_balance_rounded,
          iconColor: activeBank['color'] as Color,
        ),

        pad20(
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: activeBank['color'] as Color,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        activeBank['icon'] as IconData,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        (activeBank['name'] as String).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        activeBank['fullName'] as String,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: context.isDark
                        ? context.softBg
                        : activeBank['bgColor'] as Color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (activeBank['color'] as Color).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'NOMOR VIRTUAL ACCOUNT',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            vaNumber,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: activeBank['color'] as Color,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: vaNumber));
                              showMessage('Nomor VA $vaNumber disalin!');
                            },
                            child: Icon(
                              Icons.copy_rounded,
                              size: 18,
                              color: activeBank['color'] as Color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                _bankInfoRow('Atas Nama Rekening', 'NEXPOOL INDONESIA'),
                _bankInfoRow(
                  'Nominal Transfer',
                  rupiah(totalPrice),
                  highlight: true,
                ),
                const Divider(height: 20),
                _bankInfoRow('Order ID', orderId),
                _bankInfoRow('Kolam Renang', selectedPoolName),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.isDark
                        ? const Color(0xFF3B3424)
                        : kYellowSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      colorfulIcon(
                        icon: Icons.warning_amber_rounded,
                        color: context.isDark
                            ? const Color(0xFFFFD166)
                            : const Color(0xff9a6c00),
                        boxSize: 28,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Transfer tepat sesuai nominal tagihan melalui M-Banking atau ATM bank terkait.',
                          style: TextStyle(
                            fontSize: 10,
                            color: context.isDark
                                ? const Color(0xFFFFD166)
                                : const Color(0xff7a5800),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        pad20(
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isCheckingPaymentStatus
                  ? null
                  : () => _checkPaymentStatus(showPendingMessage: true),
              icon: const Icon(Icons.sync_rounded, size: 20),
              label: const Text(
                'Cek Status Pembayaran',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              style: primaryStyle.copyWith(
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
        ),

        pad20(
          OutlinedButton(
            onPressed: _backToSelect,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('← Pilih Metode / Bank Lain'),
          ),
          top: 8,
          bottom: 20,
        ),
      ],
    );
  }

  Widget _paymentInfoHeader() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: kGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TOTAL PEMBAYARAN',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rupiah(totalPrice),
                  style: const TextStyle(
                    color: kGold,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Order ID: $orderId',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _statusChip(
                '⏱ $countdownLabel',
                _remainingSeconds <= 60 ? kRed : kOrange,
              ),
              const SizedBox(height: 6),
              Text(
                '$qtyAdult Dewasa${qtyChild > 0 ? ', $qtyChild Anak' : ''}',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TIMER PEMBAYARAN
  // ============================================================
  void _startPayTimer({int? initialSeconds}) {
    _payTimer?.cancel();

    final startSeconds = (initialSeconds != null && initialSeconds > 0)
        ? initialSeconds
        : payDurationSeconds;

    setState(() {
      _remainingSeconds = startSeconds;
      paymentExpired = false;
    });

    _payTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds <= 1) {
        timer.cancel();
        _paymentStatusTimer?.cancel();
        if (mounted) {
          setState(() {
            _remainingSeconds = 0;
            paymentExpired = true;
            statusPembayaran = 'expired';
          });
        }
        return;
      }

      setState(() => _remainingSeconds--);
    });
  }

  void _stopPayTimer() {
    _payTimer?.cancel();
    _payTimer = null;
  }

  /// Keberadaan helper ini hanya dipakai oleh tampilan pembayaran lama.
  void _backToSelect() {
    _stopPayTimer();
    setState(() => paySubStep = 'select');
  }

  /// Minta QRIS baru setelah Midtrans menyatakan transaksi lama kedaluwarsa.
  void _restartPayment() {
    _stopPayTimer();
    _paymentStatusTimer?.cancel();
    setState(() {
      orderId = '';
      currentQrUrl = null;
      currentQrImage = null;
      statusPembayaran = 'pending';
      paymentExpired = false;
      paySubStep = 'process';
    });
    _createReservationAndQris();
  }

  String get countdownLabel {
    final m = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Widget _buildQrImageError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.broken_image_rounded,
            color: Colors.grey,
            size: 36,
          ),
          const SizedBox(height: 6),
          const Text(
            'Gagal memuat QRIS',
            style: TextStyle(fontSize: 11, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          TextButton(
            onPressed: orderId.isEmpty
                ? null
                : () => setState(() {
                    currentQrImage = ApiService.getMidtransQrImage(orderId);
                  }),
            child: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }

  Widget _countdownBanner() {
    final bool urgent = _remainingSeconds <= 60;
    final Color color = urgent ? kRed : kOrange;

    return infoBox(
      color: urgent ? kRedSoft : kOrangeSoft,
      radius: 12,
      pad: 12,
      border: color.withOpacity(.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timer_rounded, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _remainingSeconds == 0
                      ? 'Memeriksa status pembayaran ke Midtrans...'
                      : 'Selesaikan pembayaran sebelum waktu habis',
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                countdownLabel,
                style: TextStyle(
                  fontSize: 16,
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _remainingSeconds / payDurationSeconds,
              minHeight: 6,
              backgroundColor: color.withOpacity(.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  /// Tampilan untuk status pembayaran yang tidak bisa lagi diproses.
  Widget buildPaymentExpired() {
    final canRetry = statusPembayaran != 'refunded';
    final title = switch (statusPembayaran) {
      'cancelled' => 'Pembayaran Dibatalkan',
      'failed' => 'Pembayaran Gagal',
      'refunded' => 'Pembayaran Dikembalikan',
      _ => 'QRIS Kedaluwarsa',
    };
    final message = statusPembayaran == 'refunded'
        ? 'Transaksi untuk pesanan $orderId telah dikembalikan. Periksa riwayat tiket atau hubungi petugas jika membutuhkan bantuan.'
        : 'Waktu pembayaran QRIS untuk pesanan $orderId telah habis (5 menit). Silakan buat transaksi / QRIS baru untuk melanjutkan.';

    return Column(
      children: [
        const SizedBox(height: 24),
        pad20(
          infoBox(
            color: context.cardBg,
            radius: 20,
            pad: 24,
            border: kRed.withOpacity(.3),
            child: Column(
              children: [
                colorfulIcon(
                  icon: Icons.timer_off_rounded,
                  color: kRed,
                  bgColor: kRedSoft,
                  boxSize: 76,
                  size: 40,
                  isCircle: true,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: kRed,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.mutedText,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 22),
                if (canRetry)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _restartPayment,
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                      label: const Text(
                        'Buat QRIS Baru',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: primaryStyle.copyWith(
                        padding: const WidgetStatePropertyAll(
                          EdgeInsets.symmetric(vertical: 16),
                        ),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: canRetry
                        ? () => goStep(3)
                        : () => setState(() => selectedTab = 1),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      canRetry
                          ? '← Kembali ke Pilih Tiket'
                          : 'Lihat Riwayat Tiket',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(.2),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withOpacity(.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _bankInfoRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: highlight ? 15 : 13,
              fontWeight: FontWeight.w800,
              color: highlight ? kBlue : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStep5() {
    final normalizedPoolId = normalizePoolId(selectedPoolId);
    final payLabel = _paymentLabel();
    final paidTime = paidAt != null ? formatDateTime(paidAt!) : '—';

    return Column(
      children: [
        const SizedBox(height: 24),

        Center(
          child: AnimatedBuilder(
            animation: _successAnimController,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kGreen.withOpacity(0.15),
                      ),
                    ),
                  ),
                  CustomPaint(
                    size: const Size(140, 140),
                    painter: _ConfettiParticlesPainter(
                      progress: _scaleAnimation.value,
                    ),
                  ),
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: kGreen,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: kGreen.withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        const SizedBox(height: 18),

        const Text(
          'Pembayaran Berhasil! 🎉',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'Tiket Anda telah dikonfirmasi & siap digunakan!',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 20),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: RepaintBoundary(
            key: _step5ReceiptKey,
            child: Container(
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.07),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: const BoxDecoration(
                    gradient: kGradient,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      colorfulIcon(
                        icon: Icons.pool_rounded,
                        color: Colors.white,
                        bgColor: Colors.white.withOpacity(0.2),
                        boxSize: 48,
                        size: 26,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        selectedPoolName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Pool ID: $normalizedPoolId ($selectedPoolId)',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: kGreen.withOpacity(.25),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: kGreen.withOpacity(.5)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: kGreen,
                              size: 14,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'PAID — LUNAS',
                              style: TextStyle(
                                color: kGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: context.softBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: kBlue.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'KODE TIKET RESMI',
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
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                                color: kDarkBlue,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),
                      const Divider(),

                      receiptRow(Icons.pin_rounded, kBlue, 'Order ID', orderId),
                      receiptRow(
                        Icons.confirmation_number_rounded,
                        kOrange,
                        'Kode Tiket',
                        ticketId,
                      ),
                      receiptRow(
                        Icons.pool_rounded,
                        kAqua,
                        'ID Pool',
                        '$normalizedPoolId ($selectedPoolId)',
                      ),
                      receiptRow(
                        Icons.water_rounded,
                        kBlue,
                        'Kolam Renang',
                        selectedPoolName,
                      ),
                      receiptRow(
                        Icons.person_rounded,
                        kPurple,
                        'Nama Pemesan',
                        nama.isEmpty ? '—' : nama,
                      ),
                      receiptRow(
                        Icons.phone_in_talk_rounded,
                        kGreen,
                        'No. Telepon',
                        phoneDisplay,
                      ),
                      receiptRow(
                        Icons.calendar_month_rounded,
                        kBlue,
                        'Tanggal Kunjungan',
                        selectedDateLabel.isEmpty ? '—' : selectedDateLabel,
                      ),
                      receiptRow(
                        Icons.local_activity_rounded,
                        kOrange,
                        'Kategori',
                        category == 'dewasa' ? 'Dewasa' : 'Anak-anak',
                      ),
                      receiptRow(
                        Icons.group_rounded,
                        kGreen,
                        'Jumlah',
                        qtyChild > 0
                            ? '$qtyAdult Dewasa, $qtyChild Anak'
                            : '$qtyAdult Dewasa',
                      ),
                      if (keterangan.isNotEmpty)
                        receiptRow(
                          Icons.notes_rounded,
                          kGold,
                          'Keterangan',
                          keterangan,
                        ),
                      receiptRow(
                        Icons.payment_rounded,
                        kDarkBlue,
                        'Metode Pembayaran',
                        payLabel,
                      ),
                      receiptRow(
                        Icons.price_change_rounded,
                        kBlue,
                        'Harga Tiket',
                        rupiah(adultPrice),
                      ),
                      receiptRow(
                        Icons.receipt_rounded,
                        kAqua,
                        'Biaya Admin',
                        rupiah(adminFee),
                      ),

                      const SizedBox(height: 14),

                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          gradient: kGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Dibayarkan',
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              rupiah(totalPrice),
                              style: const TextStyle(
                                color: kGold,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.access_time_filled_rounded,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Dibayar: $paidTime',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: context.softBg.withOpacity(.5),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
                  ),
                  child: const Text(
                    '⚠️ Tunjukkan struk ini kepada petugas di pintu masuk.\n'
                    'Tiket berlaku pada tanggal kunjungan yang tertera.\n'
                    'Hubungi Customer Care Nexpool jika ada pertanyaan.',
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
      ),

        const SizedBox(height: 20),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      _isDownloadingReceipt ? null : _downloadStep5Receipt,
                  icon: _isDownloadingReceipt
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.download_rounded, size: 20),
                  label: Text(
                    _isDownloadingReceipt
                        ? 'Menyimpan Struk...'
                        : 'Download Struk Pembayaran (Galeri)',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreen,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() => selectedTab = 1);
                    goStep(1);
                  },
                  icon: const Icon(Icons.confirmation_number_rounded, size: 18),
                  label: const Text('Lihat Tiket Saya'),
                  style: primaryStyle.copyWith(
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(vertical: 14),
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: myTickets.isNotEmpty
                      ? () => openReschedule(0)
                      : null,
                  icon: const Icon(Icons.sync_rounded, size: 18),
                  label: const Text('Reschedule Tiket Ini'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPurpleSoft,
                    foregroundColor: kPurple,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.home_rounded, size: 18),
                  label: const Text('Kembali ke Beranda'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget receiptRow(IconData icon, Color color, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          colorfulIcon(icon: icon, color: color, boxSize: 24, size: 13),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 9,
                color: Colors.grey,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMyTickets() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 88),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTabs(),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
            child: Row(
              children: [
                colorfulIcon(
                  icon: Icons.confirmation_number_rounded,
                  color: kAqua,
                  boxSize: 34,
                  size: 20,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Daftar Tiket Saya',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),

          _buildStatusFilter(),

          if (myTickets.isEmpty)
            _buildEmptyTickets()
          else
            ...List.generate(
              myTickets.length,
              (i) => buildTicketCard(i, myTickets[i]),
            ),
        ],
      ),
    );
  }

  String _ticketFilter = 'all';

  Widget _buildStatusFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          _filterChip('all', 'Semua', Icons.local_activity_rounded, kBlue),
          const SizedBox(width: 8),
          _filterChip('paid', 'Paid', Icons.check_circle_rounded, kGreen),
          const SizedBox(width: 8),
          _filterChip(
            'pending',
            'Pending',
            Icons.access_time_filled_rounded,
            kOrange,
          ),
          const SizedBox(width: 8),
          _filterChip('cancelled', 'Cancelled', Icons.cancel_rounded, kRed),
        ],
      ),
    );
  }

  Widget _filterChip(String value, String label, IconData icon, Color color) {
    final selected = _ticketFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _ticketFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: selected ? color : Colors.grey.shade300),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: selected ? Colors.white : color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTickets() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ilustrasi ikon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: context.softBg,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: kBlue.withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.confirmation_number_rounded,
                color: kAqua,
                size: 48,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Belum Ada Tiket',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: context.textMain,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Kamu belum punya tiket.\nPesan tiket sekarang untuk mulai berwisata!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.mutedText,
                fontSize: 13,
                height: 1.55,
              ),
            ),

            const SizedBox(height: 28),

            // Tombol Pesan Tiket
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => setState(() => selectedTab = 0),
                icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                label: const Text(
                  'Pesan Tiket Sekarang',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                style: primaryStyle.copyWith(
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(vertical: 15),
                  ),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTicketCard(int index, Map<String, dynamic> ticket) {
    final status = ticket['status']?.toString() ?? 'pending';
    final resched = ticket['reschedule'] as int? ?? 0;

    if (_ticketFilter != 'all' && status != _ticketFilter) {
      return const SizedBox.shrink();
    }

    Color statusFg;
    Color statusBg;
    String statusLabel;
    IconData statusIcon;

    switch (status) {
      case 'paid':
        statusFg = const Color(0xff087f65);
        statusBg = const Color(0xffe3fff7);
        statusLabel = 'PAID';
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'cancelled':
        statusFg = kRed;
        statusBg = kRedSoft;
        statusLabel = 'CANCELLED';
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusFg = kOrange;
        statusBg = kOrangeSoft;
        statusLabel = 'PENDING';
        statusIcon = Icons.access_time_filled_rounded;
    }

    final cardPoolName = ticket['poolName']?.toString() ?? selectedPoolName;
    final cardPoolId =
        ticket['poolId']?.toString() ?? normalizePoolId(selectedPoolId);
    final cardTicketId =
        ticket['ticketId']?.toString() ?? ticket['orderId']?.toString() ?? '—';

    return pad20(
      infoBox(
        color: context.cardBg,
        radius: 18,
        pad: 16,
        border: status == 'cancelled'
            ? Colors.grey.shade300
            : status == 'pending'
            ? kOrange.withOpacity(.3)
            : Colors.grey.shade200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${ticket['orderId'] ?? cardTicketId}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ticket['name']?.toString() ?? '—',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                badge(statusLabel, statusFg, statusBg, icon: statusIcon),
              ],
            ),

            if (resched > 0) ...[
              const SizedBox(height: 8),
              badge(
                'Pernah Reschedule $resched×',
                kPurple,
                kPurpleSoft,
                icon: Icons.sync_rounded,
              ),
            ],

            const SizedBox(height: 12),

            ticketInfo(Icons.pool_rounded, kAqua, 'Kolam', cardPoolName),
            ticketInfo(Icons.pin_rounded, kPurple, 'ID Pool', cardPoolId),
            ticketInfo(
              Icons.confirmation_number_rounded,
              kOrange,
              'Kode Tiket',
              cardTicketId,
            ),
            ticketInfo(
              Icons.calendar_month_rounded,
              kBlue,
              'Tanggal Kunjungan',
              ticket['date']?.toString() ?? '—',
            ),
            ticketInfo(
              Icons.group_rounded,
              kGreen,
              'Jumlah',
              ticket['qty']?.toString() ?? '—',
            ),
            ticketInfo(
              Icons.payment_rounded,
              kDarkBlue,
              'Bayar via',
              ticket['payment']?.toString() ?? '—',
            ),
            ticketInfo(
              Icons.monetization_on_rounded,
              kGold,
              'Total Pembayaran',
              rupiah(ticket['total'] as int? ?? 0),
            ),

            if (status == 'paid' &&
                ticket['paidAt'] != null &&
                ticket['paidAt'].toString().isNotEmpty)
              ticketInfo(
                Icons.access_time_filled_rounded,
                kGreen,
                'Waktu Bayar',
                ticket['paidAt'].toString(),
              ),

            const SizedBox(height: 14),

            if (status == 'paid') ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => showReceiptFromTicket(ticket),
                      icon: const Icon(Icons.receipt_long_rounded, size: 15),
                      label: const Text(
                        'Lihat Struk',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => openReschedule(index),
                      icon: const Icon(Icons.sync_rounded, size: 15),
                      label: const Text(
                        'Reschedule',
                        style: TextStyle(fontSize: 11),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPurpleSoft,
                        foregroundColor: kPurple,
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (status == 'pending') ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => showReceiptFromTicket(ticket),
                      icon: const Icon(Icons.receipt_long_rounded, size: 15),
                      label: const Text(
                        'Detail',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => cancelTransaction(index),
                      icon: const Icon(Icons.cancel_rounded, size: 15),
                      label: const Text(
                        'Batalkan',
                        style: TextStyle(fontSize: 11),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kRedSoft,
                        foregroundColor: kRed,
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => showReceiptFromTicket(ticket),
                  icon: const Icon(Icons.receipt_long_rounded, size: 15),
                  label: const Text(
                    'Lihat Detail',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ),
            ],
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
    IconData? icon,
    double fontSize = 10,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: fg,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget ticketInfo(IconData icon, Color color, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          colorfulIcon(icon: icon, color: color, boxSize: 22, size: 12),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void showReceiptFromTicket(Map<String, dynamic> ticket) {
    final status = ticket['status']?.toString() ?? 'pending';
    final receiptKey = GlobalKey();
    final isPaid = status == 'paid';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return sheetShell(
          height: .85,
          radius: 25,
          child: Column(
            children: [
              sheetHandle(),
              const SizedBox(height: 16),

              const Text(
                'Detail Transaksi Tiket',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),

              const SizedBox(height: 8),

              badge(
                isPaid ? 'PAID — LUNAS' : status.toUpperCase(),
                isPaid ? kGreen : kOrange,
                isPaid ? kGreen.withOpacity(.12) : kOrange.withOpacity(.12),
                icon: isPaid
                    ? Icons.check_circle_rounded
                    : Icons.access_time_filled_rounded,
              ),

              const SizedBox(height: 16),

              Expanded(
                child: SingleChildScrollView(
                  child: RepaintBoundary(
                    key: receiptKey,
                    child: _buildPrintableReceipt(ticket, status),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              if (isPaid) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _downloadReceiptImage(receiptKey, ticket),
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Unduh Bukti Pembayaran (PNG)'),
                    style: primaryStyle.copyWith(
                      padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(vertical: 14),
                      ),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrintableReceipt(
    Map<String, dynamic> ticket,
    String paymentStatus,
  ) {
    final visitDate = _receiptDate(
      ticket['visitDate']?.toString() ?? ticket['date']?.toString(),
    );
    final reservationDate = _receiptDate(
      ticket['reservedAt']?.toString(),
      includeTime: true,
    );
    final paymentDate = _receiptDate(
      ticket['paidAtIso']?.toString() ?? ticket['paidAt']?.toString(),
      includeTime: true,
    );

    Widget detail(String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 12, color: context.mutedText),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: context.textMain,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.isDark
              ? Colors.white.withOpacity(.12)
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.pool_rounded, color: kBlue, size: 34),
          const SizedBox(height: 6),
          Text(
            'NEXPOOL',
            style: TextStyle(
              color: context.textMain,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          Text(
            'BUKTI PEMBAYARAN TIKET',
            style: TextStyle(
              color: context.mutedText,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: context.mutedText.withOpacity(.25)),
          const SizedBox(height: 10),
          detail('Status', paymentStatus.toUpperCase()),
          detail('Kode tiket', ticket['ticketId']?.toString() ?? '—'),
          detail('ID transaksi', ticket['orderId']?.toString() ?? '—'),
          detail('Kolam renang', ticket['poolName']?.toString() ?? '—'),
          detail('Nama pemesan', ticket['customerName']?.toString() ?? nama),
          detail('Nomor telepon', ticket['customerPhone']?.toString() ?? '—'),
          detail('Tanggal pemesanan', reservationDate),
          detail('Tanggal kunjungan', visitDate),
          detail('Jumlah tiket', ticket['qty']?.toString() ?? '—'),
          detail('Metode pembayaran', ticket['payment']?.toString() ?? 'QRIS'),
          detail('Waktu pembayaran', paymentDate),
          const SizedBox(height: 7),
          Container(height: 1, color: context.mutedText.withOpacity(.25)),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOTAL DIBAYAR',
                  style: TextStyle(
                    color: context.mutedText,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  rupiah((ticket['total'] as num?)?.round() ?? 0),
                  style: const TextStyle(
                    color: kBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: context.isDark
                  ? const Color(0xFF3B3424)
                  : const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'PENTING: Tiket hanya berlaku pada tanggal kunjungan yang tercantum. Jika tidak digunakan sampai tanggal tersebut terlewat, tiket hangus dan tidak dapat dipakai pada hari lain.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.isDark
                    ? const Color(0xFFFFD166)
                    : const Color(0xFF765500),
                fontSize: 10,
                height: 1.4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tunjukkan bukti ini kepada petugas loket.',
            style: TextStyle(
              color: context.mutedText,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _receiptDate(String? value, {bool includeTime = false}) {
    if (value == null || value.trim().isEmpty) return '—';
    final date = DateTime.tryParse(value);
    if (date == null) return value;
    return includeTime
        ? formatDateTime(date.toLocal())
        : formatDate(date.toLocal());
  }

  Future<void> _downloadReceiptImage(
    GlobalKey receiptKey,
    Map<String, dynamic> ticket,
  ) async {
    try {
      await WidgetsBinding.instance.endOfFrame;
      final renderObject = receiptKey.currentContext?.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) {
        throw StateError('Gambar struk belum siap dibuat.');
      }

      final image = await renderObject.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      image.dispose();
      if (byteData == null) {
        throw StateError('Gagal mengubah struk menjadi gambar PNG.');
      }

      final fileName =
          'NexPool-Struk-${ticket['ticketId']?.toString() ?? 'Tiket'}'
              .replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '-');
      final savedPath = await FileSaver.instance.saveAs(
        name: fileName,
        bytes: byteData.buffer.asUint8List(),
        fileExtension: 'png',
        mimeType: MimeType.png,
        dialogTitle: 'Unduh bukti pembayaran',
      );
      if (savedPath != null && mounted) {
        showMessage('Bukti pembayaran berhasil diunduh.');
      }
    } catch (e) {
      debugPrint('Gagal mengunduh bukti pembayaran: $e');
      if (mounted) showMessage('Gagal mengunduh bukti pembayaran: $e');
    }
  }

  Widget sheetHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
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
    final content = Padding(padding: const EdgeInsets.all(20), child: child);

    return Container(
      height: MediaQuery.of(context).size.height * height,
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
      ),
      child: safeArea ? SafeArea(child: content) : content,
    );
  }

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
            final availableDates = datesFrom(29, offset: 1);
            final baseWeekday = weekdayPrice > 0 ? weekdayPrice : 15000;
            final baseWeekend = weekendPrice > 0 ? weekendPrice : 20000;

            final newPrice = newDate != null && isWeekendDate(newDate!)
                ? baseWeekend
                : baseWeekday;
            final currentPrice =
                (ticket['total'] as num?)?.toInt() ?? baseWeekday;
            final diff = newPrice - currentPrice;

            final cardPoolName =
                ticket['poolName']?.toString() ?? selectedPoolName;

            return sheetShell(
              height: .88,
              safeArea: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sheetHandle(),
                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Reschedule Tiket',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),

                  const Text(
                    'Pilih tanggal kunjungan baru Anda',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          infoBox(
                            radius: 15,
                            pad: 15,
                            border: kBlue.withOpacity(.25),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    colorfulIcon(
                                      icon: Icons.confirmation_number_rounded,
                                      color: kAqua,
                                      boxSize: 28,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'INFORMASI TIKET SAAT INI',
                                      style: TextStyle(
                                        color: kAqua,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                infoRow('Kolam Renang', cardPoolName),
                                infoRow(
                                  'No. Tiket',
                                  ticket['ticketId']?.toString() ??
                                      ticket['orderId']?.toString() ??
                                      '—',
                                ),
                                infoRow(
                                  'Tanggal Saat Ini',
                                  ticket['date']?.toString() ?? '—',
                                ),
                                infoRow(
                                  'Kategori',
                                  ticket['qty']?.toString() ?? '—',
                                ),
                                infoRow(
                                  'Total Terbayar',
                                  rupiah(ticket['total'] as int? ?? 0),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          infoBox(
                            color: context.isDark
                                ? const Color(0xFF3B3424)
                                : kYellowSoft,
                            radius: 14,
                            pad: 14,
                            border: kGold.withOpacity(.5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    colorfulIcon(
                                      icon: Icons.policy_rounded,
                                      color: const Color(0xff9a6c00),
                                      boxSize: 28,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Ketentuan Reschedule',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xff9a6c00),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 7),
                                const Text(
                                  '• Hanya dapat dilakukan sebelum tanggal kunjungan.\n'
                                  '• Maksimal H-1 dari tanggal kunjungan.\n'
                                  '• Tanggal baru harus memiliki kuota tersisa.\n'
                                  '• Jika harga weekend lebih mahal, bayar selisih.',
                                  style: TextStyle(fontSize: 11, height: 1.5),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          const Text(
                            'Pilih Tanggal Baru',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 10),

                          dateStrip(
                            list: availableDates,
                            active: newDate,
                            height: 85,
                            onPick: (d) => setModalState(() => newDate = d),
                          ),

                          if (newDate != null) ...[
                            const SizedBox(height: 10),
                            infoBox(
                              color: const Color(0xffe8fff8),
                              child: Text(
                                'Tanggal Baru: ${formatDate(newDate!)}\n'
                                '${diff > 0
                                    ? 'Harga lebih mahal ${rupiah(diff)}'
                                    : diff < 0
                                    ? 'Harga lebih murah ${rupiah(diff.abs())}'
                                    : 'Harga sama (tidak ada selisih)'}',
                                style: const TextStyle(
                                  color: Color(0xff087f65),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
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
                                    myTickets[index]['date'] = formatShortDate(
                                      newDate!,
                                    );
                                    myTickets[index]['reschedule'] =
                                        (myTickets[index]['reschedule']
                                                as int? ??
                                            0) +
                                        1;
                                  });
                                  Navigator.pop(context);
                                  showMessage(
                                    'Reschedule berhasil ke ${formatShortDate(newDate!)}',
                                  );
                                },
                          style: primaryStyle,
                          child: const Text('Konfirmasi Reschedule'),
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

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder fieldBorder({Color? color, double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: color ?? Colors.grey.shade300,
        width: width,
      ),
    );
  }
}

class _ConfettiParticlesPainter extends CustomPainter {
  final double progress;

  _ConfettiParticlesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final count = 12;
    final colors = [kGreen, kBlue, kGold, kPurple, kOrange, kRed];

    for (int i = 0; i < count; i++) {
      final angle = (i * (2 * math.pi / count));
      final distance = 40 + (progress * 30);
      final x = center.dx + math.cos(angle) * distance;
      final y = center.dy + math.sin(angle) * distance;

      final pPaint = Paint()
        ..color = colors[i % colors.length].withOpacity(
          (1 - progress).clamp(0.0, 1.0),
        )
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 4 * (1 - progress * 0.3), pPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
