import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class ProfilePage extends StatelessWidget {
  final Map<String, dynamic>? userData;

  // embedded = true kalau dipakai sebagai tab di navbar bawah
  final bool embedded;

  // Dipanggil setelah logout (dipakai saat embedded)
  final VoidCallback? onLogout;

  const ProfilePage({
    super.key,
    this.userData,
    this.embedded = false,
    this.onLogout,
  });

  // Skema warna tema NexPool
  static const Color navy = Color(0xFF173F7A);
  static const Color blue = Color(0xFF2675D8);
  static const Color background = Color(0xFFF3F7FD);

  String _pick(List<String> keys, String fallback) {
    for (final k in keys) {
      final v = userData?[k];
      if (v != null && v.toString().trim().isNotEmpty) {
        return v.toString();
      }
    }
    return fallback;
  }

  Future<void> _logout(BuildContext context) async {
    // Hapus sesi login dari HP
    await AuthService.logout();

    // Sebagai tab: kabari MainShell, dia yang pindah ke Home
    if (onLogout != null) {
      onLogout!();
      return;
    }

    if (!context.mounted) return;

    // Sebagai halaman biasa: kembali ke halaman sebelumnya
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final String nama = _pick(['nama', 'name'], 'Pengguna NexPool');
    final String username = _pick(['username'], '-');
    final String email = _pick(['email'], '-');
    final String noHp = _pick(['no_hp', 'phone', 'telepon'], '-');
    final String alamat = _pick(['alamat', 'address'], '-');

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Profil Saya',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: !embedded,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Header Avatar & Nama Pengguna
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: const BoxDecoration(
                color: navy,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 42,
                      backgroundColor: background,
                      child: const Icon(Icons.person_rounded, size: 50, color: blue),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    nama,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@$username',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Kartu Rincian Data Registrasi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Card(
                elevation: 1.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Column(
                    children: [
                      _buildInfoTile(
                        icon: Icons.person_outline_rounded,
                        label: 'Nama Lengkap',
                        value: nama,
                      ),
                      const Divider(indent: 20, endIndent: 20, height: 1),
                      _buildInfoTile(
                        icon: Icons.alternate_email_rounded,
                        label: 'Username',
                        value: username,
                      ),
                      const Divider(indent: 20, endIndent: 20, height: 1),
                      _buildInfoTile(
                        icon: Icons.email_outlined,
                        label: 'Email Terdaftar',
                        value: email,
                      ),
                      const Divider(indent: 20, endIndent: 20, height: 1),
                      _buildInfoTile(
                        icon: Icons.phone_outlined,
                        label: 'Nomor HP / WhatsApp',
                        value: noHp,
                      ),
                      const Divider(indent: 20, endIndent: 20, height: 1),
                      _buildInfoTile(
                        icon: Icons.location_on_outlined,
                        label: 'Alamat',
                        value: alamat,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Tombol Logout / Keluar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFEF476F),
                    side: const BorderSide(color: Color(0xFFEF476F), width: 1.2),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: const Text(
                    'Keluar Akun',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            ),

            // Ruang kosong supaya tidak tertutup navbar bawah
            SizedBox(height: embedded ? 120 : 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: blue, size: 22),
      ),
      title: Text(
        label,
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: navy,
        ),
      ),
    );
  }
}