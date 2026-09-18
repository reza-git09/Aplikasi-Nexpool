import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'home_page.dart';
import 'explore_page.dart';
import 'peta_page.dart';
import 'tiket_page.dart';

class ReviewPage extends StatefulWidget {
  // =========================================================
  // DATA KOLAM YANG DIPILIH DARI HOME
  // =========================================================

  final String? namaKolam;
  final String? gambarKolam;

  const ReviewPage({
    super.key,
    this.namaKolam,
    this.gambarKolam,
  });

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  // =========================================================
  // RATING
  // =========================================================

  // Awalnya 0 = semua bintang kosong
  int overallRating = 0;

  // =========================================================
  // KOMENTAR
  // =========================================================

  final TextEditingController commentController =
      TextEditingController();

  // =========================================================
  // FOTO
  // =========================================================

  final ImagePicker imagePicker = ImagePicker();

  final List<XFile> selectedPhotos = [];

  // =========================================================
  // ULASAN YANG BARU DIUPLOAD
  // =========================================================

  final List<ReviewData> newlyUploadedReviews = [];

  // =========================================================
  // CEK APAKAH KOLAM SUDAH DIPILIH
  // =========================================================

  bool get hasSelectedPool {
    return widget.namaKolam != null &&
        widget.namaKolam!.trim().isNotEmpty;
  }

  // =========================================================
  // INIT STATE
  // =========================================================

