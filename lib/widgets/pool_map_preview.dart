import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../theme/app_theme.dart';
import 'pool_map_surface_stub.dart'
    if (dart.library.html) 'pool_map_surface_web.dart'
    as map_surface;

// KEY PETA CARTO (opsional, gratis, tanpa akun): https://carto.com/basemaps/apikey
// Kosong  -> peta HP memakai Esri World Street Map (tanpa key).
// Terisi -> peta HP memakai CARTO Voyager (tampilan lebih mirip Google Maps).
const String _cartoKey = '';

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

  // Peta di HP memakai Leaflet (bisa digeser 1 jari & dicubit), karena peta
  // embed Google di dalam iframe sulit digeser di HP.
  // Peta di web (laptop) tetap memakai embed Google lewat iframe.
  String get _mapHtml {
    final name = jsonEncode(widget.fullName ?? widget.poolName)
        .replaceAll('<', r'\u003c');
    return _leafletTemplate
        .replaceAll('__BASE_URL__', jsonEncode(_tileUrl))
        .replaceAll('__BASE_ATTR__', jsonEncode(_tileAttribution))
        .replaceAll('__LAT__', widget.latitude.toString())
        .replaceAll('__LNG__', widget.longitude.toString())
        .replaceAll('__ZOOM__', _zoom.toString())
        .replaceAll('__SAT__', _isSatellite ? 'true' : 'false')
        .replaceAll('__NAME__', name);
  }

  String get _tileUrl => _cartoKey.isEmpty
      ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}'
      : 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png?key=${Uri.encodeQueryComponent(_cartoKey)}';

  String get _tileAttribution => _cartoKey.isEmpty
      ? 'Tiles © Esri'
      : '© OpenStreetMap contributors © CARTO';

  Future<void> _runMapJs(String js) async {
    if (!_controllerReady) return;
    try {
      await _mapController!.runJavaScript(js);
    } catch (error) {
      debugPrint('Gagal menjalankan JS peta: $error');
    }
  }

  // Posisi tombol di atas peta: di HP dinaikkan sedikit supaya tidak
  // menutupi tulisan atribusi peta di bagian bawah.
  double get _overlayBottom => kIsWeb ? 10.0 : 26.0;

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
      await _mapController!.loadHtmlString(_mapHtml);
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
    if (!kIsWeb) {
      HapticFeedback.selectionClick();
      _runMapJs('zoomMap($delta);');
      return;
    }
    final nextZoom = (_zoom + delta).clamp(3, 20).toInt();
    if (nextZoom == _zoom) return;
    HapticFeedback.selectionClick();
    setState(() => _zoom = nextZoom);
    _loadMap();
  }

  void _toggleMapType() {
    HapticFeedback.selectionClick();
    setState(() => _isSatellite = !_isSatellite);
    if (kIsWeb) return; // web: widget dibangun ulang dengan URL baru
    _runMapJs('setSatellite($_isSatellite);');
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
        color: context.cardBg,
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
                Positioned(
                  right: 10,
                  bottom: _overlayBottom,
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
                  bottom: _overlayBottom,
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
                      color: context.pageBg,
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
                                style: TextStyle(
                                  color: context.textMain,
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
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: context.textMain,
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
                          color: context.mutedText,
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

// HTML peta Leaflet untuk WebView di HP. Placeholder __XXX__ diisi di _mapHtml.
const String _leafletTemplate = r'''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css">
<style>
  html, body { margin: 0; padding: 0; width: 100%; height: 100%; background: #e8eef2; overflow: hidden; }
  #map { position: absolute; top: 0; right: 0; bottom: 0; left: 0; background: #e8eef2; }
  .leaflet-container { font-family: Roboto, Arial, sans-serif; }
  .leaflet-control-attribution { font-size: 9px; background: rgba(255,255,255,0.85); color: #444; padding: 1px 6px; }
  .pin { filter: drop-shadow(0 2px 2px rgba(0,0,0,0.35)); }
  #msg { display: none; position: absolute; top: 0; right: 0; bottom: 0; left: 0; z-index: 1000; background: #f5f8fc; color: #123c73; font: 13px Roboto, Arial, sans-serif; align-items: center; justify-content: center; text-align: center; padding: 16px; box-sizing: border-box; }
</style>
</head>
<body>
<div id="map"></div>
<div id="msg">Peta gagal dimuat. Periksa koneksi internet.</div>
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script>
  var map = null, base = null, sat = null;

  function setSatellite(on) {
    if (!map || !base || !sat) return;
    if (on) {
      if (map.hasLayer(base)) map.removeLayer(base);
      if (!map.hasLayer(sat)) sat.addTo(map);
    } else {
      if (map.hasLayer(sat)) map.removeLayer(sat);
      if (!map.hasLayer(base)) base.addTo(map);
    }
  }

  function zoomMap(delta) {
    if (!map) return;
    if (delta > 0) map.zoomIn(); else map.zoomOut();
  }

  (function () {
    if (typeof L === 'undefined') {
      document.getElementById('msg').style.display = 'flex';
      return;
    }
    var lat = __LAT__, lng = __LNG__;
    map = L.map('map', { zoomControl: false, minZoom: 3, maxZoom: 19 }).setView([lat, lng], __ZOOM__);
    map.attributionControl.setPrefix(false);

    base = L.tileLayer(__BASE_URL__, { maxZoom: 19, attribution: __BASE_ATTR__ });
    sat = L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
      maxZoom: 19, maxNativeZoom: 18,
      attribution: 'Tiles &copy; Esri'
    });

    var pin = '<svg class="pin" xmlns="http://www.w3.org/2000/svg" width="30" height="42" viewBox="0 0 30 42">' +
      '<path d="M15 0C6.7 0 0 6.7 0 15c0 11.2 15 27 15 27s15-15.8 15-27C30 6.7 23.3 0 15 0z" fill="#E53935"/>' +
      '<circle cx="15" cy="15" r="6" fill="#8E1B17"/></svg>';
    var icon = L.divIcon({ className: '', html: pin, iconSize: [30, 42], iconAnchor: [15, 42], popupAnchor: [0, -38] });
    var marker = L.marker([lat, lng], { icon: icon }).addTo(map);

    var label = document.createElement('b');
    label.textContent = __NAME__;
    marker.bindPopup(label);

    var loaded = 0, failed = 0;
    [base, sat].forEach(function (layer) {
      layer.on('tileload', function () { loaded++; });
      layer.on('tileerror', function () { failed++; });
    });
    setTimeout(function () {
      if (loaded === 0 && failed > 0) document.getElementById('msg').style.display = 'flex';
    }, 6000);

    setSatellite(__SAT__);
  })();
</script>
</body>
</html>
''';
