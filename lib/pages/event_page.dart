import 'package:flutter/material.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  // ==========================================================
  // FILTER
  // ==========================================================

  int selectedFilter = 0;

  final List<String> filters = [
    'Semua',
    'Akan Datang',
    'Berlangsung',
    'Selesai',
  ];

  // ==========================================================
  // DATA EVENT
  // ==========================================================

  final List<Map<String, dynamic>> events = [
    {
      'title': 'Fun Swimming Competition 2026',
      'location': 'Tiara Jember Park',
      'date': '28 Sep 2026',
      'time': '07.00 – 15.00 WIB',
      'category': 'Kompetisi',
      'status': 'Akan Datang',
      'icon': '🏆',
      'color': const Color(0xff0077b6),
      'bgColor': const Color(0xffe0f4ff),
      'desc': 'Kompetisi renang seru untuk semua usia! Daftarkan dirimu dan raih hadiah menarik senilai jutaan rupiah.',
      'prize': 'Hadiah Rp5.000.000',
    },
    {
      'title': 'Water Splash Festival',
      'location': 'Annasya Waterpark',
      'date': '5 Okt 2026',
      'time': '09.00 – 17.00 WIB',
      'category': 'Festival',
      'status': 'Akan Datang',
      'icon': '💦',
      'color': const Color(0xff0096c7),
      'bgColor': const Color(0xffe0f9ff),
      'desc': 'Festival air terbesar di Jember! Nikmati berbagai wahana, pertunjukan, dan hiburan keluarga sepanjang hari.',
      'prize': 'Free Entry Anak < 5 Tahun',
    },
    {
      'title': 'Lomba Renang Antar Sekolah',
      'location': 'Kebon Agung',
      'date': '21 Sep 2026',
      'time': '08.00 – 13.00 WIB',
      'category': 'Kompetisi',
      'status': 'Berlangsung',
      'icon': '🎓',
      'color': const Color(0xff4cc9f0),
      'bgColor': const Color(0xffe8f8ff),
      'desc': 'Ajang adu prestasi renang antar pelajar SD, SMP, SMA se-Kabupaten Jember. Bergengsi dan berhadiah!',
      'prize': 'Piala + Sertifikat',
    },
    {
      'title': 'Family Fun Day',
      'location': 'Dira Park',
      'date': '14 Sep 2026',
      'time': '08.00 – 16.00 WIB',
      'category': 'Hiburan',
      'status': 'Selesai',
      'icon': '👨‍👩‍👧‍👦',
      'color': const Color(0xff48cae4),
      'bgColor': const Color(0xffe8f9fc),
      'desc': 'Hari kebersamaan keluarga penuh keceriaan dengan berbagai permainan air, musik, dan kuliner lezat.',
      'prize': 'Diskon 50% Tiket Keluarga',
    },
    {
      'title': 'Aqua Kids Challenge',
      'location': 'Jati Park',
      'date': '12 Okt 2026',
      'time': '08.30 – 12.00 WIB',
      'category': 'Anak-anak',
      'status': 'Akan Datang',
      'icon': '🧒',
      'color': const Color(0xff023e8a),
      'bgColor': const Color(0xffe0eeff),
      'desc': 'Kompetisi renang khusus anak usia 4–12 tahun. Aman, menyenangkan, dan penuh semangat!',
      'prize': 'Medali + Tas Renang',
    },
    {
      'title': 'Night Swimming Gala',
      'location': 'Tiara Jember Park',
      'date': '18 Okt 2026',
      'time': '18.00 – 22.00 WIB',
      'category': 'Festival',
      'status': 'Akan Datang',
      'icon': '🌙',
      'color': const Color(0xff03045e),
      'bgColor': const Color(0xffe8eaff),
      'desc': 'Rasakan sensasi berenang di malam hari dengan tata cahaya spektakuler dan musik live yang meriah!',
      'prize': 'Tiket Spesial Rp25.000',
    },
  ];

  // ==========================================================
  // FILTER EVENT
  // ==========================================================

  List<Map<String, dynamic>> get filteredEvents {
    if (selectedFilter == 0) return events;
    final label = filters[selectedFilter];
    return events.where((e) => e['status'] == label).toList();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f8ff),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterChips(),
            Expanded(
              child: filteredEvents.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      itemCount: filteredEvents.length,
                      itemBuilder: (context, index) {
                        return _buildEventCard(filteredEvents[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // HEADER
  // ==========================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff0077b6), Color(0xff00b4d8)],
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Event 🎉',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Acara seru di kolam renang Jember',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '🗓️ Sep – Okt 2026',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // FILTER CHIPS
  // ==========================================================

  Widget _buildFilterChips() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: SizedBox(
        height: 34,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final selected = selectedFilter == i;

            // Count for each filter
            int count = 0;
            if (i == 0) {
              count = events.length;
            } else {
              count = events.where((e) => e['status'] == filters[i]).length;
            }

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedFilter = i;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xff0077b6)
                      : const Color(0xfff0f8ff),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? const Color(0xff0077b6)
                        : Colors.grey.shade200,
                  ),
                ),
                child: Text(
                  '${filters[i]} ($count)',
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ==========================================================
  // EVENT CARD
  // ==========================================================

  Widget _buildEventCard(Map<String, dynamic> event) {
    final Color color = event['color'] as Color;
    final Color bgColor = event['bgColor'] as Color;
    final String status = event['status'].toString();

    Color statusColor;
    Color statusBg;

    switch (status) {
      case 'Berlangsung':
        statusColor = const Color(0xff2d9d4a);
        statusBg = const Color(0xffe6f9ec);
        break;
      case 'Selesai':
        statusColor = Colors.grey.shade600;
        statusBg = Colors.grey.shade100;
        break;
      default:
        statusColor = const Color(0xff0077b6);
        statusBg = const Color(0xffe0f4ff);
    }

    return GestureDetector(
      onTap: () => _showEventDetail(event),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // TOP BANNER
            Container(
              height: 90,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
              ),
              child: Stack(
                children: [
                  // Big emoji background
                  Positioned(
                    right: 20,
                    top: 10,
                    child: Text(
                      event['icon'].toString(),
                      style: const TextStyle(fontSize: 62),
                    ),
                  ),

                  // Category tag
                  Positioned(
                    top: 12,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color.withOpacity(.3)),
                      ),
                      child: Text(
                        event['category'].toString(),
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),

                  // Status badge
                  Positioned(
                    bottom: 12,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            status,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // CONTENT
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title'].toString(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xff172B4D),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    event['desc'].toString(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Meta info row
                  Row(
                    children: [
                      _metaChip(
                        Icons.location_on_outlined,
                        event['location'].toString(),
                        color,
                      ),
                      const SizedBox(width: 8),
                      _metaChip(
                        Icons.calendar_today_outlined,
                        event['date'].toString(),
                        color,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      _metaChip(
                        Icons.access_time_outlined,
                        event['time'].toString(),
                        color,
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color, color.withOpacity(.7)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          event['prize'].toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
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
    );
  }

  Widget _metaChip(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // EMPTY STATE
  // ==========================================================

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎭', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          const Text(
            'Belum Ada Event',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xff172B4D),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tidak ada event di kategori ini.',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // DETAIL BOTTOM SHEET
  // ==========================================================

  void _showEventDetail(Map<String, dynamic> event) {
    final Color color = event['color'] as Color;
    final Color bgColor = event['bgColor'] as Color;
    final String status = event['status'].toString();

    Color statusColor;
    switch (status) {
      case 'Berlangsung':
        statusColor = const Color(0xff2d9d4a);
        break;
      case 'Selesai':
        statusColor = Colors.grey.shade600;
        break;
      default:
        statusColor = const Color(0xff0077b6);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * .7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Drag handle
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Banner
              Container(
                margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                height: 110,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 20,
                      top: 10,
                      child: Text(
                        event['icon'].toString(),
                        style: const TextStyle(fontSize: 70),
                      ),
                    ),
                    Positioned(
                      top: 14,
                      left: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              event['category'].toString(),
                              style: TextStyle(
                                color: color,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                status,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
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

              // Content scrollable
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['title'].toString(),
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Color(0xff172B4D),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        event['desc'].toString(),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 18),

                      _detailRow('📍', 'Lokasi', event['location'].toString()),
                      _detailRow('📅', 'Tanggal', event['date'].toString()),
                      _detailRow('⏰', 'Waktu', event['time'].toString()),
                      _detailRow(
                        '🎁',
                        'Hadiah / Benefit',
                        event['prize'].toString(),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: status == 'Selesai'
                              ? null
                              : () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '✅ Berhasil daftar: ${event['title']}',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: status == 'Selesai'
                                ? Colors.grey.shade300
                                : color,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            status == 'Selesai'
                                ? 'Event Telah Berakhir'
                                : '🎉 Daftar Sekarang',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String emoji, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff172B4D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
