
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _loginController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  // =====================================================
  // ALAMAT API LARAVEL
  // =====================================================

  static const String baseUrl =
      'http://192.168.1.36:8000/api';

  // =====================================================
  // LOGIN
  // =====================================================

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final login = _loginController.text.trim();
    final password = _passwordController.text;

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'login': login,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final responseData = jsonDecode(response.body);

      if (!mounted) return;

      // =====================================================
      // LOGIN BERHASIL
      // =====================================================

      if (response.statusCode == 200 &&
          responseData['success'] == true) {
        final data = responseData['data'];

        final prefs =
            await SharedPreferences.getInstance();

        await prefs.setBool(
          'is_logged_in',
          true,
        );

        await prefs.setInt(
          'user_id',
          data['id'],
        );

        await prefs.setString(
          'user_nama',
          data['nama'] ?? '',
        );

        await prefs.setString(
          'user_email',
          data['email'] ?? '',
        );

        await prefs.setString(
          'user_username',
          data['username'] ?? '',
        );

        await prefs.setString(
          'user_no_hp',
          data['no_hp'] ?? '',
        );

        await prefs.setString(
          'user_alamat',
          data['alamat'] ?? '',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login berhasil'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      } else {
        final message =
            responseData['message'] ??
                'Email/username atau password salah.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on http.ClientException {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tidak dapat terhubung ke server Laravel.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Terjadi kesalahan: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f9fc),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xff173f73),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Sign In',
          style: TextStyle(
            color: Color(0xff173f73),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [

                const SizedBox(height: 25),

                // =====================================================
                // LOGO
                // =====================================================

                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xffe3f2fd),
                    borderRadius:
                        BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.pool,
                    size: 45,
                    color: Color(0xff1597c7),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Selamat Datang di NEXPOOL',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff173f73),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Silakan masuk untuk melakukan pemesanan tiket.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 35),

                // =====================================================
                // EMAIL / USERNAME
                // =====================================================

                TextFormField(
                  controller: _loginController,
                  keyboardType:
                      TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email / Username',
                    hintText:
                        'Masukkan email atau username',
                    prefixIcon: const Icon(
                      Icons.person_outline,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Email atau username wajib diisi';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // =====================================================
                // PASSWORD
                // =====================================================

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Masukkan password',
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword =
                              !_obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Password wajib diisi';
                    }

                    if (value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 28),

                // =====================================================
                // TOMBOL SIGN IN
                // =====================================================

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed:
                        _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xff1597c7),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child:
                                CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // =====================================================
                // REGISTER
                // =====================================================

                GestureDetector(
                  onTap: () {
                    // Nanti diarahkan ke halaman Register
                  },
                  child: const Text(
                    'Belum memiliki akun? Daftar sekarang',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xff1597c7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
