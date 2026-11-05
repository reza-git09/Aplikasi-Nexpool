import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Menyimpan dan membaca pilihan tema (terang / gelap) memakai Shared Preferences.
///
/// Alur:
/// 1. main() memanggil [load] -> membaca nilai 'darkMode' dari penyimpanan HP.
/// 2. MaterialApp mendengarkan [mode] lewat ValueListenableBuilder.
/// 3. Saat switch diubah, [setDark] mengganti tema langsung DAN menyimpannya
///    (prefs.setBool), jadi pilihan tetap ada walau aplikasi ditutup / dibuka lagi.
class ThemeService {
  ThemeService._();

  /// Kunci penyimpanan (sama seperti contoh di materi: "darkMode").
  static const String _key = 'darkMode';

  /// Tema yang sedang dipakai. Default terang.
  static final ValueNotifier<ThemeMode> mode = ValueNotifier<ThemeMode>(ThemeMode.light);

  static bool get isDark => mode.value == ThemeMode.dark;

  /// READ: ambil pilihan tema tersimpan. Kalau belum pernah disimpan (null) -> terang.
  static Future<void> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? darkMode = prefs.getBool(_key);
    mode.value = (darkMode ?? false) ? ThemeMode.dark : ThemeMode.light;
  }

  /// WRITE: ganti tema sekarang juga, lalu simpan ke Shared Preferences.
  static Future<void> setDark(bool value) async {
    mode.value = value ? ThemeMode.dark : ThemeMode.light;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }

  /// DELETE: hapus pilihan tersimpan (kembali ke tema terang).
  static Future<void> reset() async {
    mode.value = ThemeMode.light;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}