import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

class NavItem {
  final IconData icon;
  final String label;
  const NavItem(this.icon, this.label);
}

/// Navbar ala iOS "Liquid Glass".
/// - Bisa di-tap
/// - Bisa di-slide (geser lensa kaca ke kiri/kanan, lepas = snap ke tab terdekat)
class LiquidGlassNavBar extends StatefulWidget {
  const LiquidGlassNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items = const [
      NavItem(Icons.home_rounded, 'Home'),
      NavItem(Icons.confirmation_number_rounded, 'Tiket'),
      NavItem(Icons.star_rounded, 'Ulasan'),
    ],
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavItem> items;

  @override
  State<LiquidGlassNavBar> createState() => _LiquidGlassNavBarState();
}

class _LiquidGlassNavBarState extends State<LiquidGlassNavBar> {
  static const double _barHeight = 72;
  static const double _pad = 6;

  bool _dragging = false;
  double _dragPos =
      0; // posisi lensa dalam satuan index (0..n-1, boleh pecahan)

  int get _n => widget.items.length;

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.isDark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
      child: LayoutBuilder(
        builder: (context, c) {
          final double itemW = (c.maxWidth - _pad * 2) / _n;
          final double pos = _dragging
              ? _dragPos
              : widget.currentIndex.toDouble();
          final int activeIndex = pos.round().clamp(0, _n - 1);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (d) {
              final int i = ((d.localPosition.dx - _pad) / itemW).floor().clamp(
                0,
                _n - 1,
              );
              if (i != widget.currentIndex) {
                HapticFeedback.selectionClick();
                widget.onTap(i);
              }
            },
            onHorizontalDragStart: (_) {
              setState(() {
                _dragging = true;
                _dragPos = widget.currentIndex.toDouble();
              });
            },
            onHorizontalDragUpdate: (d) {
              final double next = (_dragPos + d.delta.dx / itemW).clamp(
                0.0,
                (_n - 1).toDouble(),
              );
              final int before = _dragPos.round();
              setState(() => _dragPos = next);
              if (next.round() != before) HapticFeedback.selectionClick();
            },
            onHorizontalDragEnd: (_) {
              final int i = _dragPos.round().clamp(0, _n - 1);
              setState(() => _dragging = false);
              if (i != widget.currentIndex) widget.onTap(i);
            },
            onHorizontalDragCancel: () => setState(() => _dragging = false),
            child: SizedBox(
              height: _barHeight,
              child: Stack(
                children: [
                  // ===== BODY KACA UTAMA =====
                  Positioned.fill(
                    child: _Glass(
                      radius: 40,
                      blur: isDark ? 22 : 30,
                      tintTop: isDark ? 0.72 : 0.48,
                      tintBottom: isDark ? 0.48 : 0.22,
                      borderOpacity: isDark ? 0.42 : 0.9,
                      baseColor: context.cardBg,
                      borderColor: isDark ? context.softBg : Colors.white,
                      shadow: true,
                      accent: isDark ? null : const Color(0xFFB9EAF4),
                    ),
                  ),

                  // ===== LENSA KACA YANG BISA DI-SLIDE =====
                  AnimatedPositioned(
                    duration: _dragging
                        ? Duration.zero
                        : const Duration(milliseconds: 380),
                    curve: Curves.easeOutBack,
                    left: _pad + pos * itemW,
                    top: _pad,
                    width: itemW,
                    height: _barHeight - _pad * 2,
                    child: AnimatedScale(
                      scale: _dragging ? 1.14 : 1.0,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      child: _Glass(
                        radius: 34,
                        blur: isDark ? 12 : 16,
                        tintTop: isDark
                            ? (_dragging ? 0.84 : 0.76)
                            : (_dragging ? 0.68 : 0.58),
                        tintBottom: isDark
                            ? (_dragging ? 0.66 : 0.56)
                            : (_dragging ? 0.42 : 0.32),
                        borderOpacity: isDark ? 0.62 : 0.95,
                        baseColor: context.cardBg,
                        borderColor: isDark ? context.softBg : Colors.white,
                        shadow: _dragging,
                        accent: isDark
                            ? Theme.of(context).colorScheme.primary
                            : const Color(0xFF62C6DF),
                      ),
                    ),
                  ),

                  // ===== ICON + LABEL =====
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: _pad),
                      child: Row(
                        children: List.generate(_n, (i) {
                          final bool active = i == activeIndex;
                          final item = widget.items[i];
                          return Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedScale(
                                  scale: active ? 1.15 : 1.0,
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    item.icon,
                                    size: 25,
                                    color: active
                                        ? Theme.of(context).colorScheme.primary
                                        : context.mutedText,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: active
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: active
                                        ? Theme.of(context).colorScheme.primary
                                        : context.mutedText,
                                  ),
                                  child: Text(item.label),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
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
}

/// Lapisan kaca: blur + gradient transparan + border highlight + kilap atas.
class _Glass extends StatelessWidget {
  const _Glass({
    required this.radius,
    required this.blur,
    required this.tintTop,
    required this.tintBottom,
    required this.borderOpacity,
    this.shadow = false,
    this.accent,
    required this.baseColor,
    required this.borderColor,
  });

  final double radius;
  final double blur;
  final double tintTop;
  final double tintBottom;
  final double borderOpacity;
  final bool shadow;
  final Color? accent;
  final Color baseColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final BorderRadius br = BorderRadius.circular(radius);

    return Container(
      decoration: BoxDecoration(
        borderRadius: br,
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: br,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: br,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  baseColor.withOpacity(tintTop),
                  (accent ?? borderColor).withOpacity(tintBottom),
                ],
              ),
              border: Border.all(
                color: Color.lerp(
                  Colors.transparent,
                  borderColor,
                  borderOpacity,
                )!,
                width: 1.3,
              ),
            ),
            // Reflect theme light across the glass surface without washing it out.
            child: Align(
              alignment: Alignment.topCenter,
              child: FractionallySizedBox(
                heightFactor: 0.5,
                widthFactor: 0.85,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(radius),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        (Theme.of(context).brightness == Brightness.dark
                                ? Theme.of(context).colorScheme.primary
                                : Colors.white)
                            .withOpacity(
                              Theme.of(context).brightness == Brightness.dark
                                  ? 0.20
                                  : 0.38,
                            ),
                        (Theme.of(context).brightness == Brightness.dark
                                ? Theme.of(context).colorScheme.primary
                                : Colors.white)
                            .withOpacity(0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
