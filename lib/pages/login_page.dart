
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

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
      // Memeriksa akun melalui API Laravel.
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
    } catch (e) {
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
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _bubble({
    required double size,
    double? left,
    double? right,
    required double top,
    required double progress,
  }) {
    final value = progress % 1.0;
    final offset = 12 * 
        (value < 0.5 ? value : 1 - value);

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
        color: Color(0xff234C68),
        fontSize: 13,
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
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xff9AAEBC),
          fontSize: 13,
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xff008ED6),
          size: 21,
        ),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xffDCEAF2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xffDCEAF2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xff008ED6),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4FAFF),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xff0077B6),
                  Color(0xff00AEEF),
                  Color(0xffF4FAFF),
                ],
                stops: [0.0, 0.40, 0.72],
              ),
            ),
          ),

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
                SizedBox(
                  height: 270,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 20,
                        top: 10,
                        child: Material(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(15),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () => Navigator.pop(context),
                            child: const SizedBox(
                              width: 45,
                              height: 45,
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 19,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 52,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 25,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.pool_rounded,
                                color: Color(0xff008ED6),
                                size: 43,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'NEXPOOL',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your swimming experience starts here',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.88),
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xffF8FCFF),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(38),
                        topRight: Radius.circular(38),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        25, 30, 25, 30,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 440,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Container(
                                  width: 42,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: const Color(0xffD7E6EF),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 27),

                              const Text(
                                'Selamat Datang 👋',
                                style: TextStyle(
                                  fontSize: 27,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xff123B5D),
                                  letterSpacing: -0.7,
                                ),
                              ),

                              const SizedBox(height: 7),

                              const Text(
                                'Masuk untuk melanjutkan perjalananmu\n'
                                'bersama NEXPOOL.',
                                style: TextStyle(
                                  color: Color(0xff718696),
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),

                              const SizedBox(height: 27),

                              _label('Username atau Email'),
                              const SizedBox(height: 9),

                              _input(
                                controller: usernameController,
                                hint: 'Masukkan username atau email',
                                icon: Icons.person_rounded,
                                textInputAction: TextInputAction.next,
                              ),

                              const SizedBox(height: 19),

                              _label('Password'),
                              const SizedBox(height: 9),

                              _input(
                                controller: passwordController,
                                hint: 'Masukkan password',
                                icon: Icons.lock_rounded,
                                obscureText: obscurePassword,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => login(),
                                suffix: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      obscurePassword = !obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    obscurePassword
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    color: const Color(0xff7B94A5),
                                    size: 21,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 27),

                              SizedBox(
                                width: double.infinity,
                                height: 58,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xff008ED6),
                                        Color(0xff00B4E8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(17),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xff00AEEF)
                                            .withOpacity(0.28),
                                        blurRadius: 18,
                                        offset: const Offset(0, 9),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      disabledBackgroundColor:
                                          Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(17),
                                      ),
                                    ),
                                    child: isLoading
                                        ? const SizedBox(
                                            width: 23,
                                            height: 23,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                            ),
                                          )
                                        : const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Masuk ke NEXPOOL',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15.5,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Icon(
                                                Icons.arrow_forward_rounded,
                                                color: Colors.white,
                                                size: 21,
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xffEAF8FF),
                                      Color(0xffF3FBFF),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(17),
                                  border: Border.all(
                                    color: const Color(0xffD3EFFB),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.verified_user_rounded,
                                      color: Color(0xff0099DD),
                                      size: 25,
                                    ),
                                    SizedBox(width: 11),
                                    Expanded(
                                      child: Text(
                                        'Gunakan akun yang sudah didaftarkan '
                                        'melalui halaman Registrasi NEXPOOL.',
                                        style: TextStyle(
                                          color: Color(0xff688091),
                                          fontSize: 12,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
