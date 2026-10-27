import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with SingleTickerProviderStateMixin {
  // ─── Controllers ───────────────────────────────────────────────
  final TextEditingController _loginCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();

  // ─── State ─────────────────────────────────────────────────────
  int _step = 0; // 0 = masukkan akun, 1 = buat password baru
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _verifiedLogin; // username/email yang sudah diverifikasi

  late AnimationController _bubbleCtrl;

  // ─── Warna (sama dengan LoginPage) ─────────────────────────────
  static const Color navy = Color(0xFF173F7A);
  static const Color blue = Color(0xFF2675D8);
  static const Color background = Color(0xFFF3F7FD);
  static const Color headerDark = Color(0xFF102E60);
  static const Color headerMiddle = Color(0xFF205BA9);
  static const Color headerLight = Color(0xFF3688E8);

  @override
  void initState() {
    super.initState();
    _bubbleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _bubbleCtrl.dispose();
    _loginCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ─── Langkah 1: verifikasi akun ────────────────────────────────
  Future<void> _verifyAccount() async {
    final login = _loginCtrl.text.trim();
    if (login.isEmpty) {
      _snack('Masukkan username atau email terlebih dahulu.', isError: true);
      return;
    }
    setState(() => _isLoading = true);

    final exists = await AuthService.checkAccountExists(login);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (exists) {
      setState(() {
        _verifiedLogin = login;
        _step = 1;
      });
    } else {
      _snack(
        AuthService.lastError.isNotEmpty
            ? AuthService.lastError
            : 'Akun dengan username/email tersebut tidak ditemukan.',
        isError: true,
      );
    }
  }

  // ─── Langkah 2: reset password ─────────────────────────────────
  Future<void> _resetPassword() async {
    final pass = _passCtrl.text;
    final confirm = _confirmCtrl.text;

    if (pass.isEmpty || confirm.isEmpty) {
      _snack('Password baru tidak boleh kosong.', isError: true);
      return;
    }
    if (pass.length < 6) {
      _snack('Password minimal 6 karakter.', isError: true);
      return;
    }
    if (pass != confirm) {
      _snack('Konfirmasi password tidak cocok.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final error = await AuthService.resetPassword(
      login: _verifiedLogin!,
      newPassword: pass,
      confirmPassword: confirm,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      // Sukses — kembali ke login
      _snack('Password berhasil diperbarui! Silakan login.', isError: false);
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      Navigator.pop(context);
    } else {
      _snack(error, isError: true);
    }
  }

  void _snack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFEF476F) : const Color(0xFF2ECC71),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ─── Bubble animasi ────────────────────────────────────────────
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
          border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.5),
        ),
      ),
    );
  }

  // ─── Input field ───────────────────────────────────────────────
  Widget _input({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    VoidCallback? onToggleObscure,
    TextInputAction action = TextInputAction.next,
    VoidCallback? onSubmit,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      textInputAction: action,
      onSubmitted: (_) => onSubmit?.call(),
      autocorrect: false,
      enableSuggestions: !obscure,
      style: const TextStyle(color: navy, fontSize: 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF8490A3), fontSize: 13),
        prefixIcon: Icon(icon, color: navy, size: 21),
        suffixIcon: onToggleObscure != null
            ? IconButton(
                onPressed: onToggleObscure,
                icon: Icon(
                  obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: const Color(0xFF73829A),
                  size: 21,
                ),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF8FAFE),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE2E9F3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE2E9F3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: blue, width: 1.7),
        ),
      ),
    );
  }

  // ─── Tombol utama ──────────────────────────────────────────────
  Widget _primaryButton({required String label, required VoidCallback? onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: navy,
          disabledBackgroundColor: navy.withOpacity(0.6),
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: navy.withOpacity(0.25),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_step == 0 ? Icons.search_rounded : Icons.lock_reset_rounded),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 19),
                ],
              ),
      ),
    );
  }

  // ─── Step Indicator ────────────────────────────────────────────
  Widget _stepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (i) {
        final active = i == _step;
        final done = i < _step;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 28 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: done
                ? const Color(0xFF2ECC71)
                : active
                    ? blue
                    : const Color(0xFFE2E9F3),
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }

  // ─── Konten Step 0: verifikasi akun ────────────────────────────
  Widget _buildStep0() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lupa Password? 🔑',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: navy,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Masukkan username atau email yang kamu daftarkan untuk memverifikasi akunmu.',
          style: TextStyle(color: Color(0xFF8490A3), fontSize: 13, height: 1.6),
        ),
        const SizedBox(height: 28),

        const Text(
          'Username atau Email',
          style: TextStyle(color: navy, fontSize: 14, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 9),
        _input(
          controller: _loginCtrl,
          hint: 'Masukkan username atau email',
          icon: Icons.person_search_rounded,
          action: TextInputAction.done,
          onSubmit: _verifyAccount,
        ),

        const SizedBox(height: 28),
        _primaryButton(label: 'VERIFIKASI AKUN', onPressed: _verifyAccount),

        const SizedBox(height: 16),

        // Info box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F5FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD6E4FF)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, color: blue, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Pastikan username atau email sesuai yang terdaftar di NEXPOOL.',
                  style: TextStyle(color: Color(0xFF4A6FA5), fontSize: 12, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Konten Step 1: buat password baru ─────────────────────────
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Buat Password Baru 🔒',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: navy,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: const TextStyle(color: Color(0xFF8490A3), fontSize: 13, height: 1.6),
            children: [
              const TextSpan(text: 'Akun '),
              TextSpan(
                text: _verifiedLogin ?? '',
                style: const TextStyle(
                  color: navy,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const TextSpan(text: ' ditemukan. Silakan buat password baru.'),
            ],
          ),
        ),
        const SizedBox(height: 28),

        const Text(
          'Password Baru',
          style: TextStyle(color: navy, fontSize: 14, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 9),
        _input(
          controller: _passCtrl,
          hint: 'Minimal 6 karakter',
          icon: Icons.lock_outline_rounded,
          obscure: _obscurePass,
          onToggleObscure: () => setState(() => _obscurePass = !_obscurePass),
          action: TextInputAction.next,
        ),

        const SizedBox(height: 18),

        const Text(
          'Konfirmasi Password',
          style: TextStyle(color: navy, fontSize: 14, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 9),
        _input(
          controller: _confirmCtrl,
          hint: 'Ulangi password baru',
          icon: Icons.lock_reset_rounded,
          obscure: _obscureConfirm,
          onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
          action: TextInputAction.done,
          onSubmit: _resetPassword,
        ),

        const SizedBox(height: 28),
        _primaryButton(label: 'SIMPAN & LANJUT LOGIN', onPressed: _resetPassword),

        const SizedBox(height: 14),

        // Tombol kembali ke step 0
        Center(
          child: TextButton.icon(
            onPressed: _isLoading
                ? null
                : () => setState(() {
                      _step = 0;
                      _passCtrl.clear();
                      _confirmCtrl.clear();
                    }),
            icon: const Icon(Icons.arrow_back_rounded, size: 16),
            label: const Text('Ganti Akun'),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF8490A3)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [headerDark, headerMiddle, headerLight],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),

          // Bubble animasi
          AnimatedBuilder(
            animation: _bubbleCtrl,
            builder: (_, __) => Stack(
              children: [
                _bubble(size: 70, left: 25, top: 95, progress: _bubbleCtrl.value),
                _bubble(size: 28, left: 140, top: 50, progress: _bubbleCtrl.value + 0.2),
                _bubble(size: 45, right: 35, top: 140, progress: _bubbleCtrl.value + 0.4),
                _bubble(size: 20, right: 135, top: 75, progress: _bubbleCtrl.value + 0.6),
              ],
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // HEADER
                SizedBox(
                  height: 250,
                  child: Stack(
                    children: [
                      // Tombol kembali
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

                      // Logo & judul
                      Positioned(
                        top: 22,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.14),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.35),
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.lock_reset_rounded,
                                size: 42,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'NEXPOOL',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Reset Password Akun',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Ikuti langkah berikut untuk memulihkan akunmu.',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // FORM
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
                      padding: const EdgeInsets.fromLTRB(22, 28, 22, 30),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
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
                              children: [
                                // Bar tarik
                                Container(
                                  width: 42,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE2E9F3),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                const SizedBox(height: 6),

                                // Step indicator
                                _stepIndicator(),
                                const SizedBox(height: 22),

                                // Konten step
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  transitionBuilder: (child, anim) => FadeTransition(
                                    opacity: anim,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0.08, 0),
                                        end: Offset.zero,
                                      ).animate(anim),
                                      child: child,
                                    ),
                                  ),
                                  child: KeyedSubtree(
                                    key: ValueKey(_step),
                                    child: _step == 0 ? _buildStep0() : _buildStep1(),
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
