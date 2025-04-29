import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../data/data_respon/listservice.dart';
import '../controllers/booking_controller.dart';
import 'detailservice.dart';

// ────────────────  CLIPPER & DASH  ─────────────────────────────────────────
class _TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const r = 10.0;
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height / 2 - r)
      ..arcToPoint(
        Offset(size.width, size.height / 2 + r),
        radius: const Radius.circular(r),
        clockwise: false,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, size.height / 2 + r)
      ..arcToPoint(
        Offset(0, size.height / 2 - r),
        radius: const Radius.circular(r),
        clockwise: false,
      )
      ..close();
  }

  @override
  bool shouldReclip(_) => false;
}

class _DashPainter extends CustomPainter {
  final double dashWidth, dashSpace;
  final Color color;
  _DashPainter({this.dashWidth = 6, this.dashSpace = 4, required this.color});
  @override
  void paint(Canvas c, Size s) {
    final p =
        Paint()
          ..color = color
          ..strokeWidth = 1;
    double x = 0, y = s.height / 2;
    while (x < s.width) {
      c.drawLine(Offset(x, y), Offset(x + dashWidth, y), p);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ────────────────  SERVICE ITEM  ───────────────────────────────────────────
class ServiceItemCard extends StatelessWidget {
  ServiceItemCard({super.key, required this.service, this.unread = false});

  final ListService service;
  final bool unread;
  final bookingController = Get.find<BookingController>();

  // util row
  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? Colors.grey[400] : Colors.grey[800],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: '$label: ',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              children: [
                TextSpan(
                  text: value,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.normal,
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  // mini-chip
  Widget _miniChip(BuildContext ctx, IconData icn, String txt) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icn, size: 14, color: Theme.of(ctx).hintColor),
          const SizedBox(width: 4),
          Text(txt, style: GoogleFonts.nunito(fontSize: 12)),
        ],
      ),
    );
  }

