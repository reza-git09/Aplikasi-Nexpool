import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/api_service.dart';
import 'tiket_page.dart';

// ============================================================
// DATA PROMO FALLBACK — ditampilkan kalau API gagal / offline
// ============================================================
const List<Map<String, dynamic>> _kFallbackPromos = [
  {
    'nama': 'Promo Weekend Seru',
    'deskripsi':
        'Nikmati diskon spesial setiap akhir pekan! Ajak keluarga dan teman untuk berenang bersama dengan harga yang lebih hemat.',
    'label_diskon': 'Diskon 20%',
    'tanggal_mulai': '',
    'tanggal_selesai': '2025-12-31',
    'pool_id': '',
  },
  {
    'nama': 'Promo Pelajar & Mahasiswa',
    'deskripsi':
        'Tunjukkan kartu pelajar atau KTM dan dapatkan harga tiket spesial. Berlaku setiap hari kerja.',
    'label_diskon': 'Diskon 15%',
    'tanggal_mulai': '',
    'tanggal_selesai': '2025-12-31',
    'pool_id': 'pool_id_01',
  },
  {
    'nama': 'Promo Keluarga Bahagia',
    'deskripsi':
        'Beli 4 tiket dewasa, gratis 2 tiket anak! Jadikan liburan bersama keluarga semakin menyenangkan.',
    'label_diskon': 'Beli 4 Gratis 2',
    'tanggal_mulai': '',
    'tanggal_selesai': '2025-11-30',
    'pool_id': '',
  },
];

class PromoPage extends StatefulWidget {
  const PromoPage({super.key});

  @override
  State<PromoPage> createState() => _PromoPageState();
}

class _PromoPageState extends State<PromoPage> with SingleTickerProviderStateMixin {
  bool _loading = true;
  String _error = '';
  List<Map<String, dynamic>> _promos = [];

  final Set<int> _expanded = {};

  late AnimationController _shimmerController;

  static const Color _ink = Color(0xff172B4D);
  static const Color _blue = Color(0xff0077B6);
  static const Color _navy = Color(0xff173F7A);

  static const List<List<Color>> _gradients = [
    [Color(0xff0077B6), Color(0xff00B4D8)],
    [Color(0xff06D6A0), Color(0xff0077A8)],
    [Color(0xff7B61FF), Color(0xffEF476F)],
    [Color(0xff173F7A), Color(0xff2675D8)],
    [Color(0xffF7B731), Color(0xffEF476F)],
  ];

