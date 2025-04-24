import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:geocoding/geocoding.dart';
import 'package:tka_customer/app/modules/emergency/controllers/emergency_controller.dart';
import 'package:tka_customer/app/routes/app_pages.dart';
import 'package:tka_customer/app/data/data_respon/list_emergency.dart';

import '../componen/langkah_penggunaan.dart';

class EmergencyView extends GetView<EmergencyController> {
  const EmergencyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final EmergencyController c = Get.put(EmergencyController());
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : const Color(0xFFF6F7FB),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        onPressed: () => Get.toNamed(Routes.FORMEMERGENCY),
        icon: const Icon(Icons.warning_rounded),
        label: const Text('Buat Emergency Service'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: RefreshIndicator(
        onRefresh: c.fetchEmergencyList,
        child: Obx(() {
          // ─── 1. LOADING ──────────────────────────────────────────
          if (c.isLoading.value) {
            return _buildLoadingState(isDark, c, context);
          }

          // ─── 2. OFFLINE (interface NONE atau pesan jaringan) ────
          final bool offlineInterface =
              c.debouncedStatus.value == ConnectivityResult.none;

          final String errLower = c.errorMessage.value.toLowerCase();
          final bool offlineMsg = errLower.contains('tidak ada jaringan') ||
              errLower.contains('no internet') ||
              errLower.contains('socket') ||
              errLower.contains('failed host');

          if (offlineInterface || offlineMsg) {
            return const _NoConnectionWidget();
          }

          // ─── 3. SERVER ERROR (online, tapi ada pesan) ────────────
          if (c.errorMessage.value.isNotEmpty) {
            return  _ServerDownWidget();
          }
          // ─── 4. DATA NORMAL ─────────────────────────────────────
          return _buildMainContent(isDark, c, context);
        })

      ),
    );
  }


  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildLoadingState(bool isDark, EmergencyController c,
      BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Filter',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey[300] : Colors.grey[800],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildFilterSection(context, c),
          const SizedBox(height: 8),
          const RoundedDivider(
              thickness: 1, color: Colors.grey, indent: 10, endIndent: 10),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ─── Judul ───────────────────────────────────────────────
              Text(
                'Riwayat Layanan Darurat',
                style: GoogleFonts.lato(
                  textStyle: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),

              // ─── Tombol Info ────────────────────────────────────────
              ElevatedButton.icon(
                icon: const Icon(Icons.info_outline, size: 18, color: Colors.white),
                label: const Text(
                  'Info',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,        // latar jingga
                  elevation: 0,                          // flat look
                  padding: const EdgeInsets.symmetric(   // ruang nyaman
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Get.to(() => const EmergencyGuidePage()),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Column(children: List.generate(5, (_) => ShimmerEmergencyItem(isDark: isDark))),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildMainContent(bool isDark, EmergencyController c,
      BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Filter',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey[300] : Colors.grey[800],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildFilterSection(context, c),
          const SizedBox(height: 8),
          const RoundedDivider(
              thickness: 1, color: Colors.grey, indent: 10, endIndent: 10),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ─── Judul ───────────────────────────────────────────────
              Text(
                'Riwayat Layanan Darurat',
                style: GoogleFonts.lato(
                  textStyle: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),

              // ─── Tombol Info (ikon + teks, warna jingga) ─────────────
              ElevatedButton.icon(
                icon: const Icon(Icons.info_outline, size: 18, color: Colors.white),
                label: const Text(
                  'Info',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,        // latar jingga
                  elevation: 0,                          // flat look
                  padding: const EdgeInsets.symmetric(   // ruang nyaman
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Get.to(() => const EmergencyGuidePage()),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (c.emergencyList.isEmpty)
            _EmptyState(isDark: isDark, dateFilter: c.dateFilter)
          else
            Column(
              children: c.emergencyList
                  .map((Data item) => _EmergencyItemCard(item: item))
                  .toList(),
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ─── FILTER SECTION (kode asli Anda) ──────────────────────────────────────
  Widget _buildFilterSection(BuildContext context, EmergencyController c) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    String formatDate(DateTime? date) =>
        date == null ? "Pilih Tanggal" : DateFormat('dd/MM/yyyy').format(date);

    return Container(
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
              Icon(Icons.calendar_today,
                  color: isDark ? Colors.white70 : Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  formatDate(c.dateFilter),
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              if (c.dateFilter != null)
                IconButton(
                  icon: Icon(Icons.clear,
                      color: isDark ? Colors.white70 : Colors.grey),
                  onPressed: () {
                    c.resetFilter();
                    c.applyFilters();
                  },
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(   // ruang nyaman
                    horizontal: 10,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  await c.pickFilterDate(context);
                  c.applyFilters();
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
                controller: c.searchController,
                onChanged: (v) {
                  c.searchQuery.value = v;
                  c.applyFilters();
                },
                decoration: InputDecoration(
                  hintText: 'Cari Kode / No. Polisi',
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark ? const Color(0xFFF1F2F6) : Colors.grey[800],
                  ),
                  border: InputBorder.none,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── EMPTY STATE ────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isDark;
  final DateTime? dateFilter;
  const _EmptyState({Key? key, required this.isDark, required this.dateFilter})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          dateFilter == null
              ? 'Belum ada data Emergency Service.\nSilakan buat permintaan Emergency Service jika kendaraan Anda mengalami kendala.'
              : 'Tanggal yang Anda pilih tidak ada data',
          style: GoogleFonts.nunito(
            fontSize: 14,
            color: isDark ? Colors.grey[400] : Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// ─── NO-CONNECTION WIDGET ───────────────────────────────────────────────────
class _NoConnectionWidget extends StatelessWidget {
  const _NoConnectionWidget({Key? key}) : super(key: key);

  EmergencyController get c => EmergencyController();
  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Filter',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[300] : Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildFilterSection(context, c),
            const SizedBox(height: 8),
            const RoundedDivider(
                thickness: 1, color: Colors.grey, indent: 10, endIndent: 10),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ─── Judul ───────────────────────────────────────────────
                Text(
                  'Riwayat Layanan Darurat',
                  style: GoogleFonts.lato(
                    textStyle: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.info_outline),
                  tooltip: 'Informasi',
                  splashRadius: 22,
                  onPressed: () {
                    Get.to(() => const EmergencyGuidePage());
                  },
                ),
              ],
            ),
            const SizedBox(height: 50),
            Image.asset(
              'assets/icon/no_conexion.png',
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 10),
            Text(
              'Tidak ada jaringan\nMohon periksa kembali jaringan internet anda',
              style: GoogleFonts.nunito(color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildFilterSection(BuildContext context, EmergencyController c) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    String formatDate(DateTime? date) =>
        date == null ? "Pilih Tanggal" : DateFormat('dd/MM/yyyy').format(date);

    return Container(
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
              Icon(Icons.calendar_today,
                  color: isDark ? Colors.white70 : Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  formatDate(c.dateFilter),
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              if (c.dateFilter != null)
                IconButton(
                  icon: Icon(Icons.clear,
                      color: isDark ? Colors.white70 : Colors.grey),
                  onPressed: () {
                    c.resetFilter();
                    c.applyFilters();
                  },
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(   // ruang nyaman
                    horizontal: 10,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  await c.pickFilterDate(context);
                  c.applyFilters();
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
                controller: c.searchController,
                onChanged: (v) {
                  c.searchQuery.value = v;
                  c.applyFilters();
                },
                decoration: InputDecoration(
                  hintText: 'Cari Kode / No. Polisi',
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark ? const Color(0xFFF1F2F6) : Colors.grey[800],
                  ),
                  border: InputBorder.none,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SERVER-DOWN WIDGET ─────────────────────────────────────────────────────
class _ServerDownWidget extends StatelessWidget {
   _ServerDownWidget({Key? key}) : super(key: key);

  EmergencyController get c => EmergencyController();

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Filter',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[300] : Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildFilterSection(context, c),
            const SizedBox(height: 8),
            const RoundedDivider(
                thickness: 1, color: Colors.grey, indent: 10, endIndent: 10),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Riwayat Layanan Darurat',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[300] : Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 50),
            Image.asset(
              'assets/icon/server-down.png',
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 10),
            Text(
              'Mohon Maaf 🙏🏻\nAplikasi sendang terkendala Server,\nKami akan segera memperbaikinya',
              style: GoogleFonts.nunito(color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildFilterSection(BuildContext context, EmergencyController c) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    String formatDate(DateTime? date) =>
        date == null ? "Pilih Tanggal" : DateFormat('dd/MM/yyyy').format(date);

    return Container(
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
              Icon(Icons.calendar_today,
                  color: isDark ? Colors.white70 : Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  formatDate(c.dateFilter),
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              if (c.dateFilter != null)
                IconButton(
                  icon: Icon(Icons.clear,
                      color: isDark ? Colors.white70 : Colors.grey),
                  onPressed: () {
                    c.resetFilter();
                    c.applyFilters();
                  },
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(   // ruang nyaman
                    horizontal: 10,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  await c.pickFilterDate(context);
                  c.applyFilters();
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
                controller: c.searchController,
                onChanged: (v) {
                  c.searchQuery.value = v;
                  c.applyFilters();
                },
                decoration: InputDecoration(
                  hintText: 'Cari Kode / No. Polisi',
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark ? const Color(0xFFF1F2F6) : Colors.grey[800],
                  ),
                  border: InputBorder.none,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── EMERGENCY ITEM CARD (kode asli, tidak diubah) ─────────────────────────
class _EmergencyItemCard extends StatelessWidget {
  final Data item;
  const _EmergencyItemCard({Key? key, required this.item}) : super(key: key);

  Future<String> _getAddress(String? lat, String? lng) async {
    final latD = double.tryParse(lat ?? '');
    final lngD = double.tryParse(lng ?? '');
    if (latD == null || lngD == null) return 'Alamat tidak tersedia';
    try {
      final placemarks = await placemarkFromCoordinates(latD, lngD);
      if (placemarks.isEmpty) return 'Alamat tidak ditemukan';
      final p = placemarks.first;
      return '${p.street ?? ''}, ${p.locality ?? ''}, '
          '${p.administrativeArea ?? ''}, ${p.country ?? ''}';
    } catch (e) {
      return 'Error: $e';
    }
  }
  bool _isNewItem() {
    DateTime? itemDate;

    // 1) Coba format ISO 8601 (yyyy-MM-ddTHH:mm:ss.SSSZ)
    try {
      itemDate = DateTime.parse(item.tgl ?? '-').toLocal();
    } catch (_) {}

    // 2) Coba “yyyy-MM-dd HH:mm” (tanpa detik)
    if (itemDate == null) {
      try {
        itemDate = DateFormat('yyyy-MM-dd HH:mm').parse(item.tgl ?? '-', true).toLocal();
      } catch (_) {}
    }

    // 3) Coba hanya tanggal “yyyy-MM-dd”
    if (itemDate == null) {
      try {
        itemDate = DateFormat('yyyy-MM-dd').parse(item.tgl ?? '-', true).toLocal();
      } catch (_) {}
    }

    if (itemDate == null) return false; // gagal parse → bukan item baru

    final now = DateTime.now();
    return itemDate.year  == now.year &&
        itemDate.month == now.month &&
        itemDate.day   == now.day;   // masih di hari yang sama
  }

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final cardBg   = isDark ? const Color(0xFF2B2B2B) : Colors.white;

    final tgl   = item.tgl ?? '-';
    final jam   = item.jam ?? '-';
    final kode  = item.kode ?? '-';
    final stat  = item.status ?? '-';
    final lat   = item.latitude ?? '-';
    final lng   = item.longitude ?? '-';
    final keluh = item.keluhan ?? '-';
    final badge = _getBadgeColor(stat);

    final isNew   = _isNewItem();
    return ClipPath(
      clipper: _TicketClipper(),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.grey.withOpacity(.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Get.toNamed(Routes.DETAILEMERGENCY, arguments: item),
          child: Column(
            children: [
              if (isNew)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.green.withOpacity(.15),
                    borderRadius: BorderRadius.circular(30)),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          color: Colors.green, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text('Emergency Service baru yang anda buat',
                        style: GoogleFonts.nunito(
                            color: Colors.green,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(Icons.event,
                        size: 20, color: Theme.of(context).hintColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tgl: $tgl',
                                style: GoogleFonts.nunito(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87)),
                            const SizedBox(height: 2),
                            Text('Jam: $jam',
                                style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[700])),
                          ]),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                          color: badge.withOpacity(.15),
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                                color: badge, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Text(stat,
                              style: GoogleFonts.nunito(
                                  color: badge,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // garis perforasi
              LayoutBuilder(
                builder: (_, cs) => CustomPaint(
                  size: Size(cs.maxWidth, 1),
                  painter: _DashPainter(
                      color: isDark
                          ? Colors.grey.shade600
                          : Colors.grey.shade400),
                ),
              ),
              // BODY
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.qr_code,
                            size: 18, color: Theme.of(context).hintColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Kode Service: $kode',
                              style: GoogleFonts.nunito(fontSize: 14)),
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: Colors.transparent),
                    Row(
                      children: [
                        Icon(Icons.directions_car,
                            size: 18, color: Theme.of(context).hintColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('No. Polisi: ${item.noPolisi ?? '-'}',
                              style: GoogleFonts.nunito(fontSize: 14)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.my_location,
                            size: 18, color: Theme.of(context).hintColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FutureBuilder<String>(
                            future: _getAddress(lat, lng),
                            builder: (ctx, snap) {
                              if (snap.connectionState ==
                                  ConnectionState.waiting) {
                                return Text('Mengambil alamat...',
                                    style: GoogleFonts.nunito(fontSize: 14));
                              }
                              return Text(snap.data ?? '-',
                                  style: GoogleFonts.nunito(fontSize: 14));
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning_amber_outlined,
                            size: 18, color: Theme.of(context).hintColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Keluhan: $keluh',
                              style: GoogleFonts.nunito(fontSize: 14)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBadgeColor(String s) {
    switch (s.toLowerCase()) {
      case 'diterima':
        return Colors.green;
      case 'mekanik ditugaskan':
        return Colors.orange;
      case 'estimasi':
        return Colors.purple;
      case 'pkb':
        return Colors.teal;
      case 'pkb tutup':
        return Colors.grey;
      case 'invoice':
        return Colors.green;
      default:
        return Colors.redAccent;
    }
  }
}

// ─── CLIPPERS & PAINTERS (asli) ─────────────────────────────────────────────
class _TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const r = 10.0;
    final p = Path();
    p.moveTo(0, 0);
    p.lineTo(size.width, 0);
    p.lineTo(size.width, size.height / 2 - r);
    p.arcToPoint(Offset(size.width, size.height / 2 + r),
        radius: const Radius.circular(r), clockwise: false);
    p.lineTo(size.width, size.height);
    p.lineTo(0, size.height);
    p.lineTo(0, size.height / 2 + r);
    p.arcToPoint(Offset(0, size.height / 2 - r),
        radius: const Radius.circular(r), clockwise: false);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(oldClipper) => false;
}

class _DashPainter extends CustomPainter {
  final Color color;
  final double dashWidth, dashSpace;
  _DashPainter({required this.color, this.dashWidth = 6, this.dashSpace = 4});
  @override
  void paint(Canvas c, Size s) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    var x = 0.0, y = s.height / 2;
    while (x < s.width) {
      c.drawLine(Offset(x, y), Offset(x + dashWidth, y), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── SHIMMER PLACEHOLDER ────────────────────────────────────────────────────
class ShimmerEmergencyItem extends StatelessWidget {
  final bool isDark;
  const ShimmerEmergencyItem({Key? key, required this.isDark})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade600 : Colors.grey.shade100,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          height: 16,
                          width: 80,
                          color: isDark ? Colors.grey[850] : Colors.white),
                      const SizedBox(height: 8),
                      Container(
                          height: 14,
                          width: 50,
                          color: isDark ? Colors.grey[850] : Colors.white),
                    ],
                  ),
                ),
                Container(
                  height: 20,
                  width: 60,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[850] : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
                height: 14,
                width: 120,
                color: isDark ? Colors.grey[850] : Colors.white),
            const Divider(height: 20, color: Colors.transparent),
            Container(
                height: 14,
                width: 100,
                color: isDark ? Colors.grey[850] : Colors.white),
            const SizedBox(height: 8),
            Container(
                height: 14,
                width: 160,
                color: isDark ? Colors.grey[850] : Colors.white),
            const SizedBox(height: 8),
            Container(
                height: 14,
                width: 200,
                color: isDark ? Colors.grey[850] : Colors.white),
          ],
        ),
      ),
    );
  }
}

// ─── ROUNDED DIVIDER ────────────────────────────────────────────────────────
class RoundedDivider extends StatelessWidget {
  final double thickness;
  final Color? color;
  final double indent;
  final double endIndent;

  const RoundedDivider({
    Key? key,
    this.thickness = 2,
    this.color,
    this.indent = 0,
    this.endIndent = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dividerColor = color ?? Theme.of(context).dividerColor;
    return Padding(
      padding: EdgeInsets.only(left: indent, right: endIndent),
      child: Container(
        width: double.infinity,
        height: thickness,
        decoration: BoxDecoration(
          color: dividerColor,
          borderRadius: BorderRadius.circular(thickness / 2),
        ),
      ),
    );
  }
}
