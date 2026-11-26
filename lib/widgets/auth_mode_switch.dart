import 'package:flutter/material.dart';

import '../services/auth_service.dart';

/// Saklar untuk memilih mode auth:
///  - ON  = SQLite (lokal di HP, tanpa server)
///  - OFF = Backend (Laravel/MySQL lewat API)
/// Pilihan tersimpan di SharedPreferences lewat AuthService.
class AuthModeSwitch extends StatefulWidget {
  const AuthModeSwitch({super.key});

  @override
  State<AuthModeSwitch> createState() => _AuthModeSwitchState();
}

class _AuthModeSwitchState extends State<AuthModeSwitch> {
  bool _sqlite = true;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sqlite = await AuthService.isSqliteMode();
    if (!mounted) return;
    setState(() {
      _sqlite = sqlite;
      _loaded = true;
    });
  }

  Future<void> _toggle(bool value) async {
    setState(() => _sqlite = value);
    await AuthService.setAuthMode(
      value ? AuthService.modeSqlite : AuthService.modeApi,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();

    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      value: _sqlite,
      onChanged: _toggle,
      title: Text(
        _sqlite ? 'Mode: SQLite (lokal)' : 'Mode: Backend (server)',
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        _sqlite
            ? 'Register & login disimpan di HP, tanpa server.'
            : 'Register & login lewat server Laravel (butuh OTP).',
        style: const TextStyle(fontSize: 11.5),
      ),
    );
  }
}