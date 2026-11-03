import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

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

class _PoolMapPreviewState extends State<PoolMapPreview> {
  // Samakan dengan applicationId di android/app/build.gradle.kts
  static const String _userAgentPackage = 'com.example.nexpool';

  final MapController _mapController = MapController();

  bool _isSatellite = false;
  double _zoom = 15;

  LatLng get _point => LatLng(widget.latitude, widget.longitude);

  @override
  void didUpdateWidget(covariant PoolMapPreview oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _mapController.move(_point, _zoom);
      });
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _changeZoom(double delta) {
    final current = _mapController.camera.zoom;
    final next = (current + delta).clamp(3.0, 19.0);

    if (next == current) return;

    HapticFeedback.selectionClick();
    _zoom = next;
    _mapController.move(_mapController.camera.center, next);
  }

  void _toggleMapType() {
    HapticFeedback.selectionClick();
    setState(() => _isSatellite = !_isSatellite);
  }

  void _recenter() {
    HapticFeedback.selectionClick();
    _mapController.move(_point, _zoom);
  }

  Future<void> _launchMaps() async {
    HapticFeedback.mediumImpact();

    if (widget.onOpenMaps != null) {
      widget.onOpenMaps!();
      return;
    }

    final url = widget.mapsUrl?.isNotEmpty == true
        ? widget.mapsUrl!
        : 'https://www.google.com/maps/search/?api=1'
            '&query=${widget.latitude},${widget.longitude}';

    try {
      final launched = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!launched) _showActionError('Tidak dapat membuka Google Maps.');
    } catch (error) {
      _showActionError('Tidak dapat membuka Google Maps: $error');
    }
  }

  Future<void> _launchDirections() async {
    HapticFeedback.mediumImpact();

    final uri = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': '${widget.latitude},${widget.longitude}',
    });

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) _showActionError('Tidak dapat membuka rute.');
    } catch (error) {
      _showActionError('Tidak dapat membuka rute: $error');
    }
  }

  void _copyCoordinates() {
    HapticFeedback.lightImpact();

    final text = '${widget.latitude}, ${widget.longitude}';
    Clipboard.setData(ClipboardData(text: text));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Koordinat disalin: $text'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _copyAddress() {
    HapticFeedback.lightImpact();

    Clipboard.setData(
      ClipboardData(text: widget.address ?? widget.poolName),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alamat disalin ke clipboard!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showActionError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          SizedBox(
            height: widget.height,
            width: double.infinity,
            child: Stack(
              children: [
                // ===== PETA (bisa digeser & di-zoom pakai jari) =====
                Positioned.fill(
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _point,
                      initialZoom: _zoom,
                      minZoom: 3,
                      maxZoom: 19,
                      interactionOptions: const InteractionOptions(
                        // geser, cubit-zoom, double-tap zoom; tanpa rotasi
                        flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                      ),
                      // Ketuk peta -> buka lokasi di Google Maps
                      onTap: (tapPosition, point) => _launchMaps(),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: _isSatellite
                            ? 'https://server.arcgisonline.com/ArcGIS/rest/'
                                'services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                            : 'https://server.arcgisonline.com/ArcGIS/rest/'
                                'services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
                        userAgentPackageName: _userAgentPackage,
                        maxNativeZoom: 19,
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _point,
                            width: 44,
                            height: 44,
                            alignment: Alignment.topCenter,
                            child: const Icon(
                              Icons.location_on_rounded,
                              size: 44,
                              color: Color(0xffEF476F),
                              shadows: [
                                Shadow(
                                  color: Colors.black38,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SimpleAttributionWidget(
                        source: Text(
                          _isSatellite
                              ? 'Esri World Imagery'
                              : 'Esri World Street Map',
                          style: const TextStyle(fontSize: 9),
                        ),
                        alignment: Alignment.bottomCenter,
                      ),
                    ],
                  ),
                ),

                // Koordinat (ketuk untuk menyalin)
                Positioned(
                  left: 10,
                  top: 10,
                  child: GestureDetector(
                    onTap: _copyCoordinates,
                    child: _mapBadge(
                      background: Colors.black.withOpacity(0.65),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.gps_fixed_rounded,
                            size: 11,
                            color: Color(0xff00E5FF),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.latitude.toStringAsFixed(4)}, '
                            '${widget.longitude.toStringAsFixed(4)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Tombol Peta/Satelit + Maps
                Positioned(
                  top: 10,
                  right: 10,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _mapAction(
                        icon: _isSatellite
                            ? Icons.map_outlined
                            : Icons.satellite_alt_rounded,
                        label: _isSatellite ? 'Peta' : 'Satelit',
                        onTap: _toggleMapType,
                      ),
                      const SizedBox(width: 6),
                      _mapAction(
                        icon: Icons.map_rounded,
                        label: 'Maps ↗',
                        background: const Color(0xff0077A8),
                        foreground: Colors.white,
                        onTap: _launchMaps,
                      ),
                    ],
                  ),
                ),

                // Zoom + / - dan kembali ke lokasi
                Positioned(
                  right: 10,
                  bottom: 24,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.94),
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
                        _zoomButton(Icons.add, () => _changeZoom(1)),
                        _divider(),
                        _zoomButton(Icons.remove, () => _changeZoom(-1)),
                        _divider(),
                        _zoomButton(Icons.my_location_rounded, _recenter),
                      ],
                    ),
                  ),
                ),

                // Petunjuk
                Positioned(
                  left: 10,
                  bottom: 24,
                  child: IgnorePointer(
                    child: _mapBadge(
                      background: Colors.white.withOpacity(0.92),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.touch_app_rounded,
                            size: 11,
                            color: Color(0xff00A4C6),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Geser peta • Ketuk untuk buka Maps',
                            style: TextStyle(
                              color: Color(0xff123C73),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
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

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.location_on_rounded,
                        size: 16,
                        color: Color(0xffEF476F),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${widget.address ?? 'Kabupaten Jember'}\n'
                        'Jawa Timur, Indonesia',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.copy_rounded,
                        size: 16,
                        color: Color(0xff00A4C6),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Salin Alamat',
                      onPressed: _copyAddress,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
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
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: OutlinedButton.icon(
                        onPressed: _launchDirections,
                        icon: const Icon(
                          Icons.directions_rounded,
                          size: 16,
                          color: Color(0xff0077A8),
                        ),
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
                            color: Color(0xff0077A8),
                            width: 1.5,
                          ),
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

  Widget _divider() => Container(
        width: 20,
        height: 1,
        color: Colors.grey.shade300,
      );

  Widget _mapBadge({
    required Color background,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _mapAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color background = Colors.white,
    Color foreground = const Color(0xff123C73),
  }) {
    return Material(
      color: background.withOpacity(0.94),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: foreground),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: foreground,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _zoomButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 34,
        height: 32,
        child: Icon(icon, size: 18, color: const Color(0xff123C73)),
      ),
    );
  }
}