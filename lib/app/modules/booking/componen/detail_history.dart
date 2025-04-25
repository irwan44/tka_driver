import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/booking_controller.dart';

class StepperPage extends StatelessWidget {
  const StepperPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final BookingController stepController = Get.put(BookingController());
    final data = Get.arguments as Map<String, String>?;
    final String date = data?['date'] ?? '-';
    final String jenisService = data?['jenisService'] ?? '-';
    final String statusService = data?['statusService'] ?? '-';
    final String platNomor = data?['platNomor'] ?? '-';
    final String lokasi = data?['lokasi'] ?? '-';
    final String keterangan = data?['keterangan'] ?? '-';
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[850] : Colors.grey[100],
        elevation: 0,
        title: Text(
          'Detail History',
          style: GoogleFonts.nunito(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (data != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[850] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black54 : Colors.black12,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tanggal: $date',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Jenis Service: $jenisService',
                          style: GoogleFonts.nunito(
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Status Service: $statusService',
                          style: GoogleFonts.nunito(
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Plat Nomor: $platNomor',
                          style: GoogleFonts.nunito(
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Lokasi: $lokasi',
                          style: GoogleFonts.nunito(
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Keterangan: $keterangan',
                          style: GoogleFonts.nunito(
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
