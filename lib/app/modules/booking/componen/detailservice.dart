import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../controllers/booking_controller.dart';

class DetailServiceView extends StatefulWidget {
  final String kodeSvc;
  final String status;

  const DetailServiceView({
    Key? key,
    required this.kodeSvc,
    required this.status,
  }) : super(key: key);

  @override
  State<DetailServiceView> createState() => _DetailServiceViewState();
}

class _DetailServiceViewState extends State<DetailServiceView> {
  late final BookingController controller;
  String _safe(dynamic v) {
    if (v == null) return "‑";
    final s = v.toString().trim();
    if (s.isEmpty || s.toLowerCase() == "null") return "‑";
    return s;
  }

  String formatRupiah(dynamic value) {
    if (value == null) return "‑";
    final num parsed = num.tryParse(value.toString()) ?? 0;
    return NumberFormat.currency(
      locale: "id_ID",
      symbol: "Rp ",
      decimalDigits: 0,
    ).format(parsed);
  }

  @override
  void initState() {
    super.initState();
    controller = Get.put(BookingController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchDetail(widget.kodeSvc);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final statusLower = widget.status.trim().toLowerCase();
    final isPlanning = statusLower == 'not confirmed';

    return Scaffold(
      appBar: _buildAppBar(isDarkMode),
      backgroundColor: isDarkMode ? Colors.grey[900] : const Color(0xFFF6F7FB),
      floatingActionButton:
          isPlanning
              ? Obx(() {
                final confirmed = controller.isPlanningConfirmed(
                  widget.kodeSvc,
                );
                return FloatingActionButton.extended(
                  backgroundColor: confirmed ? Colors.grey : Colors.green,
                  foregroundColor: Colors.white,
                  onPressed:
                      confirmed
                          ? null
                          : () => controller.confirmPlanningService(
                            context,
                            widget.kodeSvc,
                          ),
                  icon: Icon(
                    confirmed ? Icons.check_circle : Icons.warning_rounded,
                  ),
                  label: Text(
                    confirmed
                        ? "Sudah Dikonfirmasi"
                        : "Konfirmasi Planning Service",
                  ),
                );
              })
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      body: RefreshIndicator(
        onRefresh: () async => controller.fetchDetail(widget.kodeSvc),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Obx(() {
            if (controller.isLoading.value) {
              return _buildShimmer(isDarkMode);
            }
            if (controller.errorMessage.value.isNotEmpty) {
              print("Error: ${controller.errorMessage.value}");
              return Center(
                child: Text(
                  "Terjadi kesalahan. Coba lagi.",
                  style: GoogleFonts.nunito(),
                ),
              );
            }
            if (controller.detailService.value == null) {
              return Center(
                child: Text("Data tidak tersedia", style: GoogleFonts.nunito()),
              );
            }

            final d = controller.detailService.value!;
            final bool isEstimasi = statusLower == 'estimasi';
            final kodeLabel = isEstimasi ? "Kode Estimasi" : "Kode PKB";
            final kodeValue =
                isEstimasi
                    ? _safe(d.dataSvc?.kodeEstimasi)
                    : _safe(d.dataSvc?.kodePkb);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TicketCard(
                  title: "Informasi Utama",
                  iconData: Icons.info_outline,
                  child: Column(
                    children: [
                      _twoCol(
                        "Kode Svc",
                        _safe(d.dataSvc?.kodeSvc),
                        kodeLabel,
                        kodeValue,
                      ),
                      _twoCol(
                        "Tipe Svc",
                        _safe(d.dataSvc?.tipeSvc),
                        "Keluhan",
                        _safe(d.dataSvc?.keluhan),
                      ),
                      _twoCol(
                        "Tgl Keluar",
                        _safe(d.dataSvc?.tglKeluar),
                        "Tgl Kembali",
                        _safe(d.dataSvc?.tglKembali),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TicketCard(
                  title: "Detail Kendaraan",
                  iconData: Icons.directions_car,
                  child: Column(
                    children: [
                      _twoCol(
                        "No Polisi",
                        _safe(d.dataSvc?.noPolisi),
                        "Merk",
                        _safe(d.dataSvc?.namaMerk),
                      ),
                      _twoCol(
                        "Tipe",
                        _safe(d.dataSvc?.namaTipe),
                        "Tahun",
                        _safe(d.dataSvc?.tahun),
                      ),
                      _twoCol(
                        "Warna",
                        _safe(d.dataSvc?.warna),
                        "Transmisi",
                        _safe(d.dataSvc?.transmisi),
                      ),
                      _twoCol(
                        "Odometer",
                        _safe(d.dataSvc?.odometer),
                        "Kategori",
                        _safe(d.dataSvc?.kategoriKendaraan),
                      ),
                      _twoCol(
                        "No Rangka",
                        _safe(d.dataSvc?.noRangka),
                        "No Mesin",
                        _safe(d.dataSvc?.noMesin),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TicketCard(
                  title: "Detail PIC",
                  iconData: Icons.person_outline,
                  child: _twoCol(
                    "PIC",
                    _safe(d.dataSvc?.pic),
                    "HP PIC",
                    _safe(d.dataSvc?.hpPic),
                  ),
                ),
                const SizedBox(height: 20),
                TicketCard(
                  title: "Paket Service",
                  iconData: Icons.build_circle_outlined,
                  child:
                      (d.dataSvcPaket?.isNotEmpty ?? false)
                          ? Column(
                            children:
                                d.dataSvcPaket!
                                    .map(
                                      (p) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 6,
                                        ),
                                        child: TicketCardItem(
                                          children: [
                                            _detailRow(
                                              Icons.code,
                                              "Kode",
                                              _safe(p.kode),
                                            ),
                                            _detailRow(
                                              Icons.label,
                                              "Nama",
                                              _safe(p.nama),
                                            ),
                                            _detailRow(
                                              Icons.format_list_numbered,
                                              "Qty",
                                              _safe(p.qty),
                                            ),
                                            _detailRow(
                                              Icons.attach_money,
                                              "Harga",
                                              formatRupiah(p.harga),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                          )
                          : const Text("Tidak ada paket service."),
                ),
                const SizedBox(height: 12),
                TicketCard(
                  title: "Sparepart Service",
                  iconData: Icons.settings_applications_outlined,
                  child:
                      (d.dataSvcDtlPart?.isNotEmpty ?? false)
                          ? Column(
                            children:
                                d.dataSvcDtlPart!
                                    .map(
                                      (part) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 6,
                                        ),
                                        child: TicketCardItem(
                                          children: [
                                            _detailRow(
                                              Icons.extension,
                                              "Nama Sparepart",
                                              _safe(part.namaSparepart),
                                            ),
                                            _detailRow(
                                              Icons.format_list_numbered,
                                              "Qty",
                                              _safe(part.qtySparepart),
                                            ),
                                            _detailRow(
                                              Icons.attach_money,
                                              "Harga",
                                              formatRupiah(part.hargaSparepart),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                          )
                          : const Text("Tidak ada sparepart service."),
                ),
                const SizedBox(height: 12),
                TicketCard(
                  title: "Jasa Service",
                  iconData: Icons.handyman_outlined,
                  child:
                      (d.dataSvcDtlJasa?.isNotEmpty ?? false)
                          ? Column(
                            children:
                                d.dataSvcDtlJasa!
                                    .map(
                                      (j) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 6,
                                        ),
                                        child: TicketCardItem(
                                          children: [
                                            _detailRow(
                                              Icons.handyman,
                                              "Nama Jasa",
                                              _safe(j.namaJasa),
                                            ),
                                            _detailRow(
                                              Icons.format_list_numbered,
                                              "Qty",
                                              _safe(j.qtyJasa),
                                            ),
                                            _detailRow(
                                              Icons.attach_money,
                                              "Harga",
                                              formatRupiah(j.hargaJasa),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                          )
                          : const Text("Tidak ada jasa service."),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool dark) => AppBar(
    backgroundColor: dark ? Colors.grey[900] : const Color(0xFFF6F7FB),
    elevation: 1,
    title: Text(
      'Detail Service',
      style: GoogleFonts.nunito(color: dark ? Colors.white : Colors.black),
    ),
    iconTheme: IconThemeData(color: dark ? Colors.white : Colors.black),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
    ),
  );

  Widget _twoCol(String l1, String v1, String l2, String v2) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    TextStyle label = GoogleFonts.nunito(
      fontWeight: FontWeight.bold,
      fontSize: 15,
      color: dark ? Colors.white70 : Colors.grey[800],
    );
    TextStyle val = GoogleFonts.nunito(
      fontSize: 15,
      color: dark ? Colors.white : Colors.black87,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l1, style: label),
                const SizedBox(height: 4),
                Text(v1, style: val),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l2, style: label),
                const SizedBox(height: 4),
                Text(v2, style: val),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData ic, String label, String value) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ic, size: 20, color: dark ? Colors.white70 : Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: dark ? Colors.white70 : Colors.grey[800],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.nunito(
                fontSize: 15,
                color: dark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer(bool dark) {
    final base = dark ? Colors.grey[700]! : Colors.grey[300]!;
    final hi = dark ? Colors.grey[500]! : Colors.grey[100]!;
    Widget bar(int n) => Column(
      children: List.generate(
        n,
        (_) => Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          height: 20,
          color: base,
        ),
      ),
    );
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: hi,
      child: Column(
        children: [
          TicketCard(
            title: "Informasi Utama",
            iconData: Icons.info_outline,
            child: bar(6),
          ),
          const SizedBox(height: 12),
          TicketCard(
            title: "Detail Kendaraan",
            iconData: Icons.directions_car,
            child: bar(10),
          ),
          const SizedBox(height: 12),
          TicketCard(
            title: "Detail PIC",
            iconData: Icons.person_outline,
            child: bar(2),
          ),
        ],
      ),
    );
  }
}

class TicketCard extends StatelessWidget {
  final String title;
  final Widget child;
  final IconData iconData;
  const TicketCard({
    Key? key,
    required this.title,
    required this.child,
    this.iconData = Icons.receipt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ClipPath(
        clipper: TicketClipper(),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  dark
                      ? [Colors.grey.shade800, Colors.grey.shade700]
                      : [Colors.white, Colors.grey.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color:
                      dark
                          ? Colors.blueGrey.withOpacity(0.3)
                          : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      iconData,
                      size: 20,
                      color: dark ? Colors.white70 : Colors.blueGrey[700],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: dark ? Colors.white : Colors.blueGrey[800],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 1,
                width: double.infinity,
                color: Colors.grey.withOpacity(0.3),
              ),
              const SizedBox(height: 8),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class TicketCardItem extends StatelessWidget {
  final List<Widget> children;
  const TicketCardItem({Key? key, required this.children}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: dark ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) {
    const r = 10.0;
    final p =
        Path()
          ..moveTo(0, 0)
          ..lineTo(s.width, 0)
          ..lineTo(s.width, s.height / 2 - r)
          ..arcToPoint(
            Offset(s.width, s.height / 2 + r),
            radius: const Radius.circular(r),
            clockwise: false,
          )
          ..lineTo(s.width, s.height)
          ..lineTo(0, s.height)
          ..lineTo(0, s.height / 2 + r)
          ..arcToPoint(
            Offset(0, s.height / 2 - r),
            radius: const Radius.circular(r),
            clockwise: false,
          )
          ..close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
