import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'pages/home_page.dart';
import 'pages/tiket_page.dart';
import 'pages/review_page.dart';
import 'pages/liquid_glass_navbar.dart';
import 'pages/register_page.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.logout(); // SEMENTARA: hapus nanti setelah selesai tes
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

  // Pool data shared from HomePage
  String _poolId = 'pool_id_01';
  String _poolName = 'Tiara Jember Park Waterboom';
  String _poolGambar = '';
  int _homeSelectedPool = 0;

  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    AuthService.isLoggedIn().then((v) {
      if (mounted) setState(() => _loggedIn = v);
    });
  }

  /// Buka Registrasi (lalu Login). Mengembalikan true kalau akhirnya login.
  Future<bool> _openAuth() async {
    final bool? result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
    final bool ok = result == true && await AuthService.isLoggedIn();
    if (mounted && ok) setState(() => _loggedIn = true);
    return ok;
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

    // Guard: Tiket butuh akun. Belum login -> Registrasi dulu, lalu Login.
    if (index == 1) {
      final bool logged = await AuthService.isLoggedIn();
      if (!mounted) return;
      if (!logged) {
        final bool ok = await _openAuth();
        if (!ok || !mounted) return;
      } else if (!_loggedIn) {
        setState(() => _loggedIn = true);
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}