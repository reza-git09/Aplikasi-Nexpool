import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'pool_map_surface_stub.dart'
    if (dart.library.html) 'pool_map_surface_web.dart' as map_surface;

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
  WebViewController? _mapController;
  late final Set<Factory<OneSequenceGestureRecognizer>> _gestureRecognizers = {
    Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
  };
  int _zoom = 15;
  bool _isSatellite = false;
  bool _mapLoading = true;
  String? _mapError;
  bool _controllerReady = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _mapController = WebViewController();
      _initializeMap();
    }
  }

  @override
  void didUpdateWidget(covariant PoolMapPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controllerReady &&
        (oldWidget.latitude != widget.latitude ||
            oldWidget.longitude != widget.longitude)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadMap();
      });
    }
  }

  Future<void> _initializeMap() async {
    try {
      final controller = _mapController!;
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setBackgroundColor(Colors.white);
      await controller.setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted && (!_mapLoading || _mapError != null)) {
              setState(() {
                _mapLoading = true;
                _mapError = null;
              });
            }
          },
          onPageFinished: (_) {
            if (mounted && _mapLoading) {
              setState(() => _mapLoading = false);
            }
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == false || !mounted) return;
            setState(() {
              _mapLoading = false;
              _mapError = 'Peta gagal dimuat. Periksa koneksi internet.';
            });
          },
        ),
      );
      _controllerReady = true;
      await _loadMap();
    } catch (error) {
      _showMapError(error);
    }
  }

  Uri get _mapUri => Uri.https('www.google.com', '/maps', {
    'q': '${widget.latitude},${widget.longitude}',
    'z': '$_zoom',
    'output': 'embed',
    't': _isSatellite ? 'k' : 'm',
  });

  Future<void> _loadMap() async {
    if (kIsWeb) return;
    if (!_controllerReady) return;
    if (mounted) {
      setState(() {
        _mapLoading = true;
        _mapError = null;
      });
    }
    try {
      await _mapController!.loadRequest(_mapUri);
    } catch (error) {
      _showMapError(error);
    }
  }

  void _showMapError(Object error) {
    debugPrint('Gagal memuat peta Google Maps: $error');
    if (mounted) {
      setState(() {
        _mapLoading = false;
        _mapError = 'Peta gagal dimuat. Periksa koneksi internet.';
      });
    }
  }

  void _changeZoom(int delta) {
    final nextZoom = (_zoom + delta).clamp(3, 20).toInt();
    if (nextZoom == _zoom) return;
    HapticFeedback.selectionClick();
    setState(() => _zoom = nextZoom);
    _loadMap();
  }

  void _toggleMapType() {
    HapticFeedback.selectionClick();
    setState(() => _isSatellite = !_isSatellite);
    _loadMap();
  }

  Future<void> _launchMaps() async {
    HapticFeedback.mediumImpact();
    if (widget.onOpenMaps != null) {
      widget.onOpenMaps!();
      return;
    }

    final url = widget.mapsUrl?.isNotEmpty == true
        ? widget.mapsUrl!
        : 'https://www.google.com/maps/search/?api=1&query=${widget.latitude},${widget.longitude}';
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (error) {
      _showActionError('Tidak dapat membuka Google Maps: $error');
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
    Clipboard.setData(ClipboardData(text: widget.address ?? widget.poolName));
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
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
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
                Positioned.fill(
                  child: kIsWeb
                      ? KeyedSubtree(
                          key: ValueKey(_mapUri.toString()),
                          child: map_surface.buildWebMapSurface(
                            url: _mapUri.toString(),
                            onLoad: () {
                              if (mounted && _mapLoading) {
                                setState(() => _mapLoading = false);
                              }
                            },
                          ),
                        )
                      : WebViewWidget(
                          controller: _mapController!,
                          gestureRecognizers: _gestureRecognizers,
                        ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
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
                            '${widget.latitude.toStringAsFixed(4)}, ${widget.longitude.toStringAsFixed(4)}',
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
                Positioned(
                  top: 10,
                  right: 10,
                  child: _mapAction(
                    icon: _isSatellite
                        ? Icons.map_outlined
                        : Icons.satellite_alt_rounded,
                    label: _isSatellite ? 'Peta' : 'Satelit',
                    onTap: _toggleMapType,
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
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
                        _zoomButton(Icons.add, 1),
                        Container(
                          width: 20,
                          height: 1,
                          color: Colors.grey.shade300,
                        ),
                        _zoomButton(Icons.remove, -1),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  bottom: 10,
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
                          'Geser & cubit untuk navigasi',
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
                if (_mapLoading)
                  const Positioned.fill(
                    child: IgnorePointer(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xff00A4C6),
                        ),
                      ),
                    ),
                  ),
                if (_mapError != null)
                  Positioned.fill(
                    child: ColoredBox(
                      color: Color(0xffF5F8FC),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.map_outlined,
                                color: Color(0xff0077A8),
                                size: 30,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _mapError!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xff123C73),
                                  fontSize: 12,
                                ),
                              ),
                              TextButton(
                                onPressed: _loadMap,
                                child: const Text('Coba lagi'),
                              ),
                            ],
                          ),
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
                SizedBox(
                  width: double.infinity,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapBadge({required Color background, required Widget child}) {
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

  Widget _zoomButton(IconData icon, int delta) {
    return InkWell(
      onTap: () => _changeZoom(delta),
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 34,
        height: 32,
        child: Icon(icon, size: 18, color: const Color(0xff123C73)),
      ),
    );
  }
}
