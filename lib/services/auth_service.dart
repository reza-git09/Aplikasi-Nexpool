
import 'dart:convert';

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
    required String username,
    required String name,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('is_logged_in', true);
    await prefs.setString('user_username', username);
    await prefs.setString('user_name', name);
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
  // =====================================================

  static Future<String?> register({
    required String name,
    required String email,
    required String username,
    required String password,
    required String noHp,
    required String alamat,
  }) async {
    lastError = '';

    try {
      final response = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/register'),
            headers: _headers,
            body: jsonEncode({
              'name': name.trim(),
              'email': email.trim(),
              'username': username.trim(),
              'password': password,
              'no_hp': noHp.trim(),
              'alamat': alamat.trim(),
            }),
          )
          .timeout(const Duration(seconds: 15));

      final body = _decodeResponse(response);

      if ((response.statusCode == 200 ||
              response.statusCode == 201) &&
          body['success'] == true) {
        return null;
      }

      lastError = _errorMessage(
        response,
        'Registrasi gagal.',
      );

      return lastError;
    } catch (e) {
      lastError =
          'Tidak bisa terhubung ke server Laravel. Periksa IP, server, dan jaringan.';
      return lastError;
    }
  }

  // =====================================================
  // LOGIN PENGUNJUNG
  // POST /api/login
  // =====================================================

  static Future<String?> verifyLogin(
    String username,
    String password,
  ) async {
    lastError = '';

    try {
      final response = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/login'),
            headers: _headers,
            body: jsonEncode({
              'login': username.trim(),
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final body = _decodeResponse(response);

      if (response.statusCode == 200 &&
          body['success'] == true &&
          body['data'] is Map) {
        final data = Map<String, dynamic>.from(
          body['data'] as Map,
        );

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
          (data['name'] ?? '').toString(),
        );

        await prefs.setString(
          'user_email',
          (data['email'] ?? '').toString(),
        );

        await prefs.setString(
          'user_username',
          (data['username'] ?? username).toString(),
        );

        await prefs.setString(
          'user_no_hp',
          (data['no_hp'] ?? '').toString(),
        );

        await prefs.setString(
          'user_alamat',
          (data['alamat'] ?? '').toString(),
        );

        // Controller Laravel saat ini belum mengirim token.
        await prefs.remove(_kToken);

        return (data['name'] ?? username).toString();
      }

      lastError = _errorMessage(
        response,
        'Username/email atau password salah.',
      );

      return null;
    } catch (e) {
      lastError =
          'Tidak bisa terhubung ke server Laravel. Periksa IP, server, dan jaringan.';
      return null;
    }
  }

  // =====================================================
  // BACA RESPONSE JSON
  // =====================================================

  static Map<String, dynamic> _decodeResponse(
    http.Response response,
  ) {
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

  static String _errorMessage(
    http.Response response,
    String fallback,
  ) {
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
