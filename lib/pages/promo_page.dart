import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'tiket_page.dart';

class PromoPage extends StatefulWidget {
  const PromoPage({super.key, this.poolId, this.poolName});

  final String? poolId;
  final String? poolName;

  @override
  State<PromoPage> createState() => _PromoPageState();
}

class _PromoPageState extends State<PromoPage>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  String _error = '';
  List<Map<String, dynamic>> _promos = [];

  final Set<int> _expanded = {};

  late AnimationController _shimmerController;

  // ── Design tokens ──────────────────────────────────────────────
  static const Color _primary = Color(0xff0B5F8A);
  static const Color _accent = Color(0xff0A86AD);
  static const Color _bg = Color(0xffF4F7FB);

  static const List<String> _months = [
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
    'Des',
  ];

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _load();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  // ── API ─────────────────────────────────────────────────────────
  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = '';
      });
    }
    try {
      final promos = await ApiService.getPromos(
        poolId: widget.poolId,
        includeUpcoming: true,
      );
      if (!mounted) return;
      setState(() {
        _promos = promos;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Gagal memuat promo: $e');
      if (!mounted) return;
      setState(() {
        _promos = [];
        _error = 'Promo gagal dimuat. Periksa koneksi lalu coba lagi.';
        _loading = false;
      });
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────
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

  bool _endsToday(String rawDate) {
    final DateTime? parsedDate = DateTime.tryParse(rawDate);
    if (parsedDate == null) return false;
    final DateTime end = parsedDate.isUtc ? parsedDate.toLocal() : parsedDate;
    final DateTime today = DateTime.now();
    return end.year == today.year &&
        end.month == today.month &&
        end.day == today.day;
  }

  void _use(Map<String, dynamic> promo) {
    HapticFeedback.mediumImpact();
    final poolId = promo['pool_id']?.toString() ?? widget.poolId ?? '';
    if (poolId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kolam renang untuk promo ini belum tersedia.'),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TiketPage(
          poolId: poolId,
          poolName: widget.poolId == poolId && widget.poolName != null
              ? widget.poolName
              : poolDisplayName(poolId, 'Kolam Renang'),
          initialPromo: promo,
        ),
      ),
    );
  }

  // ── BUILD ────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.isDark ? context.pageBg : _bg,
      body: RefreshIndicator(
        onRefresh: _load,
        color: _accent,
        strokeWidth: 2.5,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            _buildSliverAppBar(),
            _buildSectionHeader(),
            if (_loading)
              _buildSliverShimmer()
            else if (_error.isNotEmpty)
              SliverToBoxAdapter(child: _buildError())
            else if (_promos.isEmpty)
              SliverToBoxAdapter(child: _buildEmpty())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _promoCard(i, _promos[i]),
                    childCount: _promos.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── SLIVER APP BAR ───────────────────────────────────────────────
  Widget _buildSliverAppBar() {
    return SliverToBoxAdapter(
      child: ColoredBox(
        color: context.cardBg,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            child: Row(
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: IconButton(
                    tooltip: 'Kembali',
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      Navigator.pop(context);
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: context.isDark
                          ? context.softBg
                          : const Color(0xffEDF2F8),
                      foregroundColor: context.textMain,
                      shape: const CircleBorder(),
                    ),
                    icon: const Icon(Icons.arrow_back_rounded, size: 25),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Promo & Diskon',
                        style: TextStyle(
                          color: context.textMain,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.poolName ?? 'Penawaran spesial untuk kamu',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.mutedText,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
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

  // ── SECTION HEADER ───────────────────────────────────────────────
  Widget _buildSectionHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Promo tersedia',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: context.textMain,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Promo yang berlaku atau segera berlaku',
                    style: TextStyle(fontSize: 13, color: context.mutedText),
                  ),
                ],
              ),
            ),
            if (!_loading && _error.isEmpty && _promos.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffDFF0F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xffB5D9ED)),
                ),
                child: Text(
                  '${_promos.length} promo',
                  style: const TextStyle(
                    color: _primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── SHIMMER ──────────────────────────────────────────────────────
  Widget _buildSliverShimmer() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, i) => AnimatedBuilder(
            animation: _shimmerController,
            builder: (_, __) {
              final shine = (_shimmerController.value * 2 - 1).clamp(-1.0, 1.0);
              return Container(
                height: 220,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment(shine - 1, 0),
                    end: Alignment(shine + 1, 0),
                    colors: context.isDark
                        ? [
                            const Color(0xff1A2A40),
                            const Color(0xff253A55),
                            const Color(0xff1A2A40),
                          ]
                        : [
                            const Color(0xffE8EFF5),
                            const Color(0xffD4E3EE),
                            const Color(0xffE8EFF5),
                          ],
                  ),
                ),
              );
            },
          ),
          childCount: 2,
        ),
      ),
    );
  }

  // ── EMPTY ────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 52),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: context.isDark
                ? Colors.white.withValues(alpha: 0.07)
                : const Color(0xffE2EAF2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xffDFF0F9), Color(0xffB8DDEF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_offer_rounded,
                size: 36,
                color: _primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Belum Ada Promo Tersedia',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: context.textMain,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Promo terbaru akan muncul di sini.\nTarik layar ke bawah untuk memperbarui.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: context.mutedText,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── ERROR ────────────────────────────────────────────────────────
  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xffFEEEEE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 34,
                color: Color(0xffEF476F),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: context.textMain,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text(
                  'Coba Lagi',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── KARTU PROMO ──────────────────────────────────────────────────
  Widget _promoCard(int index, Map<String, dynamic> p) {
    final String nama = p['nama']?.toString() ?? 'Promo';
    final String deskripsi = p['deskripsi']?.toString() ?? '';
    final String syaratDariServer = p['syarat']?.toString() ?? '';
    final String syarat = syaratDariServer.trim().isNotEmpty
        ? syaratDariServer
        : deskripsi;
    final String label = p['label_diskon']?.toString() ?? '';
    final String tanggalMulai = p['tanggal_mulai']?.toString() ?? '';
    final String tanggalSelesai = p['tanggal_selesai']?.toString() ?? '';
    final String mulai = _fmt(tanggalMulai);
    final String selesai = _fmt(tanggalSelesai);
    final bool isExpanded = _expanded.contains(index);
    final bool berakhirHariIni = _endsToday(tanggalSelesai);
    final String poolId = p['pool_id']?.toString() ?? '';
    final String namaKolamTerpilih = widget.poolId == poolId
        ? widget.poolName ?? ''
        : '';
    final String namaKolam = namaKolamTerpilih.isNotEmpty
        ? namaKolamTerpilih
        : _poolLabel(p);

    String periode = '';
    if (mulai.isNotEmpty && selesai.isNotEmpty) {
      periode = '$mulai – $selesai';
    } else if (selesai.isNotEmpty) {
      periode = 'Hingga $selesai';
    } else if (mulai.isNotEmpty) {
      periode = 'Mulai $mulai';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xffDFE7EF),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff163A5F).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBanner(nama, label, periode),
          _buildTearLine(),
          _buildCardBody(
            deskripsi: deskripsi,
            selesai: selesai,
            namaKolam: namaKolam,
            syarat: syarat,
            berakhirHariIni: berakhirHariIni,
            isExpanded: isExpanded,
            periode: periode,
            label: label,
            nama: nama,
            index: index,
            p: p,
          ),
        ],
      ),
    );
  }

  // ── Bagian atas kartu ─────────────────────────────────────────────
  Widget _buildBanner(String nama, String label, String periode) {
    return Container(
      color: context.cardBg,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            _chip(label, bg: const Color(0xffE8F4F9), fg: _primary, bold: true),
          if (label.isNotEmpty) const SizedBox(height: 10),
          Text(
            nama,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.textMain,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: -0.4,
            ),
          ),
          if (periode.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 15, color: _primary),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    periode,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.textMain,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(
    String text, {
    required Color bg,
    required Color fg,
    bool bold = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
    );
  }

  // ── Garis sobek horizontal ────────────────────────────────────────
  Widget _buildTearLine() {
    final Color cutoutColor = context.isDark ? context.pageBg : _bg;

    return SizedBox(
      height: 24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _PromoPerforationPainter(
                color: context.isDark
                    ? Colors.white.withValues(alpha: 0.28)
                    : const Color(0xffCAD5DF),
              ),
            ),
          ),
          Positioned(left: -14, child: _PromoNotch(color: cutoutColor)),
          Positioned(right: -14, child: _PromoNotch(color: cutoutColor)),
        ],
      ),
    );
  }

  // ── Isi kartu tiket ───────────────────────────────────────────────
  Widget _buildCardBody({
    required String deskripsi,
    required String selesai,
    required String namaKolam,
    required String syarat,
    required bool berakhirHariIni,
    required bool isExpanded,
    required String periode,
    required String label,
    required String nama,
    required int index,
    required Map<String, dynamic> p,
  }) {
    final String validity = [
      if (selesai.isNotEmpty) 'Berlaku s/d $selesai',
      if (namaKolam.isNotEmpty) 'di $namaKolam',
    ].join(' ');

    return Container(
      color: context.cardBg,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (deskripsi.trim().isNotEmpty) ...[
            Text(
              deskripsi,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.mutedText,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (validity.isNotEmpty)
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xffE8F4F9),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: _primary,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    validity,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.textMain,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          if (syarat.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.confirmation_number_outlined,
                  size: 17,
                  color: context.mutedText,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    syarat,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.mutedText,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (berakhirHariIni) ...[
            const SizedBox(height: 10),
            _chip(
              'Berakhir hari ini',
              bg: const Color(0xffFDECEC),
              fg: const Color(0xffB42318),
              bold: true,
            ),
          ],
          if (isExpanded) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: context.isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : const Color(0xffF0F7FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _detailRow(Icons.pool_outlined, 'Kolam', namaKolam),
                  if (label.isNotEmpty)
                    _detailRow(Icons.local_offer_outlined, 'Diskon', label),
                  if (periode.isNotEmpty)
                    _detailRow(Icons.event_outlined, 'Periode', periode),
                  if (syarat.isNotEmpty)
                    _detailRow(
                      Icons.confirmation_number_outlined,
                      'Syarat',
                      syarat,
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          _buildActions(index, isExpanded, nama, p),
        ],
      ),
    );
  }

  Widget _buildActions(
    int index,
    bool isExpanded,
    String nama,
    Map<String, dynamic> promo,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Semantics(
            button: true,
            label: isExpanded
                ? 'Tutup syarat dan ketentuan'
                : 'Lihat syarat dan ketentuan',
            child: TextButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() {
                  isExpanded ? _expanded.remove(index) : _expanded.add(index);
                });
              },
              style: TextButton.styleFrom(
                foregroundColor: _primary,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                minimumSize: const Size(48, 48),
                alignment: Alignment.centerLeft,
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                ),
              ),
              child: Text(isExpanded ? 'Tutup S&K' : 'Detail S&K'),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Semantics(
            button: true,
            label: 'Gunakan promo $nama',
            child: ElevatedButton(
              onPressed: () => _use(promo),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(48, 50),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shape: const StadiumBorder(),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text(
                'Gunakan Promo',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: _primary),
          const SizedBox(width: 8),
          SizedBox(
            width: 68,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                color: context.mutedText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: context.textMain,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoNotch extends StatelessWidget {
  const _PromoNotch({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: DecoratedBox(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

class _PromoPerforationPainter extends CustomPainter {
  const _PromoPerforationPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final double centerY = size.height / 2;
    for (double x = 14; x < size.width - 14; x += 8) {
      canvas.drawLine(Offset(x, centerY), Offset(x + 3.5, centerY), paint);
    }
  }

  @override
  bool shouldRepaint(_PromoPerforationPainter old) => old.color != color;
}
