import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Menyimpan foto profil PER AKUN dan membagikannya ke semua halaman
/// (Profil, Home, dll) lewat [photo].
///
/// Foto disimpan sebagai isi gambar (base64) di SharedPreferences,
/// bukan path file sementara, jadi tidak hilang walau cache dibersihkan,
/// dan tidak ikut terhapus saat logout. Tiap akun punya kunci sendiri.
class ProfilePhotoService {
  ProfilePhotoService._();

  /// Foto akun yang sedang login (null = belum ada foto / belum login).
  static final ValueNotifier<Uint8List?> photo = ValueNotifier<Uint8List?>(null);

  /// Kunci penyimpanan unik per akun (username -> email -> user_id).
  static Future<String> _key() async {
    final prefs = await SharedPreferences.getInstance();
    String id = '';
    for (final k in const ['user_username', 'user_email', 'user_id']) {
      final v = prefs.get(k)?.toString().trim() ?? '';
      if (v.isNotEmpty) {
        id = v;
        break;
      }
    }
    if (id.isEmpty) id = 'guest';
    return 'user_foto_b64_${id.toLowerCase()}';
  }

  /// Muat foto milik akun yang sedang login ke [photo].
  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(await _key());
      if (raw == null || raw.isEmpty) {
        photo.value = null;
        return;
      }
      photo.value = base64Decode(raw);
    } catch (_) {
      photo.value = null;
    }
  }

  /// Simpan foto baru untuk akun yang sedang login, lalu kabari semua halaman.
  static Future<void> save(Uint8List bytes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(await _key(), base64Encode(bytes));
    photo.value = bytes;
  }

  /// Kosongkan foto di memori saja (dipanggil saat logout).
  /// Foto di penyimpanan TIDAK dihapus, jadi muncul lagi saat login ulang.
  static void clearMemory() {
    photo.value = null;
  }
}