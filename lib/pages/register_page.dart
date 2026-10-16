import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController namaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController noHpController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();

  bool passwordVisible = false;
  bool isLoading = false;

  @override
  void dispose() {
    namaController.dispose();
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

    final String? error = await AuthService.register(
      nama: namaController.text,
      email: emailController.text,
      username: usernameController.text,
      password: passwordController.text,
      noHp: noHpController.text,
      alamat: alamatController.text,
    );

    if (!mounted) return;
    setState(() => isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registrasi berhasil! Silakan login.'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Registrasi sukses -> lanjut ke Login
    await _goToLogin();
  }

  /// Buka halaman Login. Kalau login sukses (hasil true),
  /// tutup halaman Register dan kirim true ke pemanggil (TiketPage).
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

  InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF173F7A)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF173F7A),
          width: 2,
        ),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FC),

      appBar: AppBar(
        backgroundColor: const Color(0xFF173F7A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Register',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 10),

                const Center(
                  child: Icon(
                    Icons.pool,
                    size: 70,
                    color: Color(0xFF173F7A),
                  ),
                ),

                const SizedBox(height: 15),

                const Center(
                  child: Text(
                    'Buat Akun Nexpool',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF173F7A),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                const Center(
                  child: Text(
                    'Daftar dulu untuk bisa memesan tiket',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Nama
                TextFormField(
                  controller: namaController,
                  decoration: inputDecoration(
                    'Nama Lengkap',
                    Icons.person_outline,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama wajib diisi';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // Email
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: inputDecoration(
                    'Email',
                    Icons.email_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email wajib diisi';
                    }
                    if (!value.contains('@')) {
                      return 'Masukkan email yang valid';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // Username
                TextFormField(
                  controller: usernameController,
                  decoration: inputDecoration(
                    'Username',
                    Icons.account_circle_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Username wajib diisi';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // Password
                TextFormField(
                  controller: passwordController,
                  obscureText: !passwordVisible,
                  decoration: inputDecoration(
                    'Password',
                    Icons.lock_outline,
                  ).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color(0xFF173F7A),
                      ),
                      onPressed: () {
                        setState(() {
                          passwordVisible = !passwordVisible;
                        });
                      },
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

                const SizedBox(height: 15),

                // No HP
                TextFormField(
                  controller: noHpController,
                  keyboardType: TextInputType.phone,
                  decoration: inputDecoration(
                    'No. HP',
                    Icons.phone_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'No. HP wajib diisi';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // Alamat
                TextFormField(
                  controller: alamatController,
                  maxLines: 3,
                  decoration: inputDecoration(
                    'Alamat',
                    Icons.location_on_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Alamat wajib diisi';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 25),

                // Tombol Daftar
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : daftar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF173F7A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'DAFTAR',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // Link ke Login
                Center(
                  child: GestureDetector(
                    onTap: _goToLogin,
                    child: RichText(
                      text: const TextSpan(
                        text: 'Sudah mempunyai akun? ',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                        children: [
                          TextSpan(
                            text: 'Login',
                            style: TextStyle(
                              color: Color(0xFF173F7A),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}