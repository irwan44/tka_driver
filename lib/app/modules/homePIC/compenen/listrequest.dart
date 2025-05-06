// lib/app/modules/home_p_i_c/views/listrequest_service.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tka_customer/app/modules/homePIC/compenen/requestdetailPage.dart';

import '../controllers/home_p_i_c_controller.dart';

class ListrequestService extends StatelessWidget {
  const ListrequestService({Key? key}) : super(key: key);

  Widget _buildFilterSection(BuildContext context, HomePICController c) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseClr = isDark ? Colors.grey[800]! : Colors.white;
    final hintClr = isDark ? Colors.white54 : Colors.grey[700]!;

    String fmt(DateTime? d) =>
        d == null ? 'Tanggal' : DateFormat('dd/MM').format(d);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: baseClr,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // date picker
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () async {
              await c.pickFilterDate(context);
              c.applyFilters();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: hintClr),
                  const SizedBox(width: 4),
                  Text(
                    fmt(c.dateFilter),
                    style: TextStyle(
                      fontSize: 14,
                      color: hintClr,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (c.dateFilter != null) ...[
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        c.resetFilter();
                        c.applyFilters();
                      },
                      child: Icon(Icons.close, size: 14, color: hintClr),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // search field
          Expanded(
            child: TextField(
              controller: c.searchController,
              onChanged: (_) => c.applyFilters(),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Cari Kode / No. Polisi',
                hintStyle: TextStyle(color: hintClr, fontSize: 14),
                prefixIcon: Icon(Icons.search, size: 18, color: hintClr),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: isDark ? Colors.white10 : Colors.grey[200],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Column(
      children: List.generate(4, (_) {
        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Container(height: 16, color: Colors.white)),
                    const SizedBox(width: 12),
                    Container(width: 60, height: 16, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 8),
                Container(width: 100, height: 14, color: Colors.white),
                const SizedBox(height: 8),
                Container(width: 150, height: 14, color: Colors.white),
                const SizedBox(height: 8),
                Container(width: 80, height: 12, color: Colors.white),
              ],
            ),
          ),
        );
      }),
    );
  }

  Color _statusColor(String? s) {
    switch (s?.toLowerCase()) {
      case 'waiting':
        return Colors.orange;
      case 'done':
      case 'selesai':
        return Colors.green;
      case 'rejected':
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomePICController>(
      builder: (c) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return RefreshIndicator(
          onRefresh: () => c.fetchRequests(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // selalu tampilkan filter
                _buildFilterSection(context, c),
                const SizedBox(height: 16),

                // konten berdasarkan state
                if (c.isLoading.value) ...[
                  _buildShimmer(context),
                ] else if (c.error.value.isNotEmpty) ...[
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
                ] else if (c.filteredList.isEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[850] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        c.dateFilter == null
                            ? 'Belum ada data Request Service, untuk saat ini.'
                            : 'Tanggal yang Anda pilih tidak ada data',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  // tampilkan daftar
                  ...c.filteredList.map((r) {
                    final date =
                        r.createdAt != null
                            ? DateFormat(
                              'dd MMM yyyy',
                            ).format(DateTime.parse(r.createdAt!))
                            : '-';
                    final time =
                        r.jamService?.isNotEmpty == true
                            ? r.jamService!
                            : (r.createdAt != null
                                ? DateFormat(
                                  'HH:mm',
                                ).format(DateTime.parse(r.createdAt!))
                                : '-');

                    return InkWell(
                      onTap: () {
                        Get.to(() => RequestDetailPage(item: r));
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[850] : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // header
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    r.kodeRequestService ?? '-',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _statusColor(r.status),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    r.status ?? '-',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // detail
                            Row(
                              children: [
                                const Icon(Icons.directions_car, size: 16),
                                const SizedBox(width: 4),
                                Text(r.noPolisi ?? '-'),
                                const Spacer(),
                                const Icon(Icons.person, size: 16),
                                const SizedBox(width: 4),
                                Text(r.kodePelanggan ?? '-'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Keluhan: ${r.keluhan ?? '-'}'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '$date • $time',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
