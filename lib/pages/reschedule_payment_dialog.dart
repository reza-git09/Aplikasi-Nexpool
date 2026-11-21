import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../services/api_service.dart';

class ReschedulePaymentDialog extends StatefulWidget {
  const ReschedulePaymentDialog({
    required this.orderId,
    required this.remainingSeconds,
    required this.errorColor,
    required this.primaryButtonStyle,
    super.key,
  });

  final String orderId;
  final int remainingSeconds;
  final Color errorColor;
  final ButtonStyle primaryButtonStyle;

  @override
  State<ReschedulePaymentDialog> createState() =>
      _ReschedulePaymentDialogState();
}

class _ReschedulePaymentDialogState extends State<ReschedulePaymentDialog> {
  late int _remainingSeconds;
  late Future<Uint8List> _qrImage;
  Timer? _countdownTimer;
  Timer? _statusTimer;
  bool _isChecking = false;
  bool _isExpired = false;
  String _statusError = '';

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.remainingSeconds;
    _qrImage = ApiService.getMidtransQrImage(widget.orderId);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _remainingSeconds <= 0) return;
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds == 0) _isExpired = true;
      });
    });
    _statusTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkPaymentStatus(),
    );
    unawaited(_checkPaymentStatus());
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _statusTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkPaymentStatus() async {
    if (_isChecking || !mounted) return;
    setState(() {
      _isChecking = true;
      _statusError = '';
    });

    try {
      final result = await ApiService.getMidtransPaymentStatus(widget.orderId);
      final paymentStatus =
          result['status_pembayaran']?.toString().toLowerCase() ?? 'pending';
      final rescheduleStatus = result['reschedule_status']?.toString();

      if (paymentStatus == 'paid' && rescheduleStatus == 'berhasil') {
        if (mounted) Navigator.of(context).pop(true);
        return;
      }

      if (paymentStatus == 'expired' ||
          paymentStatus == 'cancelled' ||
          paymentStatus == 'failed' ||
          paymentStatus == 'refunded') {
        setState(() => _isExpired = true);
      }
    } catch (error) {
      debugPrint('Gagal memeriksa pembayaran selisih: $error');
      if (mounted) {
        setState(
          () => _statusError = 'Status belum dapat diperiksa. Coba lagi.',
        );
      }
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Bayar Selisih Reschedule',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_isExpired)
                  Text(
                    'Transaksi QRIS kedaluwarsa. Pengajuan tetap aktif; tekan Bayar Selisih lagi untuk membuat QR baru.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: widget.errorColor,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  )
                else
                  Text(
                    'Selesaikan pembayaran dalam $minutes:$seconds',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                const SizedBox(height: 14),
                FutureBuilder<Uint8List>(
                  future: _qrImage,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 220,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return SizedBox(
                        height: 220,
                        child: Center(
                          child: Text(
                            snapshot.error?.toString() ??
                                'QRIS tidak dapat dimuat.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    return Image.memory(
                      snapshot.data!,
                      width: 220,
                      height: 220,
                      fit: BoxFit.contain,
                    );
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  'Order ID: ${widget.orderId}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
                if (_statusError.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    _statusError,
                    style: TextStyle(color: widget.errorColor, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isChecking ? null : _checkPaymentStatus,
                    icon: _isChecking
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.refresh_rounded),
                    label: const Text('Cek Status Pembayaran'),
                    style: widget.primaryButtonStyle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
