part of 'tiket_page.dart';

extension _TicketRescheduleUi on _TiketPageState {
  Future<void> openReschedule(int index) async {
    final ticket = myTickets[index];
    if (ticket['status']?.toString() != 'paid' || !_isTicketActive(ticket)) {
      showMessage('Tiket tidak aktif dan tidak dapat dijadwalkan ulang.');
      return;
    }

    final reservationCode =
        ticket['reservationCode']?.toString().trim().isNotEmpty == true
        ? ticket['reservationCode'].toString().trim()
        : ticket['ticketId']?.toString().trim() ?? '';
    final phone = ticket['customerPhone']?.toString().trim().isNotEmpty == true
        ? ticket['customerPhone'].toString().trim()
        : telepon.trim();
    DateTime? newDate;
    bool isSubmitting = false;
    bool isPaying = false;
    bool isStatusLoading = true;
    bool isQuoteLoading = false;
    bool sheetOpen = true;
    bool pollingStarted = false;
    bool refreshingStatus = false;
    int quoteVersion = 0;
    Map<String, dynamic>? statusData;
    Map<String, dynamic>? quote;
    String quoteError = '';
    StateSetter? setModalState;
    Timer? statusTimer;

    Map<String, dynamic>? asMap(Object? value) {
      return value is Map ? Map<String, dynamic>.from(value) : null;
    }

    Future<void> refreshStatus() async {
      if (refreshingStatus ||
          !sheetOpen ||
          reservationCode.isEmpty ||
          phone.isEmpty) {
        return;
      }

      refreshingStatus = true;
      try {
        final response = await ApiService.getRescheduleStatus(
          kodeReservasi: reservationCode,
          noHp: phone,
        );
        if (!sheetOpen) return;

        final previousStatus = asMap(
          statusData?['request'],
        )?['status']?.toString();
        final latestRequest = asMap(response['request']);
        setModalState?.call(() {
          statusData = response;
          isStatusLoading = false;
        });

        final successfulRequest = asMap(response['latest_successful_request']);
        final actualDate = DateTime.tryParse(
          response['tanggal_kunjungan']?.toString() ?? '',
        );
        final successfulId = successfulRequest?['id']?.toString() ?? '';
        if (successfulId.isNotEmpty &&
            actualDate != null &&
            ticket['appliedRescheduleRequestId']?.toString() != successfulId) {
          final initialDate = DateTime.tryParse(
            response['tanggal_kunjungan_awal']?.toString() ??
                successfulRequest?['tanggal_lama']?.toString() ??
                '',
          );
          if (mounted) {
            _updatePageState(() {
              ticket['initialVisitDate'] ??= initialDate?.toIso8601String();
              ticket['rescheduleInfo'] = successfulRequest;
              ticket['appliedRescheduleRequestId'] = successfulId;
              ticket['date'] = formatShortDate(actualDate);
              ticket['visitDate'] = actualDate.toIso8601String();
              ticket['reschedule'] = (ticket['reschedule'] as int? ?? 0) + 1;
            });
            try {
              await _persistSavedTickets();
            } catch (error) {
              debugPrint(
                'Gagal menyimpan jadwal baru ke riwayat lokal: $error',
              );
            }
          }
        }

        final currentStatus = latestRequest?['status']?.toString();
        if (previousStatus != null && currentStatus != previousStatus) {
          final reason = latestRequest?['alasan_penolakan']?.toString() ?? '';
          final message = switch (currentStatus) {
            'menunggu_pembayaran' =>
              'Pengajuan disetujui. Selisih harga sudah bisa dibayar.',
            'ditolak' =>
              reason.isEmpty
                  ? 'Pengajuan reschedule ditolak admin.'
                  : 'Pengajuan ditolak: $reason',
            'berhasil' =>
              'Pembayaran berhasil. Tanggal tiket sudah diperbarui.',
            'kedaluwarsa' =>
              'Pengajuan reschedule kedaluwarsa. Tiket lama tetap berlaku.',
            _ => '',
          };
          if (message.isNotEmpty && mounted) showMessage(message);
        }
      } catch (error) {
        debugPrint('Gagal memuat status reschedule: $error');
        if (sheetOpen) {
          setModalState?.call(() => isStatusLoading = false);
        }
      } finally {
        refreshingStatus = false;
      }
    }

    Future<void> loadQuote(
      DateTime selectedDate,
      StateSetter updateModal,
    ) async {
      final requestVersion = ++quoteVersion;
      updateModal(() {
        isQuoteLoading = true;
        quote = null;
        quoteError = '';
      });

      try {
        final dateValue =
            '${selectedDate.year.toString().padLeft(4, '0')}-'
            '${selectedDate.month.toString().padLeft(2, '0')}-'
            '${selectedDate.day.toString().padLeft(2, '0')}';
        final result = await ApiService.getRescheduleQuote(
          kodeReservasi: reservationCode,
          noHp: phone,
          tanggalKunjungan: dateValue,
        );
        if (!sheetOpen || requestVersion != quoteVersion) return;
        updateModal(() {
          quote = result;
          isQuoteLoading = false;
        });
      } catch (error) {
        if (!sheetOpen || requestVersion != quoteVersion) return;
        updateModal(() {
          quoteError = error.toString().replaceFirst('Exception: ', '');
          isQuoteLoading = false;
        });
      }
    }

    Future<void> payReschedule(
      Map<String, dynamic> requestInfo,
      StateSetter updateModal,
    ) async {
      if (isPaying) return;
      updateModal(() => isPaying = true);

      try {
        final requestId = int.tryParse(requestInfo['id']?.toString() ?? '');
        if (requestId == null) {
          throw Exception('Data pengajuan reschedule tidak valid.');
        }

        final payment = await ApiService.createRescheduleQrisPayment(
          kodeReservasi: reservationCode,
          noHp: phone,
          requestId: requestId,
          customerName: ticket['customerName']?.toString() ?? nama,
          customerEmail: email,
        );

        if (payment['status_pembayaran']?.toString() == 'paid') {
          await refreshStatus();
          if (mounted) {
            showMessage('Pembayaran selisih berhasil. Tiket sudah diperbarui.');
          }
          return;
        }

        final orderId = payment['order_id']?.toString() ?? '';
        if (orderId.isEmpty) {
          throw Exception('Kode transaksi QRIS tidak diterima dari server.');
        }

        final isPaid = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => ReschedulePaymentDialog(
            orderId: orderId,
            qrUrl: payment['qr_url']?.toString() ?? '',
            remainingSeconds:
                int.tryParse(payment['remaining_seconds']?.toString() ?? '') ??
                600,
            errorColor: kRed,
            primaryButtonStyle: primaryStyle,
          ),
        );
        if (isPaid == true && mounted) {
          await refreshStatus();
          showMessage('Pembayaran selisih berhasil. Tiket sudah diperbarui.');
        }
      } catch (error) {
        if (mounted) {
          showMessage(error.toString().replaceFirst('Exception: ', ''));
        }
      } finally {
        if (sheetOpen) updateModal(() => isPaying = false);
      }
    }

