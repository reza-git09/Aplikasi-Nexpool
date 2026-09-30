import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'pages/home_page.dart';
import 'pages/tiket_page.dart';
import 'pages/review_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Roboto'),
      home: const MainShell(),
    );
  }
}

// ================================================================
// CONSTANTS
// ================================================================
const _kTabColors = [
  Color(0xFF378ADD), // Home  – biru
  Color(0xFFEF9F27), // Tiket – oranye
  Color(0xFFD4537E), // Ulasan – pink
];

const _kTabIcons = [
  Icons.home_rounded,
  Icons.confirmation_number_rounded,
  Icons.star_rounded,
];

const _kTabLabels = ['Home', 'Tiket', 'Ulasan'];

const _kBubbleDiameter = 48.0;
const _kBarHeight = 56.0;
const _kStackHeight = 72.0; // bubble(48) top-aligned, bar(56) bottom-aligned → 48+16=72... bar starts at y=16
const _kBarRadius = 28.0;
const _kBarMarginB = 16.0;

// ================================================================
// MAIN SHELL
// ================================================================
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // Pool data shared from HomePage
  String _poolId = 'pool_id_01';
  String _poolName = 'Tiara Jember Park Waterboom';
  String _poolGambar = '';
  int _homeSelectedPool = 0;

  void _onPoolChanged(
    int poolIndex,
    String poolId,
    String poolName,
    String poolGambar,
  ) {
    setState(() {
      _homeSelectedPool = poolIndex;
      _poolId = poolId;
      _poolName = poolName;
      _poolGambar = poolGambar;
    });
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    // Guard: Ulasan needs a pool selected
    if (index == 2 && _homeSelectedPool == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Silakan pilih kolam renang terlebih dahulu untuk memberikan ulasan.',
          ),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    HapticFeedback.selectionClick();
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                HomePage(
                  key: const ValueKey('home'),
                  onPoolChanged: _onPoolChanged,
                ),
                TiketPage(
                  key: ValueKey('tiket_$_poolId'),
                  poolId: _poolId,
                  poolName: _poolName,
                ),
                ReviewPage(
                  key: ValueKey('review_$_poolId'),
                  poolId: _poolId,
                  namaKolam: _poolName,
                  gambarKolam: _poolGambar,
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: _kBarMarginB),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: _SlidingBubbleNavbar(
                    currentIndex: _currentIndex,
                    onTabSelected: _onTabTapped,
                    scaffoldBgColor: const Color(0xffF5F8FC),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// SLIDING BUBBLE NAVBAR
// ================================================================
class _SlidingBubbleNavbar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final Color scaffoldBgColor;

  const _SlidingBubbleNavbar({
    required this.currentIndex,
    required this.onTabSelected,
    required this.scaffoldBgColor,
  });

  @override
  State<_SlidingBubbleNavbar> createState() => _SlidingBubbleNavbarState();
}

class _SlidingBubbleNavbarState extends State<_SlidingBubbleNavbar> {
  double? _dragOffsetX; // null = not dragging
  late int _displayIndex; // index reflected during drag

  @override
  void initState() {
    super.initState();
    _displayIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(_SlidingBubbleNavbar old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex && _dragOffsetX == null) {
      _displayIndex = widget.currentIndex;
    }
  }

  // The "confirmed" tab index (may differ from displayIndex during drag)
  int get _activeIndex => widget.currentIndex;

  double _clamp(double v, double lo, double hi) =>
      math.max(lo, math.min(hi, v));

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth;
        const n = 3;
        final tabWidth = barWidth / n;

        // --- bubble centre X within bar ---
        double bubbleCx;
        if (_dragOffsetX != null) {
          bubbleCx = _clamp(
            _dragOffsetX!,
            _kBubbleDiameter / 2,
            barWidth - _kBubbleDiameter / 2,
          );
        } else {
          bubbleCx = tabWidth * _activeIndex + tabWidth / 2;
        }

        return SizedBox(
          height: _kStackHeight,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,

            // --- DRAG ---
            onHorizontalDragUpdate: (details) {
              final raw = (_dragOffsetX ?? bubbleCx) + details.delta.dx;
              final clamped = _clamp(
                raw,
                tabWidth / 2,
                barWidth - tabWidth / 2,
              );

              // Which tab is closest?
              final nearestIdx = (clamped / tabWidth).floor().clamp(0, n - 1);

              setState(() {
                _dragOffsetX = clamped;
                if (nearestIdx != _displayIndex) {
                  _displayIndex = nearestIdx;
                  HapticFeedback.selectionClick();
                }
              });
            },
            onHorizontalDragEnd: (details) {
              // Snap to closest tab
              final clamped = _clamp(
                _dragOffsetX ?? bubbleCx,
                tabWidth / 2,
                barWidth - tabWidth / 2,
              );
              final nearest = (clamped / tabWidth).floor().clamp(0, n - 1);
              setState(() => _dragOffsetX = null);
              widget.onTabSelected(nearest);
            },
            onHorizontalDragCancel: () => setState(() => _dragOffsetX = null),

            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // ── BAR ──────────────────────────────────────────
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: _kBarHeight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(_kBarRadius),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF378ADD).withOpacity(0.15),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: List.generate(n, (i) {
                        return _BarTab(
                          index: i,
                          activeIndex: _displayIndex,
                          tabWidth: tabWidth,
                          onTap: () => widget.onTabSelected(i),
                        );
                      }),
                    ),
                  ),
                ),

                // ── BUBBLE ───────────────────────────────────────
                // top: 0  → bubble top = top of Stack
                // bubble extends from y=0 to y=48, bar starts at y=16
                // so 32px of bubble is inside bar, 16px protrudes above.
                AnimatedPositioned(
                  duration: _dragOffsetX != null
                      ? Duration.zero
                      : const Duration(milliseconds: 450),
                  curve: Curves.easeOutBack,
                  top: 0,
                  left: bubbleCx - _kBubbleDiameter / 2,
                  child: _Bubble(
                    activeIndex: _displayIndex,
                    ringColor: widget.scaffoldBgColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ================================================================
// BUBBLE WIDGET
// ================================================================
class _Bubble extends StatelessWidget {
  final int activeIndex;
  final Color ringColor;

  const _Bubble({required this.activeIndex, required this.ringColor});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(
        begin: _kTabColors[activeIndex],
        end: _kTabColors[activeIndex],
      ),
      duration: const Duration(milliseconds: 300),
      builder: (context, color, _) {
        return Container(
          width: _kBubbleDiameter,
          height: _kBubbleDiameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ringColor, width: 4),
            color: color ?? _kTabColors[activeIndex],
            boxShadow: [
              BoxShadow(
                color: (color ?? _kTabColors[activeIndex]).withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) {
                return ScaleTransition(
                  scale: anim,
                  child: RotationTransition(
                    turns: Tween<double>(begin: -0.08, end: 0.0).animate(anim),
                    child: child,
                  ),
                );
              },
              child: Icon(
                _kTabIcons[activeIndex],
                key: ValueKey(activeIndex),
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ================================================================
// BAR TAB (inside the bar, one per tab)
// ================================================================
class _BarTab extends StatelessWidget {
  final int index;
  final int activeIndex;
  final double tabWidth;
  final VoidCallback onTap;

  const _BarTab({
    required this.index,
    required this.activeIndex,
    required this.tabWidth,
    required this.onTap,
  });

  bool get _isActive => index == activeIndex;
  Color get _tabColor => _kTabColors[index];

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _kTabLabels[index],
      selected: _isActive,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: tabWidth,
          height: _kBarHeight,
          child: _isActive
              // Active: bubble occupies top 32px; label fills remaining ~24px at bottom
              ? Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _ActiveLabel(
                      color: _tabColor,
                      label: _kTabLabels[index],
                    ),
                  ),
                )
              // Inactive: icon + label centred in bar
              : Center(
                  child: _InactiveItem(
                    key: ValueKey('inactive_$index'),
                    icon: _kTabIcons[index],
                    color: _tabColor,
                    label: _kTabLabels[index],
                  ),
                ),
        ),
      ),
    );
  }
}

class _ActiveLabel extends StatelessWidget {
  final Color color;
  final String label;

  const _ActiveLabel({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      key: ValueKey('active_$label'),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: HSLColor.fromColor(color).withLightness(0.30).toColor(),
        letterSpacing: 0.2,
      ),
    );
  }
}

class _InactiveItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _InactiveItem({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color.withOpacity(0.38)),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade400,
          ),
        ),
      ],
    );
  }
}
