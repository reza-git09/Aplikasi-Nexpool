import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/home_page.dart';
import 'pages/tiket_page.dart';
import 'pages/review_page.dart';
import 'pages/profile_page.dart';
import 'pages/liquid_glass_navbar.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';
import 'theme/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)) {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
  await ThemeService.load(); // baca tema terang/gelap yang tersimpan di HP
  await ApiService.init(); // baca URL server yang tersimpan (jika ada)
  // Dimatikan supaya login tetap tersimpan setelah app dibuka ulang.
  // Kalau mau reset login tiap app jalan (untuk tes), aktifkan lagi:
  // await AuthService.logout();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.mode,
      builder: (context, mode, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: mode,
        themeAnimationDuration: const Duration(milliseconds: 360),
        themeAnimationCurve: Curves.easeInOutCubic,
        home: const MainShell(),
      ),
    );
  }
}

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

  // Index tab
  static const int _tabHome = 0;
  static const int _tabUlasan = 2;
  static const int _tabProfil = 3;

  // Pool data shared from HomePage
  String _poolId = '';
  String _poolName = '';
  String _poolGambar = '';
  int _homeSelectedPool = 0;

  // ============================================================
  // SESI LOGIN (satu sumber untuk semua tab)
  // ============================================================
  bool _loggedIn = false;
  Map<String, dynamic>? _user;
  int _sessionTick = 0; // naik tiap status login berubah -> Home ikut update
  int _reviewRefreshTick = 0;
  OverlayEntry? _poolSelectionWarning;
  Timer? _poolSelectionWarningTimer;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final bool logged = prefs.getBool('is_logged_in') ?? false;

    if (!mounted) return;

    setState(() {
      _loggedIn = logged;
      _user = logged
          ? {
              'name': prefs.getString('user_name') ?? '',
              'nama_lengkap':
                  prefs.getString('user_nama_lengkap') ??
                  prefs.getString('user_name') ??
                  '',
              'username': prefs.getString('user_username') ?? '',
              'email': prefs.getString('user_email') ?? '',
              'no_hp': prefs.getString('user_no_hp') ?? '',
              'alamat': prefs.getString('user_alamat') ?? '',
            }
          : null;
      _sessionTick++;
    });
  }

  Future<void> _openLogin() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
    await _loadSession();
  }

  Future<void> _openRegister() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
    await _loadSession();
  }

  Future<void> _handleLogout() async {
    await _loadSession();
    if (!mounted) return;
    setState(() => _currentIndex = _tabHome);
  }

  void _onPoolChanged(
    int poolIndex,
    String poolId,
    String poolName,
    String poolGambar,
  ) {
    ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
    _poolSelectionWarningTimer?.cancel();
    _poolSelectionWarning?.remove();
    _poolSelectionWarning = null;
    _poolSelectionWarningTimer = null;

    setState(() {
      _homeSelectedPool = poolIndex;
      _poolId = poolId;
      _poolName = poolName;
      _poolGambar = poolGambar;
    });
  }

  void _showPoolSelectionWarning(String message) {
    _poolSelectionWarningTimer?.cancel();
    _poolSelectionWarning?.remove();

    final overlay = Overlay.of(context);
    _poolSelectionWarning = OverlayEntry(
      builder: (overlayContext) {
        final theme = Theme.of(overlayContext);
        final accent = theme.colorScheme.primary;

        return Positioned(
          top: 0,
          left: 16,
          right: 16,
          child: SafeArea(
            bottom: false,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              builder: (context, progress, child) => Opacity(
                opacity: progress,
                child: Transform.translate(
                  offset: Offset(0, -12 * (1 - progress)),
                  child: child,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: accent.withOpacity(0.35)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: accent, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          message,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 13,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_poolSelectionWarning!);
    _poolSelectionWarningTimer = Timer(const Duration(seconds: 3), () {
      _poolSelectionWarning?.remove();
      _poolSelectionWarning = null;
      _poolSelectionWarningTimer = null;
    });
  }

  @override
  void dispose() {
    _poolSelectionWarningTimer?.cancel();
    _poolSelectionWarning?.remove();
    super.dispose();
  }

  Future<void> _onTabTapped(int index) async {
    if (index == _currentIndex) return;

    // Booking requires an explicitly selected pool from the home page.
    if (index == 1 && _homeSelectedPool == 0) {
      _showPoolSelectionWarning(
        'Silakan pilih wisata kolam renang terlebih dahulu sebelum memesan tiket.',
      );
      return;
    }

    // Guard: Ulasan needs a pool selected
    if (index == _tabUlasan && _homeSelectedPool == 0) {
      _showPoolSelectionWarning(
        'Silakan pilih kolam renang terlebih dahulu untuk memberikan ulasan.',
      );
      return;
    }

    // Tab Tiket & Profil: boleh dibuka meski belum login.
    // Halaman guest (button register/login) akan ditampilkan di dalam tab.

    HapticFeedback.selectionClick();
    setState(() {
      _currentIndex = index;
      if (index == _tabUlasan) {
        _reviewRefreshTick++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBg,
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
                  sessionTick: _sessionTick,
                  onSessionChanged: _loadSession,
                  onOpenProfile: () {
                    setState(() => _currentIndex = _tabProfil);
                  },
                ),
                _loggedIn
                    ? TiketPage(
                        key: ValueKey('tiket_${_poolId}_$_loggedIn'),
                        poolId: _poolId,
                        poolName: _poolName,
                        onReturnHome: () {
                          setState(() => _currentIndex = _tabHome);
                        },
                      )
                    : _GuestTiket(
                        key: const ValueKey('tiket_guest'),
                        onSignIn: _openLogin,
                        onRegister: _openRegister,
                      ),
                ReviewPage(
                  key: ValueKey('review_$_poolId'),
                  poolId: _poolId,
                  namaKolam: _poolName,
                  gambarKolam: _poolGambar,
                  sessionTick: _sessionTick,
                  purchaseRefreshTick: _reviewRefreshTick,
                  onSessionChanged: _loadSession,
                  onOpenTicketBooking: () => _onTabTapped(1),
                ),
                _loggedIn
                    ? ProfilePage(
                        key: const ValueKey('profil'),
                        userData: _user,
                        embedded: true,
                        onLogout: _handleLogout,
                      )
                    : _GuestProfile(
                        key: const ValueKey('profil_guest'),
                        onSignIn: _openLogin,
                        onRegister: _openRegister,
                      ),
              ],
            ),
          ),

          // ===== NAVBAR LIQUID GLASS =====
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: LiquidGlassNavBar(
                  currentIndex: _currentIndex,
                  onTap: _onTabTapped,
                  items: const [
                    NavItem(Icons.home_rounded, 'Home'),
                    NavItem(Icons.confirmation_number_rounded, 'Tiket'),
                    NavItem(Icons.star_rounded, 'Ulasan'),
                    NavItem(Icons.person_rounded, 'Profil'),
                  ],
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
// TAMPILAN TAB PROFIL KALAU BELUM LOGIN
// ================================================================
class _GuestProfile extends StatelessWidget {
  const _GuestProfile({
    super.key,
    required this.onSignIn,
    required this.onRegister,
  });

  final VoidCallback onSignIn;
  final VoidCallback onRegister;

  static const Color navy = Color(0xFF173F7A);
  static const Color blue = Color(0xFF2675D8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        title: const Text(
          'Profil Saya',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 120),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: navy.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  size: 52,
                  color: context.textMain,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Kamu belum login',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: context.textMain,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Masuk ke akunmu untuk melihat profil\ndan memesan tiket kolam renang.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF8490A3),
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: onSignIn,
                  icon: const Icon(Icons.login_rounded),
                  label: const Text(
                    'SIGN IN',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: navy,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: onRegister,
                style: TextButton.styleFrom(foregroundColor: blue),
                child: const Text(
                  'Belum punya akun? Daftar sekarang',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// TAMPILAN TAB TIKET KALAU BELUM LOGIN
// ================================================================
class _GuestTiket extends StatelessWidget {
  const _GuestTiket({
    super.key,
    required this.onSignIn,
    required this.onRegister,
  });

  final VoidCallback onSignIn;
  final VoidCallback onRegister;

  static const Color navy = Color(0xFF173F7A);
  static const Color blue = Color(0xFF2675D8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        title: const Text(
          'Pesan Tiket',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 120),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: navy.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.confirmation_number_outlined,
                  size: 52,
                  color: context.textMain,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Kamu belum login',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: context.textMain,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Masuk ke akunmu untuk memesan tiket\nkolam renang favoritmu.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF8490A3),
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: onSignIn,
                  icon: const Icon(Icons.login_rounded),
                  label: const Text(
                    'SIGN IN',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: navy,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: onRegister,
                style: TextButton.styleFrom(foregroundColor: blue),
                child: const Text(
                  'Belum punya akun? Daftar sekarang',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