  @override
  void initState() {
    super.initState();

    // Kalau tidak ada kolam yang dipilih,
    // user tidak boleh masuk halaman ulasan.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!hasSelectedPool && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Silakan pilih kolam renang terlebih dahulu untuk memberikan ulasan.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );

        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    });
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
      final List<XFile> images =
          await imagePicker.pickMultiImage(
        imageQuality: 80,
      );

      if (images.isEmpty) {
        return;
      }

      setState(() {
        // Maksimal 5 foto
        final remaining =
            5 - selectedPhotos.length;

        if (remaining > 0) {
          selectedPhotos.addAll(
            images.take(remaining),
          );
        }
      });

      if (images.length >
          (5 - selectedPhotos.length)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Maksimal 5 foto yang dapat diunggah.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Gagal memilih foto.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // =========================================================
  // HAPUS FOTO
  // =========================================================

  void removePhoto(int index) {
    setState(() {
      selectedPhotos.removeAt(index);
    });
  }

  // =========================================================
  // KIRIM ULASAN
  // =========================================================

  void submitReview() {
    final String comment =
        commentController.text.trim();

    // Rating wajib diisi
    if (overallRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Silakan pilih rating bintang terlebih dahulu.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Komentar wajib diisi
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Silakan tulis komentar terlebih dahulu.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Simpan review baru
    final ReviewData newReview = ReviewData(
      name: 'Anda',
      date: 'Baru saja',
      poolName: widget.namaKolam!,
      rating: overallRating,
      comment: comment,
      photoPaths: selectedPhotos
          .map((photo) => photo.path)
          .toList(),
    );

    setState(() {
      // Review terbaru ditaruh paling atas
      newlyUploadedReviews.insert(
        0,
        newReview,
      );

      // Reset form
      overallRating = 0;
      commentController.clear();
      selectedPhotos.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Terima kasih! Ulasan Anda berhasil dikirim.',
        ),
        behavior: SnackBarBehavior.floating,
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
        backgroundColor: const Color(0xFFF5F9FC),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F7FA),
                      borderRadius:
                          BorderRadius.circular(25),
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      size: 40,
                      color: Color(0xFF0077A8),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Pilih Kolam Renang Terlebih Dahulu',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF172B3A),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Anda harus memilih kolam renang terlebih dahulu sebelum memberikan ulasan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
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
                            builder: (context) =>
                                const HomePage(),
                          ),
                        );
                      },
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF0077A8),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Kembali ke Home',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
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
      backgroundColor: const Color(0xFFF5F9FC),

      body: SafeArea(
        child: Column(
          children: [
            // =================================================
            // HEADER
            // =================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                20,
                18,
                20,
                22,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0077A8),
                    Color(0xFF00B4D8),
                  ],
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
                        color:
                            Colors.white.withOpacity(0.15),
                        borderRadius:
                            BorderRadius.circular(12),
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
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
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
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  top: 16,
                  bottom: 20,
                ),
                child: Column(
                  children: [
                    // =========================================
                    // KOLAM YANG DIPILIH
                    // =========================================

                    selectedPoolCard(),

                    const SizedBox(height: 18),

                    // =========================================
                    // FORM ULASAN
                    // =========================================

                    reviewForm(),

                    const SizedBox(height: 24),

                    // =========================================
                    // ULASAN TERBARU
                    // =========================================

                    newlyUploadedSection(),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // =======================================================
      // BOTTOM NAVIGATION
      // =======================================================

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 65,
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround,
              children: [
                navItem(
                  Icons.home,
                  'Home',
                  false,
                  () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const HomePage(),
                      ),
                    );
                  },
                ),

                navItem(
                  Icons.pool,
                  'Explore',
                  false,
                  () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const ExplorePage(),
                      ),
                    );
                  },
                ),

                navItem(
                  Icons.map,
                  'Peta',
                  false,
                  () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const PetaPage(),
                      ),
                    );
                  },
                ),

                navItem(
                  Icons.confirmation_number,
                  'Tiket',
                  false,
                  () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const TiketPage(),
                      ),
                    );
                  },
                ),

                navItem(
                  Icons.rate_review,
                  'Ulasan',
                  true,
                  () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // CARD KOLAM YANG DIPILIH
  // ===========================================================

  Widget selectedPoolCard() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // GAMBAR KOLAM
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F7FA),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            clipBehavior: Clip.antiAlias,
            child: buildPoolImage(),
          ),

          const SizedBox(width: 13),

          // NAMA KOLAM
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Anda akan mengulas',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  widget.namaKolam!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF172B3A),
                  ),
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    const Icon(
                      Icons.pool,
                      size: 14,
                      color: Color(0xFF00B4D8),
                    ),

                    const SizedBox(width: 4),

                    Text(
                      'Kolam Renang',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
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
    if (widget.gambarKolam == null ||
        widget.gambarKolam!.trim().isEmpty) {
      return const Icon(
        Icons.pool,
        size: 32,
        color: Color(0xFF00B4D8),
      );
    }

    final String image =
        widget.gambarKolam!;

    if (image.startsWith('http')) {
      return Image.network(
        image,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) {
          return const Icon(
            Icons.pool,
            size: 32,
            color: Color(0xFF00B4D8),
          );
        },
      );
    }

    return Image.asset(
      image,
      fit: BoxFit.cover,
      errorBuilder:
          (context, error, stackTrace) {
        return const Icon(
          Icons.pool,
          size: 32,
          color: Color(0xFF00B4D8),
        );
      },
    );
  }

  // ===========================================================
  // FORM REVIEW
  // ===========================================================

  Widget reviewForm() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ===============================================
          // JUDUL
          // ===============================================

          const Text(
            'Bagaimana pengalaman Anda?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF172B3A),
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Berikan penilaian untuk ${widget.namaKolam}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),

          const SizedBox(height: 18),

          // ===============================================
          // STAR RATING
          // ===============================================

          Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) {
                      final int starNumber =
                          index + 1;

                      final bool selected =
                          starNumber <=
                              overallRating;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            overallRating =
                                starNumber;
                          });
                        },
                        child: Padding(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 4,
                          ),
                          child: Icon(
                            selected
                                ? Icons.star
                                : Icons.star_border,
                            size: 40,
                            color: selected
                                ? const Color(
                                    0xFFFFD166,
                                  )
                                : const Color(
                                    0xFFCBD5E1,
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
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
                    fontWeight:
                        overallRating == 0
                            ? FontWeight.w400
                            : FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Divider(
            color: Colors.grey.shade200,
          ),

          const SizedBox(height: 12),

          // ===============================================
          // KOMENTAR
          // ===============================================

          const Text(
            'Komentar Anda',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF172B3A),
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: commentController,
            maxLines: 4,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF172B3A),
            ),
            decoration: InputDecoration(
              hintText:
                  'Ceritakan pengalaman Anda di ${widget.namaKolam}...',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 13,
              ),
              filled: true,
              fillColor:
                  const Color(0xFFF8FAFC),
              contentPadding:
                  const EdgeInsets.all(13),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(12),
                borderSide: BorderSide(
                  color:
                      Colors.grey.shade200,
                ),
              ),
              enabledBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(12),
                borderSide: BorderSide(
                  color:
                      Colors.grey.shade200,
                ),
              ),
              focusedBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(12),
                borderSide:
                    const BorderSide(
                  color: Color(0xFF00B4D8),
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // ===============================================
          // FOTO
          // ===============================================

          const Text(
            'Foto',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF172B3A),
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Tambahkan foto pengalaman Anda (maks. 5 foto)',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),

          const SizedBox(height: 10),

          // ===============================================
          // FOTO YANG DIPILIH
          // ===============================================

          if (selectedPhotos.isNotEmpty)
            SizedBox(
              height: 82,
              child: ListView.separated(
                scrollDirection:
                    Axis.horizontal,
                itemCount:
                    selectedPhotos.length,
                separatorBuilder:
                    (context, index) =>
                        const SizedBox(
                  width: 8,
                ),
                itemBuilder:
                    (context, index) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                        child: Image.file(
                          File(
                            selectedPhotos[
                                    index]
                                .path,
                          ),
                          width: 82,
                          height: 82,
                          fit: BoxFit.cover,
                        ),
                      ),

                      Positioned(
                        top: 4,
                        right: 4,
                        child:
                            GestureDetector(
                          onTap: () {
                            removePhoto(
                              index,
                            );
                          },
                          child: Container(
                            width: 23,
                            height: 23,
                            decoration:
                                const BoxDecoration(
                              color:
                                  Colors.black54,
                              shape:
                                  BoxShape.circle,
                            ),
                            child:
                                const Icon(
                              Icons.close,
                              size: 14,
                              color:
                                  Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

          if (selectedPhotos.isNotEmpty)
            const SizedBox(height: 10),

          // ===============================================
          // BUTTON TAMBAH FOTO
          // ===============================================

          GestureDetector(
            onTap: selectedPhotos.length >= 5
                ? null
                : pickPhotos,
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(
                vertical: 13,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FCFD),
                borderRadius:
                    BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(
                    0xFFD0E8F5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
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
                      fontWeight:
                          FontWeight.w700,
                      color: Color(0xFF0077A8),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 15),

          // ===============================================
          // KIRIM ULASAN
          // ===============================================

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: submitReview,
              icon: const Icon(
                Icons.send,
                size: 17,
              ),
              label: const Text(
                'Kirim Ulasan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF0077A8),
                foregroundColor:
                    Colors.white,
                elevation: 0,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // ULASAN YANG BARU DIUPLOAD
  // ===========================================================

  Widget newlyUploadedSection() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.new_releases_outlined,
                size: 19,
                color: Color(0xFF00B4D8),
              ),

              const SizedBox(width: 6),

              const Text(
                'Ulasan yang Baru Saja Diunggah',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF172B3A),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        if (newlyUploadedReviews.isEmpty)
          Container(
            margin:
                const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            padding:
                const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(0.04),
                  blurRadius: 8,
                  offset:
                      const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.rate_review_outlined,
                  size: 38,
                  color: Colors.grey.shade300,
                ),

                const SizedBox(height: 10),

                const Text(
                  'Belum ada ulasan yang baru saja diunggah.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w600,
                    color: Color(0xFF172B3A),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Ulasan Anda akan muncul di sini setelah dikirim.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: newlyUploadedReviews
                .map(
                  (review) =>
                      uploadedReviewCard(
                    review,
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  // ===========================================================
  // CARD ULASAN BARU
  // ===========================================================

  Widget uploadedReviewCard(
    ReviewData review,
  ) {
    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        20,
        0,
        20,
        10,
      ),
      padding:
          const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset:
                const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ===============================================
          // USER INFO
          // ===============================================

          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration:
                    const BoxDecoration(
                  color: Color(0xFFE8F7FA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color:
                      Color(0xFF0077A8),
                  size: 20,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.name,
                      style:
                          const TextStyle(
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w700,
                        color:
                            Color(0xFF172B3A),
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      review.date,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors
                            .grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFE8F7FA),
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
                child: const Text(
                  'Baru',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        Color(0xFF0077A8),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ===============================================
          // NAMA KOLAM
          // ===============================================

          Row(
            children: [
              const Icon(
                Icons.pool,
                size: 14,
                color: Color(0xFF00B4D8),
              ),

              const SizedBox(width: 5),

              Expanded(
                child: Text(
                  review.poolName,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w600,
                    color:
                        Color(0xFF0077A8),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ===============================================
          // STAR
          // ===============================================

          Row(
            children: List.generate(
              5,
              (index) {
                return Icon(
                  index < review.rating
                      ? Icons.star
                      : Icons.star_border,
                  size: 18,
                  color: index <
                          review.rating
                      ? const Color(
                          0xFFFFD166,
                        )
                      : const Color(
                          0xFFCBD5E1,
                        ),
                );
              },
            ),
          ),

          const SizedBox(height: 9),

          // ===============================================
          // KOMENTAR
          // ===============================================

          Text(
            review.comment,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),

          // ===============================================
          // FOTO
          // ===============================================

          if (review.photoPaths.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.only(
                top: 12,
              ),
              child: SizedBox(
                height: 75,
                child: ListView.separated(
                  scrollDirection:
                      Axis.horizontal,
                  itemCount:
                      review.photoPaths.length,
                  separatorBuilder:
                      (context, index) =>
                          const SizedBox(
                    width: 8,
                  ),
                  itemBuilder:
                      (context, index) {
                    return ClipRRect(
                      borderRadius:
                          BorderRadius.circular(
                        10,
                      ),
                      child: Image.file(
                        File(
                          review
                              .photoPaths[index],
                        ),
                        width: 75,
                        height: 75,
                        fit: BoxFit.cover,
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

  // ===========================================================
  // BOTTOM NAV ITEM
  // ===========================================================

  Widget navItem(
    IconData icon,
    String label,
    bool active,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      behavior:
          HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 23,
              color: active
                  ? const Color(0xFF0077A8)
                  : const Color(0xFF8BA3BA),
            ),

            const SizedBox(height: 3),

            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: active
                    ? FontWeight.w700
                    : FontWeight.w500,
                color: active
                    ? const Color(0xFF0077A8)
                    : const Color(0xFF8BA3BA),
              ),
            ),
          ],
        ),
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