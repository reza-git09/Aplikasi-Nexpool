import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // =========================================================
  // ALAMAT API LARAVEL
  // =========================================================

  static const String baseUrl =
      'http://192.168.1.36:8000/api';

  static const Duration _timeout =
      Duration(seconds: 15);

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
  // GET KOLAM RENANG
  // =========================================================

  static Future<List<dynamic>> getKolamRenang() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/kolam-renang'),
            headers: {
              'Accept': 'application/json',
            },
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data['data'] ?? [];
      }

      throw Exception(
        'Gagal mengambil data kolam. '
        'Status: ${response.statusCode}',
      );
    } catch (e) {
      throw Exception(
        'Terjadi kesalahan: $e',
      );
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
            headers: {
              'Accept': 'application/json',
            },
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List<dynamic> result =
            data['data'] ?? [];

        if (result.isEmpty) {
          return _defaultHarga;
        }

        return result;
      }

      return _defaultHarga;
    } catch (e) {
      return _defaultHarga;
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
            headers: {
              'Accept': 'application/json',
            },
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          return data['data'] ?? [];
        }

        throw Exception(
          data['message'] ??
              'Gagal mengambil data review',
        );
      }

      throw Exception(
        'Gagal mengambil review. '
        'Status: ${response.statusCode}',
      );
    } catch (e) {
      throw Exception(
        'Terjadi kesalahan saat mengambil review: $e',
      );
    }
  }

  // =========================================================
  // GET REVIEW BERDASARKAN POOL
  // =========================================================

  static Future<List<dynamic>> getReviewsByPool(
    String poolId,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/reviews?pool_id=$poolId',
            ),
            headers: {
              'Accept': 'application/json',
            },
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          return data['data'] ?? [];
        }

        throw Exception(
          data['message'] ??
              'Gagal mengambil review',
        );
      }

      throw Exception(
        'Gagal mengambil review. '
        'Status: ${response.statusCode}',
      );
    } catch (e) {
      throw Exception(
        'Terjadi kesalahan saat mengambil review: $e',
      );
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
      final Uri url =
          Uri.parse('$baseUrl/reviews');

      // =====================================================
      // MULTIPART REQUEST
      // =====================================================

      final request = http.MultipartRequest(
        'POST',
        url,
      );

      request.headers['Accept'] =
          'application/json';

      // =====================================================
      // DATA TEXT
      // =====================================================

      request.fields['pool_id'] = poolId;

      request.fields['nama_pengunjung'] =
          namaPengunjung;

      request.fields['rating'] =
          rating.toString();

      request.fields['komentar'] =
          komentar;

      // =====================================================
      // UPLOAD FOTO
      // =====================================================

      if (fotoPath != null &&
          fotoPath.trim().isNotEmpty) {
        debugPrint(
          '========================================',
        );

        debugPrint(
          'MENYIAPKAN UPLOAD FOTO',
        );

        debugPrint(
          'PATH FOTO: $fotoPath',
        );

        final foto =
            await http.MultipartFile.fromPath(
          'foto',
          fotoPath,
        );

        request.files.add(foto);

        debugPrint(
          'FILE FOTO BERHASIL DITAMBAHKAN',
        );

        debugPrint(
          'JUMLAH FILE: ${request.files.length}',
        );

        debugPrint(
          '========================================',
        );
      } else {
        debugPrint(
          'TIDAK ADA FOTO YANG DIUPLOAD',
        );
      }

      // =====================================================
      // KIRIM REQUEST
      // =====================================================

      debugPrint(
        'KIRIM REVIEW KE: $url',
      );

      debugPrint(
        'JUMLAH FILE: ${request.files.length}',
      );

      final streamedResponse =
          await request
              .send()
              .timeout(_timeout);

      final response =
          await http.Response.fromStream(
        streamedResponse,
      );

      // =====================================================
      // DEBUG RESPONSE
      // =====================================================

      debugPrint(
        'STATUS API: ${response.statusCode}',
      );

      debugPrint(
        'RESPONSE API: ${response.body}',
      );

      // =====================================================
      // DECODE RESPONSE
      // =====================================================

      final dynamic decoded =
          jsonDecode(response.body);

      if (decoded
          is! Map<String, dynamic>) {
        throw Exception(
          'Response API tidak valid.',
        );
      }

      final Map<String, dynamic> data =
          decoded;

      // =====================================================
      // BERHASIL
      // =====================================================

      if (response.statusCode == 201 &&
          data['success'] == true) {
        return data;
      }

      // =====================================================
      // VALIDASI
      // =====================================================

      if (response.statusCode == 422) {
        throw Exception(
          data['message'] ??
              'Data review tidak valid.',
        );
      }

      // =====================================================
      // ERROR SERVER
      // =====================================================

      throw Exception(
        data['message'] ??
            'Gagal mengirim review.',
      );
    } catch (e) {
      debugPrint(
        'ERROR SUBMIT REVIEW: $e',
      );

      throw Exception(
        'Terjadi kesalahan saat mengirim review: $e',
      );
    }
  }
}