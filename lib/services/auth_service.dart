import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';

class AuthService {
  static const String _kToken = 'auth_token';

  static String lastError = '';

  static Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  // =====================================================
  // STATUS LOGIN
  // =====================================================

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool('is_logged_in') ?? false;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_kToken);

    return (token == null || token.isEmpty) ? null : token;
  }

  // =====================================================
  // SIMPAN STATUS LOGIN
  // =====================================================

  static Future<void> login({
    required String name,
    required String token,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('is_logged_in', true);
    await prefs.setString('user_name', name);
    await prefs.setString('user_nama_lengkap', name);
    await prefs.setString(_kToken, token);
  }

  // =====================================================
  // LOGOUT
  // =====================================================

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('is_logged_in');
    await prefs.remove('user_id');
    await prefs.remove('user_username');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_no_hp');
    await prefs.remove('user_alamat');
    await prefs.remove(_kToken);
  }

  // =====================================================
  // REGISTER PENGUNJUNG
  // POST /api/register
  // Return: null = sukses, String = pesan error
  // =====================================================

  static Future<String?> register({
    required String name,
    required String email,
    required String password,
    required String noHp,
    String? otpToken, // bukti verifikasi OTP WhatsApp (dari /otp/verify)
  }) async {
    lastError = '';

    try {
      final response = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/register'),
            headers: _headers,
            body: jsonEncode({
              'nama': name.trim(),
              'email': email.trim(),
              'password': password,
              'no_hp': noHp.trim(),
              'otp_token': ?otpToken,
            }),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('REGISTER STATUS: ${response.statusCode}');
      debugPrint('REGISTER BODY: ${response.body}');

      final body = _decodeResponse(response);

      // Sukses kalau status 200/201 dan backend tidak bilang success=false.
      // (Sebelumnya wajib success == true, padahal backend tidak
      // selalu mengirim key "success".)
      final bool statusOk =
          response.statusCode == 200 || response.statusCode == 201;
      final bool notFailed = body['success'] != false;

      if (statusOk && notFailed) {
        return null;
      }

      lastError = _errorMessage(response, 'Registrasi gagal.');

      return lastError;
    } catch (e) {
      debugPrint('REGISTER ERROR: $e');
      lastError = 'Tidak bisa terhubung ke server Laravel. Periksa IP, server, dan jaringan.';
      return lastError;
    }
  }

  // =====================================================
  // LOGIN PENGUNJUNG
  // POST /api/login
  // Return: nama user kalau sukses, null kalau gagal
  // =====================================================

  static Future<String?> verifyLogin(String identifier, String password) async {
    lastError = '';

    try {
      final response = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/login'),
            headers: _headers,
            body: jsonEncode({
              'login': identifier.trim(),
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('LOGIN STATUS: ${response.statusCode}');
      debugPrint('LOGIN BODY: ${response.body}');

      final body = _decodeResponse(response);

      // Data user bisa ada di body['data'] atau body['user'].
      Map<String, dynamic>? data;
      if (body['data'] is Map) {
        data = Map<String, dynamic>.from(body['data'] as Map);
      } else if (body['user'] is Map) {
        data = Map<String, dynamic>.from(body['user'] as Map);
      }

      if (response.statusCode == 200 &&
          body['success'] != false &&
          data != null) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setBool('is_logged_in', true);

        final id = data['id'];
        if (id is int) {
          await prefs.setInt('user_id', id);
        } else if (id != null) {
          final parsedId = int.tryParse(id.toString());
          if (parsedId != null) {
            await prefs.setInt('user_id', parsedId);
          }
        }

        await prefs.setString(
          'user_name',
          (data['nama'] ?? data['name'] ?? '').toString(),
        );
        await prefs.setString(
          'user_nama_lengkap',
          (data['nama'] ?? data['name'] ?? '').toString(),
        );

        await prefs.setString('user_email', (data['email'] ?? '').toString());

        await prefs.setString('user_no_hp', (data['no_hp'] ?? '').toString());
        final username = data['username']?.toString() ?? '';
        if (username.isNotEmpty) {
          await prefs.setString('user_username', username);
        } else {
          await prefs.remove('user_username');
        }

        final alamat = data['alamat']?.toString() ?? '';
        if (alamat.isNotEmpty) {
          await prefs.setString('user_alamat', alamat);
        } else {
          await prefs.remove('user_alamat');
        }

        // Simpan token kalau backend mengirimnya
        // (token bisa ada di body atau di dalam data).
        final dynamic token =
            body['token'] ?? body['access_token'] ?? data['token'];

        if (token != null && token.toString().isNotEmpty) {
          await prefs.setString(_kToken, token.toString());
        } else {
          await prefs.remove(_kToken);
        }

        return (data['nama'] ?? data['name'] ?? identifier).toString();
      }

      lastError = _errorMessage(
        response,
        'Email/nomor HP atau password salah.',
      );

      return null;
    } catch (e) {
      debugPrint('LOGIN ERROR: $e');
      lastError = 'Tidak bisa terhubung ke server Laravel. Periksa IP, server, dan jaringan.';
      return null;
    }
  }

  // =====================================================
  // LUPA PASSWORD - LANGKAH 1: CEK NOMOR HP
  // POST /api/check-account   { no_hp }
  // Return: true = akun ditemukan, false = tidak ada / gagal
  // (alasan gagal ada di AuthService.lastError)
  // =====================================================

  static Future<bool> checkPhoneExists(String noHp) async {
    lastError = '';

    try {
      final response = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/check-account'),
            headers: _headers,
            body: jsonEncode({'no_hp': noHp.trim()}),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('CHECK ACCOUNT STATUS: ${response.statusCode}');
      debugPrint('CHECK ACCOUNT BODY: ${response.body}');

      final body = _decodeResponse(response);

      final bool statusOk =
          response.statusCode == 200 || response.statusCode == 201;
      final bool notFailed = body['success'] != false;
      // Kalau backend mengirim penanda "exists"/"found", hormati itu.
      final bool notMissing = body['exists'] != false && body['found'] != false;

      if (statusOk && notFailed && notMissing) {
        return true;
      }

      lastError = _errorMessage(
        response,
        'Akun dengan nomor HP tersebut tidak ditemukan.',
      );

      return false;
    } catch (e) {
      debugPrint('CHECK ACCOUNT ERROR: $e');
      lastError = 'Tidak bisa terhubung ke server Laravel. Periksa IP, server, dan jaringan.';
      return false;
    }
  }

  // =====================================================
  // LUPA PASSWORD - LANGKAH 2: RESET PASSWORD
  // POST /api/reset-password
  // Return: null = sukses, String = pesan error
  // =====================================================

  static Future<String?> resetPassword({
    required String noHp,
    required String otpToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    lastError = '';

    try {
      final response = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/reset-password'),
            headers: _headers,
            body: jsonEncode({
              'no_hp': noHp.trim(),
              'otp_token': otpToken,
              'password': newPassword,
              'password_confirmation': confirmPassword,
            }),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('RESET PASSWORD STATUS: ${response.statusCode}');
      debugPrint('RESET PASSWORD BODY: ${response.body}');

      final body = _decodeResponse(response);

      final bool statusOk =
          response.statusCode == 200 || response.statusCode == 201;
      final bool notFailed = body['success'] != false;

      if (statusOk && notFailed) {
        return null;
      }

      lastError = _errorMessage(response, 'Gagal memperbarui password.');
      return lastError;
    } catch (e) {
      debugPrint('RESET PASSWORD ERROR: $e');
      lastError = 'Tidak bisa terhubung ke server Laravel. Periksa IP, server, dan jaringan.';
      return lastError;
    }
  }

  // =====================================================
  // BACA RESPONSE JSON
  // =====================================================

  static Map<String, dynamic> _decodeResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}

    return {};
  }

  // =====================================================
  // PESAN ERROR DARI LARAVEL
  // =====================================================

  static String _errorMessage(http.Response response, String fallback) {
    final body = _decodeResponse(response);

    final errors = body['errors'];

    if (errors is Map && errors.isNotEmpty) {
      final first = errors.values.first;

      if (first is List && first.isNotEmpty) {
        return first.first.toString();
      }
    }

    if (body['message'] != null) {
      return body['message'].toString();
    }

    return fallback;
  }
}
