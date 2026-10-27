import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'login_page.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final noHpController = TextEditingController();
  final alamatController = TextEditingController();

  bool passwordVisible = false;
  bool isLoading = false;

  static const navy = Color(0xFF173F7A);
  static const blue = Color(0xFF2675D8);
  static const background = Color(0xFFF3F7FD);

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    noHpController.dispose();
    alamatController.dispose();
    super.dispose();
  }

  Future<void> daftar() async {
    if (isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final String? error = await AuthService.register(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        username: usernameController.text.trim(),
        password: passwordController.text,
        noHp: noHpController.text.trim(),
        alamat: alamatController.text.trim(),
      );

      if (error != null) {
        _showMessage(error, isError: true);
        return;
      }

      // --- GANTI MULAI DARI SINI ---
      _showMessage('Registrasi berhasil!');

      final Map<String, dynamic> dataUserBaru = {
        'name': nameController.text,
        'email': emailController.text,
        'username': usernameController.text,
        'no_hp': noHpController.text,
        'alamat': alamatController.text,
      };

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(userData: dataUserBaru),
        ),
        (route) => false,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
      _showMessage(
        'Gagal terhubung ke server. Periksa koneksi dan coba lagi.',
        isError: true,
      );
    } // <-- Penutup blok catch (_)
  } // <-- Penutup fungsi daftar()

  Future<void> _goToLogin() async {
    final bool? ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );

    if (!mounted) return;

    if (ok == true) {
      Navigator.pop(context, true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFD93645)
            : const Color(0xFF16865B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  InputDecoration inputDecoration(
    String label,
    IconData icon, {
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Color(0xFF77849A),
        fontSize: 14,
      ),
      prefixIcon: Icon(icon, color: navy, size: 21),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF8FAFE),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  Widget sectionTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: navy,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF8490A3),
            ),
          ),
        ],
      ),
    );
  }

  Widget field({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String errorMessage,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
    Widget? suffixIcon,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: obscureText ? 1 : maxLines,
      obscureText: obscureText,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: inputDecoration(
        label,
        icon,
        suffixIcon: suffixIcon,
      ),
      validator: validator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return errorMessage;
            }
            return null;
          },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 35),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF102E60),
                      Color(0xFF205BA9),
                      Color(0xFF3688E8),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(35),
                    bottomRight: Radius.circular(35),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Material(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(13),
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.13),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.water_drop_rounded,
                                color: Colors.white,
                                size: 15,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'NEXPOOL',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  letterSpacing: 1.4,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 19),
                    Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
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
                      'REGISTRASI AKUN BARU',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Buat akun dan nikmati kemudahan\nmemesan tiket kolam renang.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

              // FORM
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF173F7A).withValues(alpha: 0.07),
                        blurRadius: 25,
                        offset: const Offset(0, 9),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Buat Akun Baru',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: navy,
                          ),
                        ),
                        const SizedBox(height: 7),
                        const Text(
                          'Lengkapi data dirimu di bawah ini.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF8490A3),
                          ),
                        ),
                        const SizedBox(height: 25),

                        sectionTitle(
                          'Informasi Pribadi',
                          'Masukkan identitas yang benar.',
                        ),

                        field(
                          label: 'Nama Lengkap',
                          icon: Icons.person_outline_rounded,
                          controller: nameController,
                          errorMessage: 'Nama wajib diisi',
                        ),
                        const SizedBox(height: 15),

                        field(
                          label: 'Email',
                          icon: Icons.alternate_email_rounded,
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          errorMessage: 'Email wajib diisi',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email wajib diisi';
                            }
                            if (!RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            ).hasMatch(value.trim())) {
                              return 'Masukkan alamat email yang valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        field(
                          label: 'Nomor HP',
                          icon: Icons.phone_android_rounded,
                          controller: noHpController,
                          keyboardType: TextInputType.phone,
                          errorMessage: 'Nomor HP wajib diisi',
                        ),
                        const SizedBox(height: 15),

                        field(
                          label: 'Alamat Lengkap',
                          icon: Icons.location_on_outlined,
                          controller: alamatController,
                          maxLines: 3,
                          errorMessage: 'Alamat wajib diisi',
                        ),

                        const SizedBox(height: 27),

                        sectionTitle(
                          'Informasi Akun',
                          'Gunakan username dan password yang aman.',
                        ),

                        field(
                          label: 'Username',
                          icon: Icons.account_circle_outlined,
                          controller: usernameController,
                          errorMessage: 'Username wajib diisi',
                        ),
                        const SizedBox(height: 15),

                        field(
                          label: 'Password',
                          icon: Icons.lock_outline_rounded,
                          controller: passwordController,
                          errorMessage: 'Password wajib diisi',
                          obscureText: !passwordVisible,
                          suffixIcon: IconButton(
                            tooltip: passwordVisible
                                ? 'Sembunyikan password'
                                : 'Tampilkan password',
                            onPressed: () {
                              setState(() {
                                passwordVisible = !passwordVisible;
                              });
                            },
                            icon: Icon(
                              passwordVisible
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                              color: const Color(0xFF73829A),
                              size: 21,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password wajib diisi';
                            }
                            if (value.length < 6) {
                              return 'Password minimal 6 karakter';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 10),

                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              size: 17,
                              color: Color(0xFF16865B),
                            ),
                            SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                'Gunakan password minimal 6 karakter untuk akunmu.',
                                style: TextStyle(
                                  color: Color(0xFF758399),
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 27),

                        // TOMBOL DAFTAR
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : daftar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: navy,
                              disabledBackgroundColor: navy.withValues(
                                alpha: 0.65,
                              ),
                              foregroundColor: Colors.white,
                              elevation: 3,
                              shadowColor: navy.withValues(alpha: 0.25),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.person_add_alt_1_rounded),
                                      SizedBox(width: 10),
                                      Text(
                                        'BUAT AKUN SEKARANG',
                                        style: TextStyle(
                                          fontSize: 14,
                                          letterSpacing: 0.5,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 23),

                        Row(
                          children: [
                            const Expanded(
                              child: Divider(color: Color(0xFFE5EAF2)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                'SUDAH PUNYA AKUN?',
                                style: TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.blueGrey.shade400,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(color: Color(0xFFE5EAF2)),
                            ),
                          ],
                        ),

                        const SizedBox(height: 17),

                        Center(
                          child: TextButton(
                            onPressed: _goToLogin,
                            style: TextButton.styleFrom(
                              foregroundColor: blue,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 10,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Login ke akunmu',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(width: 7),
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

              const Padding(
                padding: EdgeInsets.only(bottom: 22),
                child: Text(
                  'NEXPOOL • Nikmati pengalaman berenangmu',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF8995A8),
                    fontSize: 11,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
