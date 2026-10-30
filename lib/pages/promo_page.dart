import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/api_service.dart';
import 'tiket_page.dart';

class PromoPage extends StatefulWidget {
  const PromoPage({super.key});

  @override
  State<PromoPage> createState() => _PromoPageState();
}

class _PromoPageState extends State<PromoPage> {
  bool _loading = true;
  String _error = '';
  List<Map<String, dynamic>> _promos = [];

  // Kartu yang sedang dibuka detailnya
  final Set<int> _expanded = {};

  static const Color _ink = Color(0xff172B4D);
  static const Color _blue = Color(0xff0077B6);

  static const List<List<Color>> _gradients = [
    [Color(0xff0077A8), Color(0xff00B4D8)],
    [Color(0xff06D6A0), Color(0xff0077A8)],
    [Color(0xffEF476F), Color(0xff7B61FF)],
    [Color(0xff7B61FF), Color(0xff4A36C8)],
    [Color(0xffF7B731), Color(0xffEF476F)],
  ];

  static const List<String> _emojis = ['🎁', '🌊', '🎉', '⭐', '🏊'];

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ============================================================
  // AMBIL PROMO DARI API LARAVEL
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
          .timeout(const Duration(seconds: 15));

      debugPrint('PROMO STATUS: ${res.statusCode} BODY: ${res.body}');

      if (res.statusCode != 200) {
        throw Exception('Server mengembalikan status ${res.statusCode}');
      }

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
        _promos = list;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Gagal ambil promo: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Gagal memuat promo. Periksa koneksi lalu coba lagi.';
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
      backgroundColor: const Color(0xffF5F8FC),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: EdgeInsets.zero,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _buildHeader(),
            _buildSectionTitle(),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error.isNotEmpty)
              _buildError()
            else if (_promos.isEmpty)
              _buildEmpty()
            else
              ...List.generate(_promos.length, (i) => _promoCard(i, _promos[i])),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xffFFD166), Color(0xffF7B731)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              right: 22,
              top: 34,
              child: Opacity(
                opacity: 0.35,
                child: const Text('🎁', style: TextStyle(fontSize: 96)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: _ink),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Promo & Diskon 🎁',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: _ink,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Penawaran spesial dari NEXPOOL',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xff5A4300),
                      fontWeight: FontWeight.w500,
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

  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 16),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department_rounded, color: Color(0xffEF6C35), size: 28),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Promo Aktif',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _ink),
            ),
          ),
          if (!_loading && _error.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xffFFEFB3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_promos.length} Aktif',
                style: const TextStyle(
                  color: Color(0xff7A5800),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14)],
      ),
      child: Column(
        children: [
          const Text('🎟️', style: TextStyle(fontSize: 54)),
          const SizedBox(height: 14),
          const Text(
            'Belum Ada Promo Aktif',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _ink),
          ),
          const SizedBox(height: 6),
          Text(
            'Promo terbaru akan muncul di sini.\nTarik layar ke bawah untuk memuat ulang.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14)],
      ),
      child: Column(
        children: [
          const Icon(Icons.wifi_off_rounded, size: 44, color: Color(0xffEF476F)),
          const SizedBox(height: 12),
          Text(
            _error,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: _ink, height: 1.5),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // KARTU PROMO
  // ============================================================
  Widget _promoCard(int index, Map<String, dynamic> p) {
    final colors = _gradients[index % _gradients.length];
    final emoji = _emojis[index % _emojis.length];

    final String nama = p['nama']?.toString() ?? 'Promo';
    final String deskripsi = p['deskripsi']?.toString() ?? '';
    final String label = p['label_diskon']?.toString() ?? '';
    final String mulai = _fmt(p['tanggal_mulai']?.toString());
    final String selesai = _fmt(p['tanggal_selesai']?.toString());
    final bool expanded = _expanded.contains(index);

    String periode = '';
    if (mulai.isNotEmpty && selesai.isNotEmpty) {
      periode = 'Berlaku $mulai – $selesai';
    } else if (selesai.isNotEmpty) {
      periode = 'Berlaku sampai $selesai';
    } else if (mulai.isNotEmpty) {
      periode = 'Berlaku mulai $mulai';
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- Bagian atas berwarna ----------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(22, 22, 18, 22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (label.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.22),
                            borderRadius: BorderRadius.circular(20),
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
                      const SizedBox(height: 14),
                      Text(
                        nama,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          height: 1.15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (periode.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          periode,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(emoji, style: const TextStyle(fontSize: 56)),
              ],
            ),
          ),

          // ---------- Bagian isi ----------
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (deskripsi.isNotEmpty)
                  Text(
                    deskripsi,
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.55,
                      color: Colors.grey.shade700,
                    ),
                  ),
                if (selesai.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 17, color: Color(0xffEF476F)),
                      const SizedBox(width: 8),
                      Text(
                        'Berakhir $selesai',
                        style: const TextStyle(
                          color: Color(0xffEF476F),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _use(p),
                        icon: const Icon(Icons.confirmation_number_rounded, size: 20),
                        label: const Text(
                          'Gunakan',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _blue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 17),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          expanded ? _expanded.remove(index) : _expanded.add(index);
                        });
                      },
                      child: Container(
                        width: 60,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xffB9DDEB), width: 1.5),
                        ),
                        child: Icon(
                          expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                          color: _blue,
                        ),
                      ),
                    ),
                  ],
                ),

                // ---------- Detail (dibuka lewat tombol panah) ----------
                if (expanded) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xffF0FAFE),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xffB3E8F5)),
                    ),
                    child: Column(
                      children: [
                        _detailRow(Icons.pool_rounded, 'Berlaku di', _poolLabel(p)),
                        if (label.isNotEmpty) _detailRow(Icons.local_offer_rounded, 'Diskon', label),
                        if (periode.isNotEmpty)
                          _detailRow(Icons.event_available_rounded, 'Periode', periode.replaceFirst('Berlaku ', '')),
                        _detailRow(
                          Icons.info_outline_rounded,
                          'Ketentuan',
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
          Icon(icon, size: 17, color: const Color(0xff00A4C6)),
          const SizedBox(width: 10),
          SizedBox(
            width: 78,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
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