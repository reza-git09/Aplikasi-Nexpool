import 'dart:math' as math;
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Halaman loading beranimasi yang tampil sebelum Home.
///
/// Tema "kolam terisi air": air naik dari bawah, logo mengapung dengan riak
/// halus, dan bar loading besar terisi dari kosong sampai penuh seiring persen.
///
/// Cara pakai (di main.dart):
///
///   home: SplashPage(
///     preload: ApiService.init,
///     nextBuilder: (_) => const MainShell(),
///   ),
class SplashPage extends StatefulWidget {
  const SplashPage({
    super.key,
    required this.nextBuilder,
    this.preload,
    this.minDuration = const Duration(milliseconds: 2800),
    this.maxPreloadWait = const Duration(seconds: 6),
  });

  /// Halaman tujuan setelah loading selesai (mis. Home atau Login).
  final WidgetBuilder nextBuilder;

  /// Pekerjaan awal yang dijalankan selama loading (opsional).
  /// Kalau gagal atau terlalu lama, aplikasi tetap lanjut.
  final Future<void> Function()? preload;

  /// Lama minimal splash tampil, supaya animasinya sempat terlihat.
  /// Air, bar, dan persen penuh tepat di akhir durasi ini.
  final Duration minDuration;

  /// Batas tunggu untuk [preload] supaya loading tidak menggantung.
  final Duration maxPreloadWait;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  static const Color _navy = Color(0xFF173F7A);
  static const Color _sky = Color(0xFF3688E8);

  late final AnimationController _intro; // logo & teks muncul
  late final AnimationController _fillCtrl; // air naik + bar + persen
  late final AnimationController _wave; // gelombang bergerak
  late final AnimationController _bubbles; // gelembung naik
  late final AnimationController _ripple; // riak di sekitar logo
  late final AnimationController _float; // logo mengapung
  late final AnimationController _shimmer; // kilau di tulisan NEXPOOL

  late final Animation<double> _fill;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  static const List<String> _statuses = [
    'Menyiapkan kolam renang...',
    'Mengisi air...',
    'Hampir siap...',
  ];

  @override
  void initState() {
    super.initState();

    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    _fillCtrl = AnimationController(vsync: this, duration: widget.minDuration)
      ..forward();

    _wave = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat();

    _bubbles = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _ripple = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();

    // Satu animasi ini menggerakkan air, bar, dan persen sekaligus,
    // jadi ketiganya selalu sinkron.
    _fill = CurvedAnimation(parent: _fillCtrl, curve: Curves.easeInOutCubic);

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _logoFade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );

