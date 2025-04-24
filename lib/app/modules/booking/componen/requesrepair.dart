import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class _TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const r = 10.0;
    final p = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height / 2 - r)
      ..arcToPoint(Offset(size.width, size.height / 2 + r),
          radius: const Radius.circular(r), clockwise: false)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, size.height / 2 + r)
      ..arcToPoint(Offset(0, size.height / 2 - r),
          radius: const Radius.circular(r), clockwise: false)
      ..close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _DashPainter extends CustomPainter {
  final double dashWidth, dashSpace;
  final Color color;
  _DashPainter(
      {this.dashWidth = 6, this.dashSpace = 4, required this.color});

  @override
  void paint(Canvas c, Size s) {
    final paint = Paint()..color = color..strokeWidth = 1;
    double x = 0, y = s.height / 2;
    while (x < s.width) {
      c.drawLine(Offset(x, y), Offset(x + dashWidth, y), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class RequestServiceItem extends StatelessWidget {
  const RequestServiceItem({
    super.key,
    required this.tanggal,
    required this.status,
    required this.noPolisi,
    required this.keluhan,
    required this.kodereques,
    required this.kodekendaraan,
  });

  final String tanggal;
  final String status;
  final String noPolisi;
  final String keluhan;
  final String kodereques;
  final String kodekendaraan;

  Color _statusColor() {
    switch (status.toLowerCase()) {
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


  Widget _infoRow(BuildContext ctx, IconData icn, String label, String value,
      {int maxLines = 1, TextStyle? valueStyle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icn, size: 16, color: Theme.of(ctx).hintColor),
        const SizedBox(width: 6),
        Text('$label : ',
            style:
            GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700)),
        Expanded(
          child: Text(
            value,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: valueStyle ??
                GoogleFonts.nunito(
                    fontSize: 13, fontWeight: FontWeight.normal),
          ),
        ),
      ],
    );
  }
  bool _isNewItem() {
    DateTime? itemDate;

    try {
      itemDate = DateTime.parse(tanggal).toLocal();
    } catch (_) {}

    if (itemDate == null) {
      try {
        itemDate = DateFormat('yyyy-MM-dd HH:mm').parse(tanggal, true).toLocal();
      } catch (_) {}
    }

    if (itemDate == null) {
      try {
        itemDate = DateFormat('yyyy-MM-dd').parse(tanggal, true).toLocal();
      } catch (_) {}
    }

    if (itemDate == null) return false;

    final now = DateTime.now();
    return itemDate.year  == now.year &&
        itemDate.month == now.month &&
        itemDate.day   == now.day;
  }

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF2B2B2B) : Colors.white;
    final statusCol = _statusColor();
    final isNew   = _isNewItem();
    return ClipPath(
      clipper: _TicketClipper(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
        child: Column(
          children: [
            if (isNew)
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(.15),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: Colors.green, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Request Service baru yang anda buat',
                      style: GoogleFonts.nunito(
                        color: Colors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(Icons.event, size: 18, color: theme.hintColor),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      tanggal,
                      style: GoogleFonts.nunito(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: statusCol.withOpacity(.15),
                        borderRadius: BorderRadius.circular(30)),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                              color: statusCol, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text(status.toUpperCase(),
                            style: GoogleFonts.nunito(
                                color: statusCol,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            LayoutBuilder(
              builder: (_, cs) => CustomPaint(
                size: Size(cs.maxWidth, 1),
                painter: _DashPainter(
                    color:
                    isDark ? Colors.grey.shade600 : Colors.grey.shade400),
              ),
            ),

            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow(context, Icons.confirmation_number,
                      'Kode Request', kodereques),
                  const SizedBox(height: 10),
                  _infoRow(context, Icons.directions_car, 'Kode Kendaraan',
                      kodekendaraan),
                  _infoRow(context, Icons.directions_car, 'No Polisi',
                      noPolisi),
                  const SizedBox(height: 4),
                  _infoRow(context, Icons.report_problem, 'Keluhan',
                      keluhan.isEmpty ? '–' : keluhan,
                      maxLines: 3),
                  const SizedBox(height: 10),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
