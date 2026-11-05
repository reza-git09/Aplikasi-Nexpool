import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/theme_service.dart';

/// Kartu kecil berisi switch Mode Gelap / Mode Terang.
/// Pilihan langsung berlaku dan disimpan lewat Shared Preferences (ThemeService).
class ThemeSwitchTile extends StatelessWidget {
  const ThemeSwitchTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.mode,
      builder: (context, mode, _) {
        final bool dark = mode == ThemeMode.dark;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 9)],
          ),
          child: SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
            secondary: Icon(
              dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: dark ? const Color(0xFFFFD166) : const Color(0xFF0077A8),
            ),
            title: Text(
              dark ? 'Mode Gelap' : 'Mode Terang',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: context.textMain),
            ),
            subtitle: const Text(
              'Pilihan tema tersimpan di HP',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
            value: dark,
            activeColor: const Color(0xFF00B4D8),
            onChanged: (bool value) => ThemeService.setDark(value),
          ),
        );
      },
    );
  }
}