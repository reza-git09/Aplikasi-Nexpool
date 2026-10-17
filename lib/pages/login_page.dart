
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController usernameController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  late AnimationController bubbleController;

  // Warna disamakan dengan RegisterPage.
  static const Color navy = Color(0xFF173F7A);
  static const Color blue = Color(0xFF2675D8);
  static const Color background = Color(0xFFF3F7FD);

  static const Color headerDark = Color(0xFF102E60);
  static const Color headerMiddle = Color(0xFF205BA9);
  static const Color headerLight = Color(0xFF3688E8);

  @override
  void initState() {
    super.initState();

    bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    bubbleController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (isLoading) return;

    final username = usernameController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showMessage(
        'Username dan password wajib diisi.',
        Colors.orange.shade700,
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Tetap menggunakan API Laravel yang sudah ada.
      final nama = await AuthService.verifyLogin(
        username,
        password,
      );

      if (!mounted) return;

      if (nama != null) {
        _showMessage(
          'Login berhasil. Selamat datang, $nama!',
          Colors.green.shade700,
        );

        await Future.delayed(
          const Duration(milliseconds: 400),
        );

        if (!mounted) return;

        Navigator.pop(context, true);
      } else {
        _showMessage(
          AuthService.lastError.isNotEmpty
              ? AuthService.lastError
              : 'Username atau password salah.',
          Colors.red.shade600,
        );
      }
    } catch (_) {
      if (!mounted) return;

      _showMessage(
        'Terjadi kesalahan saat login. Coba lagi.',
        Colors.red.shade600,
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Future<void> _goToRegister() async {
    if (isLoading) return;

    final bool? registered = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const RegisterPage(),
      ),
    );

    if (!mounted) return;

    // Jika registrasi berhasil lalu login berhasil dari RegisterPage,
    // teruskan hasil login ke halaman sebelumnya.
    if (registered == true) {
      Navigator.pop(context, true);
    }
  }

  Widget _bubble({
    required double size,
    double? left,
    double? right,
    required double top,
    required double progress,
  }) {
    final value = progress % 1.0;
    final offset = 12 * (value < 0.5 ? value : 1 - value);

    return Positioned(
      left: left,
      right: right,
      top: top + offset,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.10),
          border: Border.all(
            color: Colors.white.withOpacity(0.25),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: navy,
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputAction textInputAction = TextInputAction.next,
    ValueChanged<String>? onSubmitted,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      autocorrect: false,
      enableSuggestions: !obscureText,
      style: const TextStyle(
        color: navy,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFF8490A3),
          fontSize: 13,
        ),
        prefixIcon: Icon(
          icon,
          color: navy,
          size: 21,
        ),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF8FAFE),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFFE2E9F3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFFE2E9F3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: blue,
            width: 1.7,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          // Gradasi header sama seperti RegisterPage.
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  headerDark,
                  headerMiddle,
                  headerLight,
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),

          // Animasi gelembung.
          AnimatedBuilder(
            animation: bubbleController,
            builder: (context, child) {
              return Stack(
                children: [
                  _bubble(
                    size: 75,
                    left: 30,
                    top: 100,
                    progress: bubbleController.value,
                  ),
                  _bubble(
                    size: 30,
                    left: 150,
                    top: 55,
                    progress: bubbleController.value + 0.2,
                  ),
                  _bubble(
                    size: 48,
                    right: 40,
                    top: 150,
                    progress: bubbleController.value + 0.4,
                  ),
                  _bubble(
                    size: 22,
                    right: 145,
                    top: 80,
                    progress: bubbleController.value + 0.6,
                  ),
                ],
              );
            },
          ),

          SafeArea(
            child: Column(
              children: [
                // HEADER
                SizedBox(
                  height: 270,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 20,
                        top: 10,
                        child: Material(
                          color: Colors.white.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(13),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(13),
                            onTap: () => Navigator.pop(context),
                            child: const SizedBox(
                              width: 45,
                              height: 45,
                              child: Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                                size: 21,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 28,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            Container(
                              width: 86,
                              height: 86,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.14),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.35),
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.pool_rounded,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 17),
                            const Text(
                              'NEXPOOL',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Selamat datang kembali!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Masuk dan lanjutkan pengalaman berenangmu.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.88),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // FORM LOGIN
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(35),
                        topRight: Radius.circular(35),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        22,
                        28,
                        22,
                        25,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 440,
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: navy.withOpacity(0.07),
                                  blurRadius: 25,
                                  offset: const Offset(0, 9),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Container(
                                    width: 42,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE2E9F3),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 25),

                                const Text(
                                  'Selamat Datang 👋',
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w900,
                                    color: navy,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Masuk ke akunmu untuk melanjutkan '
                                  'pemesanan tiket kolam renang.',
                                  style: TextStyle(
                                    color: Color(0xFF8490A3),
                                    fontSize: 13,
                                    height: 1.6,
                                  ),
                                ),
                                const SizedBox(height: 27),

                                _label('Username atau Email'),
                                const SizedBox(height: 9),
                                _input(
                                  controller: usernameController,
                                  hint: 'Masukkan username atau email',
                                  icon: Icons.person_outline_rounded,
                                  textInputAction: TextInputAction.next,
                                ),

                                const SizedBox(height: 20),

                                _label('Password'),
                                const SizedBox(height: 9),
                                _input(
                                  controller: passwordController,
                                  hint: 'Masukkan password',
                                  icon: Icons.lock_outline_rounded,
                                  obscureText: obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => login(),
                                  suffix: IconButton(
                                    tooltip: obscurePassword
                                        ? 'Tampilkan password'
                                        : 'Sembunyikan password',
                                    onPressed: () {
                                      setState(() {
                                        obscurePassword = !obscurePassword;
                                      });
                                    },
                                    icon: Icon(
                                      obscurePassword
                                          ? Icons.visibility_off_rounded
                                          : Icons.visibility_rounded,
                                      color: const Color(0xFF73829A),
                                      size: 21,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 27),

                                // TOMBOL LOGIN
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: navy,
                                      disabledBackgroundColor:
                                          navy.withOpacity(0.65),
                                      foregroundColor: Colors.white,
                                      elevation: 3,
                                      shadowColor: navy.withOpacity(0.25),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.login_rounded),
                                              SizedBox(width: 10),
                                              Text(
                                                'MASUK KE AKUN',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  letterSpacing: 0.5,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Icon(
                                                Icons.arrow_forward_rounded,
                                                size: 19,
                                              ),
                                            ],
                                          ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // INFORMASI AKUN
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F7FD),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFE2E9F3),
                                    ),
                                  ),
                                  child: const Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.verified_user_rounded,
                                        color: navy,
                                        size: 23,
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Gunakan username atau email dan '
                                          'password yang kamu daftarkan '
                                          'di NEXPOOL.',
                                          style: TextStyle(
                                            color: Color(0xFF758399),
                                            fontSize: 12,
                                            height: 1.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 23),

                                Row(
                                  children: [
                                    const Expanded(
                                      child: Divider(
                                        color: Color(0xFFE5EAF2),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Text(
                                        'AKUN NEXPOOL',
                                        style: TextStyle(
                                          fontSize: 10,
                                          letterSpacing: 1,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.blueGrey.shade400,
                                        ),
                                      ),
                                    ),
                                    const Expanded(
                                      child: Divider(
                                        color: Color(0xFFE5EAF2),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                const Center(
                                  child: Text(
                                    'Belum punya akun NEXPOOL?',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFF8490A3),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 5),

                                // TOMBOL DAFTAR SEKARANG
                                Center(
                                  child: TextButton(
                                    onPressed: isLoading
                                        ? null
                                        : _goToRegister,
                                    style: TextButton.styleFrom(
                                      foregroundColor: navy,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 10,
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.person_add_alt_1_rounded,
                                          size: 19,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Daftar Sekarang',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
}
