part of 'tiket_page.dart';

extension _TicketHistoryUi on _TiketPageState {
  Widget buildMyTickets() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 88),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTabs(),
          _buildTicketOverview(),
          if (myTickets.isEmpty)
            _buildEmptyTickets()
          else
            ...myTickets.asMap().entries.map(
              (entry) => buildTicketCard(entry.key, entry.value),
            ),
        ],
      ),
    );
  }

  bool _isTicketActive(Map<String, dynamic> ticket) {
    final visitDate = DateTime.tryParse(ticket['visitDate']?.toString() ?? '');
    if (visitDate == null) return false;

    return !DateUtils.dateOnly(visitDate).isBefore(
      DateUtils.dateOnly(DateTime.now()),
    );
  }

  Widget _buildTicketOverview() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [kDarkBlue, kBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: kBlue.withOpacity(.22),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.confirmation_number_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Perjalanan Wisatamu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        myTickets.isEmpty
                            ? 'Tiketmu akan tersimpan di sini'
                            : '${myTickets.length} tiket tersimpan',
                        style: TextStyle(
                          color: Colors.white.withOpacity(.82),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${myTickets.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          height: 1,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'TIKET',
                        style: TextStyle(
                          color: Colors.white.withOpacity(.82),
                          fontSize: 8,
                          letterSpacing: .8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTickets() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: context.softBg),
          ),
          child: Column(
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kBlue.withOpacity(.12), kBlue.withOpacity(.04)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.confirmation_number_rounded,
                  color: kAqua,
                  size: 44,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Belum Ada Tiket',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: context.textMain,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tiket yang kamu pesan akan muncul di sini.\nYuk, rencanakan serunya berenang!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.mutedText,
                  fontSize: 13,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _openBookingTab,
                  icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                  label: const Text(
                    'Pesan Tiket Sekarang',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  style: primaryStyle.copyWith(
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(vertical: 15),
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTicketCard(int index, Map<String, dynamic> ticket) {
    final status = ticket['status']?.toString() ?? 'pending';
    final resched = ticket['reschedule'] as int? ?? 0;
    final isActive = status == 'paid' && _isTicketActive(ticket);

    Color statusFg;
    String statusLabel;
    IconData statusIcon;

    switch (status) {
      case 'paid':
        statusFg = const Color(0xff087f65);
        statusLabel = 'LUNAS';
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'cancelled':
        statusFg = kRed;
        statusLabel = 'DIBATALKAN';
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusFg = kOrange;
        statusLabel = 'MENUNGGU';
        statusIcon = Icons.access_time_filled_rounded;
    }

    final cardPoolName = ticket['poolName']?.toString() ?? selectedPoolName;
    final cardPoolId =
        ticket['poolId']?.toString() ?? normalizePoolId(selectedPoolId);
    final cardTicketId =
        ticket['ticketId']?.toString() ?? ticket['orderId']?.toString() ?? '—';
    final orderId = ticket['orderId']?.toString() ?? cardTicketId;
    final visitDate = ticket['date']?.toString() ?? '—';
    final quantity = ticket['qty']?.toString() ?? '—';
    final paymentMethod = ticket['payment']?.toString() ?? '—';
    final total = rupiah(ticket['total'] as int? ?? 0);
    final paidAt = ticket['paidAt']?.toString() ?? '';
    final accent = status == 'paid'
        ? isActive
              ? const Color(0xff10b981)
              : kRed
        : status == 'cancelled'
        ? kRed
        : kOrange;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 7, 20, 13),
      child: Container(
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: context.softBg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(context.isDark ? .12 : .045),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 4, color: accent),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'KODE RESERVASI',
                              style: TextStyle(
                                color: context.mutedText,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: .8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              orderId,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.textMain,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (status == 'paid')
                        badge(
                          isActive ? 'AKTIF' : 'TIDAK AKTIF',
                          isActive ? const Color(0xff087f65) : kRed,
                          isActive ? const Color(0xffe3fff7) : kRedSoft,
                          icon: isActive
                              ? Icons.event_available_rounded
                              : Icons.event_busy_rounded,
                        ),
                    ],
                  ),
                  if (resched > 0) ...[
                    const SizedBox(height: 10),
                    badge(
                      'Pernah dijadwalkan ulang $resched×',
                      kPurple,
                      kPurpleSoft,
                      icon: Icons.sync_rounded,
                    ),
                  ],
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kBlue.withOpacity(context.isDark ? .13 : .07),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        colorfulIcon(
                          icon: Icons.pool_rounded,
                          color: kAqua,
                          boxSize: 38,
                          size: 19,
                          radius: 12,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cardPoolName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: context.textMain,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '$cardPoolId  ·  Kode tiket $cardTicketId',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: context.mutedText,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _ticketDetailTile(
                          Icons.calendar_month_rounded,
                          kBlue,
                          'Tanggal kunjungan',
                          visitDate,
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: _ticketDetailTile(
                          Icons.group_rounded,
                          kGreen,
                          'Jumlah tiket',
                          quantity,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      Expanded(
                        child: _ticketDetailTile(
                          Icons.payment_rounded,
                          kDarkBlue,
                          'Metode bayar',
                          paymentMethod,
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: _ticketDetailTile(
                          Icons.payments_rounded,
                          kOrange,
                          'Total pembayaran',
                          total,
                          emphasized: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  _ticketDetailTile(
                    statusIcon,
                    statusFg,
                    'Status',
                    statusLabel,
                  ),
                  if (status == 'paid' && paidAt.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 15,
                          color: statusFg,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Dibayar $paidAt',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.mutedText,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 14),
                  _buildTicketActions(index, ticket, status),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ticketDetailTile(
    IconData icon,
    Color color,
    String label,
    String value, {
    bool emphasized = false,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.pageBg,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: context.softBg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.mutedText,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: emphasized ? kBlue : context.textMain,
              fontSize: emphasized ? 12 : 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketActions(
    int index,
    Map<String, dynamic> ticket,
    String status,
  ) {
    final isPaid = status == 'paid';
    final isPending = status == 'pending';
    final isActive = isPaid && _isTicketActive(ticket);

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => showReceiptFromTicket(ticket),
            icon: Icon(
              isPending ? Icons.receipt_long_rounded : Icons.receipt_rounded,
              size: 16,
            ),
            label: Text(
              isPaid
                  ? 'Lihat Struk'
                  : isPending
                  ? 'Detail'
                  : 'Lihat Detail',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: kDarkBlue,
              side: BorderSide(color: kDarkBlue.withOpacity(.35)),
              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
              textStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        if (isPaid || isPending) ...[
          const SizedBox(width: 9),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: isPending
                  ? () => cancelTransaction(index)
                  : isActive
                  ? () => openReschedule(index)
                  : null,
              icon: Icon(
                isPaid ? Icons.sync_rounded : Icons.cancel_rounded,
                size: 16,
              ),
              label: Text(isPaid ? 'Reschedule' : 'Batalkan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isActive
                    ? kPurpleSoft
                    : isPending
                    ? kRedSoft
                    : context.softBg,
                foregroundColor: isActive
                    ? kPurple
                    : isPending
                    ? kRed
                    : context.mutedText,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  vertical: 11,
                  horizontal: 8,
                ),
                textStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget badge(
    String text,
    Color fg,
    Color bg, {
    IconData? icon,
    double fontSize = 10,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: fg,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  void showReceiptFromTicket(Map<String, dynamic> ticket) {
    final status = ticket['status']?.toString() ?? 'pending';
    final receiptKey = GlobalKey();
    final isPaid = status == 'paid';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return sheetShell(
          height: .85,
          radius: 25,
          child: Column(
            children: [
              sheetHandle(),
              const SizedBox(height: 16),

              const Text(
                'Struk Pembayaran',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: SingleChildScrollView(
                  child: RepaintBoundary(
                    key: receiptKey,
                    child: _buildReceiptCanvas(ticket, status),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              if (isPaid) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _downloadReceiptImage(receiptKey, ticket),
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Unduh Struk'),
                    style: primaryStyle.copyWith(
                      padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(vertical: 14),
                      ),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReceiptCanvas(
    Map<String, dynamic> ticket,
    String paymentStatus,
  ) {
    final quantity = ticket['qty']?.toString() ?? '';
    final adultMatch = RegExp(
      r'(\d+)\s*Dewasa',
      caseSensitive: false,
    ).firstMatch(quantity);
    final childMatch = RegExp(
      r'(\d+)\s*Anak',
      caseSensitive: false,
    ).firstMatch(quantity);
    final adultCount = _receiptInteger(
      ticket['adultQty'],
      fallback:
          int.tryParse(adultMatch?.group(1) ?? '') ??
          int.tryParse(quantity) ??
          0,
    );
    final childCount = _receiptInteger(
      ticket['childQty'],
      fallback: int.tryParse(childMatch?.group(1) ?? '') ?? 0,
    );
    final fee = _receiptInteger(ticket['adminFee'], fallback: adminFee);
    final paidTotal = _receiptInteger(ticket['total']);
    final unitPrice = _receiptInteger(
      ticket['unitPrice'],
      fallback: _receiptInteger(
        ticket['adultPrice'],
        fallback: adultCount > 0
            ? ((paidTotal > 0 ? paidTotal : fee) - fee) ~/ adultCount
            : 0,
      ),
    );
    final itemsTotal = adultCount * unitPrice;
    final promoDiscount = _receiptInteger(ticket['promoDiscount']);
    final promoName = ticket['promoName']?.toString() ?? '';
    final payableTotal = _receiptInteger(
      ticket['total'],
      fallback: itemsTotal + fee - promoDiscount,
    );
    final ticketCode =
        ticket['ticketId']?.toString() ??
        ticket['reservationCode']?.toString() ??
        '—';
    final orderIdValue = ticket['orderId']?.toString() ?? '—';
    final paymentDate = _receiptDate(
      ticket['paidAtIso']?.toString() ?? ticket['paidAt']?.toString(),
      includeTime: true,
    );
    final visitDate = _receiptVisitDate(ticket);
    final rescheduleInfo = ticket['rescheduleInfo'] is Map
        ? Map<String, dynamic>.from(ticket['rescheduleInfo'] as Map)
        : null;
    final rescheduleDate = DateTime.tryParse(
      rescheduleInfo?['tanggal_baru']?.toString() ?? '',
    );
    final rescheduleAmount = _receiptInteger(rescheduleInfo?['selisih_harga']);
    final phone = _receiptPhone(ticket['customerPhone']?.toString() ?? '');
    final rawPoolName = ticket['poolName']?.toString().trim() ?? '';
    final poolName = rawPoolName.isNotEmpty ? rawPoolName : selectedPoolName;
    final mono = const TextStyle(
      fontFamily: 'monospace',
      fontSize: 13,
      color: Color(0xff1f2937),
      height: 1.35,
    );
    final secondary = mono.copyWith(color: const Color(0xff4b5563));

    Widget detail(String label, String value, {bool bold = false}) {
      final style = bold ? mono.copyWith(fontWeight: FontWeight.w700) : mono;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(label, style: style)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(value, textAlign: TextAlign.right, style: style),
            ),
          ],
        ),
      );
    }

    Widget itemAmount(String description, String amount) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(child: Text(description, style: mono)),
            const SizedBox(width: 8),
            Text(amount, style: mono),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 360.0;
        final canvasWidth = math.min(360.0, availableWidth);
        final paperWidth = math.min(320.0, math.max(0.0, canvasWidth - 24));

        return SizedBox(
          width: canvasWidth,
          child: ColoredBox(
            color: const Color(0xffd1d5db),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: (canvasWidth - paperWidth) / 2,
                vertical: 18,
              ),
              child: ClipPath(
                clipper: TicketReceiptTearClipper(),
                child: Container(
                  width: paperWidth,
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'NEXPOOL',
                        style: mono.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(poolName, textAlign: TextAlign.center, style: mono),
                      Text(
                        'STRUK PEMBAYARAN TIKET',
                        textAlign: TextAlign.center,
                        style: secondary.copyWith(fontSize: 11),
                      ),
                      const SizedBox(height: 12),
                      _receiptDashedLine(),
                      const SizedBox(height: 12),
                      Text(
                        'KODE TIKET',
                        style: secondary.copyWith(fontSize: 11),
                      ),
                      const SizedBox(height: 3),
                      SizedBox(
                        width: double.infinity,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            ticketCode,
                            maxLines: 1,
                            style: mono.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _receiptDashedLine(),
                      const SizedBox(height: 10),
                      detail('Kunjungan', visitDate, bold: true),
                      detail(
                        'Pemesan',
                        ticket['customerName']?.toString() ?? '—',
                      ),
                      detail('Telepon', phone),
                      detail('Dibayar', paymentDate),
                      const SizedBox(height: 10),
                      _receiptDashedLine(),
                      const SizedBox(height: 10),
                      if (adultCount > 0) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Tiket Dewasa', style: mono),
                        ),
                        itemAmount(
                          '$adultCount x ${_receiptAmount(unitPrice)}',
                          _receiptAmount(itemsTotal),
                        ),
                      ],
                      if (childCount > 0) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Tiket Anak', style: mono),
                        ),
                        itemAmount('$childCount x Gratis', '0'),
                      ],
                      itemAmount('Biaya admin', _receiptAmount(fee)),
                      if (promoDiscount > 0)
                        itemAmount(
                          promoName.isEmpty
                              ? 'Potongan promo'
                              : 'Promo: $promoName',
                          '-${_receiptAmount(promoDiscount)}',
                        ),
                      const SizedBox(height: 10),
                      _receiptDashedLine(),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'TOTAL',
                              style: mono.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          Text(
                            rupiah(payableTotal),
                            style: mono.copyWith(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      detail('Metode', ticket['payment']?.toString() ?? '—'),
                      const SizedBox(height: 12),
                      Transform.rotate(
                        angle: -3 * math.pi / 180,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xff1f2937),
                              width: 2,
                            ),
                          ),
                          child: Text(
                            paymentStatus == 'paid'
                                ? 'LUNAS'
                                : paymentStatus.toUpperCase(),
                            style: mono.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _receiptDashedLine(),
                      if (rescheduleInfo != null && rescheduleDate != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          'INFORMASI RESCHEDULE',
                          style: mono.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _receiptDashedLine(),
                        const SizedBox(height: 8),
                        detail('Tanggal baru', formatDate(rescheduleDate)),
                        detail(
                          'Pembayaran reschedule',
                          rupiah(rescheduleAmount),
                        ),
                        detail(
                          'Status',
                          rescheduleAmount > 0 ? 'LUNAS' : 'BERHASIL',
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Dijadwalkan ulang ke ${formatDate(rescheduleDate)}',
                          textAlign: TextAlign.center,
                          style: secondary.copyWith(fontSize: 11),
                        ),
                        Text(
                          rescheduleAmount > 0
                              ? 'Selisih ${rupiah(rescheduleAmount)} sudah dibayar'
                              : 'Tidak ada selisih yang perlu dibayar',
                          textAlign: TextAlign.center,
                          style: secondary.copyWith(fontSize: 11),
                        ),
                        const SizedBox(height: 8),
                        _receiptDashedLine(),
                      ],
                      const SizedBox(height: 12),
                      Text('Order ID', style: secondary.copyWith(fontSize: 11)),
                      const SizedBox(height: 3),
                      Text(
                        orderIdValue,
                        textAlign: TextAlign.center,
                        style: secondary.copyWith(fontSize: 11),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Tunjukkan struk ini ke petugas di pintu masuk. '
                        'Berlaku pada tanggal kunjungan.',
                        textAlign: TextAlign.center,
                        style: secondary.copyWith(fontSize: 11),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Terima kasih, selamat berenang!',
                        textAlign: TextAlign.center,
                        style: secondary.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _receiptDashedLine() {
    return CustomPaint(
      painter: const TicketReceiptDashedLinePainter(Color(0xff9ca3af)),
      child: const SizedBox(width: double.infinity, height: 1),
    );
  }

  int _receiptInteger(Object? value, {int fallback = 0}) {
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  String _receiptAmount(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match.group(1)}.',
    );
  }

  String _receiptPhone(String value) {
    final phone = value.trim();
    if (phone.isEmpty) return '—';
    if (phone.startsWith('+')) return phone;
    if (phone.startsWith('0')) return '+62 ${phone.substring(1)}';
    if (phone.startsWith('62')) return '+$phone';
    return '+62 $phone';
  }

  String _receiptVisitDate(Map<String, dynamic> ticket) {
    final initialDate = ticket['initialVisitDate']?.toString();
    final date = DateTime.tryParse(
      initialDate?.isNotEmpty == true
          ? initialDate!
          : ticket['visitDate']?.toString() ?? '',
    );
    final displayDate = initialDate?.isNotEmpty == true
        ? null
        : ticket['date']?.toString();
    if (date != null) {
      final localDate = date.toLocal();
      if (displayDate != null &&
          displayDate.isNotEmpty &&
          displayDate != formatShortDate(localDate)) {
        return displayDate;
      }
      return formatDate(localDate);
    }
    return displayDate?.isNotEmpty == true ? displayDate! : '—';
  }

  String _receiptDate(String? value, {bool includeTime = false}) {
    if (value == null || value.trim().isEmpty) return '—';
    final date = DateTime.tryParse(value);
    if (date == null) return value;
    return includeTime
        ? formatDateTime(date.toLocal())
        : formatDate(date.toLocal());
  }

  Future<void> _downloadReceiptImage(
    GlobalKey receiptKey,
    Map<String, dynamic> ticket,
  ) async {
    try {
      await WidgetsBinding.instance.endOfFrame;
      final renderObject = receiptKey.currentContext?.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) {
        throw StateError('Gambar struk belum siap dibuat.');
      }

      final image = await renderObject.toImage(pixelRatio: 2);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      image.dispose();
      if (byteData == null) {
        throw StateError('Gagal mengubah struk menjadi gambar PNG.');
      }

      final fileName =
          'NexPool-Struk-${ticket['ticketId']?.toString() ?? 'Tiket'}'
              .replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '-');
      final savedPath = await FileSaver.instance.saveAs(
        name: fileName,
        bytes: byteData.buffer.asUint8List(),
        fileExtension: 'png',
        mimeType: MimeType.png,
        dialogTitle: 'Unduh bukti pembayaran',
      );
      if (savedPath != null && mounted) {
        showMessage('Bukti pembayaran berhasil diunduh.');
      }
    } catch (e) {
      debugPrint('Gagal mengunduh bukti pembayaran: $e');
      if (mounted) showMessage('Gagal mengunduh bukti pembayaran: $e');
    }
  }

  Widget sheetHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget sheetShell({
    required Widget child,
    required double height,
    double radius = 28,
    bool safeArea = false,
  }) {
    final content = Padding(padding: const EdgeInsets.all(20), child: child);

    return Container(
      height: MediaQuery.of(context).size.height * height,
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
      ),
      child: safeArea ? SafeArea(child: content) : content,
    );
  }

  Future<void> _downloadStep5Receipt() async {
    if (_isDownloadingReceipt) return;
    _updatePageState(() => _isDownloadingReceipt = true);

    try {
      await WidgetsBinding.instance.endOfFrame;
      final boundary =
          _step5ReceiptKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        throw StateError('Tampilan struk belum siap untuk disimpan.');
      }

      final image = await boundary.toImage(pixelRatio: 2);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      image.dispose();

      final bytes = byteData?.buffer.asUint8List();
      if (bytes == null || bytes.isEmpty) {
        throw StateError('Gagal membuat gambar struk pembayaran.');
      }

      final cleanTicket =
          (ticketId.isNotEmpty
                  ? ticketId
                  : (orderId.isNotEmpty ? orderId : 'Pembayaran'))
              .replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '-');
      final fileName = 'NexPool-Struk-$cleanTicket';

      final savedPath = await FileSaver.instance.saveAs(
        name: fileName,
        bytes: bytes,
        fileExtension: 'png',
        mimeType: MimeType.png,
        dialogTitle: 'Simpan Struk Pembayaran',
      );

      if (savedPath != null && mounted) {
        showMessage('Struk pembayaran berhasil disimpan ke galeri!');
      }
    } catch (e) {
      debugPrint('Gagal unduh struk: $e');
      if (mounted) showMessage('Gagal mengunduh struk: $e');
    } finally {
      if (mounted) _updatePageState(() => _isDownloadingReceipt = false);
    }
  }
}
