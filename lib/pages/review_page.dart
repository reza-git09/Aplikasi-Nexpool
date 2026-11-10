import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';

import 'home_page.dart';
import 'login_page.dart';

class ReviewPage extends StatefulWidget {
  // =========================================================
  // DATA KOLAM YANG DIPILIH
  // =========================================================

  final String? poolId;
  final String? namaKolam;
  final String? gambarKolam;
  final int sessionTick;
  final Future<void> Function()? onSessionChanged;

  const ReviewPage({
    super.key,
    this.poolId,
    this.namaKolam,
    this.gambarKolam,
    this.sessionTick = 0,
    this.onSessionChanged,
  });

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  // =========================================================
  // RATING
  // =========================================================

  int overallRating = 0;

  // =========================================================
  // KOMENTAR
  // =========================================================

  final TextEditingController commentController = TextEditingController();

  // =========================================================
  // FOTO
  // =========================================================

  final ImagePicker imagePicker = ImagePicker();

  final List<XFile> selectedPhotos = [];

  // =========================================================
  // REVIEW LOKAL YANG BARU DIKIRIM
  // =========================================================

  final List<ReviewData> newlyUploadedReviews = [];

  // =========================================================
  // REVIEW DARI API
  // =========================================================

  List<dynamic> reviewsFromApi = [];

  bool isLoadingReviews = true;
  bool isSendingReview = false;
  bool isCheckingReviewAccount = true;
  bool hasSubmittedReview = false;
  String? reviewAccountKey;
  String? reviewerName;
  int? reviewerId;

  // =========================================================
  // CEK KOLAM
  // =========================================================

  bool get hasSelectedPool {
    // Cukup namaKolam yang wajib ada agar halaman ulasan bisa dibuka.
    // poolId boleh kosong — API mungkin belum selesai load saat navigasi.
    return widget.namaKolam != null && widget.namaKolam!.trim().isNotEmpty;
  }

  // poolId efektif yang dipakai untuk request API
  String get effectivePoolId {
    if (widget.poolId != null && widget.poolId!.trim().isNotEmpty) {
      return widget.poolId!.trim();
    }
    // Fallback: gunakan namaKolam sebagai identifier
    return widget.namaKolam?.trim() ?? '';
  }

