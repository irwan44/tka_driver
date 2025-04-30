import 'dart:io';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/booking_controller.dart';

class RegularRepairPage extends StatelessWidget {
  const RegularRepairPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final BookingController c = Get.find<BookingController>();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bg = isDark ? Colors.black : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color hintColor = isDark ? Colors.white54 : Colors.black38;
    // Gunakan warna eksplisit, bukan primaryColor
    final Color accentColor = isDark ? Colors.tealAccent : Colors.blueAccent;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Request Service',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kendaraan
                Text(
                  'Kendaraan',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pilih kendaraan yang ingin diservis. Pastikan nomor plat sesuai.',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: hintColor,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomDropdown<String>(
                        hintText: 'Pilih kendaraan',
                        items: c.availableVehicles,
                        initialItem:
                            c.selectedVehicle.value.isEmpty
                                ? null
                                : c.selectedVehicle.value,
                        excludeSelected: false,
                        onChanged: c.onVehicleChanged,
                        decoration: CustomDropdownDecoration(
                          closedFillColor: bg,
                          expandedFillColor: bg,
                          closedBorder: Border.all(color: Colors.grey.shade300),
                          expandedBorder: Border.all(
                            color: Colors.grey.shade300,
                          ),
                          closedBorderRadius: BorderRadius.circular(8),
                          expandedBorderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      if (c.selectedVehicle.value.isNotEmpty &&
                          c.vehicleAlreadyRequested(c.selectedVehicle.value))
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Sudah ada request service untuk kendaraan ini.',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Keluhan
                Text(
                  'Keluhan',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Jelaskan masalah kendaraan secara detail, misal: suara mesin kasar atau rem kurang pakem.',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: hintColor,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: c.complaintController,
                  maxLines: 4,
                  onChanged: (v) => c.complaintText.value = v,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Jelaskan keluhan...',
                    hintStyle: TextStyle(color: hintColor),
                    filled: true,
                    fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Bukti Kerusakan
                Text(
                  'Bukti Kerusakan',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Unggah foto atau video untuk membantu teknisi memahami kerusakan.',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: hintColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => c.pickImage(),
                        icon: Icon(Icons.photo_camera, color: Colors.green),
                        label: Text(
                          'Foto',
                          style: GoogleFonts.nunito(color: textColor),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor:
                              isDark ? Colors.grey[850] : Colors.grey[100],
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => c.pickVideo(),
                        icon: Icon(Icons.videocam, color: Colors.orange),
                        label: Text(
                          'Video',
                          style: GoogleFonts.nunito(color: textColor),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor:
                              isDark ? Colors.grey[850] : Colors.grey[100],
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Obx(
                  () =>
                      c.mediaList.isEmpty
                          ? Text(
                            'Belum ada media. Tambahkan foto atau video.',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: hintColor,
                            ),
                          )
                          : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                c.mediaList.map((file) {
                                  final bool isVideo = file.path
                                      .toLowerCase()
                                      .endsWith('.mp4');
                                  return Stack(
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color:
                                              isDark
                                                  ? Colors.grey[850]
                                                  : Colors.grey[100],
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child:
                                            isVideo
                                                ? Icon(
                                                  Icons.videocam,
                                                  color: Colors.orange,
                                                )
                                                : ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Image.file(
                                                    File(file.path),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () => c.removeMedia(file),
                                          child: Icon(
                                            Icons.close,
                                            size: 20,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                          ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Obx(
            () => ElevatedButton.icon(
              onPressed:
                  (c.isLoading.value || c.disableSubmitButton.value)
                      ? null
                      : () => c.submitRequest(context),
              icon:
                  c.isLoading.value
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : Icon(Icons.send, color: bg),
              label: Text(
                c.isLoading.value ? 'Loading...' : 'Kirim Permintaan',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: bg,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