  static const List<IconData> _icons = [
    Icons.local_offer_rounded,
    Icons.waves_rounded,
    Icons.celebration_rounded,
    Icons.star_rounded,
    Icons.pool_rounded,
  ];

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _load();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  // ============================================================
  // AMBIL PROMO DARI API LARAVEL — dengan fallback ke dummy data
  // ============================================================
  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = '';
      });
    }

    try {
      final res = await http
          .get(
            Uri.parse('${ApiService.baseUrl}/promo'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('PROMO STATUS: ${res.statusCode} BODY: ${res.body}');

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final raw = body is Map ? (body['data'] ?? []) : body;

        final list = <Map<String, dynamic>>[];
        if (raw is List) {
          for (final item in raw) {
            if (item is Map) list.add(Map<String, dynamic>.from(item));
          }
        }

        if (!mounted) return;
        setState(() {
          // Kalau API berhasil tapi kosong, tetap pakai fallback
          _promos = list.isNotEmpty ? list : List.from(_kFallbackPromos);
          _loading = false;
        });
        return;
      }

      // Status bukan 200 → pakai fallback, tidak tampilkan error
      if (!mounted) return;
      setState(() {
        _promos = List.from(_kFallbackPromos);
        _loading = false;
      });
    } catch (_) {
      // Koneksi gagal → pakai fallback, tidak tampilkan error
      if (!mounted) return;
      setState(() {
        _promos = List.from(_kFallbackPromos);
        _loading = false;
      });
    }
  }

  // ============================================================
  // HELPER
  // ============================================================
  String _fmt(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final d = DateTime.tryParse(raw);
    if (d == null) return raw;
    return '${d.day} ${_months[d.month - 1]} ${d.year}';
  }

  String _poolLabel(Map<String, dynamic> p) {
    final poolId = p['pool_id']?.toString() ?? '';
    if (poolId.isEmpty) return 'Semua Kolam';
    return poolDisplayName(poolId, poolId);
  }

  void _use(Map<String, dynamic> promo) {
    final poolId = promo['pool_id']?.toString() ?? '';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TiketPage(
          poolId: poolId.isEmpty ? null : poolId,
          poolName: poolId.isEmpty ? null : poolDisplayName(poolId, 'Kolam Renang'),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF0F4FA),
      body: RefreshIndicator(
        onRefresh: _load,
        color: _blue,
        child: ListView(
          padding: EdgeInsets.zero,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _buildHeader(),
            _buildSectionTitle(),
            if (_loading)
              _buildShimmer()
            else if (_error.isNotEmpty)
              _buildError()
            else if (_promos.isEmpty)
              _buildEmpty()
            else
              ...List.generate(_promos.length, (i) => _promoCard(i, _promos[i])),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff173F7A), Color(0xff2675D8)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Dekorasi lingkaran belakang
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              right: 30,
              bottom: -10,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            // Icon dekorasi kanan atas
            Positioned(
              right: 24,
              top: 44,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.local_offer_rounded, color: Colors.white, size: 40),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tombol kembali
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_fire_department_rounded, color: Colors.orangeAccent, size: 14),
                        SizedBox(width: 5),
                        Text(
                          'PENAWARAN SPESIAL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Promo & Diskon',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hemat lebih banyak dengan penawaran\nexklusif dari NexPool! 🎉',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.5,
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

  // ============================================================
  // SECTION TITLE
  // ============================================================
  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xffFFF3E0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(Icons.local_fire_department_rounded, color: Color(0xffEF6C35), size: 20),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Promo Aktif',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _ink),
            ),
          ),
          if (!_loading && _error.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff0077B6), Color(0xff00B4D8)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_promos.length} Promo',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // SHIMMER LOADING
  // ============================================================
  Widget _buildShimmer() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, _) {
        final shimmerColor = ColorTween(
          begin: Colors.grey.shade200,
          end: Colors.grey.shade100,
        ).evaluate(_shimmerController)!;

        return Column(
          children: List.generate(2, (i) => Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
            ),
            child: Column(
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 14, width: 180, color: shimmerColor),
                      const SizedBox(height: 10),
                      Container(height: 12, color: shimmerColor),
                      const SizedBox(height: 6),
                      Container(height: 12, width: 220, color: shimmerColor),
                      const SizedBox(height: 20),
                      Container(height: 48, decoration: BoxDecoration(color: shimmerColor, borderRadius: BorderRadius.circular(16))),
                    ],
                  ),
                ),
              ],
            ),
          )),
        );
      },
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================
  Widget _buildEmpty() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 14)],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xffEEF4FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_offer_rounded, size: 40, color: _blue),
          ),
          const SizedBox(height: 18),
          const Text(
            'Belum Ada Promo Aktif',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _ink),
          ),
          const SizedBox(height: 8),
          Text(
            'Promo terbaru akan muncul di sini.\nTarik layar ke bawah untuk memuat ulang.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.5),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================
  Widget _buildError() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 14)],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xffFFF0F3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.wifi_off_rounded, size: 36, color: Color(0xffEF476F)),
          ),
          const SizedBox(height: 16),
          Text(
            _error,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13.5, color: _ink, height: 1.5),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Coba Lagi', style: TextStyle(fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // KARTU PROMO — desain modern
  // ============================================================
  Widget _promoCard(int index, Map<String, dynamic> p) {
    final colors = _gradients[index % _gradients.length];
    final cardIcon = _icons[index % _icons.length];

    final String nama = p['nama']?.toString() ?? 'Promo';
    final String deskripsi = p['deskripsi']?.toString() ?? '';
    final String label = p['label_diskon']?.toString() ?? '';
    final String mulai = _fmt(p['tanggal_mulai']?.toString());
    final String selesai = _fmt(p['tanggal_selesai']?.toString());
    final bool isExpanded = _expanded.contains(index);

    String periode = '';
    if (mulai.isNotEmpty && selesai.isNotEmpty) {
      periode = '$mulai – $selesai';
    } else if (selesai.isNotEmpty) {
      periode = 'Sampai $selesai';
    } else if (mulai.isNotEmpty) {
      periode = 'Mulai $mulai';
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors[0].withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Banner atas berwarna ──────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
            ),
            child: Stack(
              children: [
                // Lingkaran dekorasi
                Positioned(
                  right: -16,
                  top: -16,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (label.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                label.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                          Text(
                            nama,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              height: 1.2,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (periode.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.access_time_rounded, color: Colors.white70, size: 13),
                                const SizedBox(width: 5),
                                Text(
                                  periode,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(cardIcon, color: Colors.white, size: 30),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Isi kartu ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kolam berlaku
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xffEEF7FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.pool_rounded, size: 16, color: _blue),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Berlaku di: ${_poolLabel(p)}',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                if (deskripsi.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    deskripsi,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: isExpanded ? null : 2,
                    overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  ),
                ],

                if (selesai.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xffFFF0F3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_rounded, size: 14, color: Color(0xffEF476F)),
                        const SizedBox(width: 6),
                        Text(
                          'Berakhir $selesai',
                          style: const TextStyle(
                            color: Color(0xffEF476F),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 18),

                // Tombol aksi
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _use(p),
                        icon: const Icon(Icons.confirmation_number_rounded, size: 18),
                        label: const Text(
                          'Gunakan Promo',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _navy,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isExpanded ? _expanded.remove(index) : _expanded.add(index);
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xffEEF4FF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xffC8DEFF), width: 1.5),
                        ),
                        child: Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: _blue,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Detail expand ──────────────────────────────
                if (isExpanded) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xffF4F8FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xffC8DEFF)),
                    ),
                    child: Column(
                      children: [
                        _detailRow(Icons.pool_rounded, 'Berlaku di', _poolLabel(p)),
                        if (label.isNotEmpty) _detailRow(Icons.local_offer_rounded, 'Diskon', label),
                        if (periode.isNotEmpty)
                          _detailRow(Icons.event_available_rounded, 'Periode', periode),
                        _detailRow(
                          Icons.info_outline_rounded,
                          'Syarat',
                          'Berlaku sesuai periode promo. Promo dapat berakhir lebih cepat.',
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: _blue),
          const SizedBox(width: 10),
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12.5, color: _ink, fontWeight: FontWeight.w700, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}