  // =========================================================
  // INIT STATE
  // =========================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (hasSelectedPool && mounted) {
        await _loadReviewAccount();
        if (mounted) loadReviews();
      }
    });
  }

  @override
  void didUpdateWidget(covariant ReviewPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sessionTick != widget.sessionTick) {
      _loadReviewAccount().then((_) {
        if (mounted) loadReviews();
      });
    }
  }

  String _reviewSubmissionKey(String accountKey) {
    final value = base64Url.encode(utf8.encode('$accountKey|$effectivePoolId'));
    return 'review_submitted_$value';
  }

  Future<void> _loadReviewAccount() async {
    if (mounted) {
      setState(() {
        isCheckingReviewAccount = true;
      });
    }

    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('is_logged_in') ?? false;
    final userId = prefs.get('user_id')?.toString();
    final username = prefs.getString('user_username')?.trim() ?? '';
    final email = prefs.getString('user_email')?.trim() ?? '';
    final name = prefs.getString('user_name')?.trim() ?? '';
    final identifier = userId?.isNotEmpty == true
        ? 'id:$userId'
        : username.isNotEmpty
        ? 'username:${username.toLowerCase()}'
        : email.isNotEmpty
        ? 'email:${email.toLowerCase()}'
        : null;

    if (!mounted) return;

    final hasReviewed =
        loggedIn &&
        identifier != null &&
        (prefs.getBool(_reviewSubmissionKey(identifier)) ?? false);

    setState(() {
      reviewerId = int.tryParse(userId ?? '');
      reviewAccountKey = loggedIn ? identifier : null;
      reviewerName = name.isNotEmpty
          ? name
          : username.isNotEmpty
          ? username
          : null;
      hasSubmittedReview = hasReviewed;
      isCheckingReviewAccount = false;
    });
  }

  Future<void> _openLogin() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
    if (widget.onSessionChanged != null) {
      await widget.onSessionChanged!();
      return;
    }
    await _loadReviewAccount();
    if (mounted) loadReviews();
  }

  bool _apiContainsReviewForAccount(
    List<dynamic> reviews, {
    required String accountKey,
    required int? accountId,
  }) {
    for (final review in reviews) {
      if (review is! Map) continue;

      final reviewUserId =
          review['user_id'] ??
          review['pengunjung_id'] ??
          review['id_pengunjung'];
      if (accountId != null &&
          reviewUserId != null &&
          reviewUserId.toString() == accountId.toString()) {
        return true;
      }

      final username = review['username']?.toString().trim().toLowerCase();
      final email = review['email']?.toString().trim().toLowerCase();
      if (accountKey.startsWith('username:') &&
          username == accountKey.substring('username:'.length)) {
        return true;
      }
      if (accountKey.startsWith('email:') &&
          email == accountKey.substring('email:'.length)) {
        return true;
      }
    }

    return false;
  }

  // =========================================================
  // AMBIL REVIEW DARI API
  // =========================================================

  Future<void> loadReviews() async {
    if (effectivePoolId.isEmpty) {
      return;
    }

    if (mounted) {
      setState(() {
        isLoadingReviews = true;
      });
    }

    try {
      final accountKey = reviewAccountKey;
      final accountId = reviewerId;
      final data = await ApiService.getReviewsByPool(effectivePoolId);

      if (!mounted) return;

      final accountIsUnchanged = accountKey == reviewAccountKey;
      final hasRemoteReview =
          accountIsUnchanged &&
          accountKey != null &&
          _apiContainsReviewForAccount(
            data,
            accountKey: accountKey,
            accountId: accountId,
          );
      if (hasRemoteReview) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_reviewSubmissionKey(accountKey), true);
      }

      if (!mounted) return;

      setState(() {
        reviewsFromApi = data;
        isLoadingReviews = false;
        hasSubmittedReview = hasSubmittedReview || hasRemoteReview;
      });

      debugPrint('========================================');
      debugPrint('REVIEW BERHASIL DIAMBIL');
      debugPrint('POOL ID: $effectivePoolId');
      debugPrint('JUMLAH REVIEW: ${reviewsFromApi.length}');
      debugPrint('========================================');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingReviews = false;
      });

      debugPrint('ERROR LOAD REVIEW: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil review: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  // =========================================================
  // PILIH FOTO
  // =========================================================

  Future<void> pickPhotos() async {
    try {
      final List<XFile> images = await imagePicker.pickMultiImage(
        imageQuality: 80,
      );

      if (images.isEmpty) {
        return;
      }

      final int remaining = 5 - selectedPhotos.length;

      if (remaining <= 0) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maksimal 5 foto yang dapat dipilih.'),
            behavior: SnackBarBehavior.floating,
          ),
        );

        return;
      }

      final List<XFile> photosToAdd = images.take(remaining).toList();

      setState(() {
        selectedPhotos.addAll(photosToAdd);
      });

      debugPrint('========================================');
      debugPrint('FOTO DIPILIH');
      debugPrint('JUMLAH FOTO: ${selectedPhotos.length}');

      for (int i = 0; i < selectedPhotos.length; i++) {
        debugPrint('FOTO ${i + 1}: ${selectedPhotos[i].path}');
      }

      debugPrint('========================================');

      if (images.length > remaining && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maksimal 5 foto yang dapat dipilih.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      debugPrint('ERROR PILIH FOTO: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memilih foto.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // =========================================================
  // HAPUS FOTO
  // =========================================================

  void removePhoto(int index) {
    if (index < 0 || index >= selectedPhotos.length) {
      return;
    }

    setState(() {
      selectedPhotos.removeAt(index);
    });

    debugPrint('FOTO DIHAPUS. SISA FOTO: ${selectedPhotos.length}');
  }

  // =========================================================
  // KIRIM ULASAN KE LARAVEL
  // =========================================================

  Future<void> submitReview() async {
    final String comment = commentController.text.trim();
    final String? submittingAccountKey = reviewAccountKey;
    final String submittingName = reviewerName ?? 'Pengunjung';

    if (submittingAccountKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan login untuk memberikan ulasan.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (hasSubmittedReview) {
      _showAlreadyReviewedMessage();
      return;
    }

    // =======================================================
    // VALIDASI RATING
    // =======================================================

    if (overallRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih rating bintang terlebih dahulu.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    // =======================================================
    // VALIDASI KOMENTAR
    // =======================================================

    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan tulis komentar terlebih dahulu.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    // =======================================================
    // VALIDASI POOL ID
    // =======================================================

    if (effectivePoolId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID kolam tidak ditemukan.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    // =======================================================
    // CEGAH KIRIM BERULANG
    // =======================================================

    if (isSendingReview) {
      return;
    }

    setState(() {
      isSendingReview = true;
    });

    try {
      // =====================================================
      // FOTO PERTAMA YANG DIKIRIM
      // =====================================================

      final XFile? fotoUtama =
          selectedPhotos.isNotEmpty ? selectedPhotos.first : null;

      // =====================================================
      // DEBUG SEBELUM KIRIM
      // =====================================================

      debugPrint('========================================');

      debugPrint('MENGIRIM REVIEW');

      debugPrint('POOL ID       : $effectivePoolId');

      debugPrint('NAMA          : $submittingName');

      debugPrint('RATING        : $overallRating');

      debugPrint('KOMENTAR      : $comment');

      debugPrint('JUMLAH FOTO   : ${selectedPhotos.length}');

      debugPrint('FOTO NAMA     : ${fotoUtama?.name}');

      debugPrint('========================================');

      // =====================================================
      // KIRIM KE API
      // =====================================================

      final Map<String, dynamic> result = await ApiService.submitReview(
        poolId: effectivePoolId,
        namaPengunjung: submittingName,
        rating: overallRating,
        komentar: comment,
        foto: fotoUtama,
      );

      if (!mounted) return;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_reviewSubmissionKey(submittingAccountKey), true);

      // =====================================================
      // SIMPAN REVIEW LOKAL
      // =====================================================

      final ReviewData newReview = ReviewData(
        name: submittingName,
        date: 'Baru saja',
        poolName: widget.namaKolam ?? 'Kolam Renang',
        rating: overallRating,
        comment: comment,

        // Simpan semua foto untuk tampilan lokal.
        // Yang dikirim ke server hanya foto pertama.
        photoPaths: selectedPhotos.map((photo) => photo.path).toList(),
      );

      setState(() {
        newlyUploadedReviews.insert(0, newReview);

        overallRating = 0;

        commentController.clear();

        selectedPhotos.clear();

        isSendingReview = false;
        hasSubmittedReview = reviewAccountKey == submittingAccountKey;
      });

      // =====================================================
      // AMBIL ULANG REVIEW DARI LARAVEL
      // =====================================================

      await loadReviews();

      if (!mounted) return;

      // =====================================================
      // PESAN BERHASIL
      // =====================================================

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message']?.toString() ?? 'Ulasan berhasil dikirim.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSendingReview = false;
      });

      debugPrint('========================================');

      debugPrint('ERROR KIRIM REVIEW');

      debugPrint('$e');

      debugPrint('========================================');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim ulasan: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showAlreadyReviewedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Akun ini sudah memberikan ulasan untuk kolam renang ini.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildReviewEntry() {
    if (isCheckingReviewAccount || isLoadingReviews) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (reviewAccountKey == null) {
      return _reviewNotice(
        icon: Icons.lock_outline_rounded,
        title: 'Login untuk memberi ulasan',
        message:
            'Silakan masuk ke akun Anda. Setiap akun hanya dapat mengulas kolam ini satu kali.',
        actionLabel: 'Login',
        onAction: _openLogin,
      );
    }

    if (hasSubmittedReview) {
      return _reviewNotice(
        icon: Icons.verified_rounded,
        title: 'Ulasan sudah dikirim',
        message:
            'Akun Anda sudah memberikan rating dan ulasan untuk ${widget.namaKolam}. Setiap akun hanya dapat mengulas satu kali.',
      );
    }

    return reviewForm();
  }

  Widget _reviewNotice({
    required IconData icon,
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xff0077A8), size: 23),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: context.textMain,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: TextStyle(
                    color: context.mutedText,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 10),
                  TextButton(onPressed: onAction, child: Text(actionLabel)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    // =======================================================
    // JIKA BELUM PILIH KOLAM
    // =======================================================

    if (!hasSelectedPool) {
      return Scaffold(
        backgroundColor: context.pageBg,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: context.softBg,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      Icons.lock_outline,
                      size: 40,
                      color: context.isDark
                          ? const Color(0xFF80D9E8)
                          : const Color(0xFF0077A8),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Pilih Kolam Renang Terlebih Dahulu',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: context.textMain,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Anda harus memilih kolam renang terlebih dahulu sebelum memberikan ulasan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.mutedText,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0077A8),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Kembali ke Home',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // =======================================================
    // HALAMAN REVIEW
    // =======================================================

    return Scaffold(
      backgroundColor: context.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            // =================================================
            // HEADER
            // =================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0077A8), Color(0xFF00B4D8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Beri Ulasan',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Bagikan pengalaman kunjungan Anda',
                          style: TextStyle(fontSize: 13, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // =================================================
            // CONTENT
            // =================================================
            Expanded(
              child: RefreshIndicator(
                onRefresh: loadReviews,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 16, bottom: 20),
                  child: Column(
                    children: [
                      selectedPoolCard(),

                      const SizedBox(height: 18),

                      _buildReviewEntry(),

                      const SizedBox(height: 24),

                      apiReviewSection(),

                      const SizedBox(height: 24),

                      newlyUploadedSection(),

                      const SizedBox(
                        height: 88, // Clearance for floating bubble navbar
                      ),
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

  // ===========================================================
  // CARD KOLAM
  // ===========================================================

  Widget selectedPoolCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F7FA),
              borderRadius: BorderRadius.circular(14),
            ),
            clipBehavior: Clip.antiAlias,
            child: buildPoolImage(),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Anda akan mengulas',
                  style: TextStyle(fontSize: 11, color: context.mutedText),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.namaKolam!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: context.textMain,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.pool, size: 14, color: Color(0xFF00B4D8)),
                    const SizedBox(width: 4),
                    Text(
                      'Kolam Renang',
                      style: TextStyle(fontSize: 11, color: context.mutedText),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // GAMBAR KOLAM
  // ===========================================================

  Widget buildPoolImage() {
    if (widget.gambarKolam == null || widget.gambarKolam!.trim().isEmpty) {
      return const Icon(Icons.pool, size: 32, color: Color(0xFF00B4D8));
    }

    final String image = widget.gambarKolam!;

    if (image.startsWith('http')) {
      return Image.network(
        image,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.pool, size: 32, color: Color(0xFF00B4D8));
        },
      );
    }

    return Image.asset(
      image,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.pool, size: 32, color: Color(0xFF00B4D8));
      },
    );
  }

  // ===========================================================
  // GAMBAR FOTO YANG DIPILIH (WEB + MOBILE)
  // ===========================================================

  Widget buildPickedImage(
    String path, {
    required double width,
    required double height,
  }) {
    final Widget errorWidget = Container(
      width: width,
      height: height,
      color: context.softBg,
      child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
    );

    if (kIsWeb) {
      // Di web, path dari image_picker adalah blob URL,
      // jadi harus ditampilkan dengan Image.network.
      return Image.network(
        path,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => errorWidget,
      );
    }

    return Image.file(
      File(path),
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => errorWidget,
    );
  }

  // ===========================================================
  // FORM REVIEW
  // ===========================================================

  Widget reviewForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bagaimana pengalaman Anda?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: context.textMain,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Berikan penilaian untuk ${widget.namaKolam}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),

          const SizedBox(height: 18),

          // ===================================================
          // RATING
          // ===================================================
          Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final int starNumber = index + 1;

                    final bool selected = starNumber <= overallRating;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          overallRating = starNumber;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          selected ? Icons.star : Icons.star_border,
                          size: 40,
                          color: selected
                              ? const Color(0xFFFFD166)
                              : const Color(0xFFCBD5E1),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 7),

                Text(
                  overallRating == 0
                      ? 'Belum memberikan rating'
                      : '$overallRating dari 5 bintang',
                  style: TextStyle(
                    fontSize: 12,
                    color: overallRating == 0
                        ? Colors.grey.shade500
                        : const Color(0xFF0077A8),
                    fontWeight: overallRating == 0
                        ? FontWeight.w400
                        : FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Divider(color: context.softBg),

          const SizedBox(height: 12),

          // ===================================================
          // KOMENTAR
          // ===================================================
          Text(
            'Komentar Anda',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: context.textMain,
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: commentController,
            maxLines: 4,
            style: TextStyle(fontSize: 13, color: context.textMain),
            decoration: InputDecoration(
              hintText: 'Ceritakan pengalaman Anda di ${widget.namaKolam}...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              filled: true,
              fillColor: context.softBg,
              contentPadding: const EdgeInsets.all(13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF00B4D8)),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // ===================================================
          // FOTO
          // ===================================================
          Text(
            'Foto',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: context.textMain,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Tambahkan foto pengalaman Anda. Foto pertama akan disimpan ke review.',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),

          const SizedBox(height: 10),

          // ===================================================
          // PREVIEW FOTO
          // ===================================================
          if (selectedPhotos.isNotEmpty)
            SizedBox(
              height: 82,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: selectedPhotos.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: buildPickedImage(
                          selectedPhotos[index].path,
                          width: 82,
                          height: 82,
                        ),
                      ),

                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            removePhoto(index);
                          },
                          child: Container(
                            width: 23,
                            height: 23,
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      // FOTO PERTAMA
                      if (index == 0)
                        Positioned(
                          bottom: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Upload',
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),

          if (selectedPhotos.isNotEmpty) const SizedBox(height: 10),

          // ===================================================
          // TOMBOL TAMBAH FOTO
          // ===================================================
          GestureDetector(
            onTap: selectedPhotos.length >= 5 ? null : pickPhotos,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: context.softBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD0E8F5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 20,
                    color: Color(0xFF0077A8),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    selectedPhotos.length >= 5
                        ? 'Maksimal 5 foto'
                        : 'Tambah Foto',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0077A8),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 15),

          // ===================================================
          // KIRIM
          // ===================================================
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: isSendingReview ? null : submitReview,
              icon: isSendingReview
                  ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send, size: 17),
              label: Text(
                isSendingReview ? 'Mengirim...' : 'Kirim Ulasan',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0077A8),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade400,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // REVIEW DARI API
  // ===========================================================

  Widget apiReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Icon(
                Icons.rate_review_outlined,
                size: 19,
                color: Color(0xFF00B4D8),
              ),
              const SizedBox(width: 6),
              Text(
                'Ulasan Pengunjung',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: context.textMain,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        if (isLoadingReviews)
          const Padding(
            padding: EdgeInsets.all(30),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (reviewsFromApi.isEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.rate_review_outlined,
                  size: 38,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 10),
                Text(
                  'Belum ada ulasan',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.textMain,
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: reviewsFromApi
                .map((review) => apiReviewCard(review))
                .toList(),
          ),
      ],
    );
  }

  // ===========================================================
  // CARD REVIEW DARI API
  // ===========================================================

  Widget apiReviewCard(dynamic review) {
    final String nama = review['nama_pengunjung']?.toString() ?? 'Pengunjung';

    final int rating = int.tryParse(review['rating']?.toString() ?? '0') ?? 0;

    final String komentar = review['komentar']?.toString() ?? '';

    final String status = review['status']?.toString() ?? 'Menunggu';

    final String balasan = review['balasan_admin']?.toString() ?? '';

    final String fotoUrl = review['foto_url']?.toString() ?? '';

    debugPrint('REVIEW: $nama | FOTO URL: $fotoUrl');

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =================================================
          // USER
          // =================================================

          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F7FA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF0077A8),
                  size: 20,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nama,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: context.textMain,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 11,
                        color: status == 'Dibalas'
                            ? Colors.green
                            : Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // =================================================
          // RATING
          // =================================================
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < rating ? Icons.star : Icons.star_border,
                size: 18,
                color: index < rating
                    ? const Color(0xFFFFD166)
                    : const Color(0xFFCBD5E1),
              );
            }),
          ),

          const SizedBox(height: 9),

          // =================================================
          // KOMENTAR
          // =================================================
          if (komentar.isNotEmpty)
            Text(
              komentar,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),

          // =================================================
          // FOTO DARI LARAVEL
          // =================================================
          if (fotoUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  fotoUrl,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,

                  // =================================================
                  // LOADING FOTO
                  // =================================================
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }

                    return Container(
                      width: double.infinity,
                      height: 180,
                      alignment: Alignment.center,
                      color: context.softBg,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    );
                  },

                  // =================================================
                  // ERROR FOTO
                  // =================================================
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('GAGAL LOAD FOTO: $fotoUrl');

                    return Container(
                      width: double.infinity,
                      height: 180,
                      alignment: Alignment.center,
                      color: context.softBg,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image_outlined,
                            color: Colors.grey.shade400,
                            size: 32,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Foto tidak dapat dimuat',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

          // =================================================
          // BALASAN ADMIN
          // =================================================
          if (balasan.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.softBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Balasan Admin',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0077A8),
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    balasan,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.mutedText,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ===========================================================
  // ULASAN BARU LOKAL
  // ===========================================================

  Widget newlyUploadedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Icon(
                Icons.new_releases_outlined,
                size: 19,
                color: Color(0xFF00B4D8),
              ),
              const SizedBox(width: 6),
              Text(
                'Ulasan yang Baru Saja Diunggah',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: context.textMain,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        if (newlyUploadedReviews.isEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.rate_review_outlined,
                  size: 38,
                  color: Colors.grey.shade300,
                ),

                const SizedBox(height: 10),

                Text(
                  'Belum ada ulasan baru.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.textMain,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Ulasan Anda akan muncul di sini setelah dikirim.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: context.mutedText),
                ),
              ],
            ),
          )
        else
          Column(
            children: newlyUploadedReviews
                .map((review) => uploadedReviewCard(review))
                .toList(),
          ),
      ],
    );
  }

  // ===========================================================
  // CARD ULASAN BARU
  // ===========================================================

  Widget uploadedReviewCard(ReviewData review) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F7FA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF0077A8),
                  size: 20,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: context.textMain,
                      ),
                    ),

                    Text(
                      review.date,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F7FA),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Baru',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0077A8),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // RATING
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < review.rating ? Icons.star : Icons.star_border,
                size: 18,
                color: index < review.rating
                    ? const Color(0xFFFFD166)
                    : const Color(0xFFCBD5E1),
              );
            }),
          ),

          const SizedBox(height: 9),

          Text(
            review.comment,
            style: TextStyle(
              fontSize: 13,
              color: context.mutedText,
              height: 1.5,
            ),
          ),

          // FOTO LOKAL
          if (review.photoPaths.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SizedBox(
                height: 75,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: review.photoPaths.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: buildPickedImage(
                        review.photoPaths[index],
                        width: 75,
                        height: 75,
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// =============================================================
// MODEL DATA REVIEW
// =============================================================

class ReviewData {
  final String name;
  final String date;
  final String poolName;
  final int rating;
  final String comment;
  final List<String> photoPaths;

  ReviewData({
    required this.name,
    required this.date,
    required this.poolName,
    required this.rating,
    required this.comment,
    required this.photoPaths,
  });
}