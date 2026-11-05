import 'package:flutter/material.dart';

/// Warna & ThemeData untuk mode terang dan gelap NexPool.
class AppTheme {
  AppTheme._();

  // Terang (sama seperti tampilan NexPool sekarang)
  static const Color lightBg = Color(0xFFF5F8FC);
  static const Color lightCard = Colors.white;
  static const Color lightText = Color(0xFF172B4D);
  static const Color lightSoft = Color(0xFFEEF2F8);
  static const Color lightMutedText = Color(0xFF68778D);

  // Gelap
  static const Color darkBg = Color(0xFF101A2B);
  static const Color darkCard = Color(0xFF1A2A40);
  static const Color darkText = Color(0xFFE6EDF7);
  static const Color darkSoft = Color(0xFF263950);
  static const Color darkMutedText = Color(0xFFA8B5C8);

  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0077A8),
          brightness: Brightness.light,
        ).copyWith(
          surface: lightCard,
          onSurface: lightText,
          onSurfaceVariant: lightMutedText,
        ),
        scaffoldBackgroundColor: lightBg,
        cardColor: lightCard,
        canvasColor: lightBg,
        dividerColor: lightSoft,
        appBarTheme: const AppBarTheme(
          backgroundColor: lightCard,
          foregroundColor: lightText,
          surfaceTintColor: Colors.transparent,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: lightCard,
          surfaceTintColor: Colors.transparent,
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: lightCard,
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: lightSoft,
          hintStyle: const TextStyle(color: lightMutedText),
          labelStyle: const TextStyle(color: lightMutedText),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      );

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00B4D8),
          brightness: Brightness.dark,
        ).copyWith(
          primary: const Color(0xFF31C4DF),
          onPrimary: const Color(0xFF062532),
          secondary: const Color(0xFF80D9E8),
          surface: darkCard,
          onSurface: darkText,
          onSurfaceVariant: darkMutedText,
        ),
        scaffoldBackgroundColor: darkBg,
        cardColor: darkCard,
        canvasColor: darkBg,
        dividerColor: darkSoft,
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: darkCard,
          surfaceTintColor: Colors.transparent,
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: darkCard,
          surfaceTintColor: Colors.transparent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: darkBg,
          foregroundColor: darkText,
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: darkSoft,
          hintStyle: const TextStyle(color: darkMutedText),
          labelStyle: const TextStyle(color: darkMutedText),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide.none,
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: darkSoft,
          contentTextStyle: TextStyle(color: darkText),
        ),
      );
}

/// Warna yang otomatis menyesuaikan tema. Pakai di widget: context.cardBg, context.textMain, dst.
extension AppThemeContext on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Latar halaman
  Color get pageBg => Theme.of(this).scaffoldBackgroundColor;

  /// Latar kartu / kotak putih
  Color get cardBg => Theme.of(this).cardColor;

  /// Warna teks utama (judul, nama)
  Color get textMain => Theme.of(this).colorScheme.onSurface;

  /// Latar abu-abu lembut (tombol kecil, chip)
  Color get softBg => Theme.of(this).dividerColor;

  /// Teks sekunder dan metadata
  Color get mutedText => Theme.of(this).colorScheme.onSurfaceVariant;
}