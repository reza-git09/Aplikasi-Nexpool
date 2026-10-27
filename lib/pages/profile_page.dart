import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const ProfilePage({super.key, this.userData});

  // Skema warna tema NexPool
  static const Color navy = Color(0xFF173F7A);
  static const Color blue = Color(0xFF2675D8);
  static const Color background = Color(0xFFF3F7FD);

  @override
  Widget build(BuildContext context) {
    // Membaca field dari database Laravel (mendukung nama kolom id/en)
    final String nama = userData?['nama'] ?? userData?['name'] ?? 'Pengguna NexPool';
    final String username = userData?['username'] ?? '-';
    final String email = userData?['email'] ?? '-';
    final String noHp = userData?['no_hp'] ?? userData?['phone'] ?? userData?['telepon'] ?? '-';
    final String alamat = userData?['alamat'] ?? userData?['address'] ?? '-';

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
                  onPressed: () {
                    // Arahkan kembali ke login dan hapus sesi layar sebelumnya
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  },
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: const Text(
                    'Keluar Akun',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
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