import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static Database? _db;

  static Future<Database> get db async {
    _db ??= await openDatabase(
      join(await getDatabasesPath(), 'nexpool.db'),
      version: 1,
      onCreate: (db, version) => db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nama TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          no_hp TEXT NOT NULL UNIQUE,
          password_hash TEXT NOT NULL,
          salt TEXT NOT NULL
        )
      '''),
    );
    return _db!;
  }

  static String _hash(String password, String salt) =>
      sha256.convert(utf8.encode(password + salt)).toString();

  static String _newSalt() {
    final r = Random.secure();
    return base64Url.encode(List.generate(16, (_) => r.nextInt(256)));
  }

  /// REGISTER. Return null kalau sukses, atau pesan error (String).
  static Future<String?> register({
    required String nama,
    required String email,
    required String noHp,
    required String password,
  }) async {
    final database = await db;
    final emailClean = email.trim().toLowerCase();
    final hpClean = noHp.trim();

    final dupEmail = await database.query(
      'users',
      where: 'email = ?',
      whereArgs: [emailClean],
    );
    if (dupEmail.isNotEmpty) return 'Email sudah terdaftar.';

    final dupHp = await database.query(
      'users',
      where: 'no_hp = ?',
      whereArgs: [hpClean],
    );
    if (dupHp.isNotEmpty) return 'Nomor HP sudah terdaftar.';

    final salt = _newSalt();
    await database.insert('users', {
      'nama': nama.trim(),
      'email': emailClean,
      'no_hp': hpClean,
      'password_hash': _hash(password, salt),
      'salt': salt,
    });
    return null;
  }

  /// LOGIN pakai email ATAU no HP. Return data user, atau null kalau gagal.
  static Future<Map<String, dynamic>?> login(
    String identifier,
    String password,
  ) async {
    final database = await db;
    final id = identifier.trim();

    final rows = await database.query(
      'users',
      where: 'email = ? OR no_hp = ?',
      whereArgs: [id.toLowerCase(), id],
    );
    if (rows.isEmpty) return null;

    final user = rows.first;
    final ok = user['password_hash'] == _hash(password, user['salt'] as String);
    return ok ? user : null;
  }
}