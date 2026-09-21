import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Alamat API Laravel
  static const String baseUrl = 'http://192.168.1.202:8000/api';

  // ==============================
  // Ambil data semua kolam renang
  // ==============================
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
          'Gagal mengambil data kolam. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // ==============================
  // Ambil data harga tiket
  // ==============================
  static Future<List<dynamic>> getHargaTiket() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/harga-tiket'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data['data'] ?? [];
      } else {
        throw Exception(
          'Gagal mengambil data harga tiket. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}