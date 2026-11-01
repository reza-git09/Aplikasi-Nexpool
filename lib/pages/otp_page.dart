import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/otp_service.dart';

/// Halaman input kode OTP WhatsApp.
/// Mengembalikan otp_token (String) lewat Navigator.pop kalau verifikasi
/// berhasil, atau null kalau pengguna membatalkan.
class OtpPage extends StatefulWidget {
  final String noHp;
  final int initialResendIn;
  final int initialExpiresIn;
  final String? debugCode;

  const OtpPage({
    super.key,
    required this.noHp,
    this.initialResendIn = 60,
    this.initialExpiresIn = 300,
    this.debugCode,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  static const navy = Color(0xFF173F7A);
  static const blue = Color(0xFF2675D8);
  static const background = Color(0xFFF3F7FD);
  static const green = Color(0xFF16865B);

  final _controller = TextEditingController();
  final _focus = FocusNode();

  Timer? _timer;
  int _resendLeft = 0;
  int _expiresLeft = 0;

  bool _verifying = false;
  bool _resending = false;
  String? _error;
  String? _debugCode;

  @override
  void initState() {
    super.initState();
    _debugCode = widget.debugCode;
    _startTimers(widget.initialResendIn, widget.initialExpiresIn);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _startTimers(int resend, int expires) {
    _timer?.cancel();
    setState(() {
      _resendLeft = resend;
      _expiresLeft = expires;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_resendLeft > 0) _resendLeft--;
        if (_expiresLeft > 0) _expiresLeft--;
      });
    });
  }

  String get _maskedPhone {
    final p = widget.noHp.trim();
    if (p.length <= 7) return p;
    return '${p.substring(0, 4)}****${p.substring(p.length - 3)}';
  }

  String _mmss(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final r = (s % 60).toString().padLeft(2, '0');
    return '$m:$r';
  }

  Future<void> _verify() async {
    if (_verifying) return;

    final code = _controller.text.trim();
    if (code.length != 6) {
      setState(() => _error = 'Masukkan 6 digit kode OTP.');
      return;
    }

    setState(() {
      _verifying = true;
      _error = null;
    });

    try {
      final r = await OtpService.verify(widget.noHp, code);
      if (!mounted) return;

      if (r.token != null) {
        Navigator.pop(context, r.token);
        return;
      }

      setState(() => _error = r.error ?? 'Kode OTP salah.');
      _controller.clear();
      _focus.requestFocus();
    } finally {
      // Spinner SELALU berhenti, apa pun hasilnya
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _resend() async {
    if (_resendLeft > 0 || _resending) return;

    setState(() {
      _resending = true;
      _error = null;
    });

    try {
      final r = await OtpService.send(widget.noHp);
      if (!mounted) return;

      if (r.error != null) {
        setState(() => _error = r.error);
        if (r.resendIn > 0) _startTimers(r.resendIn, _expiresLeft);
        return;
      }

      _controller.clear();
      _debugCode = r.debugCode;
      _startTimers(r.resendIn, r.expiresIn);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Kode baru sudah dikirim ke WhatsApp.'),
          backgroundColor: green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool expired = _expiresLeft == 0;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded, color: navy),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: navy.withValues(alpha: 0.07),
                      blurRadius: 25,
                      offset: const Offset(0, 9),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: green.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mark_chat_read_rounded,
                        color: green,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Verifikasi Nomor HP',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: navy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kami mengirim kode 6 digit ke WhatsApp $_maskedPhone. '
                      'Masukkan kodenya di bawah ini.',
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        color: Color(0xFF8490A3),
                      ),
                    ),

                    if (_debugCode != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF6DB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Mode tes (WA belum dikirim sungguhan). Kode: $_debugCode',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF7A5B00),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 22),
                    TextField(
                      controller: _controller,
                      focusNode: _focus,
                      autofocus: true,
                      enabled: !_verifying,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 6,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 14,
                        color: navy,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '------',
                        hintStyle: TextStyle(
                          fontSize: 28,
                          letterSpacing: 14,
                          color: navy.withValues(alpha: 0.18),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFE),
                        contentPadding: const EdgeInsets.symmetric(vertical: 18),
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
                      onChanged: (v) {
                        if (_error != null) setState(() => _error = null);
                        if (v.length == 6) _verify(); // otomatis verifikasi
                      },
                    ),

                    if (_error != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _error!,
                        style: const TextStyle(
                          color: Color(0xFFD93645),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),
                    Text(
                      expired
                          ? 'Kode kedaluwarsa. Minta kode baru.'
                          : 'Kode berlaku ${_mmss(_expiresLeft)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: expired
                            ? const Color(0xFFD93645)
                            : const Color(0xFF8490A3),
                      ),
                    ),

                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: (_verifying || expired) ? null : _verify,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: navy,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _verifying
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'VERIFIKASI & DAFTAR',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.4,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    Center(
                      child: TextButton(
                        onPressed: (_resendLeft > 0 || _resending) ? null : _resend,
                        child: Text(
                          _resending
                              ? 'Mengirim...'
                              : _resendLeft > 0
                                  ? 'Kirim ulang kode dalam ${_resendLeft}s'
                                  : 'Kirim ulang kode',
                          style: const TextStyle(fontWeight: FontWeight.w700),
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
    );
  }
}