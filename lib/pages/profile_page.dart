import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
import '../services/profile_photo_service.dart';

class ProfilePage extends StatefulWidget {
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

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  // ─── Skema Warna ───────────────────────────────────────────────
  static const Color navy = Color(0xFF173F7A);
  static const Color navyLight = Color(0xFF1E4D96);
  static const Color blue = Color(0xFF2675D8);
  static const Color blueAccent = Color(0xFF4A90E2);
  static const Color background = Color(0xFFF3F7FD);
  static const Color cardBg = Colors.white;
  static const Color textMuted = Color(0xFF8490A3);

  // ─── State ─────────────────────────────────────────────────────
  late TextEditingController _namaController;
  late TextEditingController _namaLengkapController;

  String _email = '';
  String _username = '';
  String _noHp = '';
  String _alamat = '';

  bool _isEditing = false;
  bool _isSaving = false;

  late AnimationController _headerAnim;
  late AnimationController _cardAnim;
  late Animation<double> _headerScale;
  late Animation<Offset> _cardSlide;
  late Animation<double> _cardFade;

  // ─── Init ──────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    _namaController = TextEditingController(
      text: _pick(['name', 'nama'], 'Pengguna NexPool'),
    );
    _namaLengkapController = TextEditingController(
      text: _pick([
        'full_name',
        'nama_lengkap',
        'name',
        'nama',
      ], 'Pengguna NexPool'),
    );

    _email = _pick(['email'], '-');
    _username = _pick(['username'], '-');
    _noHp = _pick(['no_hp', 'phone', 'telepon'], '-');
    _alamat = _pick(['alamat', 'address'], '-');

    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _cardAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _headerScale = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _headerAnim, curve: Curves.easeOutBack));
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardAnim, curve: Curves.easeOutCubic));
    _cardFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _cardAnim, curve: Curves.easeOut));

    _headerAnim.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _cardAnim.forward();
    });

    _loadSavedPhoto();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _namaLengkapController.dispose();
    _headerAnim.dispose();
    _cardAnim.dispose();
    super.dispose();
  }

  // ─── Helpers ───────────────────────────────────────────────────
  String _pick(List<String> keys, String fallback) {
    for (final k in keys) {
      final v = widget.userData?[k];
      if (v != null && v.toString().trim().isNotEmpty) {
        return v.toString();
      }
    }
    return fallback;
  }

  Future<void> _loadSavedPhoto() async {
    // Foto disimpan per akun & dibagikan ke Home lewat ProfilePhotoService
    await ProfilePhotoService.load();
  }

  Widget _avatarPlaceholder() {
    return Container(
      width: 96,
      height: 96,
      color: background,
      child: const Icon(Icons.person_rounded, size: 52, color: blue),
    );
  }

  // Tap foto: kalau sudah ada -> perbesar, kalau belum -> pilih foto
  Future<void> _onAvatarTap() async {
    final bytes = ProfilePhotoService.photo.value;
    if (bytes == null) {
      await _pickPhoto();
      return;
    }

    final bool? ganti = await Navigator.of(context).push<bool>(
      PageRouteBuilder<bool>(
        transitionDuration: const Duration(milliseconds: 240),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (_, __, ___) => _PhotoViewerPage(
          bytes: bytes,
          nama: _namaController.text.isNotEmpty
              ? _namaController.text
              : 'Pengguna NexPool',
        ),
        transitionsBuilder: (_, anim, __, child) {
          final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );

    if (ganti == true && mounted) await _pickPhoto();
  }

  // ─── Ambil Foto ────────────────────────────────────────────────
  Future<void> _pickPhoto() async {
    // 1. Tampilkan sheet pilih sumber
    final choice = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PhotoSourceSheet(),
    );

    if (choice == null || !mounted) return;

    // 2. Buka picker
    XFile? picked;
    try {
      picked = await ImagePicker().pickImage(
        source: choice,
        imageQuality: 75,
        maxWidth: 600,
      );
    } catch (e) {
      if (mounted) _showSnack('Gagal buka kamera/galeri: $e', isError: true);
      return;
    }

    if (picked == null || !mounted) return;

    // 3. Baca bytes via XFile.readAsBytes() — aman untuk content:// URI
    try {
      final bytes = await picked.readAsBytes();
      debugPrint('[ProfilePage] foto bytes: ${bytes.length}');

      if (bytes.isEmpty) {
        if (mounted) _showSnack('Foto kosong, coba pilih lagi.', isError: true);
        return;
      }

      if (!mounted) return;

      // Simpan isi foto per akun (tidak hilang saat logout / cache dibersihkan)
      // dan kabari Home supaya avatar di header ikut berubah.
      await ProfilePhotoService.save(bytes);

      if (!mounted) return;
      _showSnack('Foto profil berhasil diperbarui ✓');
    } catch (e) {
      debugPrint('[ProfilePage] ERROR foto: $e');
      if (mounted) _showSnack('Gagal memuat foto: $e', isError: true);
    }
  }

  // ─── Simpan Perubahan ──────────────────────────────────────────
  Future<void> _saveProfile() async {
    final newNama = _namaController.text.trim();
    final newNamaLengkap = _namaLengkapController.text.trim();

    if (newNama.isEmpty || newNamaLengkap.isEmpty) {
      _showSnack('Nama dan nama lengkap tidak boleh kosong.', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', newNama);
      await prefs.setString('user_nama_lengkap', newNamaLengkap);

      setState(() {
        _isEditing = false;
        _isSaving = false;
      });

      _showSnack('Profil berhasil diperbarui ✓');
    } catch (e) {
      setState(() => _isSaving = false);
      _showSnack('Gagal menyimpan profil.', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: isError
            ? const Color(0xFFEF476F)
            : const Color(0xFF2ECC71),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      ),
    );
  }

  // ─── Logout ────────────────────────────────────────────────────
  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Keluar Akun',
          style: TextStyle(fontWeight: FontWeight.bold, color: navy),
        ),
        content: const Text('Apakah kamu yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF476F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await AuthService.logout();

    if (widget.onLogout != null) {
      widget.onLogout!();
      return;
    }

    if (!context.mounted) return;
    Navigator.pop(context);
  }

  // ─── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Profil Saya',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: !widget.embedded,
        actions: [
          if (!_isEditing)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: () => setState(() => _isEditing = true),
                icon: const Icon(
                  Icons.edit_rounded,
                  size: 16,
                  color: Colors.white,
                ),
                label: const Text(
                  'Edit',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ── HEADER ──────────────────────────────────────────
            _buildHeader(),

            const SizedBox(height: 24),

            // ── KARTU INFO ──────────────────────────────────────
            FadeTransition(
              opacity: _cardFade,
              child: SlideTransition(
                position: _cardSlide,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Bisa diedit
                      _buildSectionCard(
                        title: 'Informasi Akun',
                        children: [
                          _buildEditableTile(
                            icon: Icons.badge_outlined,
                            label: 'Nama (Username Display)',
                            controller: _namaController,
                            editable: _isEditing,
                          ),
                          _buildDivider(),
                          _buildEditableTile(
                            icon: Icons.person_outline_rounded,
                            label: 'Nama Lengkap',
                            controller: _namaLengkapController,
                            editable: _isEditing,
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Tidak bisa diedit
                      _buildSectionCard(
                        title: 'Data Terdaftar',
                        subtitle: 'Tidak dapat diubah',
                        children: [
                          _buildReadOnlyTile(
                            icon: Icons.alternate_email_rounded,
                            label: 'Username',
                            value: _username,
                          ),
                          _buildDivider(),
                          _buildReadOnlyTile(
                            icon: Icons.email_outlined,
                            label: 'Email Terdaftar',
                            value: _email,
                            isLocked: true,
                          ),
                          _buildDivider(),
                          _buildReadOnlyTile(
                            icon: Icons.phone_outlined,
                            label: 'Nomor HP / WhatsApp',
                            value: _noHp,
                            isLocked: true,
                          ),
                          _buildDivider(),
                          _buildReadOnlyTile(
                            icon: Icons.location_on_outlined,
                            label: 'Alamat',
                            value: _alamat,
                            isLocked: true,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── TOMBOL SIMPAN / BATAL ────────────────
                      if (_isEditing) _buildEditActions(),

                      // ── TOMBOL LOGOUT ────────────────────────
                      if (!_isEditing) _buildLogoutBtn(),

                      SizedBox(height: widget.embedded ? 120 : 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────
  Widget _buildHeader() {
    return ScaleTransition(
      scale: _headerScale,
      child: Stack(
        children: [
          // Background gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 30,
              bottom: 36,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [navy, navyLight, Color(0xFF1F5BAA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
            child: Column(
              children: [
                // Avatar dengan tombol edit foto
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    // Ring / border — tap untuk memperbesar foto
                    GestureDetector(
                      onTap: _onAvatarTap,
                      child: Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [blueAccent, Color(0xFF74C0FC)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: blue.withOpacity(0.5),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(3),
                        child: ClipOval(
                          child: ValueListenableBuilder<Uint8List?>(
                            valueListenable: ProfilePhotoService.photo,
                            builder: (_, bytes, __) {
                              if (bytes == null) return _avatarPlaceholder();
                              return Image.memory(
                                bytes,
                                key: ValueKey(bytes.length),
                                width: 96,
                                height: 96,
                                fit: BoxFit.cover,
                                gaplessPlayback: true,
                                errorBuilder: (_, __, ___) =>
                                    _avatarPlaceholder(),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    // Tombol kamera
                    GestureDetector(
                      onTap: _pickPhoto,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [blue, blueAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: blue.withOpacity(0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Text(
                  _namaController.text.isNotEmpty
                      ? _namaController.text
                      : 'Pengguna NexPool',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '@$_username',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatChip(Icons.confirmation_number_outlined, 'Tiket'),
                    const SizedBox(width: 12),
                    _buildStatChip(Icons.star_outline_rounded, 'Ulasan'),
                    const SizedBox(width: 12),
                    _buildStatChip(Icons.shield_outlined, 'Member'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white.withOpacity(0.9)),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Section Card ──────────────────────────────────────────────
  Widget _buildSectionCard({
    required String title,
    String? subtitle,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: navy,
                    letterSpacing: 0.3,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: textMuted.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 10,
                        color: textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 6),
          ...children,
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  // ─── Editable Tile ─────────────────────────────────────────────
  Widget _buildEditableTile({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required bool editable,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          _buildIconBox(icon, active: editable),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                editable
                    ? TextFormField(
                        controller: controller,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: navy,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 0,
                          ),
                          border: InputBorder.none,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: blue.withOpacity(0.4),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: blue, width: 2),
                          ),
                          hintText: 'Masukkan $label...',
                          hintStyle: TextStyle(
                            color: textMuted.withOpacity(0.5),
                            fontSize: 13,
                          ),
                        ),
                      )
                    : Text(
                        controller.text.isNotEmpty ? controller.text : '-',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: navy,
                        ),
                      ),
              ],
            ),
          ),
          if (editable)
            Icon(
              Icons.edit_note_rounded,
              color: blue.withOpacity(0.6),
              size: 18,
            ),
        ],
      ),
    );
  }

  // ─── Read Only Tile ────────────────────────────────────────────
  Widget _buildReadOnlyTile({
    required IconData icon,
    required String label,
    required String value,
    bool isLocked = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildIconBox(icon, active: false),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? '-' : value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isLocked ? const Color(0xFF4A5568) : navy,
                  ),
                ),
              ],
            ),
          ),
          if (isLocked)
            Icon(
              Icons.lock_outline_rounded,
              size: 15,
              color: textMuted.withOpacity(0.5),
            ),
        ],
      ),
    );
  }

  Widget _buildIconBox(IconData icon, {required bool active}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        gradient: active
            ? const LinearGradient(
                colors: [blue, blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: active ? null : background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: active
            ? [BoxShadow(color: blue.withOpacity(0.3), blurRadius: 8)]
            : [],
      ),
      child: Icon(icon, color: active ? Colors.white : blue, size: 20),
    );
  }

  Widget _buildDivider() {
    return Divider(
      indent: 58,
      endIndent: 16,
      height: 1,
      color: navy.withOpacity(0.07),
    );
  }

  // ─── Edit Actions ──────────────────────────────────────────────
  Widget _buildEditActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() {
                  _isEditing = false;
                  // Reset ke nilai awal
                  _namaController.text = _pick([
                    'name',
                    'nama',
                  ], 'Pengguna NexPool');
                  _namaLengkapController.text = _pick([
                    'full_name',
                    'nama_lengkap',
                    'name',
                    'nama',
                  ], 'Pengguna NexPool');
                }),
                style: OutlinedButton.styleFrom(
                  foregroundColor: textMuted,
                  side: BorderSide(color: textMuted.withOpacity(0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Batal',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveProfile,
                style:
                    ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ).copyWith(
                      backgroundColor: WidgetStateProperty.resolveWith((
                        states,
                      ) {
                        if (states.contains(WidgetState.disabled)) {
                          return blue.withOpacity(0.5);
                        }
                        return blue;
                      }),
                    ),
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_rounded, size: 18),
                label: Text(
                  _isSaving ? 'Menyimpan...' : 'Simpan Perubahan',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildLogoutBtn(),
      ],
    );
  }

  // ─── Logout Button ─────────────────────────────────────────────
  Widget _buildLogoutBtn() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFEF476F),
          side: const BorderSide(color: Color(0xFFEF476F), width: 1.2),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () => _logout(context),
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: const Text(
          'Keluar Akun',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
    );
  }
}

// ================================================================
// BOTTOM SHEET PILIH SUMBER FOTO
// ================================================================
class _PhotoSourceSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Ganti Foto Profil',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF173F7A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pilih sumber foto',
            style: TextStyle(fontSize: 13, color: Color(0xFF8490A3)),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _SourceOption(
                    icon: Icons.photo_library_rounded,
                    label: 'Galeri',
                    color: const Color(0xFF2675D8),
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SourceOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Kamera',
                    color: const Color(0xFF173F7A),
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SourceOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// LAYAR PENUH: PERBESAR FOTO PROFIL
// ================================================================
class _PhotoViewerPage extends StatelessWidget {
  final Uint8List bytes;
  final String nama;

  const _PhotoViewerPage({required this.bytes, required this.nama});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        // Wajib expand: tanpa ini Stack hanya setinggi baris atas (X + nama)
        // dan foto/tombol jadi terjepit di atas layar.
        fit: StackFit.expand,
        children: [
          // Foto: cubit dua jari untuk zoom, tap area kosong untuk menutup
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.pop(context),
              child: Center(
                child: InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 5.0,
                  child: Image.memory(
                    bytes,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white54,
                      size: 64,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Tombol tutup + nama
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 6, 16, 0),
                child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              ),
            ),
          ),

          // Tombol ganti foto
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context, true),
                    icon: const Icon(Icons.camera_alt_rounded, size: 18),
                    label: const Text(
                      'Ganti Foto',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF173F7A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}