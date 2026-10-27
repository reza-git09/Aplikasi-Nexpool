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
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Dimatikan supaya login tetap tersimpan setelah app dibuka ulang.
  // Kalau mau reset login tiap app jalan (untuk tes), aktifkan lagi:
  // await AuthService.logout();
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
  static const int _tabTiket = 1;
  static const int _tabUlasan = 2;
  static const int _tabProfil = 3;

  // Pool data shared from HomePage
  String _poolId = 'pool_id_01';
  String _poolName = 'Tiara Jember Park Waterboom';
  String _poolGambar = '';
  int _homeSelectedPool = 0;

  // ============================================================
  // SESI LOGIN (satu sumber untuk semua tab)
  // ============================================================
  bool _loggedIn = false;
  Map<String, dynamic>? _user;
  int _sessionTick = 0; // naik tiap status login berubah -> Home ikut update

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

  /// Buka Registrasi (lalu Login). Mengembalikan true kalau akhirnya login.
  Future<bool> _openAuth() async {
    final bool? result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
    final bool ok = result == true && await AuthService.isLoggedIn();
    await _loadSession();
    return ok;
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
    setState(() {
      _homeSelectedPool = poolIndex;
      _poolId = poolId;
      _poolName = poolName;
      _poolGambar = poolGambar;
    });
  }

  Future<void> _onTabTapped(int index) async {
    if (index == _currentIndex) return;

    // Guard: Ulasan needs a pool selected
    if (index == _tabUlasan && _homeSelectedPool == 0) {
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

    // Guard: Tiket butuh akun. Belum login -> Registrasi dulu, lalu Login.
    if (index == _tabTiket) {
      final bool logged = await AuthService.isLoggedIn();
      if (!mounted) return;
      if (!logged) {
        final bool ok = await _openAuth();
        if (!ok || !mounted) return;
      }
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
                  sessionTick: _sessionTick,
                  onSessionChanged: _loadSession,
                  onOpenProfile: () {
                    setState(() => _currentIndex = _tabProfil);
                  },
                ),
                TiketPage(
                  key: ValueKey('tiket_${_poolId}_$_loggedIn'),
                  poolId: _poolId,
                  poolName: _poolName,
                ),
                ReviewPage(
                  key: ValueKey('review_$_poolId'),
                  poolId: _poolId,
                  namaKolam: _poolName,
                  gambarKolam: _poolGambar,
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
  static const Color background = Color(0xFFF3F7FD);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
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
                  color: navy.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  size: 52,
                  color: navy,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Kamu belum login',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: navy,
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
