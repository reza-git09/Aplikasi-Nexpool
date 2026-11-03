import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'pool_map_surface_stub.dart'
    if (dart.library.html) 'pool_map_surface_web.dart'
    as map_surface;

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
    this.height = 280.0,
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
    'z': '15',
    'output': 'embed',
  });

  Future<void> _loadMap() async {
    if (kIsWeb || !_controllerReady) return;
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
    if (!mounted) return;
    setState(() {
      _mapLoading = false;
      _mapError = 'Peta gagal dimuat. Periksa koneksi internet.';
    });
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
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
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

                // Petunjuk
                Positioned(
                  left: 10,
                  bottom: 10,
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
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.fullName ?? widget.poolName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
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
                          fontSize: 13,
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
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _launchMaps,
                    icon: const Icon(Icons.map_rounded, size: 19),
                    label: const Text(
                      'Buka di Google Maps',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff00B4D8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
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
}