    final sheet = showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, updateModal) {
          setModalState = updateModal;
          if (!pollingStarted) {
            pollingStarted = true;
            unawaited(refreshStatus());
            statusTimer = Timer.periodic(
              const Duration(seconds: 8),
              (_) => unawaited(refreshStatus()),
            );
          }

          final requestInfo = asMap(statusData?['request']);
          final requestStatus = requestInfo?['status']?.toString() ?? '';
          final awaitingApproval = requestStatus == 'menunggu_persetujuan';
          final awaitingPayment = requestStatus == 'menunggu_pembayaran';
          final hasActiveRequest = awaitingApproval || awaitingPayment;
          final reservationStatus =
              statusData?['status_reservasi']?.toString() ?? '';
          final minimumVisit = DateUtils.dateOnly(DateTime.now())
              .add(const Duration(days: 2));
          final canReschedule =
              reservationStatus != 'Selesai' &&
              reservationStatus != 'Dibatalkan';
          final cardPoolName =
              ticket['poolName']?.toString() ?? selectedPoolName;

          return sheetShell(
            height: .88,
            safeArea: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sheetHandle(),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Reschedule Tiket',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const Text(
                  'Pilih tanggal kunjungan baru Anda',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        infoBox(
                          radius: 15,
                          pad: 15,
                          border: kBlue.withOpacity(.25),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'INFORMASI TIKET SAAT INI',
                                style: TextStyle(
                                  color: kAqua,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 8),
                              infoRow('Kolam Renang', cardPoolName),
                              infoRow(
                                'No. Tiket',
                                reservationCode.isEmpty ? '—' : reservationCode,
                              ),
                              infoRow(
                                'Tanggal Saat Ini',
                                ticket['date']?.toString() ?? '—',
                              ),
                              infoRow(
                                'Kategori',
                                ticket['qty']?.toString() ?? '—',
                              ),
                              infoRow(
                                'Total Terbayar',
                                rupiah(ticket['total'] as int? ?? 0),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        infoBox(
                          color: context.isDark
                              ? const Color(0xFF3B3424)
                              : kYellowSoft,
                          radius: 14,
                          pad: 14,
                          border: kGold.withOpacity(.5),
                          child: const Text(
                            '• Tanggal tujuan reschedule minimal H+2 dari hari ini.\n'
                            '• Admin merespons maksimal 24 jam.\n'
                            '• Tiket lama tetap berlaku sampai reschedule berhasil.\n'
                            '• Pembayaran QRIS selisih berlaku 10 menit.\n'
                            '• Tiket yang sudah digunakan tidak dapat dijadwalkan ulang.',
                            style: TextStyle(fontSize: 11, height: 1.5),
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (isStatusLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(14),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (requestInfo != null) ...[
                          infoBox(
                            radius: 14,
                            pad: 14,
                            border: kBlue.withOpacity(.25),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  switch (requestStatus) {
                                    'menunggu_persetujuan' =>
                                      'Menunggu Persetujuan Admin',
                                    'menunggu_pembayaran' =>
                                      'Menunggu Pembayaran Selisih',
                                    'ditolak' => 'Pengajuan Ditolak',
                                    'berhasil' => 'Reschedule Berhasil',
                                    'kedaluwarsa' =>
                                      'Pengajuan Reschedule Kedaluwarsa',
                                    _ => 'Status Reschedule',
                                  },
                                  style: const TextStyle(
                                    color: kAqua,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Tanggal baru: ${requestInfo['tanggal_baru'] ?? '—'}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                if ((requestInfo['selisih_harga'] as num? ??
                                        0) >
                                    0)
                                  Text(
                                    'Selisih: ${rupiah((requestInfo['selisih_harga'] as num).round())}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                if (awaitingApproval)
                                  const Text(
                                    'Tiket lama tetap berlaku. Tombol pembayaran aktif setelah admin menyetujui.',
                                    style: TextStyle(fontSize: 11, height: 1.4),
                                  ),
                                if (awaitingPayment)
                                  const Text(
                                    'Admin sudah menyetujui. Bayar selisih agar tanggal baru berlaku.',
                                    style: TextStyle(fontSize: 11, height: 1.4),
                                  ),
                                if (requestStatus == 'ditolak' &&
                                    (requestInfo['alasan_penolakan']
                                            ?.toString()
                                            .isNotEmpty ??
                                        false))
                                  Text(
                                    'Alasan: ${requestInfo['alasan_penolakan']}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      height: 1.4,
                                    ),
                                  ),
                                if (requestStatus == 'kedaluwarsa')
                                  const Text(
                                    'Tiket lama tetap berlaku. Anda dapat mengajukan ulang dengan tanggal tujuan minimal H+2 dari hari ini.',
                                    style: TextStyle(fontSize: 11, height: 1.4),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        if (!isStatusLoading &&
                            !hasActiveRequest &&
                            canReschedule) ...[
                          const Text(
                            'Pilih Tanggal Baru',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Tanggal merah belum bisa dipilih. Pilih tanggal minimal H+2.',
                            style: TextStyle(color: kRed, fontSize: 11),
                          ),
                          const SizedBox(height: 8),
                          dateStrip(
                            list: datesFrom(29),
                            active: newDate,
                            height: 85,
                            minimumSelectableDate: minimumVisit,
                            onPick: (date) {
                              updateModal(() => newDate = date);
                              unawaited(loadQuote(date, updateModal));
                            },
                          ),
                          if (isQuoteLoading)
                            const Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: LinearProgressIndicator(),
                            ),
                          if (quote != null) ...[
                            const SizedBox(height: 10),
                            infoBox(
                              color: context.isDark
                                  ? const Color(0xFF3B3424)
                                  : kYellowSoft,
                              radius: 12,
                              pad: 12,
                              border: kGold.withOpacity(.4),
                              child: Text(
                                (quote!['selisih_harga'] as num? ?? 0) > 0
                                    ? 'Selisih yang dibayar setelah disetujui admin: ${rupiah((quote!['selisih_harga'] as num).round())}'
                                    : 'Tidak ada selisih harga untuk tanggal ini.',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                          if (quoteError.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                quoteError,
                                style: const TextStyle(
                                  color: kRed,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                        ],
                        if (!isStatusLoading && !canReschedule)
                          infoBox(
                            radius: 12,
                            pad: 12,
                            border: kRed.withOpacity(.3),
                            child: Text(
                              reservationStatus == 'Selesai'
                                  ? 'Tiket sudah digunakan dan tidak dapat dijadwalkan ulang.'
                                  : reservationStatus == 'Dibatalkan'
                                  ? 'Tiket yang dibatalkan tidak dapat dijadwalkan ulang.'
                                  : 'Tanggal tujuan reschedule minimal H+2 dari hari ini.',
                              style: const TextStyle(color: kRed, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: isSubmitting || isPaying || isStatusLoading
                            ? null
                            : awaitingPayment
                            ? () => payReschedule(requestInfo!, updateModal)
                            : awaitingApproval || !canReschedule
                            ? null
                            : newDate == null || quote == null || isQuoteLoading
                            ? null
                            : () async {
                                updateModal(() => isSubmitting = true);
                                try {
                                  final selectedDate = newDate!;
                                  final dateValue =
                                      '${selectedDate.year.toString().padLeft(4, '0')}-'
                                      '${selectedDate.month.toString().padLeft(2, '0')}-'
                                      '${selectedDate.day.toString().padLeft(2, '0')}';
                                  final submittedRequest =
                                      await ApiService.requestReschedule(
                                        kodeReservasi: reservationCode,
                                        noHp: phone,
                                        tanggalKunjungan: dateValue,
                                      );
                                  if (!sheetOpen) return;
                                  updateModal(() {
                                    statusData = {
                                      ...?statusData,
                                      'request': submittedRequest,
                                    };
                                    newDate = null;
                                    quote = null;
                                    isSubmitting = false;
                                  });
                                  showMessage(
                                    'Pengajuan menunggu persetujuan admin. Tiket lama tetap berlaku.',
                                  );
                                  await refreshStatus();
                                } catch (error) {
                                  if (!sheetOpen) return;
                                  updateModal(() => isSubmitting = false);
                                  showMessage(
                                    error.toString().replaceFirst(
                                      'Exception: ',
                                      '',
                                    ),
                                  );
                                }
                              },
                        style: primaryStyle,
                        child: isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : isPaying
                            ? const Text('Menyiapkan Pembayaran...')
                            : Text(
                                isStatusLoading
                                    ? 'Memuat Status...'
                                    : awaitingApproval
                                    ? 'Menunggu Persetujuan'
                                    : awaitingPayment
                                    ? 'Bayar Selisih'
                                    : 'Ajukan Reschedule',
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    await sheet.whenComplete(() {
      sheetOpen = false;
      statusTimer?.cancel();
    });
  }

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder fieldBorder({Color? color, double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: color ?? Colors.grey.shade300,
        width: width,
      ),
    );
  }
}
