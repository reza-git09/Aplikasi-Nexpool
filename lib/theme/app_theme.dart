import 'package:flutter/material.dart';

/// Warna & ThemeData untuk mode terang dan gelap NexPool.
class AppTheme {
  AppTheme._();

  // Terang (sama seperti tampilan NexPool sekarang)
  static const Color lightBg = Color(0xFFF5F8FC);
  static const Color lightCard = Colors.white;
  static const Color lightText = Color(0xFF172B4D);
  static const Color lightSoft = Color(0xFFEEF2F8);

  // Gelap
  static const Color darkBg = Color(0xFF0E1726);
  static const Color darkCard = Color(0xFF18263A);
  static const Color darkText = Color(0xFFE8EEF7);
  static const Color darkSoft = Color(0xFF263A57);

  static ThemeData get light => ThemeData(fontFamily: 'Roboto');

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: darkBg,
        cardColor: darkCard,
        canvasColor: darkBg,
        dividerColor: darkSoft,
        bottomSheetTheme: const BottomSheetThemeData(backgroundColor: darkCard),
        appBarTheme: const AppBarTheme(backgroundColor: darkBg, foregroundColor: darkText),
      );
}

/// Warna yang otomatis menyesuaikan tema. Pakai di widget: context.cardBg, context.textMain, dst.
extension AppThemeContext on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Latar halaman
  Color get pageBg => isDark ? AppTheme.darkBg : AppTheme.lightBg;

  /// Latar kartu / kotak putih
  Color get cardBg => isDark ? AppTheme.darkCard : AppTheme.lightCard;

  /// Warna teks utama (judul, nama)
  Color get textMain => isDark ? AppTheme.darkText : AppTheme.lightText;

  /// Latar abu-abu lembut (tombol kecil, chip)
  Color get softBg => isDark ? AppTheme.darkSoft : AppTheme.lightSoft;
}