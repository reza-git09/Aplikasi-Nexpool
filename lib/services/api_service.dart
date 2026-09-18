import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Untuk Android Emulator
  static const String baseUrl = 'http://172.20.10.13:8000/api';

  // Ambil data semua kolam renang
  static Future<List<dynamic>> getKolamRenang() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/kolam-renang'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data['data'] ?? [];
      } else {
        throw Exception(
          'Gagal mengambil data. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}