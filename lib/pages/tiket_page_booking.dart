part of 'tiket_page.dart';

extension _TicketBookingUi on _TiketPageState {
  Widget colorfulIcon({
    required IconData icon,
    required Color color,
    Color? bgColor,
    double size = 20,
    double boxSize = 40,
    double radius = 12,
    bool isCircle = false,
  }) {
    return Container(
      width: boxSize,
      height: boxSize,
      decoration: BoxDecoration(
        color: bgColor ?? color.withOpacity(0.14),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(radius),
      ),
      child: Center(
        child: Icon(icon, color: color, size: size),
      ),
    );
  }

  Widget infoBox({
    required Widget child,
    Color color = kSoft,
    double radius = 14,
    double pad = 14,
    Color? border,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: border == null ? null : Border.all(color: border),
      ),
      child: child,
    );
  }

  Widget pad20(Widget child, {double top = 0, double bottom = 0}) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: top, bottom: bottom),
      child: child,
    );
  }

  Widget sectionTitle(String title, {IconData? icon, Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
      child: Row(
        children: [
          if (icon != null) ...[
            colorfulIcon(
              icon: icon,
              color: iconColor ?? kBlue,
              boxSize: 32,
              size: 18,
            ),
            const SizedBox(width: 10),
          ],
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget navButtons(int backStep, String nextText, VoidCallback? onNext) {
    return pad20(
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => goStep(backStep),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('← Kembali'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: onNext,
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
              child: Text(
                nextText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      bottom: 20,
    );
  }

  Widget recapDate() {
    return pad20(
      infoBox(
        color: context.softBg,
        radius: 14,
        pad: 14,
        child: Row(
          children: [
            colorfulIcon(
              icon: Icons.calendar_month_rounded,
              color: kBlue,
              boxSize: 38,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedDateLabel.isEmpty
                        ? 'Tanggal belum dipilih'
                        : selectedDateLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${isWeekend ? 'Weekend' : 'Weekday'} • $selectedPoolName',
                    style: const TextStyle(
                      fontSize: 11,
                      color: kAqua,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => goStep(1),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kBlue.withOpacity(0.3)),
                ),
                child: const Text(
                  'Ubah',
                  style: TextStyle(
                    fontSize: 11,
                    color: kBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      top: 14,
      bottom: 4,
    );
  }

  /// Kartu kecil berisi nama & nomor HP pemesan (dari akun yang login)
  Widget pemesanCard() {
    return pad20(
      infoBox(
        color: context.cardBg,
        radius: 14,
        pad: 12,
        border: Colors.grey.shade200,
        child: Row(
          children: [
            colorfulIcon(
              icon: Icons.person_rounded,
              color: kPurple,
              boxSize: 38,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PEMESAN (AKUN KAMU)',
                    style: TextStyle(
                      fontSize: 9,
                      color: context.mutedText,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    nama.isEmpty ? 'Memuat data akun...' : nama,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    phoneDisplay,
                    style: TextStyle(
                      fontSize: 11,
                      color: context.mutedText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            colorfulIcon(
              icon: Icons.verified_user_rounded,
              color: kGreen,
              boxSize: 30,
              size: 16,
            ),
          ],
        ),
      ),
      top: 10,
    );
  }

  Widget dateStrip({
    required List<DateTime> list,
    required DateTime? active,
    required ValueChanged<DateTime> onPick,
    EdgeInsets padding = EdgeInsets.zero,
    double height = 75,
    DateTime? minimumSelectableDate,
  }) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: list.length,
        itemBuilder: (context, i) {
          final date = list[i];
          final isSel = sameDay(active, date);
          final weekend = isWeekendDate(date);
          final isDisabled =
              minimumSelectableDate != null &&
              DateUtils.dateOnly(date)
                  .isBefore(DateUtils.dateOnly(minimumSelectableDate));

          return GestureDetector(
            onTap: isDisabled ? null : () => onPick(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 58,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isDisabled
                    ? kRed.withOpacity(.12)
                    : isSel
                    ? kBlue
                    : weekend
                    ? kYellowSoft
                    : context.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDisabled
                      ? kRed.withOpacity(.45)
                      : isSel
                      ? kBlue
                      : weekend
                      ? kGold.withOpacity(0.6)
                      : context.isDark
                      ? AppTheme.darkSoft
                      : Colors.grey.shade300,
                  width: isSel ? 2 : 1,
                ),
                boxShadow: isSel
                    ? [
                        BoxShadow(
                          color: kBlue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    kDayShort[date.weekday - 1],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isDisabled
                          ? kRed
                          : isSel
                          ? Colors.white70
                          : weekend
                          ? const Color(0xff9a6c00)
                          : context.mutedText,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isDisabled
                          ? kRed
                          : isSel
                          ? Colors.white
                          : weekend
                          ? const Color(0xff7a5800)
                          : context.textMain,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _TiketPageState._months[date.month - 1].substring(0, 3),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: isDisabled
                          ? kRed
                          : isSel
                          ? Colors.white70
                          : weekend
                          ? const Color(0xff9a6c00)
                          : context.mutedText,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildTabs() {
    return pad20(
      Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _openBookingTab,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: selectedTab == 0 ? kBlue : Colors.transparent,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_shopping_cart_rounded,
                        size: 16,
                        color: selectedTab == 0 ? Colors.white : Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Pesan Tiket',
                        style: TextStyle(
                          color: selectedTab == 0
                              ? Colors.white
                              : Colors.grey.shade700,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => _updatePageState(() => selectedTab = 1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: selectedTab == 1 ? kBlue : Colors.transparent,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.confirmation_number_rounded,
                        size: 16,
                        color: selectedTab == 1 ? Colors.white : Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Tiket Saya (${myTickets.length})',
                        style: TextStyle(
                          color: selectedTab == 1
                              ? Colors.white
                              : Colors.grey.shade700,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      top: 14,
    );
  }

  // ============================================================
  // STEPPER — 4 langkah: Tanggal, Tiket, Bayar, Struk
  // (id langkah internal: 1, 3, 4, 5 — langkah 2 sudah dihapus)
  // ============================================================
  Widget buildStepper() {
    const labels = ['Tanggal', 'Tiket', 'Bayar', 'Struk'];
    const stepIds = [1, 3, 4, 5];

    return pad20(
      Row(
        children: List.generate(labels.length, (index) {
          final step = stepIds[index];
          final done = currentStep > step;
          final active = currentStep == step;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: done
                              ? kGreen
                              : active
                              ? kBlue
                              : Colors.grey.shade300,
                          boxShadow: active
                              ? [
                                  BoxShadow(
                                    color: kBlue.withOpacity(0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: Center(
                          child: done
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 18,
                                )
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: active
                                        ? Colors.white
                                        : Colors.grey.shade700,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        labels[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: active
                              ? kAqua
                              : done
                              ? const Color(0xff06a77d)
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < labels.length - 1)
                  Container(
                    width: 15,
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 17),
                    color: currentStep > step ? kBlue : Colors.grey.shade300,
                  ),
              ],
            ),
          );
        }),
      ),
      top: 14,
      bottom: 6,
    );
  }

  Widget buildStep1() {
    return Column(
      children: [
        sectionTitle(
          'Kolam Renang Terpilih',
          icon: Icons.pool_rounded,
          iconColor: kAqua,
        ),

        _buildSelectedPoolCard(),

        sectionTitle(
          'Pilih Tanggal Kunjungan',
          icon: Icons.calendar_month_rounded,
          iconColor: kBlue,
        ),

        dateStrip(
          list: dates,
          active: selectedDate,
          onPick: selectDate,
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),

        pad20(
          infoBox(
            child: Row(
              children: [
                colorfulIcon(
                  icon: selectedDate == null
                      ? Icons.info_rounded
                      : Icons.event_available_rounded,
                  color: kAqua,
                  boxSize: 30,
                  size: 16,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    selectedDate == null
                        ? 'Silakan pilih tanggal di atas'
                        : '$selectedDateLabel — ${isWeekend ? 'Weekend' : 'Weekday'}',
                    style: const TextStyle(
                      color: kAqua,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          top: 8,
          bottom: 15,
        ),

        const SizedBox(height: 18),

        pad20(
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedDate == null
                  ? null
                  : () {
                      // Pemesanan butuh akun. Data pemesan diambil dari akun.
                      if (!isLoggedIn) {
                        showMessage('Silakan login dulu untuk memesan tiket.');
                        return;
                      }
                      goStep(3);
                    },
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
              child: const Text(
                'Lanjut Pilih Tiket →',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // ── Tombol Lihat Tiket Saya ─────────────────────────────────
        pad20(
          GestureDetector(
            onTap: () => _updatePageState(() => selectedTab = 1),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kGold.withOpacity(0.7), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: kGold.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: context.isDark
                          ? const Color(0xFF3B3424)
                          : kYellowSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.confirmation_number_rounded,
                      color: kOrange,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lihat Tiket Saya',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: context.textMain,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${myTickets.length} tiket tersimpan · Tap untuk lihat detail',
                          style: TextStyle(
                            fontSize: 11,
                            color: context.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: kOrange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${myTickets.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: context.mutedText,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  /// Card Single Kolam Renang yang Terintegrasi dari Dashboard
  Widget _buildSelectedPoolCard() {
    final normalizedId = normalizePoolId(selectedPoolId);
    final poolInfo = kAllPoolsList.firstWhere(
      (p) => p['id'] == selectedPoolId || p['normalizedId'] == normalizedId,
      orElse: () => {
        'id': selectedPoolId,
        'normalizedId': normalizedId,
        'name': selectedPoolName,
        'shortName': selectedPoolName,
        'icon': '🏊',
        'location': 'Jember, Jawa Timur',
      },
    );

    return pad20(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [kBlue.withOpacity(0.08), kDarkBlue.withOpacity(0.04)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBlue.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: kBlue.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            colorfulIcon(
              icon: Icons.water_rounded,
              color: kBlue,
              boxSize: 44,
              size: 24,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: kBlue,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          normalizedId,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: kGreen.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.sync_alt_rounded,
                              size: 10,
                              color: kGreen,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Pilihan Dashboard',
                              style: TextStyle(
                                color: kGreen,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    selectedPoolName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: context.textMain,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          poolInfo['location'] ?? 'Jember, Jawa Timur',
                          style: TextStyle(
                            fontSize: 11,
                            color: context.mutedText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      top: 4,
      bottom: 12,
    );
  }

  Widget buildStep3() {
    return Column(
      children: [
        recapDate(),

        // Pemesan diambil otomatis dari akun yang login
        pemesanCard(),

        sectionTitle(
          'Kategori & Jumlah Tiket',
          icon: Icons.confirmation_number_rounded,
          iconColor: kOrange,
        ),

        if (isPriceLoading)
          pad20(
            const Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text(
                  'Mengambil harga tiket dari server...',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            top: 8,
            bottom: 8,
          ),

        if (!isPriceLoading && priceError.isNotEmpty)
          pad20(
            infoBox(
              color: Colors.red.shade50,
              radius: 10,
              pad: 10,
              child: Row(
                children: [
                  colorfulIcon(
                    icon: Icons.error_rounded,
                    color: kRed,
                    boxSize: 30,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      priceError,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            top: 8,
            bottom: 8,
          ),

        pad20(
          Row(
            children: [
              categoryCard(
                Icons.face_rounded,
                kBlue,
                'Dewasa',
                isPriceLoading
                    ? 'Memuat...'
                    : adultPrice > 0
                    ? rupiah(adultPrice)
                    : 'Belum tersedia',
                'Tinggi > 100cm',
                category == 'dewasa',
                () => _updatePageState(() => category = 'dewasa'),
              ),
              const SizedBox(width: 10),
              categoryCard(
                Icons.child_care_rounded,
                kGreen,
                'Anak-anak',
                'Gratis',
                'Tinggi ≤ 100cm',
                category == 'anak',
                () => _updatePageState(() => category = 'anak'),
              ),
            ],
          ),
        ),

        buildPromoSelector(),

        pad20(
          infoBox(
            color: context.isDark ? const Color(0xFF3B3424) : kYellowSoft,
            radius: 10,
            pad: 10,
            child: Row(
              children: [
                colorfulIcon(
                  icon: Icons.info_rounded,
                  color: context.isDark
                      ? const Color(0xFFFFD166)
                      : const Color(0xff9a6c00),
                  boxSize: 30,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Harga ${isWeekend ? 'weekend' : 'weekday'} untuk $selectedPoolName mengikuti tarif resmi server. Anak ≤100cm gratis.',
                    style: TextStyle(
                      fontSize: 10,
                      color: context.isDark
                          ? const Color(0xFFFFD166)
                          : const Color(0xff7a5800),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          top: 10,
        ),

        sectionTitle(
          'Jumlah Tiket',
          icon: Icons.group_add_rounded,
          iconColor: kAqua,
        ),

        buildQuantity(
          'Dewasa',
          'Tinggi > 100cm',
          qtyAdult,
          Icons.person_rounded,
          kBlue,
          (v) {
            if (reservationCode.isNotEmpty) {
              showMessage(
                'Jumlah tiket tidak dapat diubah setelah reservasi dibuat.',
              );
              return;
            }
            _updatePageState(() => qtyAdult = (qtyAdult + v).clamp(0, 20));
          },
        ),

        buildQuantity(
          'Anak-anak',
          'Tinggi ≤ 100cm (Gratis)',
          qtyChild,
          Icons.child_care_rounded,
          kGreen,
          (v) {
            if (reservationCode.isNotEmpty) {
              showMessage(
                'Jumlah tiket tidak dapat diubah setelah reservasi dibuat.',
              );
              return;
            }
            _updatePageState(() => qtyChild = (qtyChild + v).clamp(0, 20));
          },
        ),

        sectionTitle(
          'Keterangan Tiket (Opsional)',
          icon: Icons.edit_note_rounded,
          iconColor: kPurple,
        ),

        pad20(
          TextField(
            controller: keteranganController,
            maxLength: 200,
            maxLines: 3,
            onChanged: (v) => keterangan = v,
            decoration: InputDecoration(
              hintText:
                  'Contoh: Kunjungan rombongan keluarga, ulang tahun, dll...',
              filled: true,
              fillColor: context.softBg,
              border: fieldBorder(),
              enabledBorder: fieldBorder(),
              focusedBorder: fieldBorder(color: kBlue, width: 1.5),
            ),
          ),
        ),

        const SizedBox(height: 4),

        buildSummary(),

        // Kembali -> langsung ke langkah Tanggal (langkah 1)
        navButtons(
          1,
          isCreatingPayment ? 'Menyiapkan QRIS...' : 'Lanjut Pembayaran →',
          isPriceLoading ||
                  priceError.isNotEmpty ||
                  adultPrice <= 0 ||
                  qtyAdult <= 0 ||
                  isCreatingPayment
              ? null
              : _createReservationAndQris,
        ),
      ],
    );
  }

  Widget categoryCard(
    IconData icon,
    Color iconColor,
    String name,
    String price,
    String desc,
    bool selected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? (context.isDark ? AppTheme.darkSoft : kSoft)
                : context.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? kBlue
                  : context.isDark
                  ? AppTheme.darkSoft
                  : Colors.grey.shade300,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              colorfulIcon(icon: icon, color: iconColor, boxSize: 44, size: 24),
              const SizedBox(height: 8),
              Text(
                name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: context.textMain,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                price,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: context.isDark ? Color(0xFF80D9E8) : kAqua,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 9,
                  color: context.mutedText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPromoSelector() {
    final selectedPromo = _selectedPromo;
    final promoName = selectedPromo?['nama']?.toString() ?? '';
    final subtitle = _promosLoading
        ? 'Memuat promo untuk tanggal kunjungan...'
        : selectedPromo != null
        ? '$promoName • Hemat ${rupiah(discountAmount)}'
        : _availablePromos.isNotEmpty
        ? '${_availablePromos.length} promo tersedia untuk kolam ini'
        : _promoError.isNotEmpty
        ? _promoError
        : 'Belum ada promo aktif untuk tanggal ini';

    return pad20(
      Material(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: _promosLoading ? null : _choosePromo,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selectedPromo == null
                    ? Colors.grey.shade300
                    : kAqua.withOpacity(0.55),
              ),
            ),
            child: Row(
              children: [
                colorfulIcon(
                  icon: Icons.local_offer_rounded,
                  color: kAqua,
                  boxSize: 40,
                  size: 20,
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedPromo == null ? 'Pakai Promo' : 'Promo Dipilih',
                        style: TextStyle(
                          color: context.textMain,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selectedPromo == null
                              ? context.mutedText
                              : kAqua,
                          fontSize: 11,
                          fontWeight: selectedPromo == null
                              ? FontWeight.w500
                              : FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_promosLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (_promoError.isNotEmpty)
                  IconButton(
                    tooltip: 'Muat ulang promo',
                    onPressed: _loadAvailablePromos,
                    icon: const Icon(Icons.refresh_rounded, color: kAqua),
                  )
                else
                  const Icon(Icons.chevron_right_rounded, color: kAqua),
              ],
            ),
          ),
        ),
      ),
      top: 8,
      bottom: 4,
    );
  }

  Widget buildQuantity(
    String title,
    String subtitle,
    int value,
    IconData icon,
    Color iconColor,
    ValueChanged<int> onChange,
  ) {
    return pad20(
      infoBox(
        color: context.cardBg,
        radius: 14,
        pad: 12,
        border: Colors.grey.shade200,
        child: Row(
          children: [
            _TicketBookingUi(
              this,
            ).colorfulIcon(icon: icon, color: iconColor, boxSize: 38, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
            ),
            quantityButton(Icons.remove_rounded, () => onChange(-1)),
            SizedBox(
              width: 36,
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            quantityButton(Icons.add_rounded, () => onChange(1)),
          ],
        ),
      ),
      bottom: 10,
    );
  }

  Widget quantityButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: context.softBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kBlue.withOpacity(0.2)),
        ),
        child: Center(child: Icon(icon, size: 18, color: kBlue)),
      ),
    );
  }

  Widget buildSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: kGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: kDarkBlue.withOpacity(0.25),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                colorfulIcon(
                  icon: Icons.receipt_long_rounded,
                  color: Colors.white,
                  bgColor: Colors.white.withOpacity(0.2),
                  boxSize: 32,
                  size: 18,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Ringkasan Pesanan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            summaryRow('Tiket Dewasa × $qtyAdult', rupiah(ticketSubtotal)),
            if (qtyChild > 0) summaryRow('Tiket Anak × $qtyChild', 'Gratis'),
            if (discountAmount > 0)
              summaryRow('Potongan Promo', '-${rupiah(discountAmount)}'),
            summaryRow('Kolam Renang', selectedPoolName),
            summaryRow(
              'Tanggal Kunjungan',
              selectedDate == null ? '—' : formatShortDate(selectedDate!),
            ),
            summaryRow('Biaya Layanan Admin', rupiah(adminFee)),
            const Divider(color: Colors.white24, height: 20),
            _TicketBookingUi(
              this,
            ).summaryRow('Total Pembayaran', rupiah(totalPrice), total: true),
          ],
        ),
      ),
    );
  }

  Widget summaryRow(String label, String value, {bool total = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontSize: total ? 13 : 12,
                fontWeight: total ? FontWeight.w700 : null,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: total ? kGold : Colors.white,
              fontSize: total ? 20 : 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
