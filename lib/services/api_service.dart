import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Alamat API Laravel
  static const String baseUrl = 'http://192.168.1.202:8000/api';

  // Timeout request
  static const Duration _timeout = Duration(seconds: 10);

  // ==============================
  // Harga default (fallback lokal)
  // Digunakan jika server tidak bisa diakses
  // ==============================
  static const List<Map<String, dynamic>> _defaultHarga = [
    // Tiara Park — pool_id_01
    {'pool_id': 'pool_id_01', 'kategori': 'Dewasa', 'jenis_hari': 'weekday', 'harga': '15000'},
    {'pool_id': 'pool_id_01', 'kategori': 'Dewasa', 'jenis_hari': 'weekend', 'harga': '20000'},
    // Kebon Agung — pool_id_02
    {'pool_id': 'pool_id_02', 'kategori': 'Dewasa', 'jenis_hari': 'weekday', 'harga': '10000'},
    {'pool_id': 'pool_id_02', 'kategori': 'Dewasa', 'jenis_hari': 'weekend', 'harga': '15000'},
    // Annasya — pool_id_03
    {'pool_id': 'pool_id_03', 'kategori': 'Dewasa', 'jenis_hari': 'weekday', 'harga': '12000'},
    {'pool_id': 'pool_id_03', 'kategori': 'Dewasa', 'jenis_hari': 'weekend', 'harga': '18000'},
    // Dira Park — pool_id_04
    {'pool_id': 'pool_id_04', 'kategori': 'Dewasa', 'jenis_hari': 'weekday', 'harga': '15000'},
    {'pool_id': 'pool_id_04', 'kategori': 'Dewasa', 'jenis_hari': 'weekend', 'harga': '22000'},
    // Jati Park — pool_id_05
    {'pool_id': 'pool_id_05', 'kategori': 'Dewasa', 'jenis_hari': 'weekday', 'harga': '12000'},
    {'pool_id': 'pool_id_05', 'kategori': 'Dewasa', 'jenis_hari': 'weekend', 'harga': '18000'},
  ];

  // ==============================
  // Ambil data semua kolam renang
  // ==============================
  static Future<List<dynamic>> getKolamRenang() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/kolam-renang'))
          .timeout(_timeout);

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
  // Jika server tidak bisa diakses, gunakan harga default lokal
  // ==============================
  static Future<List<dynamic>> getHargaTiket() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/harga-tiket'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> result = data['data'] ?? [];

        // Jika data dari server kosong, gunakan harga default
        if (result.isEmpty) {
          return _defaultHarga;
        }

        return result;
      } else {
        // Server merespons tapi status bukan 200 → fallback
        return _defaultHarga;
      }
    } catch (e) {
      // Server tidak bisa diakses (timeout / no connection) → fallback
      return _defaultHarga;
    }
  }
}