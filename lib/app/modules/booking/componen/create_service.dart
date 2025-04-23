import 'dart:io';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../emergency/controllers/emergency_controller.dart';
import '../controllers/booking_controller.dart';
import 'langkah_penggunaan.dart';

class RegularRepairPage extends StatelessWidget {
  RegularRepairPage({Key? key}) : super(key: key) {

  }

  @override
  Widget build(BuildContext context) {
    final BookingController c = Get.find<BookingController>();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark ? Colors.grey[800]! : const Color(0xFFF6F7FB);
    final Color hintColor = isDark ? Colors.grey[400]! : Colors.grey;
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[850] : const Color(0xFFF6F7FB),
        title: Text(
          'Buat Request Service',
          style: GoogleFonts.nunito(color: isDark ? Colors.white : Colors.black),
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      bottomNavigationBar: Container(
        color: isDark ? Colors.grey[850] : Colors.white,
        padding: const EdgeInsets.all(16),
        child: Obx(
              () => ElevatedButton.icon(
                onPressed: c.disableBuatEmergencyServiceButton
                    ? null
                    : () => c.submitEmergencyRepair(context),
            icon: c.isLoading.value
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Icon(Icons.send),
            label: c.isLoading.value
                ? const Text("Loading...")
                : Text(
              "Kirim Permintaan",
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Obx(
                () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Silakan lengkapi data berikut untuk melakukan permintaan Request Service:',
                  style: GoogleFonts.nunito(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[850] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.directions_bus, size: 24, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Kendaraan',
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Obx(() {
                        final bool isDark = Theme.of(context).brightness == Brightness.dark;
                        // pakai .shadeXXX agar selalu return Color (bukan Color?)
                        final Color bgColor = isDark
                            ? Colors.grey.shade800
                            : const Color(0xFFF6F7FB);
                        final Color borderColor = isDark
                            ? Colors.grey.shade600
                            : Colors.grey;

                        final listItemDecoration = ListItemDecoration(
                          splashColor: Colors.transparent,
                          highlightColor: isDark
                              ? Colors.grey.shade700
                              : const Color(0xFFEEEEEE),
                          selectedColor: isDark
                              ? Colors.grey.shade800
                              : const Color(0xFFF5F5F5),
                          selectedIconColor: borderColor,
                          selectedIconBorder: BorderSide(color: borderColor),
                          selectedIconShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );

                        return CustomDropdown<String>(
                          hintText: 'Pilih Kendaraan',
                          items: c.availableVehicles,
                          initialItem: c.selectedVehicle.value.isEmpty
                              ? null
                              : c.selectedVehicle.value,
                          excludeSelected: false,
                          onChanged: (value) {
                            if (value != null) c.selectedVehicle.value = value;
                          },
                          decoration: CustomDropdownDecoration(
                            closedFillColor: bgColor,
                            expandedFillColor: bgColor,
                            closedBorder: Border.all(color: Colors.transparent),
                            closedBorderRadius: BorderRadius.circular(12),
                            expandedBorder: Border.all(color: Colors.transparent),
                            expandedBorderRadius: BorderRadius.circular(12),
                            closedSuffixIcon:
                            Icon(Icons.arrow_drop_down, color: borderColor),
                            expandedSuffixIcon:
                            Icon(Icons.arrow_drop_up, color: borderColor),
                            hintStyle: TextStyle(color: borderColor),
                            headerStyle:
                            TextStyle(color: isDark ? Colors.white : Colors.black),
                            listItemStyle:
                            TextStyle(color: isDark ? Colors.white : Colors.black),
                            listItemDecoration: listItemDecoration,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[850] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          FaIcon(FontAwesomeIcons.exclamationCircle, color: Colors.orange[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Keluhan',
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[800],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      TextField(
                        controller: c.complaintController,
                        onChanged: (val) {
                          c.complaintText.value = val;
                        },
                        maxLines: 3,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: bgColor,
                          hintText: 'Jelaskan kerusakan/keluhan...',
                          hintStyle: TextStyle(color: hintColor),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[850] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.camera_alt, size: 24, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            'Bukti Kerusakan',
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? Colors.grey[800] : Colors.white,
                              ),
                              onPressed: () => c.pickImage(),
                              icon: Icon(Icons.photo_camera, color: isDark ? Colors.white : Colors.black),
                              label: Text('Foto', style: GoogleFonts.nunito(color: isDark ? Colors.white : Colors.black)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? Colors.grey[800] : Colors.white,
                              ),
                              onPressed: () => c.pickVideo(),
                              icon: Icon(Icons.videocam, color: isDark ? Colors.white : Colors.black),
                              label: Text('Video', style: GoogleFonts.nunito(color: isDark ? Colors.white : Colors.black)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (c.mediaList.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: c.mediaList.map((file) {
                            final bool isVideo = file.path.toLowerCase().endsWith('.mp4') ||
                                file.path.toLowerCase().endsWith('.mov') ||
                                file.path.toLowerCase().endsWith('.avi');
                            return Stack(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: isVideo
                                      ? const Center(child: Icon(Icons.videocam, size: 32))
                                      : ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(file.path),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: GestureDetector(
                                    onTap: () => c.removeMedia(file),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        )
                      else
                        Text(
                          'Belum ada foto atau video.',
                          style: GoogleFonts.nunito(color: isDark ? Colors.grey[400] : Colors.grey[700]),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
