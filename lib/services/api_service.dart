import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // =========================================================
  // ALAMAT API LARAVEL
  // =========================================================

  static const String baseUrl = 'http://192.168.1.9:8000/api';
  static const Duration _timeout = Duration(seconds: 15);

  // =========================================================
  // HARGA DEFAULT / FALLBACK
  // =========================================================

  static const List<Map<String, dynamic>> _defaultHarga = [
    {
      'pool_id': 'pool_id_01',
      'kategori': 'Dewasa',
      'jenis_hari': 'weekday',
      'harga': '15000',
    },
    {
      'pool_id': 'pool_id_01',
      'kategori': 'Dewasa',
      'jenis_hari': 'weekend',
      'harga': '20000',
    },
    {
      'pool_id': 'pool_id_02',
      'kategori': 'Dewasa',
      'jenis_hari': 'weekday',
      'harga': '10000',
    },
    {
      'pool_id': 'pool_id_02',
      'kategori': 'Dewasa',
      'jenis_hari': 'weekend',
      'harga': '15000',
    },
    {
      'pool_id': 'pool_id_03',
      'kategori': 'Dewasa',
      'jenis_hari': 'weekday',
      'harga': '12000',
    },
    {
      'pool_id': 'pool_id_03',
      'kategori': 'Dewasa',
      'jenis_hari': 'weekend',
      'harga': '18000',
    },
    {
      'pool_id': 'pool_id_04',
      'kategori': 'Dewasa',
      'jenis_hari': 'weekday',
      'harga': '15000',
    },
    {
      'pool_id': 'pool_id_04',
      'kategori': 'Dewasa',
      'jenis_hari': 'weekend',
      'harga': '22000',
    },
    {
      'pool_id': 'pool_id_05',
      'kategori': 'Dewasa',
      'jenis_hari': 'weekday',
      'harga': '12000',
    },
    {
      'pool_id': 'pool_id_05',
      'kategori': 'Dewasa',
      'jenis_hari': 'weekend',
      'harga': '18000',
    },
  ];

  // =========================================================
  // HELPER RESPONSE JSON
  // =========================================================

  static Map<String, dynamic> _decodeResponse(http.Response response) {
    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Respons API tidak valid.');
    }

    return decoded;
  }

  // =========================================================
  // GET KOLAM RENANG
  // =========================================================

  static Future<List<dynamic>> getKolamRenang() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/kolam-renang'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = _decodeResponse(response);

        if (data['success'] == false) {
          throw Exception(data['message'] ?? 'Gagal mengambil data kolam.');
        }

        return List<dynamic>.from(data['data'] ?? []);
      }

      throw Exception(
        'Gagal mengambil data kolam. Status: ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('ERROR GET KOLAM: $e');
      rethrow;
    }
  }

  // =========================================================
  // GET HARGA TIKET
  // =========================================================

  static Future<List<dynamic>> getHargaTiket() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/harga-tiket'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = _decodeResponse(response);

        final List<dynamic> result = List<dynamic>.from(data['data'] ?? []);

        if (data['success'] == false || result.isEmpty) {
          return _defaultHarga;
        }

        return result;
      }

      return _defaultHarga;
    } catch (e) {
      debugPrint('ERROR GET HARGA TIKET: $e');
      return _defaultHarga;
    }
  }

  // =========================================================
  // GET SEMUA FASILITAS
  // =========================================================

  static Future<List<dynamic>> getFasilitas({String? poolId}) async {
    try {
      final uri = Uri.parse('$baseUrl/fasilitas').replace(
        queryParameters: poolId != null && poolId.trim().isNotEmpty
            ? {'pool_id': poolId}
            : null,
      );

      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(_timeout);

      debugPrint('GET FASILITAS: $uri');
      debugPrint('STATUS API FASILITAS: ${response.statusCode}');

      final data = _decodeResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
        return List<dynamic>.from(data['data'] ?? []);
      }

      throw Exception(data['message'] ?? 'Gagal mengambil data fasilitas.');
    } catch (e) {
      debugPrint('ERROR GET FASILITAS: $e');
      rethrow;
    }
  }

  // =========================================================
  // GET DETAIL FASILITAS BERDASARKAN ID
  // =========================================================

  static Future<Map<String, dynamic>> getFasilitasById(int id) async {
    try {
      final uri = Uri.parse('$baseUrl/fasilitas/$id');

      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(_timeout);

      final data = _decodeResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
        return Map<String, dynamic>.from(data['data'] ?? {});
      }

      throw Exception(data['message'] ?? 'Fasilitas tidak ditemukan.');
    } catch (e) {
      debugPrint('ERROR DETAIL FASILITAS: $e');
      rethrow;
    }
  }

  // =========================================================
  // GET SEMUA REVIEW
  // =========================================================

  static Future<List<dynamic>> getReviews() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/reviews'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = _decodeResponse(response);

        if (data['success'] == true) {
          return List<dynamic>.from(data['data'] ?? []);
        }

        throw Exception(data['message'] ?? 'Gagal mengambil data review.');
      }

      throw Exception('Gagal mengambil review. Status: ${response.statusCode}');
    } catch (e) {
      debugPrint('ERROR GET REVIEW: $e');
      rethrow;
    }
  }

  // =========================================================
  // GET REVIEW BERDASARKAN POOL
  // =========================================================

  static Future<List<dynamic>> getReviewsByPool(String poolId) async {
    try {
      final uri = Uri.parse('$baseUrl/reviews')
          .replace(queryParameters: {'pool_id': poolId});

      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = _decodeResponse(response);

        if (data['success'] == true) {
          return List<dynamic>.from(data['data'] ?? []);
        }

        throw Exception(data['message'] ?? 'Gagal mengambil review.');
      }

      throw Exception('Gagal mengambil review. Status: ${response.statusCode}');
    } catch (e) {
      debugPrint('ERROR GET REVIEW BY POOL: $e');
      rethrow;
    }
  }

  // =========================================================
  // SUBMIT REVIEW + FOTO
  // =========================================================

  static Future<Map<String, dynamic>> submitReview({
    required String poolId,
    required String namaPengunjung,
    required int rating,
    required String komentar,
    String? fotoPath,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/reviews');

      final request = http.MultipartRequest('POST', url);

      request.headers['Accept'] = 'application/json';

      request.fields['pool_id'] = poolId;
      request.fields['nama_pengunjung'] = namaPengunjung;
      request.fields['rating'] = rating.toString();
      request.fields['komentar'] = komentar;

      if (fotoPath != null && fotoPath.trim().isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('foto', fotoPath));
      }

      debugPrint('KIRIM REVIEW KE: $url');

      final streamedResponse = await request.send().timeout(_timeout);

      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('STATUS API REVIEW: ${response.statusCode}');
      debugPrint('RESPONSE API REVIEW: ${response.body}');

      final data = _decodeResponse(response);

      if (response.statusCode == 201 && data['success'] == true) {
        return data;
      }

      if (response.statusCode == 422) {
        throw Exception(data['message'] ?? 'Data review tidak valid.');
      }

      throw Exception(data['message'] ?? 'Gagal mengirim review.');
    } catch (e) {
      debugPrint('ERROR SUBMIT REVIEW: $e');
      rethrow;
    }
  }

  // =========================================================
  // CREATE RESERVASI
  // =========================================================

  static Future<Map<String, dynamic>> createReservasi({
    required String poolId,
    required String namaPengunjung,
    required String noHp,
    required String tanggalKunjungan,
    required int jumlahDewasa,
    required int jumlahAnak,
    required double totalHarga,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/reservasi');

      debugPrint('MENGIRIM RESERVASI: $url');

      final response = await http
          .post(
            url,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'pool_id': poolId,
              'nama_pengunjung': namaPengunjung,
              'no_hp': noHp,
              'tanggal_kunjungan': tanggalKunjungan,
              'jumlah_dewasa': jumlahDewasa,
              'jumlah_anak': jumlahAnak,
              'total_harga': totalHarga,
            }),
          )
          .timeout(_timeout);

      debugPrint('STATUS API RESERVASI: ${response.statusCode}');
      debugPrint('RESPONSE RESERVASI: ${response.body}');

      final data = _decodeResponse(response);

      if (response.statusCode == 201 && data['success'] == true) {
        return data;
      }

      if (response.statusCode == 422) {
        throw Exception(data['message'] ?? 'Data reservasi tidak valid.');
      }

      throw Exception(data['message'] ?? 'Gagal membuat reservasi.');
    } catch (e) {
      debugPrint('ERROR CREATE RESERVASI: $e');
      rethrow;
    }
  }

  // =========================================================
  // GET SEMUA RESERVASI
  // =========================================================

  static Future<List<dynamic>> getReservasi({String? poolId}) async {
    try {
      final uri = Uri.parse('$baseUrl/reservasi').replace(
        queryParameters: poolId != null && poolId.trim().isNotEmpty
            ? {'pool_id': poolId}
            : null,
      );

      debugPrint('GET RESERVASI: $uri');

      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(_timeout);

      debugPrint('STATUS GET RESERVASI: ${response.statusCode}');

      final data = _decodeResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
        return List<dynamic>.from(data['data'] ?? []);
      }

      throw Exception(data['message'] ?? 'Gagal mengambil data reservasi.');
    } catch (e) {
      debugPrint('ERROR GET RESERVASI: $e');
      rethrow;
    }
  }

  // =========================================================
  // GET DETAIL RESERVASI BERDASARKAN ID
  // =========================================================

  static Future<Map<String, dynamic>> getReservasiById(int id) async {
    try {
      final uri = Uri.parse('$baseUrl/reservasi/$id');

      debugPrint('GET DETAIL RESERVASI: $uri');

      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(_timeout);

      final data = _decodeResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
        return Map<String, dynamic>.from(data['data'] ?? {});
      }

      throw Exception(data['message'] ?? 'Reservasi tidak ditemukan.');
    } catch (e) {
      debugPrint('ERROR DETAIL RESERVASI: $e');
      rethrow;
    }
  }

  // =========================================================
  // GET RESERVASI BERDASARKAN KODE
  // =========================================================

  static Future<Map<String, dynamic>> getReservasiByKode(
    String kodeReservasi,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/reservasi/kode/$kodeReservasi');

      debugPrint('GET RESERVASI BY KODE: $uri');

      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(_timeout);

      final data = _decodeResponse(response);

      if (response.statusCode == 200 && data['success'] == true) {
        return Map<String, dynamic>.from(data['data'] ?? {});
      }

      throw Exception(data['message'] ?? 'Kode reservasi tidak ditemukan.');
    } catch (e) {
      debugPrint('ERROR RESERVASI BY KODE: $e');
      rethrow;
    }
  }
}