    _textFade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.45, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _start();
  }

  Future<void> _start() async {
    final Future<void> minWait = Future<void>.delayed(widget.minDuration);

    try {
      final Future<void>? work = widget.preload?.call();
      await Future.wait<void>([
        minWait,
        if (work != null) work.timeout(widget.maxPreloadWait),
      ]);
    } catch (e) {
      // Persiapan gagal / terlalu lama: tetap lanjut ke aplikasi.
      debugPrint('Splash preload dilewati: $e');
      await minWait;
    }

    if (!mounted) return;

    // Jeda singkat supaya 100% sempat terlihat.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) =>
            widget.nextBuilder(context),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final CurvedAnimation curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 1.03, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _intro.dispose();
    _fillCtrl.dispose();
    _wave.dispose();
    _bubbles.dispose();
    _ripple.dispose();
    _float.dispose();
    _shimmer.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------------
  // LOGO
  // ----------------------------------------------------------------
  Widget _buildLogo() {
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Glow lembut di belakang logo
          Positioned(
            left: -50,
            top: -50,
            width: 250,
            height: 250,
            child: AnimatedBuilder(
              animation: _float,
              builder: (context, _) {
                final double a = 0.18 + 0.10 * _float.value;
                return DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF7CC0FF).withValues(alpha: a),
                        const Color(0xFF7CC0FF).withValues(alpha: 0),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Riak air tipis yang melebar dari logo
          Positioned(
            left: -85,
            top: -85,
            width: 320,
            height: 320,
            child: CustomPaint(painter: _RipplePainter(_ripple)),
          ),

          // Ring gradasi + lingkaran putih
          Container(
            width: 150,
            height: 150,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFFFFF), Color(0xFF8FC4FF), Color(0xFF3688E8)],
              ),
              boxShadow: [
                BoxShadow(
                  color: _sky.withValues(alpha: 0.40),
                  blurRadius: 34,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.white, Color(0xFFEAF3FF)],
                ),
              ),
              child: Image.asset(
                'assets/images/LOGO_NEXPOOL.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.pool_rounded, size: 70, color: _navy),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------
  // JUDUL
  // ----------------------------------------------------------------
  Widget _buildTitle() {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (context, child) {
        final double c = -0.3 + 1.6 * _shimmer.value;
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (Rect bounds) => LinearGradient(
            colors: const [Color(0xFFB9D6FF), Colors.white, Color(0xFFB9D6FF)],
            stops: [_unit(c - 0.25), _unit(c), _unit(c + 0.25)],
          ).createShader(bounds),
          child: child,
        );
      },
      child: const Text(
        'NEXPOOL',
        style: TextStyle(
          color: Colors.white,
          fontSize: 34,
          letterSpacing: 6,
          fontWeight: FontWeight.w800,
          shadows: [
            Shadow(color: Color(0x55000000), blurRadius: 12, offset: Offset(0, 3)),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  // BAR LOADING BESAR (kotak panjang, kosong -> penuh) + PERSEN DI DALAMNYA
  // ----------------------------------------------------------------
  Widget _buildProgress(BuildContext context) {
    final double barW = math.min(MediaQuery.of(context).size.width * 0.55, 220);

    return AnimatedBuilder(
      animation: _fill,
      builder: (context, _) {
        final double v = _fill.value.clamp(0.0, 1.0);
        final int idx = math.min(
          (v * _statuses.length).floor(),
          _statuses.length - 1,
        );

        return Column(
          children: [
            SizedBox(
              width: barW,
              height: 20,
              child: Stack(
                children: [
                  // Kotak kosong (track kaca)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white.withValues(alpha: 0.14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.60),
                        width: 1.3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.20),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),

                  // Isi yang terisi dari kiri sampai penuh
                  Padding(
                    padding: const EdgeInsets.all(3),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: v,
                          heightFactor: 1,
                          child: _buildBarFill(),
                        ),
                      ),
                    ),
                  ),

                  // Persen di tengah bar
                  Center(
                    child: Text(
                      '${(v * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        fontFeatures: [FontFeature.tabularFigures()],
                        shadows: [
                          Shadow(
                            color: Color(0x88000000),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Teks status
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.4),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: Text(
                _statuses[idx],
                key: ValueKey<int>(idx),
                style: const TextStyle(
                  color: Color(0xE6FFFFFF),
                  fontSize: 12,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Isi bar: gradasi biru + kilap atas + kilau yang menyapu.
  Widget _buildBarFill() {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (context, _) {
        final double c = -0.3 + 1.6 * _shimmer.value;
        return Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2F7FE0), Color(0xFF6FB8FF)],
                ),
              ),
            ),
            // Kilap setengah atas
            Align(
              alignment: Alignment.topCenter,
              child: FractionallySizedBox(
                heightFactor: 0.5,
                widthFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.35),
                        Colors.white.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Kilau menyapu
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0),
                    Colors.white.withValues(alpha: 0.40),
                    Colors.white.withValues(alpha: 0),
                  ],
                  stops: [_unit(c - 0.2), _unit(c), _unit(c + 0.2)],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ----------------------------------------------------------------
  // BUILD
  // ----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF081A3D),
                Color(0xFF133D80),
                Color(0xFF2A74D0),
                Color(0xFF3688E8),
              ],
              stops: [0.0, 0.4, 0.8, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Sinar cahaya tipis + sedikit kilau
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _LightPainter(wave: _wave, sparkle: _shimmer),
                  ),
                ),
              ),

              // Air + gelombang + gelembung (naik dari bawah)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _WaterPainter(
                      wave: _wave,
                      fill: _fill,
                      bubbles: _bubbles,
                    ),
                  ),
                ),
              ),

              // Logo, judul, dan progress
              Align(
                alignment: const Alignment(0, -0.22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: AnimatedBuilder(
                          animation: _float,
                          child: _buildLogo(),
                          builder: (context, child) {
                            final double dy =
                                -6 * Curves.easeInOut.transform(_float.value);
                            return Transform.translate(
                              offset: Offset(0, dy),
                              child: child,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    FadeTransition(
                      opacity: _textFade,
                      child: SlideTransition(
                        position: _textSlide,
                        child: Column(
                          children: [
                            _buildTitle(),
                            const SizedBox(height: 8),
                            const Text(
                              'SMART TOURISM SYSTEM',
                              style: TextStyle(
                                color: Color(0xB3FFFFFF),
                                fontSize: 10.5,
                                letterSpacing: 2.6,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 34),
                            _buildProgress(context),
                          ],
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
    );
  }
}

double _unit(double v) => v < 0.0 ? 0.0 : (v > 1.0 ? 1.0 : v);

// ================================================================
// RIAK AIR DI SEKITAR LOGO (2 cincin, tipis)
// ================================================================
class _RipplePainter extends CustomPainter {
  _RipplePainter(this.t) : super(repaint: t);

  final Animation<double> t;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);

    for (int i = 0; i < 2; i++) {
      final double p = (t.value + i / 2) % 1.0;
      final double eased = Curves.easeOutCubic.transform(p);
      final double radius = 76 + eased * 74;
      final double alpha = (1 - p) * (1 - p) * 0.24;

      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8 * (1 - p * 0.6)
          ..color = Colors.white.withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RipplePainter oldDelegate) => false;
}

// ================================================================
// SINAR CAHAYA TIPIS + KILAU SEDIKIT
// ================================================================
class _Sparkle {
  const _Sparkle({
    required this.x,
    required this.y,
    required this.radius,
    required this.phase,
  });

  final double x; // 0..1
  final double y; // 0..1 (bagian atas layar)
  final double radius;
  final double phase;
}

class _LightPainter extends CustomPainter {
  _LightPainter({required this.wave, required this.sparkle})
    : super(repaint: Listenable.merge([wave, sparkle]));

  final Animation<double> wave;
  final Animation<double> sparkle;

  static final List<_Sparkle> _sparkles = List<_Sparkle>.generate(8, (i) {
    final math.Random r = math.Random(i * 53 + 7);
    return _Sparkle(
      x: r.nextDouble(),
      y: r.nextDouble() * 0.45,
      radius: 0.9 + r.nextDouble() * 1.2,
      phase: r.nextDouble(),
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double phase = wave.value * 2 * math.pi;

    // 3 sinar cahaya lembut
    const int rays = 3;
    for (int i = 0; i < rays; i++) {
      final double baseX = w * (0.12 + 0.34 * i);
      final double sway = math.sin(phase + i * 1.6) * 14;
      final double topW = 28.0 + (i % 2) * 14;
      final double botW = topW + 60;
      final double slant = 80 + math.cos(phase + i) * 10;

      final Path ray = Path()
        ..moveTo(baseX + sway - topW / 2, 0)
        ..lineTo(baseX + sway + topW / 2, 0)
        ..lineTo(baseX + sway + slant + botW / 2, h * 0.7)
        ..lineTo(baseX + sway + slant - botW / 2, h * 0.7)
        ..close();

      final double pulse = 0.7 + 0.3 * math.sin(phase + i * 0.9);
      canvas.drawPath(
        ray,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.065 * pulse),
              Colors.white.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromLTWH(0, 0, w, h * 0.7)),
      );
    }

    // Kilau berkelip (sedikit saja)
    for (final _Sparkle s in _sparkles) {
      final double t = (sparkle.value + s.phase) % 1.0;
      final double twinkle = math.sin(t * math.pi);
      final double a = twinkle * twinkle * 0.5;
      final Offset c = Offset(s.x * w, s.y * h);

      canvas.drawCircle(
        c,
        s.radius,
        Paint()..color = Colors.white.withValues(alpha: a),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LightPainter oldDelegate) => false;
}

// ================================================================
// AIR, GELOMBANG, DAN GELEMBUNG
// ================================================================
class _Bubble {
  const _Bubble({
    required this.x,
    required this.radius,
    required this.speed,
    required this.phase,
    required this.sway,
  });

  final double x; // posisi horizontal 0..1
  final double radius;
  final int speed; // 1 atau 2 kali putaran (supaya loop mulus)
  final double phase;
  final double sway; // goyangan kiri-kanan (px)
}

class _WaterPainter extends CustomPainter {
  _WaterPainter({
    required this.wave,
    required this.fill,
    required this.bubbles,
  }) : super(repaint: Listenable.merge([wave, fill, bubbles]));

  final Animation<double> wave;
  final Animation<double> fill;
  final Animation<double> bubbles;

  static final List<_Bubble> _bubbleList = List<_Bubble>.generate(9, (i) {
    final math.Random r = math.Random(i * 97 + 11);
    return _Bubble(
      x: r.nextDouble(),
      radius: 3 + r.nextDouble() * 5.0,
      speed: 1 + r.nextInt(2),
      phase: r.nextDouble(),
      sway: 6 + r.nextDouble() * 10,
    );
  });

  /// Garis permukaan gelombang (hanya sisi atas, tanpa isian).
  Path _waveLine(
    Size size,
    double baseY,
    double amplitude,
    double cycles,
    double shift,
  ) {
    final Path path = Path();
    final int steps = (size.width / 4).ceil();

    for (int i = 0; i <= steps; i++) {
      final double x = size.width * i / steps;
      final double y =
          baseY +
          math.sin((x / size.width) * 2 * math.pi * cycles + shift) * amplitude;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    return path;
  }

  /// Gelombang tertutup sampai dasar layar.
  Path _wavePath(
    Size size,
    double baseY,
    double amplitude,
    double cycles,
    double shift,
  ) {
    return _waveLine(size, baseY, amplitude, cycles, shift)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Permukaan air naik dari dasar layar ke sekitar 60% tinggi layar.
    final double waterY = h * (0.985 - 0.385 * fill.value);
    final double phase = wave.value * 2 * math.pi;

    // Dua lapisan belakang (transparan)
    canvas.drawPath(
      _wavePath(size, waterY - 16, 12, 1.2, phase),
      Paint()..color = Colors.white.withValues(alpha: 0.09),
    );
    canvas.drawPath(
      _wavePath(size, waterY - 8, 10, 1.7, -phase + 1.0),
      Paint()..color = const Color(0xFF8FC4FF).withValues(alpha: 0.14),
    );

    // Gelembung naik di dalam air (sedikit saja)
    final double depth = h - waterY;
    if (depth > 40) {
      for (final _Bubble b in _bubbleList) {
        final double p = (bubbles.value * b.speed + b.phase) % 1.0;
        final double y = h - p * (depth - 10);
        final double x =
            b.x * w + math.sin(p * 2 * math.pi * 2 + b.phase * 6) * b.sway;

        final double fadeIn = p < 0.1 ? p / 0.1 : 1.0;
        final double alpha = 0.40 * fadeIn * (1 - p * p);
        final Offset c = Offset(x, y);

        canvas.drawCircle(
          c,
          b.radius,
          Paint()..color = Colors.white.withValues(alpha: alpha * 0.25),
        );
        canvas.drawCircle(
          c,
          b.radius,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0
            ..color = Colors.white.withValues(alpha: alpha),
        );
        canvas.drawCircle(
          c + Offset(-b.radius * 0.35, -b.radius * 0.35),
          b.radius * 0.24,
          Paint()..color = Colors.white.withValues(alpha: alpha * 1.2),
        );
      }
    }

    // Lapisan depan (gradasi biru, paling terlihat)
    const double frontAmp = 8;
    final double frontShift = phase * 2 + 2.2;
    canvas.drawPath(
      _wavePath(size, waterY, frontAmp, 1.4, frontShift),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x995BB0FF), Color(0xD92A68B8), Color(0xF2123A78)],
          stops: [0.0, 0.45, 1.0],
        ).createShader(Rect.fromLTRB(0, waterY - 20, w, h)),
    );

    // Garis buih tipis di puncak gelombang depan
    canvas.drawPath(
      _waveLine(size, waterY, frontAmp, 1.4, frontShift),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.65),
    );
  }

  @override
  bool shouldRepaint(covariant _WaterPainter oldDelegate) => false;
}