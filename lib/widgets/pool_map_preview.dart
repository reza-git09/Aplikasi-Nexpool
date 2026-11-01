import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Widget preview peta interaktif untuk destinasi kolam renang.
/// Menampilkan map tile Esri World Street Map & OpenStreetMap dengan marker pin beranimasi,
/// kontrol zoom, badge koordinat GPS, serta integrasi tombol buka langsung ke Google Maps.
class PoolMapPreview extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String poolName;
  final String? fullName;
  final String? address;
  final String? mapsUrl;
  final String? rating;
  final double height;
  final VoidCallback? onOpenMaps;

  const PoolMapPreview({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.poolName,
    this.fullName,
    this.address,
    this.mapsUrl,
    this.rating,
    this.height = 190.0,
    this.onOpenMaps,
  });

  @override
  State<PoolMapPreview> createState() => _PoolMapPreviewState();
}

class _PoolMapPreviewState extends State<PoolMapPreview>
    with SingleTickerProviderStateMixin {
  late int _zoom;
  bool _isSatellite = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _zoom = 15;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleMapType() {
    HapticFeedback.selectionClick();
    setState(() {
      _isSatellite = !_isSatellite;
    });
  }

  void _zoomIn() {
    HapticFeedback.selectionClick();
    if (_zoom < 17) {
      setState(() => _zoom++);
    }
  }

  void _zoomOut() {
    HapticFeedback.selectionClick();
    if (_zoom > 13) {
      setState(() => _zoom--);
    }
  }

  Future<void> _launchMaps() async {
    HapticFeedback.mediumImpact();
    if (widget.onOpenMaps != null) {
      widget.onOpenMaps!();
      return;
    }

    String url = widget.mapsUrl ?? '';
    if (url.isEmpty) {
      url =
          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(widget.fullName ?? widget.poolName)}+Jember';
    }

    final Uri uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      try {
        final Uri fallback = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=${widget.latitude},${widget.longitude}',
        );
        await launchUrl(fallback, mode: LaunchMode.externalApplication);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak dapat membuka Google Maps: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _launchDirections() async {
    HapticFeedback.mediumImpact();
    final Uri uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${widget.latitude},${widget.longitude}&destination_place_id=${Uri.encodeComponent(widget.poolName)}',
    );
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      _launchMaps();
    }
  }

  void _copyCoordinates() {
    HapticFeedback.lightImpact();
    final text = '${widget.latitude}, ${widget.longitude}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📍 Koordinat disalin: $text'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _copyAddress() {
    HapticFeedback.lightImpact();
    final text = widget.address ?? widget.poolName;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📋 Alamat disalin ke clipboard!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildTileImage(int tileX, int tileY, double left, double top) {
    if (_isSatellite) {
      final satelliteUrl =
          'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/$_zoom/$tileY/$tileX';
      return Positioned(
        left: left,
        top: top,
        width: 256,
        height: 256,
        child: Image.network(
          satelliteUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      );
    }

    // 1. Esri World Street Map (Jernih, jalan & bangunan lengkap di Jember, 0 watermark)
    final esriStreetUrl =
        'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/$_zoom/$tileY/$tileX';

    // 2. OpenStreetMap Standard (OSM)
    final osmUrl = 'https://tile.openstreetmap.org/$_zoom/$tileX/$tileY.png';

    // 3. OSM Humanitarian (Warna cerah, jalan jelas)
    final subdomains = ['a', 'b', 'c'];
    final sub = subdomains[(tileX.abs() + tileY.abs()) % subdomains.length];
    final hotUrl =
        'https://$sub.tile.openstreetmap.fr/hot/$_zoom/$tileX/$tileY.png';

    return Positioned(
      left: left,
      top: top,
      width: 256,
      height: 256,
      child: Image.network(
        esriStreetUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fallback ke OpenStreetMap
          return Image.network(
            osmUrl,
            headers: const {
              'User-Agent':
                  'NexpoolApp/1.0 (id.nexpool.app; contact@nexpool.id)',
            },
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              // Fallback ke OSM Humanitarian
              return Image.network(
                hotUrl,
                headers: const {
                  'User-Agent': 'NexpoolApp/1.0 (id.nexpool.app)',
                },
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double n = math.pow(2.0, _zoom).toDouble();
    final double xExact = (widget.longitude + 180.0) / 360.0 * n;
    final double latRad = widget.latitude * math.pi / 180.0;
    final double yExact =
        (1.0 - (math.log(math.tan(latRad) + 1.0 / math.cos(latRad)) / math.pi)) /
            2.0 *
            n;

    final int xCenter = xExact.floor();
    final int yCenter = yExact.floor();
    final double subX = xExact - xCenter;
    final double subY = yExact - yCenter;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff123C73).withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -----------------------------------------------------------
          // AREA MAP PREVIEW DENGAN TILE & MARKER PIN
          // -----------------------------------------------------------
          GestureDetector(
            onTap: _launchMaps,
            child: SizedBox(
              height: widget.height,
              width: double.infinity,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  // 1. Fallback Vector Map Canvas (jika offline/loading)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _StylizedMapPainter(
                        poolName: widget.poolName,
                      ),
                    ),
                  ),

                  // 2. Slippy Map Tiles (Peta Jalan / Satelit)
                  Positioned.fill(
                    child: LayoutBuilder(
                      builder: (ctx, constraints) {
                        final double w = constraints.maxWidth;
                        final double h = constraints.maxHeight;

                        final List<Widget> tileWidgets = [];
                        // Render grid 3x3 di sekitar titik tengah
                        for (int dx = -1; dx <= 1; dx++) {
                          for (int dy = -1; dy <= 1; dy++) {
                            final int tileX = xCenter + dx;
                            final int tileY = yCenter + dy;
                            final double left =
                                (w / 2) - (subX * 256.0) + (dx * 256.0);
                            final double top =
                                (h / 2) - (subY * 256.0) + (dy * 256.0);

                            tileWidgets.add(
                              _buildTileImage(tileX, tileY, left, top),
                            );
                          }
                        }

                        return Stack(
                          clipBehavior: Clip.hardEdge,
                          children: tileWidgets,
                        );
                      },
                    ),
                  ),

                  // 3. Subtle vignette overlay
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.12),
                              Colors.transparent,
                              Colors.black.withOpacity(0.20),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 4. Center Pulsing Marker Pin
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Label Bubble di atas Pin
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.18),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🏊', style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 160),
                                child: Text(
                                  widget.poolName,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xff123C73),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (widget.rating != null) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.star_rounded,
                                    size: 13, color: Color(0xffFFB703)),
                                Text(
                                  widget.rating!,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xff172B4D),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Pin Icon dengan Efek Radar Pulse
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Animasi Ripple Pulse
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Container(
                                  width: 44 * _pulseAnimation.value,
                                  height: 44 * _pulseAnimation.value,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xffEF476F).withOpacity(
                                      (1.0 - _pulseAnimation.value) * 0.45,
                                    ),
                                  ),
                                );
                              },
                            ),

                            // Main Pin Icon
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [Color(0xffFF5E7E), Color(0xffEF476F)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xffEF476F)
                                        .withOpacity(0.45),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.location_on_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 5. Badge Koordinat GPS (Kiri Atas)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: GestureDetector(
                      onTap: _copyCoordinates,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.gps_fixed_rounded,
                                size: 11, color: Color(0xff00E5FF)),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.latitude.toStringAsFixed(4)}, ${widget.longitude.toStringAsFixed(4)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 6. Tombol Toggle Tipe Peta & Buka di Maps (Kanan Atas)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tombol Toggle Satelit / Peta Jalan
                        GestureDetector(
                          onTap: _toggleMapType,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 5),
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.92),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isSatellite
                                      ? Icons.map_outlined
                                      : Icons.satellite_alt_rounded,
                                  size: 12,
                                  color: const Color(0xff123C73),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _isSatellite ? 'Peta' : 'Satelit',
                                  style: const TextStyle(
                                    color: Color(0xff123C73),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Tombol Maps ↗
                        GestureDetector(
                          onTap: _launchMaps,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xff0077A8),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.18),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.map_rounded,
                                    size: 12, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  'Maps ↗',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 7. Kontrol Zoom (Kanan Bawah)
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: _zoomIn,
                            child: Container(
                              width: 30,
                              height: 30,
                              alignment: Alignment.center,
                              child: const Icon(Icons.add,
                                  size: 17, color: Color(0xff123C73)),
                            ),
                          ),
                          Container(
                            width: 20,
                            height: 1,
                            color: Colors.grey.shade300,
                          ),
                          GestureDetector(
                            onTap: _zoomOut,
                            child: Container(
                              width: 30,
                              height: 30,
                              alignment: Alignment.center,
                              child: const Icon(Icons.remove,
                                  size: 17, color: Color(0xff123C73)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 8. Hint navigasi (Kiri Bawah)
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.90),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isSatellite
                                ? Icons.satellite_alt_rounded
                                : Icons.touch_app_rounded,
                            size: 11,
                            color: const Color(0xff00A4C6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isSatellite
                                ? 'Citra Satelit'
                                : 'Ketuk peta untuk navigasi',
                            style: const TextStyle(
                              color: Color(0xff123C73),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // -----------------------------------------------------------
          // INFORMASI ALAMAT & TOMBOL AKSI LENGKAP
          // -----------------------------------------------------------
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama Lengkap Destinasi
                Text(
                  widget.fullName ?? widget.poolName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xff172B4D),
                  ),
                ),
                const SizedBox(height: 6),

                // Alamat & Ikon Lokasi
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.location_on_rounded,
                          size: 16, color: Color(0xffEF476F)),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${widget.address ?? 'Kabupaten Jember'}\nJawa Timur, Indonesia',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded,
                          size: 16, color: Color(0xff00A4C6)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Salin Alamat',
                      onPressed: _copyAddress,
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Baris Tombol Aksi
                Row(
                  children: [
                    // Tombol Utama: Buka Google Maps
                    Expanded(
                      flex: 6,
                      child: ElevatedButton.icon(
                        onPressed: _launchMaps,
                        icon: const Icon(Icons.map_rounded, size: 16),
                        label: const Text(
                          'Buka di Google Maps',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff00B4D8),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Tombol Petunjuk Arah Langsung (Rute)
                    Expanded(
                      flex: 4,
                      child: OutlinedButton.icon(
                        onPressed: _launchDirections,
                        icon: const Icon(Icons.directions_rounded,
                            size: 16, color: Color(0xff0077A8)),
                        label: const Text(
                          'Rute',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xff0077A8),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Color(0xff0077A8), width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
    );
  }
}

/// CustomPainter untuk rendering peta visual fallback yang estetik
/// jika koneksi internet sedang lambat atau peta tile sedang dimuat.
class _StylizedMapPainter extends CustomPainter {
  final String poolName;

  _StylizedMapPainter({required this.poolName});

  @override
  void paint(Canvas canvas, Size size) {
    // Background dasar peta warna hijau/tanah lembut
    final bgPaint = Paint()..color = const Color(0xffEAF2EC);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Grid blok pemukiman
    final blockPaint = Paint()
      ..color = const Color(0xffE0EBDC)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(15, 15, size.width * 0.35, size.height * 0.40),
        const Radius.circular(8),
      ),
      blockPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            size.width * 0.55, 20, size.width * 0.38, size.height * 0.35),
        const Radius.circular(8),
      ),
      blockPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(20, size.height * 0.60, size.width * 0.40,
            size.height * 0.32),
        const Radius.circular(8),
      ),
      blockPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.50, size.height * 0.55,
            size.width * 0.42, size.height * 0.38),
        const Radius.circular(8),
      ),
      blockPaint,
    );

    // Sungai / Waterway (biru muda)
    final riverPaint = Paint()
      ..color = const Color(0xffBBE2F2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final riverPath = Path();
    riverPath.moveTo(-20, size.height * 0.25);
    riverPath.cubicTo(
      size.width * 0.3,
      size.height * 0.1,
      size.width * 0.4,
      size.height * 0.7,
      size.width + 20,
      size.height * 0.45,
    );
    canvas.drawPath(riverPath, riverPaint);

    // Area Kolam Renang (Danau buatan biru muda di tengah)
    final poolWaterPaint = Paint()
      ..color = const Color(0xff91D7EB)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.50, size.height * 0.50),
      32,
      poolWaterPaint,
    );

    // Jalan utama (kuning/putih)
    final mainRoadBorder = Paint()
      ..color = const Color(0xffD8D5CC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.square;

    final mainRoadPaint = Paint()
      ..color = const Color(0xffFFF7E6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.square;

    final roadPath = Path();
    roadPath.moveTo(0, size.height * 0.72);
    roadPath.lineTo(size.width * 0.48, size.height * 0.72);
    roadPath.lineTo(size.width * 0.48, 0);

    canvas.drawPath(roadPath, mainRoadBorder);
    canvas.drawPath(roadPath, mainRoadPaint);

    // Jalan arteri sekunder
    final secRoadPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final secPath = Path();
    secPath.moveTo(size.width * 0.48, size.height * 0.50);
    secPath.lineTo(size.width, size.height * 0.50);
    secPath.moveTo(size.width * 0.25, 0);
    secPath.lineTo(size.width * 0.25, size.height);

    canvas.drawPath(secPath, secRoadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

