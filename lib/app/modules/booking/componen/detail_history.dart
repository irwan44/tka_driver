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
          style: GoogleFonts.nunito(color: isDark ? Colors.white : Colors.black87),
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
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('Jenis Service: $jenisService',
                            style: GoogleFonts.nunito(color: isDark ? Colors.white70 : Colors.black87)),
                        const SizedBox(height: 6),
                        Text('Status Service: $statusService',
                            style: GoogleFonts.nunito(color: isDark ? Colors.white70 : Colors.black87)),
                        const SizedBox(height: 6),
                        Text('Plat Nomor: $platNomor',
                            style: GoogleFonts.nunito(color: isDark ? Colors.white70 : Colors.black87)),
                        const SizedBox(height: 6),
                        Text('Lokasi: $lokasi',
                            style: GoogleFonts.nunito(color: isDark ? Colors.white70 : Colors.black87)),
                        const SizedBox(height: 6),
                        Text('Keterangan: $keterangan',
                            style: GoogleFonts.nunito(color: isDark ? Colors.white70 : Colors.black87)),
                      ],
                    ),
                  ),
                ),
              // Stepper Section
              // Obx(
              //       () => Stepper(
              //     type: StepperType.vertical,
              //     steps: stepController.steps.map((step) {
              //       return Step(
              //         title: step.title,
              //         subtitle: step.subtitle,
              //         state: step.state,
              //         isActive: step.isActive,
              //         content: Container(
              //           margin: const EdgeInsets.only(bottom: 16),
              //           padding: const EdgeInsets.all(16),
              //           decoration: BoxDecoration(
              //             color: isDark ? Colors.grey[850] : Colors.white,
              //             borderRadius: BorderRadius.circular(8),
              //             boxShadow: [
              //               BoxShadow(
              //                 color: isDark ? Colors.black54 : Colors.black.withOpacity(0.08),
              //                 blurRadius: 8,
              //                 offset: const Offset(0, 2),
              //               ),
              //             ],
              //           ),
              //           child: Column(
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             children: [
              //               Text(
              //                 (step.title as Row)
              //                     .children
              //                     .whereType<Text>()
              //                     .first
              //                     .data
              //                     .toString(),
              //                 style: GoogleFonts.nunito(
              //                   fontSize: 16,
              //                   fontWeight: FontWeight.bold,
              //                   color: isDark ? Colors.white : Colors.black,
              //                 ),
              //               ),
              //               if (step.subtitle != null) ...[
              //                 const SizedBox(height: 4),
              //                 DefaultTextStyle(
              //                   style: GoogleFonts.nunito(
              //                     color: isDark ? Colors.grey[300] : Colors.grey,
              //                     fontSize: 14,
              //                   ),
              //                   child: step.subtitle!,
              //                 ),
              //               ],
              //               const SizedBox(height: 12),
              //               step.content,
              //             ],
              //           ),
              //         ),
              //       );
              //     }).toList(),
              //     currentStep: stepController.currentStep.value,
              //     controlsBuilder: (context, details) {
              //       return const SizedBox.shrink();
              //     },
              //     onStepTapped: (index) => stepController.jumpTo(index),
              //   ),
              // ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
