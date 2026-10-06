  import 'dart:convert';

  import 'package:flutter/foundation.dart';
  import 'package:http/http.dart' as http;

  class ApiService {
    // =========================================================
    // ALAMAT API LARAVEL
    // =========================================================

    static const String baseUrl =
        'http://10.10.180.137:8000/api';


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

        final request = http.MultipartRequest(
          'POST',
          url,
        );

        request.headers['Accept'] =
            'application/json';

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

        debugPrint(
          'STATUS API: ${response.statusCode}',
        );

        debugPrint(
          'RESPONSE API: ${response.body}',
        );

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

        if (response.statusCode == 201 &&
            data['success'] == true) {
          return data;
        }

        if (response.statusCode == 422) {
          throw Exception(
            data['message'] ??
                'Data review tidak valid.',
          );
        }

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
        final Uri url =
            Uri.parse('$baseUrl/reservasi');

        debugPrint(
          '========================================',
        );

        debugPrint(
          'MENGIRIM RESERVASI',
        );

        debugPrint(
          'URL              : $url',
        );

        debugPrint(
          'POOL ID          : $poolId',
        );

        debugPrint(
          'NAMA             : $namaPengunjung',
        );

        debugPrint(
          'NO HP             : $noHp',
        );

        debugPrint(
          'TANGGAL           : $tanggalKunjungan',
        );

        debugPrint(
          'JUMLAH DEWASA     : $jumlahDewasa',
        );

        debugPrint(
          'JUMLAH ANAK       : $jumlahAnak',
        );

        debugPrint(
          'TOTAL HARGA       : $totalHarga',
        );

        debugPrint(
          '========================================',
        );

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

        debugPrint(
          'STATUS API RESERVASI: ${response.statusCode}',
        );

        debugPrint(
          'RESPONSE RESERVASI: ${response.body}',
        );

        final dynamic decoded =
            jsonDecode(response.body);

        if (decoded
            is! Map<String, dynamic>) {
          throw Exception(
            'Response API reservasi tidak valid.',
          );
        }

        final Map<String, dynamic> data =
            decoded;

        // =====================================================
        // BERHASIL
        // =====================================================

        if (response.statusCode == 201 &&
            data['success'] == true) {
          debugPrint(
            'RESERVASI BERHASIL DIBUAT',
          );

          return data;
        }

        // =====================================================
        // VALIDASI
        // =====================================================

        if (response.statusCode == 422) {
          throw Exception(
            data['message'] ??
                'Data reservasi tidak valid.',
          );
        }

        // =====================================================
        // ERROR LAIN
        // =====================================================

        throw Exception(
          data['message'] ??
              'Gagal membuat reservasi.',
        );
      } catch (e) {
        debugPrint(
          'ERROR CREATE RESERVASI: $e',
        );

        throw Exception(
          'Terjadi kesalahan saat membuat reservasi: $e',
        );
      }
    }

    // =========================================================
    // GET SEMUA RESERVASI
    // =========================================================

    static Future<List<dynamic>> getReservasi({
      String? poolId,
    }) async {
      try {
        String url =
            '$baseUrl/reservasi';

        if (poolId != null &&
            poolId.trim().isNotEmpty) {
          url += '?pool_id=$poolId';
        }

        debugPrint(
          'GET RESERVASI: $url',
        );

        final response = await http
            .get(
              Uri.parse(url),
              headers: {
                'Accept': 'application/json',
              },
            )
            .timeout(_timeout);

        debugPrint(
          'STATUS GET RESERVASI: ${response.statusCode}',
        );

        debugPrint(
          'RESPONSE GET RESERVASI: ${response.body}',
        );

        final dynamic decoded =
            jsonDecode(response.body);

        if (decoded
            is! Map<String, dynamic>) {
          throw Exception(
            'Response API reservasi tidak valid.',
          );
        }

        final Map<String, dynamic> data =
            decoded;

        if (response.statusCode == 200 &&
            data['success'] == true) {
          return data['data'] ?? [];
        }

        throw Exception(
          data['message'] ??
              'Gagal mengambil data reservasi.',
        );
      } catch (e) {
        debugPrint(
          'ERROR GET RESERVASI: $e',
        );

        throw Exception(
          'Terjadi kesalahan saat mengambil reservasi: $e',
        );
      }
    }

    // =========================================================
    // GET DETAIL RESERVASI BERDASARKAN ID
    // =========================================================

    static Future<Map<String, dynamic>> getReservasiById(
      int id,
    ) async {
      try {
        final Uri url =
            Uri.parse('$baseUrl/reservasi/$id');

        debugPrint(
          'GET DETAIL RESERVASI: $url',
        );

        final response = await http
            .get(
              url,
              headers: {
                'Accept': 'application/json',
              },
            )
            .timeout(_timeout);

        debugPrint(
          'STATUS DETAIL RESERVASI: ${response.statusCode}',
        );

        debugPrint(
          'RESPONSE DETAIL RESERVASI: ${response.body}',
        );

        final dynamic decoded =
            jsonDecode(response.body);

        if (decoded
            is! Map<String, dynamic>) {
          throw Exception(
            'Response detail reservasi tidak valid.',
          );
        }

        final Map<String, dynamic> data =
            decoded;

        if (response.statusCode == 200 &&
            data['success'] == true) {
          return Map<String, dynamic>.from(
            data['data'] ?? {},
          );
        }

        throw Exception(
          data['message'] ??
              'Reservasi tidak ditemukan.',
        );
      } catch (e) {
        debugPrint(
          'ERROR DETAIL RESERVASI: $e',
        );

        throw Exception(
          'Terjadi kesalahan saat mengambil detail reservasi: $e',
        );
      }
    }

    // =========================================================
    // GET RESERVASI BERDASARKAN KODE
    // =========================================================

    static Future<Map<String, dynamic>> getReservasiByKode(
      String kodeReservasi,
    ) async {
      try {
        final Uri url =
            Uri.parse(
          '$baseUrl/reservasi/kode/$kodeReservasi',
        );

        debugPrint(
          'GET RESERVASI BY KODE: $url',
        );

        final response = await http
            .get(
              url,
              headers: {
                'Accept': 'application/json',
              },
            )
            .timeout(_timeout);

        debugPrint(
          'STATUS RESERVASI BY KODE: ${response.statusCode}',
        );

        debugPrint(
          'RESPONSE RESERVASI BY KODE: ${response.body}',
        );

        final dynamic decoded =
            jsonDecode(response.body);

        if (decoded
            is! Map<String, dynamic>) {
          throw Exception(
            'Response reservasi tidak valid.',
          );
        }

        final Map<String, dynamic> data =
            decoded;

        if (response.statusCode == 200 &&
            data['success'] == true) {
          return Map<String, dynamic>.from(
            data['data'] ?? {},
          );
        }

        throw Exception(
          data['message'] ??
              'Kode reservasi tidak ditemukan.',
        );
      } catch (e) {
        debugPrint(
          'ERROR RESERVASI BY KODE: $e',
        );

        throw Exception(
          'Terjadi kesalahan saat mencari reservasi: $e',
        );
      }
    }
  }