import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/data_respon/listservice.dart';
import '../controllers/booking_controller.dart';
import 'detailservice.dart';


class _TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const r = 10.0; // radius lubang
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
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _DashPainter extends CustomPainter {
  final double dashWidth, dashSpace;
  final Color color;
  _DashPainter(
      {this.dashWidth = 6, this.dashSpace = 4, required this.color});
  @override
  void paint(Canvas c, Size s) {
    var paint = Paint()..color = color..strokeWidth = 1;
    double x = 0, y = s.height / 2;
    while (x < s.width) {
      c.drawLine(Offset(x, y), Offset(x + dashWidth, y), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ServiceItemCard extends StatelessWidget {
  final ListService service;
  ServiceItemCard({Key? key, required this.service}) : super(key: key);
  final bookingController = Get.find<BookingController>();
  // Helper row
  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[800]),
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

  // Mini chip util
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

  @override
  Widget build(BuildContext context) {

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final st = (service.status ?? '').trim().toLowerCase();
    final isEstimasi = st == 'estimasi';
    final isPKB = st == 'pkb';
    final isPKBTutup = st == 'pkb tutup';
    final isInvoice = st == 'invoice';
    final isPlanning = st == 'not confirmed';

    Color badgeClr, txtClr;
    if (isEstimasi)    { badgeClr = Colors.orange.shade200;  txtClr = Colors.orange.shade800; }
    else if (isPKB)    { badgeClr = Colors.green.shade200;   txtClr = Colors.green.shade800; }
    else if (isPKBTutup){ badgeClr = Colors.red.shade200;    txtClr = Colors.red.shade800; }
    else if (isInvoice){ badgeClr = Colors.blue.shade200;    txtClr = Colors.blue.shade800; }
    else if (isPlanning){ badgeClr = Colors.redAccent.shade200; txtClr = Colors.red.shade800; }
    else               { badgeClr = isDark? Colors.grey.shade700 : Colors.grey.shade300;
    txtClr = isDark? Colors.white : Colors.black; }
    final kodeLabel = isEstimasi ? 'Kode Estimasi:' : 'Kode PKB:';
    final kodeValue = isEstimasi ? (service.kodeEstimasi ?? '-') : (service.kodePkb ?? '-');

    IconData leadingIcn = Icons.info_outline;
    String leadingTitle = 'Service';
    if (isEstimasi) { leadingIcn = Icons.calculate; leadingTitle = 'Estimasi Service'; }
    else if (isInvoice){ leadingIcn = Icons.receipt_long; leadingTitle = 'Invoice Service'; }
    else if (isPKB || isPKBTutup || isPlanning){ leadingIcn = Icons.assignment; leadingTitle = 'PKB Service'; }

    final cardBg = isDark ? const Color(0xFF2B2B2B) : Colors.white;

    return ClipPath(
      clipper: _TicketClipper(),
      child: Container(
        margin: EdgeInsets.only(left: 10,right: 10,top: 4),
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
            Get.to(() => DetailServiceView(
              kodeSvc: service.kodeSvc ?? '',
              status: service.status ?? '',
            ));
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(leadingIcn, size: 26, color: Theme.of(context).hintColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(leadingTitle,
                          style: GoogleFonts.nunito(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                               color: txtClr, shape: BoxShape.circle),
                         ),
                         const SizedBox(width: 6),
                         Text(service.status ?? '-',
                             style: GoogleFonts.nunito(
                                 fontSize: 14,
                                 fontWeight: FontWeight.bold,
                                 color: txtClr)),
                       ],
                      )

                    ),
                  ],
                ),
              ),

              LayoutBuilder(
                builder: (_, c) => CustomPaint(
                  size: Size(c.maxWidth, 1),
                  painter: _DashPainter(
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _miniChip(context, Icons.confirmation_num, service.kodeSvc ?? '-'),
                        _miniChip(context, Icons.code, kodeValue),
                        if ((service.noPolisi ?? '').isNotEmpty)
                          _miniChip(context, Icons.directions_car, service.noPolisi!),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // label kode utama
                    Text('$kodeLabel $kodeValue',
                        style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87)),
                    const SizedBox(height: 8),
                    const Divider(height: 20),
                    _detailRow(
                        icon: Icons.confirmation_num,
                        label: 'Kode Svc',
                        value: service.kodeSvc ?? '-',
                        isDark: isDark),
                    _detailRow(
                        icon: Icons.build,
                        label: 'Tipe Svc',
                        value: service.tipeSvc ?? '-',
                        isDark: isDark),
                    if (isEstimasi) ...[
                      _detailRow(
                          icon: Icons.calendar_today,
                          label: 'Tgl Estimasi',
                          value: service.tglEstimasi ?? '-',
                          isDark: isDark),
                      _detailRow(
                          icon: Icons.directions_car,
                          label: 'No Polisi',
                          value: service.noPolisi ?? '-',
                          isDark: isDark),
                      _detailRow(
                          icon: Icons.directions_car_filled,
                          label: 'Kode Kendaraan',
                          value: service.kodeKendaraan ?? '-',
                          isDark: isDark),
                    ] else if (isPKB || isPKBTutup || isInvoice || isPlanning) ...[
                      _detailRow(
                          icon: Icons.calendar_today,
                          label: 'Tgl PKB',
                          value: service.tglPkb ?? '-',
                          isDark: isDark),
                      _detailRow(
                          icon: Icons.calendar_view_day,
                          label: 'Tgl Tutup',
                          value: service.tglTutup ?? '-',
                          isDark: isDark),
                      _detailRow(
                          icon: Icons.directions_car,
                          label: 'No Polisi',
                          value: service.noPolisi ?? '-',
                          isDark: isDark),
                      _detailRow(
                          icon: Icons.directions_car_filled,
                          label: 'Kode Kendaraan',
                          value: service.kodeKendaraan ?? '-',
                          isDark: isDark),
                    ],
                    if (isPlanning)
                      Obx(() {
                        final confirmed = bookingController.isPlanningConfirmed(service.kodeSvc);
                        final bgColor = confirmed ? Colors.green : Colors.red;

                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              confirmed ? 'Sudah Konfirmasi' : 'Belum Konfirmasi',
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white, // selalu putih agar kontras baik
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