  String formatDate(String tgl) {
    try {
      final dt = DateTime.parse(tgl);
      return DateFormat('dd-MM-yyyy').format(dt);
    } catch (_) {
      final parts = tgl.split('-');
      if (parts.length == 3) {
        return '${parts[2]}-${parts[1]}-${parts[0]}';
      }
      return tgl;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // mapping status
    final st = (service.status ?? '').trim().toLowerCase();
    final isEst = st == 'estimasi';
    final isPKB = st == 'pkb';
    final isPKBT = st == 'pkb tutup';
    final isInv = st == 'invoice';
    final isPlan = st == 'not confirmed';

    Color badgeClr, txtClr;
    if (isEst) {
      badgeClr = Colors.orange.shade200;
      txtClr = Colors.orange.shade800;
    } else if (isPKB) {
      badgeClr = Colors.green.shade200;
      txtClr = Colors.green.shade800;
    } else if (isPKBT) {
      badgeClr = Colors.red.shade200;
      txtClr = Colors.red.shade800;
    } else if (isInv) {
      badgeClr = Colors.blue.shade200;
      txtClr = Colors.blue.shade800;
    } else if (isPlan) {
      badgeClr = Colors.redAccent.shade200;
      txtClr = Colors.red.shade800;
    } else {
      badgeClr = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
      txtClr = isDark ? Colors.white : Colors.black;
    }

    final kodeLabel = isEst ? 'Kode Estimasi:' : 'Kode PKB:';
    final kodeValue =
        isEst ? (service.kodeEstimasi ?? '-') : (service.kodePkb ?? '-');

    IconData leadIcn = Icons.info_outline;
    String leadTtl = 'Service';
    if (isEst) {
      leadIcn = Icons.calculate;
      leadTtl = 'Estimasi Service';
    } else if (isInv) {
      leadIcn = Icons.receipt_long;
      leadTtl = 'Invoice Service';
    } else if (isPKB || isPKBT || isPlan) {
      leadIcn = Icons.assignment;
      leadTtl = 'PKB Service';
    }

    final cardBg =
        unread
            ? (isDark
                ? Colors.orangeAccent.withOpacity(.08)
                : const Color(0xFFFFF8E1))
            : (isDark ? const Color(0xFF2B2B2B) : Colors.white);

    return ClipPath(
      clipper: _TicketClipper(),
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 4, 10, 0),
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
          onTap: () {
            bookingController.markServiceOpened(service.kodeSvc);
            Get.to(
              () => DetailServiceView(
                kodeSvc: service.kodeSvc ?? '',
                status: service.status ?? '',
              ),
            );
          },
          child: Column(
            children: [
              // ─── HEADER ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Icon(leadIcn, size: 26, color: Theme.of(context).hintColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        leadTtl,
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: badgeClr.withOpacity(.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: txtClr,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            service.status ?? '-',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: txtClr,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ─── DASH LINE ────────────────────────────────────────────
              LayoutBuilder(
                builder:
                    (_, c) => CustomPaint(
                      size: Size(c.maxWidth, 1),
                      painter: _DashPainter(
                        color:
                            isDark
                                ? Colors.grey.shade600
                                : Colors.grey.shade400,
                      ),
                    ),
              ),

              // ─── DETAIL ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _miniChip(
                          context,
                          Icons.confirmation_num,
                          service.kodeSvc ?? '-',
                        ),
                        _miniChip(context, Icons.code, kodeValue),
                        if ((service.noPolisi ?? '').isNotEmpty)
                          _miniChip(
                            context,
                            Icons.directions_car,
                            service.noPolisi!,
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$kodeLabel $kodeValue',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 20),
                    _detailRow(
                      icon: Icons.confirmation_num,
                      label: 'Kode Svc',
                      value: service.kodeSvc ?? '-',
                      isDark: isDark,
                    ),
                    _detailRow(
                      icon: Icons.build,
                      label: 'Tipe Svc',
                      value: service.tipeSvc ?? '-',
                      isDark: isDark,
                    ),

                    if (isEst) ...[
                      _detailRow(
                        icon: Icons.calendar_today,
                        label: 'Tgl Estimasi',
                        value: formatDate(service.tglEstimasi ?? '-'),
                        isDark: isDark,
                      ),
                      _detailRow(
                        icon: Icons.directions_car,
                        label: 'No Polisi',
                        value: service.noPolisi ?? '-',
                        isDark: isDark,
                      ),
                      _detailRow(
                        icon: Icons.directions_car_filled,
                        label: 'Kode Kendaraan',
                        value: service.kodeKendaraan ?? '-',
                        isDark: isDark,
                      ),
                    ] else if (isPKB || isPKBT || isInv || isPlan) ...[
                      _detailRow(
                        icon: Icons.calendar_today,
                        label: 'Tgl PKB',
                        value: formatDate(service.tglPkb ?? '-'),
                        isDark: isDark,
                      ),
                      _detailRow(
                        icon: Icons.calendar_view_day,
                        label: 'Tgl Tutup',
                        value: formatDate(service.tglTutup ?? '-'),
                        isDark: isDark,
                      ),
                      _detailRow(
                        icon: Icons.directions_car,
                        label: 'No Polisi',
                        value: service.noPolisi ?? '-',
                        isDark: isDark,
                      ),
                      _detailRow(
                        icon: Icons.directions_car_filled,
                        label: 'Kode Kendaraan',
                        value: service.kodeKendaraan ?? '-',
                        isDark: isDark,
                      ),
                    ],

                    if (isPlan)
                      Obx(() {
                        final confirmed = bookingController.isPlanningConfirmed(
                          service.kodeSvc,
                        );
                        final bg = confirmed ? Colors.green : Colors.red;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              confirmed
                                  ? 'Sudah Konfirmasi'
                                  : 'Belum Konfirmasi',
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
