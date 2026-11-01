import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_service.dart';

class OtpSendResult {
  final String? error; // null = sukses
  final int resendIn; // detik sebelum boleh kirim ulang
  final int expiresIn; // detik masa berlaku kode
  final String? debugCode; // hanya ada saat server mode tes (OTP_DRIVER=log)

  const OtpSendResult({
    this.error,
    this.resendIn = 60,
    this.expiresIn = 300,
    this.debugCode,
  });
}

class OtpVerifyResult {
  final String? token; // bukti verifikasi untuk /register
  final String? error;

  const OtpVerifyResult({this.token, this.error});
}

class OtpService {
  static const Map<String, String> _headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  static Map<String, dynamic> _decode(http.Response r) {
    try {
      final d = jsonDecode(r.body);
      if (d is Map<String, dynamic>) return d;
    } catch (_) {}
    return <String, dynamic>{};
  }

  static String _message(Map<String, dynamic> body, String fallback) {
    final errors = body['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) return first.first.toString();
    }
    final msg = body['message'];
    if (msg is String && msg.trim().isNotEmpty) return msg;
    return fallback;
  }

  /// POST /api/otp/send
  static Future<OtpSendResult> send(String noHp) async {
    try {
      final r = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/otp/send'),
            headers: _headers,
            body: jsonEncode({'no_hp': noHp.trim()}),
          )
          .timeout(const Duration(seconds: 20));

      debugPrint('OTP SEND STATUS: ${r.statusCode}');
      debugPrint('OTP SEND BODY: ${r.body}');

      final body = _decode(r);

      if (r.statusCode == 200 && body['success'] != false) {
        return OtpSendResult(
          resendIn: (body['resend_in'] as num?)?.toInt() ?? 60,
          expiresIn: (body['expires_in'] as num?)?.toInt() ?? 300,
          debugCode: body['debug_code']?.toString(),
        );
      }

      return OtpSendResult(
        error: _message(body, 'Gagal mengirim kode OTP.'),
        resendIn: (body['retry_after'] as num?)?.toInt() ?? 0,
      );
    } catch (e) {
      debugPrint('OTP SEND ERROR: $e');
      return const OtpSendResult(
        error: 'Tidak bisa terhubung ke server. Periksa IP, server, dan jaringan.',
        resendIn: 0,
      );
    }
  }

  /// POST /api/otp/verify
  static Future<OtpVerifyResult> verify(String noHp, String code) async {
    try {
      final r = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/otp/verify'),
            headers: _headers,
            body: jsonEncode({'no_hp': noHp.trim(), 'code': code.trim()}),
          )
          .timeout(const Duration(seconds: 20));

      debugPrint('OTP VERIFY STATUS: ${r.statusCode}');
      debugPrint('OTP VERIFY BODY: ${r.body}');

      final body = _decode(r);
      final token = body['otp_token']?.toString();

      if (r.statusCode == 200 && body['success'] != false &&
          token != null && token.isNotEmpty) {
        return OtpVerifyResult(token: token);
      }

      return OtpVerifyResult(error: _message(body, 'Kode OTP salah.'));
    } catch (e) {
      debugPrint('OTP VERIFY ERROR: $e');
      return const OtpVerifyResult(
        error: 'Tidak bisa terhubung ke server. Periksa IP, server, dan jaringan.',
      );
    }
  }
}