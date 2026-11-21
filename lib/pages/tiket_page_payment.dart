part of 'tiket_page.dart';

extension _TicketPaymentUi on _TiketPageState {
  Widget buildStep4() {
    if (paymentExpired) return buildPaymentExpired();
    return buildQrisPayment();
  }

  Widget buildQrisPayment() {
    return Column(
      children: [
        pad20(_paymentInfoHeader(), top: 14),
        pad20(_countdownBanner(), top: 10),

        sectionTitle(
          'Scan QRIS',
          icon: Icons.qr_code_scanner_rounded,
          iconColor: kAqua,
        ),

        pad20(
          RepaintBoundary(
            key: _qrisCardKey,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: context.softBg,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: kAqua.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.qr_code_rounded, size: 14, color: kAqua),
                        const SizedBox(width: 6),
                        Text(
                          currentQrUrl != null && currentQrUrl!.isNotEmpty
                              ? 'QRIS • MIDTRANS'
                              : 'QRIS',
                          style: TextStyle(
                            color: context.textMain,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    width: 220,
                    height: 220,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                    ),
                    child: currentQrImage != null
                        ? FutureBuilder<Uint8List>(
                            future: currentQrImage,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Image.memory(
                                  snapshot.data!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildQrImageError(),
                                );
                              }
                              if (snapshot.hasError) {
                                return _buildQrImageError();
                              }
                              return const Center(
                                child: CircularProgressIndicator(color: kBlue),
                              );
                            },
                          )
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.qr_code_2_rounded,
                                  color: Colors.grey,
                                  size: 36,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'QRIS belum tersedia',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    'NEXPOOL QRIS PAYMENT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                      color: kDarkBlue,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    rupiah(totalPrice),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: kBlue,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Order ID: $orderId',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        pad20(
          Column(
            children: [
              // 1. TOMBOL DOWNLOAD QRIS
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isDownloadingQris ? null : _downloadQrisImage,
                  icon: _isDownloadingQris
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.download_rounded, size: 20),
                  label: Text(
                    _isDownloadingQris
                        ? 'Menyimpan QRIS...'
                        : 'Download QRIS (Simpan ke Galeri)',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: primaryStyle.copyWith(
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(vertical: 16),
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 2. TOMBOL SALIN LINK URL QRIS
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _copyQrisUrl,
                  icon: const Icon(Icons.copy_rounded, size: 20),
                  label: const Text(
                    'Salin Link URL QRIS',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: kDarkBlue,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kDarkBlue,
                    side: const BorderSide(color: kBlue, width: 1.6),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Indikator auto-check status
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: kBlue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Menunggu pembayaran... (status dicek otomatis)',
                    style: TextStyle(
                      fontSize: 11,
                      color: context.mutedText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _downloadQrisImage() async {
    if (_isDownloadingQris) return;
    _updatePageState(() => _isDownloadingQris = true);

    try {
      Uint8List? bytes;
      if (currentQrImage != null) {
        try {
          bytes = await currentQrImage;
        } catch (_) {}
      }

      if (bytes == null || bytes.isEmpty) {
        await WidgetsBinding.instance.endOfFrame;
        final renderObject = _qrisCardKey.currentContext?.findRenderObject();
        if (renderObject is RenderRepaintBoundary) {
          final image = await renderObject.toImage(pixelRatio: 3);
          final byteData = await image.toByteData(format: ImageByteFormat.png);
          image.dispose();
          bytes = byteData?.buffer.asUint8List();
        }
      }

      if (bytes == null || bytes.isEmpty) {
        throw StateError('Gambar QRIS belum tersedia untuk diunduh.');
      }

      final fileName =
          'NexPool-QRIS-${orderId.isNotEmpty ? orderId : 'Pembayaran'}'
              .replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '-');

      final savedPath = await FileSaver.instance.saveAs(
        name: fileName,
        bytes: bytes,
        fileExtension: 'png',
        mimeType: MimeType.png,
        dialogTitle: 'Simpan Gambar QRIS',
      );

      if (savedPath != null && mounted) {
        showMessage('Gambar QRIS berhasil diunduh ke galeri / penyimpanan!');
      }
    } catch (e) {
      debugPrint('Gagal unduh QRIS: $e');
      if (mounted) showMessage('Gagal mengunduh QRIS: $e');
    } finally {
      if (mounted) _updatePageState(() => _isDownloadingQris = false);
    }
  }

  Future<void> _copyQrisUrl() async {
    final urlToCopy = (currentQrUrl != null && currentQrUrl!.isNotEmpty)
        ? currentQrUrl!.trim()
        : '';

    if (urlToCopy.isEmpty || !urlToCopy.startsWith('http')) {
      showMessage('Link URL QRIS belum tersedia.');
      return;
    }

    try {
      await Clipboard.setData(ClipboardData(text: urlToCopy));
      if (mounted) {
        showMessage('Link URL QRIS berhasil disalin!\n$urlToCopy');
      }
    } catch (e) {
      if (mounted) showMessage('Gagal menyalin link: $e');
    }
  }

  Widget _paymentInfoHeader() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: kGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TOTAL PEMBAYARAN',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rupiah(totalPrice),
                  style: const TextStyle(
                    color: kGold,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Order ID: $orderId',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _statusChip(
                '⏱ $countdownLabel',
                _remainingSeconds <= 60 ? kRed : kOrange,
              ),
              const SizedBox(height: 6),
              Text(
                '$qtyAdult Dewasa${qtyChild > 0 ? ', $qtyChild Anak' : ''}',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TIMER PEMBAYARAN
  // ============================================================
  void _startPayTimer({int? initialSeconds}) {
    _payTimer?.cancel();

    final startSeconds = (initialSeconds != null && initialSeconds > 0)
        ? initialSeconds
        : _TiketPageState.payDurationSeconds;

    _updatePageState(() {
      _remainingSeconds = startSeconds;
      paymentExpired = false;
    });

    _payTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds <= 1) {
        timer.cancel();
        _paymentStatusTimer?.cancel();
        if (mounted) {
          _updatePageState(() {
            _remainingSeconds = 0;
            paymentExpired = true;
            statusPembayaran = 'expired';
          });
        }
        return;
      }

      _updatePageState(() => _remainingSeconds--);
    });
  }

  void _stopPayTimer() {
    _payTimer?.cancel();
    _payTimer = null;
  }

  /// Minta QRIS baru setelah Midtrans menyatakan transaksi lama kedaluwarsa.
  void _restartPayment() {
    _stopPayTimer();
    _paymentStatusTimer?.cancel();
    _updatePageState(() {
      orderId = '';
      currentQrUrl = null;
      currentQrImage = null;
      statusPembayaran = 'pending';
      paymentExpired = false;
      paySubStep = 'process';
    });
    _createReservationAndQris();
  }

  String get countdownLabel {
    final m = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Widget _buildQrImageError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.broken_image_rounded, color: Colors.grey, size: 36),
          const SizedBox(height: 6),
          const Text(
            'Gagal memuat QRIS',
            style: TextStyle(fontSize: 11, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          TextButton(
            onPressed: orderId.isEmpty
                ? null
                : () => _updatePageState(() {
                    currentQrImage = ApiService.getMidtransQrImage(orderId);
                  }),
            child: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }

  Widget _countdownBanner() {
    final bool urgent = _remainingSeconds <= 60;
    final Color color = urgent ? kRed : kOrange;

    return infoBox(
      color: urgent ? kRedSoft : kOrangeSoft,
      radius: 12,
      pad: 12,
      border: color.withOpacity(.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timer_rounded, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _remainingSeconds == 0
                      ? 'Memeriksa status pembayaran ke Midtrans...'
                      : 'Selesaikan pembayaran sebelum waktu habis',
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                countdownLabel,
                style: TextStyle(
                  fontSize: 16,
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _remainingSeconds / _TiketPageState.payDurationSeconds,
              minHeight: 6,
              backgroundColor: color.withOpacity(.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  /// Tampilan untuk status pembayaran yang tidak bisa lagi diproses.
  Widget buildPaymentExpired() {
    final canRetry = statusPembayaran != 'refunded';
    final title = switch (statusPembayaran) {
      'cancelled' => 'Pembayaran Dibatalkan',
      'failed' => 'Pembayaran Gagal',
      'refunded' => 'Pembayaran Dikembalikan',
      _ => 'QRIS Kedaluwarsa',
    };
    final message = statusPembayaran == 'refunded'
        ? 'Transaksi untuk pesanan $orderId telah dikembalikan. Periksa riwayat tiket atau hubungi petugas jika membutuhkan bantuan.'
        : 'Waktu pembayaran QRIS untuk pesanan $orderId telah habis (5 menit). Silakan buat transaksi / QRIS baru untuk melanjutkan.';

    return Column(
      children: [
        const SizedBox(height: 24),
        pad20(
          infoBox(
            color: context.cardBg,
            radius: 20,
            pad: 24,
            border: kRed.withOpacity(.3),
            child: Column(
              children: [
                colorfulIcon(
                  icon: Icons.timer_off_rounded,
                  color: kRed,
                  bgColor: kRedSoft,
                  boxSize: 76,
                  size: 40,
                  isCircle: true,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: kRed,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.mutedText,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 22),
                if (canRetry)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _restartPayment,
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                      label: const Text(
                        'Buat QRIS Baru',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: primaryStyle.copyWith(
                        padding: const WidgetStatePropertyAll(
                          EdgeInsets.symmetric(vertical: 16),
                        ),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: canRetry
                        ? () => goStep(3)
                        : () => _updatePageState(() => selectedTab = 1),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      canRetry
                          ? '← Kembali ke Pilih Tiket'
                          : 'Lihat Riwayat Tiket',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(.2),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withOpacity(.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Map<String, dynamic> _currentReceiptTicket() {
    return {
      'orderId': orderId,
      'ticketId': ticketId.isNotEmpty ? ticketId : reservationCode,
      'poolName': selectedPoolName,
      'customerName': nama,
      'customerPhone': telepon,
      'visitDate': selectedDate?.toIso8601String(),
      'date': selectedDate == null
          ? selectedDateLabel
          : formatShortDate(selectedDate!),
      'paidAt': paidAt == null ? '' : formatDateTime(paidAt!),
      'paidAtIso': paidAt?.toIso8601String(),
      'adultQty': qtyAdult,
      'childQty': qtyChild,
      'qty': qtyChild > 0
          ? '$qtyAdult Dewasa, $qtyChild Anak'
          : '$qtyAdult Dewasa',
      'unitPrice': adultPrice,
      'adminFee': adminFee,
      'promoName': _confirmedPromoName,
      'promoDiscount': _confirmedPromoDiscount,
      'total': totalPrice,
      'payment': _paymentLabel(),
    };
  }

  Widget _buildThermalStep5() {
    return Column(
      children: [
        const SizedBox(height: 24),
        ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              color: kGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 46,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Pembayaran Berhasil!',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        const Text(
          'Tiket Anda telah dikonfirmasi dan siap digunakan.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: RepaintBoundary(
            key: _step5ReceiptKey,
            child: _buildReceiptCanvas(_currentReceiptTicket(), 'paid'),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isDownloadingReceipt
                      ? null
                      : _downloadStep5Receipt,
                  icon: _isDownloadingReceipt
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.download_rounded, size: 20),
                  label: Text(
                    _isDownloadingReceipt
                        ? 'Menyimpan Struk...'
                        : 'Unduh Struk',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _updatePageState(() => selectedTab = 1);
                    goStep(1);
                  },
                  icon: const Icon(Icons.confirmation_number_rounded, size: 18),
                  label: const Text('Lihat Tiket Saya'),
                  style: primaryStyle.copyWith(
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _returnToHome,
                  icon: const Icon(Icons.home_rounded, size: 18),
                  label: const Text('Kembali ke Home'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  void _returnToHome() {
    final onReturnHome = widget.onReturnHome;
    if (onReturnHome != null) {
      onReturnHome();
      return;
    }

    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
