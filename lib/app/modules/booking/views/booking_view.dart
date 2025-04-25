import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tka_customer/app/routes/app_pages.dart';
import 'package:video_player/video_player.dart';

import '../../emergency/views/emergency_view.dart';
import '../componen/langkah_penggunaan.dart';
import '../componen/list_planning_servis.dart';
import '../componen/listservicecard.dart';
import '../componen/requesrepair.dart';
import '../controllers/booking_controller.dart';

class BookingView extends StatefulWidget {
  const BookingView({Key? key}) : super(key: key);

  @override
  State<BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<BookingView> {
  String searchQuery = '';
  DateTime? _selectedDate;
  final BookingController c = Get.put(BookingController());
  ConnectivityResult _connectivityStatus = ConnectivityResult.none;
  late StreamSubscription<dynamic> _connectivitySub;
  @override
  void initState() {
    super.initState();
    _connectivitySub = Connectivity().onConnectivityChanged.listen(
      _handleConnectivityChange,
    );
    _initConnectivity();
  }

  @override
  void dispose() {
    _connectivitySub.cancel();
    super.dispose();
  }

  void _handleConnectivityChange(dynamic raw) {
    ConnectivityResult status;
    if (raw is List<ConnectivityResult>) {
      if (raw.contains(ConnectivityResult.mobile)) {
        status = ConnectivityResult.mobile;
      } else if (raw.contains(ConnectivityResult.wifi)) {
        status = ConnectivityResult.wifi;
      } else {
        status = ConnectivityResult.none;
      }
    } else if (raw is ConnectivityResult) {
      status = raw;
    } else {
      status = ConnectivityResult.none;
    }
    setState(() {
      _connectivityStatus = status;
    });
  }

  Future<void> _initConnectivity() async {
    dynamic raw;
    try {
      raw = await Connectivity().checkConnectivity();
    } catch (_) {
      raw = ConnectivityResult.none;
    }
    _handleConnectivityChange(raw);
  }

  DateTime _parseCreatedAt(dynamic value) {
    if (value == null) return DateTime.fromMillisecondsSinceEpoch(0);
    if (value is int) {
      final millis = value < 10000000000 ? value * 1000 : value;
      return DateTime.fromMillisecondsSinceEpoch(millis).toLocal();
    }
    if (value is String) {
      try {
        return DateTime.parse(value).toLocal();
      } catch (_) {
        try {
          return DateFormat('yyyy-MM-dd HH:mm:ss').parseUtc(value).toLocal();
        } catch (_) {}
      }
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  DateTime _toLocalDateTime(dynamic raw) {
    if (raw == null) return DateTime.fromMillisecondsSinceEpoch(0);
    if (raw is int) {
      final millis = raw < 10000000000 ? raw * 1000 : raw;
      return DateTime.fromMillisecondsSinceEpoch(millis).toLocal();
    }
    if (raw is String) {
      try {
        return DateTime.parse(raw).toLocal();
      } catch (_) {
        try {
          return DateFormat('yyyy-MM-dd HH:mm:ss').parseUtc(raw).toLocal();
        } catch (_) {}
      }
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          onPressed: () => Get.toNamed(Routes.FORMREGULER),
          icon: const Icon(Icons.warning_rounded),
          label: const Text('Buat Reguler Repair'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: NestedScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          headerSliverBuilder:
              (_, __) => [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPlanning(c, isDark),
                        SizedBox(height: 10),
                        Text(
                          'Filter',
                          style: GoogleFonts.nunito(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.grey[300] : Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildFilterSection(isDark),
                        const SizedBox(height: 8),
                        RoundedDivider(
                          thickness: 1,
                          color: Colors.grey,
                          indent: 10,
                          endIndent: 10,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Riwayat Service',
                              style: GoogleFonts.lato(
                                textStyle: Theme.of(
                                  context,
                                ).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),

                            ElevatedButton.icon(
                              icon: const Icon(
                                Icons.info_outline,
                                size: 18,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Info',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed:
                                  () => Get.to(() => const UsageGuidePage()),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarDelegate(
                    backgroundColor: isDark ? Colors.grey[850]! : Colors.white,
                    child: PreferredSize(
                      preferredSize: const Size.fromHeight(kTextTabBarHeight),
                      child: _buildTabBar(isDark),
                    ),
                  ),
                ),
              ],
          body: TabBarView(
            children: [
              _buildRequestTab(c, isDark),
              _buildServiceTab(c, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _noConnection(String msg) => SingleChildScrollView(
    physics: const AlwaysScrollableScrollPhysics(),
    child: Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 80),
          Image.asset(
            'assets/icon/no_conexion.png',
            width: 100,
            height: 100,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 10),
          Text(
            msg,
            style: GoogleFonts.nunito(color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );

  Widget _serverDown(String msg) => SingleChildScrollView(
    physics: const AlwaysScrollableScrollPhysics(),
    child: Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 50),
          Image.asset(
            'assets/icon/server-down.png',
            width: 100,
            height: 100,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 10),
          Text(
            msg.isNotEmpty
                ? 'Mohon Maaf 🙏🏻\nAplikasi sedang terkendala Server,\nKami akan segera memperbaikinya'
                : 'Mohon Maaf 🙏🏻\nAplikasi sedang terkendala Server,\nKami akan segera memperbaikinya',
            style: GoogleFonts.nunito(color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );

  Widget _buildPlanning(BookingController c, bool isDark) => Obx(() {
    final waitingList =
        c.listService
            .where(
              (s) =>
                  (s.status ?? '').toString().toUpperCase() == 'NOT CONFIRMED',
            )
            .toList();

    if (waitingList.isEmpty) return const SizedBox.shrink();
    const double kRightPadding = 16;
    final bool single = waitingList.length == 1;
    final double screenW = MediaQuery.of(context).size.width;
    final double cardW = single ? screenW - kRightPadding : screenW * 0.80;
    final double cardH = single ? 200.0 : 220.0;

    return SizedBox(
      height: cardH,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: kRightPadding),
        itemCount: waitingList.length,
        itemBuilder:
            (_, i) => Container(
              width: cardW,
              height: cardH,
              margin: EdgeInsets.only(
                right: i == waitingList.length - 1 ? 0 : 12,
              ),
              child: PlanningServiceItemCard(service: waitingList[i]),
            ),
      ),
    );
  });

  Widget _buildRequestTab(BookingController c, bool isDark) => Obx(() {
    final filtered =
        c.listRequestService.where((r) {
            final nopol = (r.noPolisi ?? '').toLowerCase();
            final q = searchQuery.toLowerCase();
            final matchSearch = q.isEmpty || nopol.contains(q);

            bool matchDate = true;
            if (_selectedDate != null) {
              final created = DateFormat(
                'yyyy-MM-dd',
              ).format(_toLocalDateTime(r.createdAt!));
              final sel = DateFormat('yyyy-MM-dd').format(_selectedDate!);
              matchDate = created == sel;
            }
            return matchSearch && matchDate;
          }).toList()
          ..sort(
            (a, b) => _toLocalDateTime(
              b.createdAt!,
            ).compareTo(_toLocalDateTime(a.createdAt!)),
          );

    return RefreshIndicator(
      onRefresh: () => c.refreshAll(),
      displacement: 40,
      child:
          (c.debouncedStatus.value == ConnectivityResult.none ||
                  c.networkError.value)
              ? _noConnection(
                'Tidak ada jaringan\nMohon periksa kembali jaringan internet anda',
              )
              : c.errorRequest.value.isNotEmpty
              ? _serverDown(c.errorRequest.value)
              : c.isLoadingRequest.value
              ? _buildLoadingList(isDark)
              : filtered.isEmpty
              ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(top: 12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[850] : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _selectedDate != null
                            ? 'Tanggal yang Anda pilih tidak ada data'
                            : 'Tidak ada data Request Service\nKlik tombol biru untuk membuat Regular Repair',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              )
              : ListView.builder(
                padding: const EdgeInsets.only(top: 4, bottom: 120),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final r = filtered[i];
                  return InkWell(
                    onTap: () => _showRequestDetailBottomSheet(ctx, r),
                    child: RequestServiceItem(
                      tanggal: r.createdAt ?? '-',
                      status: r.status ?? '-',
                      noPolisi: r.noPolisi ?? '-',
                      keluhan: r.keluhan ?? '-',
                      kodereques: r.kodeRequestService ?? '-',
                      kodekendaraan: r.kodeKendaraan ?? '-',
                    ),
                  );
                },
              ),
    );
  });

  Widget _buildServiceTab(BookingController c, bool isDark) => Obx(() {
    final filtered =
        c.listService.where((s) {
            final nopol = (s.noPolisi ?? '').toLowerCase();
            final q = searchQuery.toLowerCase();
            final matchSearch = q.isEmpty || nopol.contains(q);

            bool matchDate = true;
            if (_selectedDate != null) {
              matchDate = false;
              for (final t in [s.tglEstimasi, s.tglPkb]) {
                if (t == null) continue;
                final d = DateFormat('yyyy-MM-dd').parse(t);
                if (DateFormat('yyyy-MM-dd').format(d) ==
                    DateFormat('yyyy-MM-dd').format(_selectedDate!)) {
                  matchDate = true;
                  break;
                }
              }
            }
            return matchSearch && matchDate;
          }).toList()
          ..sort(
            (a, b) => _parseCreatedAt(
              b.createdAt,
            ).compareTo(_parseCreatedAt(a.createdAt)),
          );

    return RefreshIndicator(
      onRefresh: () => c.refreshAll(),
      displacement: 40,
      child:
          _connectivityStatus == ConnectivityResult.none
              ? _noConnection(
                'Tidak ada jaringan\nMohon periksa kembali jaringan internet anda',
              )
              : c.errorRequest.value.isNotEmpty
              ? _serverDown(c.errorRequest.value)
              : c.isLoadingServices.value
              ? _buildLoadingList(isDark)
              : filtered.isEmpty
              ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(top: 12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[850] : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _selectedDate != null
                            ? 'Tanggal yang Anda pilih tidak ada data'
                            : 'Tidak ada data Service Kendaraan Anda',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              )
              : ListView.builder(
                padding: const EdgeInsets.only(bottom: 120),
                itemCount: filtered.length,
                itemBuilder:
                    (_, i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: ServiceItemCard(service: filtered[i]),
                    ),
              ),
    );
  });

  Widget _buildLoadingList(bool isDark) => Shimmer.fromColors(
    baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
    highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
    child: ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(10),
      itemCount: 3,
      itemBuilder:
          (_, __) => Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            height: 100,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
    ),
  );

  void _showRequestDetailBottomSheet(
    BuildContext context,
    RequestService data,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    Color _statusColor(String? s) {
      switch ((s ?? '').toLowerCase()) {
        case 'menunggu':
          return Colors.orange;
        case 'diterima':
          return Colors.green;
        case 'estimasi':
          return Colors.purple;
        case 'pkb':
          return Colors.indigo;
        case 'pkb tutup':
          return Colors.green;
        case 'invoice':
          return Colors.red;
        default:
          return Colors.blue;
      }
    }

    Widget _sectionTitle(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        t,
        style: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.primary,
        ),
      ),
    );

    Widget _detailRow(
      IconData icon,
      String label,
      String? value, {
      bool multiLine = false,
    }) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment:
            multiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: theme.hintColor),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                ),
                children: [
                  TextSpan(
                    text: '$label : ',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text: (value == null || value.isEmpty) ? '–' : value,
                    style: const TextStyle(fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              maxLines: multiLine ? null : 1,
              overflow:
                  multiLine ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder:
                (_, controller) => Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2B2B2B) : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      if (!isDark)
                        const BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.disabledColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(data.status!).withOpacity(.10),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.kodeRequestService ?? '-',
                              style: GoogleFonts.nunito(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _statusColor(data.status),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  (data.status ?? '-').toUpperCase(),
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _statusColor(data.status),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          controller: controller,
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                          children: [
                            _sectionTitle('Informasi Kendaraan'),
                            _detailRow(
                              Icons.directions_car,
                              'Kode Kendaraan',
                              data.kodeKendaraan,
                            ),
                            _detailRow(
                              Icons.numbers,
                              'No Polisi',
                              data.noPolisi,
                            ),
                            const SizedBox(height: 16),
                            _sectionTitle('Detail Service'),
                            _detailRow(Icons.badge, 'Kode SVC', data.kodeSvc),
                            _detailRow(
                              Icons.person,
                              'Kode Pelanggan',
                              data.kodePelanggan,
                            ),
                            _detailRow(
                              Icons.report_problem,
                              'Keluhan',
                              data.keluhan,
                              multiLine: true,
                            ),
                            _detailRow(
                              Icons.calendar_today,
                              'Tanggal Service',
                              data.tanggalService,
                            ),
                            _detailRow(
                              Icons.schedule,
                              'Jam Service',
                              data.jamService,
                            ),
                            _detailRow(
                              Icons.event,
                              'Created At',
                              data.createdAt,
                            ),
                            const SizedBox(height: 16),
                            _sectionTitle('Kode Lain'),
                            _detailRow(
                              Icons.confirmation_number,
                              'Kode Request Service',
                              data.kodeRequestService,
                            ),
                            const SizedBox(height: 16),
                            // Media Files Section
                            if (data.mediaFiles != null &&
                                data.mediaFiles!.isNotEmpty) ...[
                              _sectionTitle('Foto/Video'),
                              SizedBox(
                                height: 120,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: data.mediaFiles!.length,
                                  itemBuilder: (context, index) {
                                    final url = data.mediaFiles![index];
                                    final isVideo =
                                        url.toLowerCase().endsWith('.mp4') ||
                                        url.toLowerCase().endsWith('.mov');
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) =>
                                                    MediaViewerPage(url: url),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Stack(
                                            children: [
                                              Image.network(
                                                url,
                                                width: 120,
                                                height: 120,
                                                fit: BoxFit.cover,
                                                loadingBuilder: (
                                                  ctx,
                                                  child,
                                                  progress,
                                                ) {
                                                  if (progress == null)
                                                    return child;
                                                  return const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                },
                                                errorBuilder:
                                                    (ctx, err, st) => Container(
                                                      width: 120,
                                                      height: 120,
                                                      color: Colors.grey[300],
                                                      child: const Icon(
                                                        Icons.slow_motion_video,
                                                        size: 40,
                                                      ),
                                                    ),
                                              ),
                                              if (isVideo)
                                                Positioned(
                                                  bottom: 4,
                                                  right: 4,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black54,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      Icons.play_arrow,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _buildFilterSection(bool isDark) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: isDark ? Colors.grey[800] : Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: isDark ? Colors.black26 : Colors.grey.shade300,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: isDark ? Colors.white70 : Colors.grey,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _selectedDate == null
                    ? "Pilih Tanggal"
                    : "Tanggal: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}",
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            if (_selectedDate != null)
              IconButton(
                icon: Icon(
                  Icons.clear,
                  color: isDark ? Colors.white70 : Colors.grey,
                ),
                onPressed: () => setState(() => _selectedDate = null),
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  // ruang nyaman
                  horizontal: 10,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
              ),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
              child: const Text("Pilih"),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: isDark ? Colors.grey[700] : Colors.grey[200],
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari No Polisi',
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? const Color(0xFFF1F2F6) : Colors.grey[800],
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              style: GoogleFonts.nunito(
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black87,
              ),
              onChanged: (v) => setState(() => searchQuery = v),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildTabBar(bool isDark) {
    final BookingController c = Get.find<BookingController>();

    return Obx(() {
      final reqCount = c.filteredRequests.length;
      final svcCount = c.filteredServices.length;
      Widget badge(int count) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(8),
        ),
        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
        child: Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      );

      return TabBar(
        labelColor: isDark ? Colors.lightBlueAccent : Colors.blue,
        unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey,
        indicatorColor: Colors.transparent,
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Request Service'),
                if (reqCount > 0) ...[
                  const SizedBox(width: 4),
                  badge(reqCount),
                ],
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Service'),
                if (svcCount > 0) ...[
                  const SizedBox(width: 4),
                  badge(svcCount),
                ],
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final Color backgroundColor;
  _TabBarDelegate({required this.child, required this.backgroundColor});

  @override
  double get minExtent => (child as PreferredSizeWidget).preferredSize.height;
  @override
  double get maxExtent => minExtent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => Material(
    color: backgroundColor,
    elevation: overlapsContent ? 2 : 0,
    child: child,
  );

  @override
  bool shouldRebuild(_TabBarDelegate old) =>
      old.backgroundColor != backgroundColor || old.child != child;
}

class MediaViewerPage extends StatefulWidget {
  final String url;
  final int? width;
  final int? height;

  const MediaViewerPage({
    super.key,
    required this.url,
    this.width,
    this.height,
  });

  @override
  State<MediaViewerPage> createState() => _MediaViewerPageState();
}

class _MediaViewerPageState extends State<MediaViewerPage> {
  late final bool _isVideo;
  late double _realAspect;
  VideoPlayerController? _vCtrl;
  ChewieController? _cCtrl;

  @override
  void initState() {
    super.initState();
    _isVideo =
        widget.url.toLowerCase().endsWith('.mp4') ||
        widget.url.toLowerCase().endsWith('.mov');

    if (_isVideo) _initVideo();
  }

  Future<void> _initVideo() async {
    _vCtrl = VideoPlayerController.network(widget.url);
    await _vCtrl!.initialize();

    final meta = _vCtrl!.value.size;
    int rot = 0;

    try {
      rot = (_vCtrl!.value.rotationCorrection) ?? 0;
    } catch (_) {}
    double w = meta.width;
    double h = meta.height;
    if (rot == 90 || rot == 270) {
      final tmp = w;
      w = h;
      h = tmp;
    }
    _realAspect = (w == 0 || h == 0) ? 9 / 16 : w / h;

    if (widget.width != null &&
        widget.height != null &&
        widget.width! > 0 &&
        widget.height! > 0) {
      final apiAspect = widget.width! / widget.height!;
      if ((apiAspect - _realAspect).abs() > 0.15) _realAspect = apiAspect;
    }

    _cCtrl = ChewieController(
      videoPlayerController: _vCtrl!,
      autoPlay: true,
      looping: false,
      aspectRatio: _realAspect,
      additionalOptions: (context) => [],
    );

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _cCtrl?.dispose();
    _vCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    body: Center(child: _isVideo ? _videoView() : _imageView()),
  );

  Widget _videoView() {
    if (_cCtrl == null || !_cCtrl!.videoPlayerController.value.isInitialized) {
      return const CircularProgressIndicator();
    }

    return LayoutBuilder(
      builder: (ctx, c) {
        double h = c.maxHeight;
        double w = h * _realAspect;

        if (w > c.maxWidth) {
          w = c.maxWidth;
          h = w / _realAspect;
        }

        return SizedBox(
          width: w,
          height: h,
          child: Chewie(controller: _cCtrl!),
        );
      },
    );
  }

  Widget _imageView() => PhotoView(
    imageProvider: NetworkImage(widget.url),
    backgroundDecoration: const BoxDecoration(color: Colors.black),
  );
}

typedef RequestService = dynamic;
