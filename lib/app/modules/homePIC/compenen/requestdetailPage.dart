// lib/app/modules/home_p_i_c/views/request_detail_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/data_respon/listrequestPIC.dart';
import '../../../data/endpoint.dart';
import '../../../routes/app_pages.dart';

class RequestDetailPage extends StatelessWidget {
  final ListRequesServicePIC item;
  const RequestDetailPage({Key? key, required this.item}) : super(key: key);

  Color _statusColor(String? s) {
    switch (s?.toLowerCase()) {
      case 'waiting':
        return Colors.orangeAccent;
      case 'done':
      case 'selesai':
        return Colors.green;
      case 'rejected':
      case 'ditolak':
        return Colors.redAccent;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _statusIcon(String? s) {
    switch (s?.toLowerCase()) {
      case 'waiting':
        return Icons.hourglass_empty;
      case 'done':
      case 'selesai':
        return Icons.check_circle;
      case 'rejected':
      case 'ditolak':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _statusColor(item.status);
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final iconColor = Theme.of(context).iconTheme.color;

    final tanggal =
        item.tanggalService?.isNotEmpty == true
            ? item.tanggalService
            : (item.createdAt != null
                ? DateFormat(
                  'dd MMM yyyy',
                ).format(DateTime.parse(item.createdAt!))
                : '-');
    final jam =
        item.jamService?.isNotEmpty == true
            ? item.jamService
            : (item.createdAt != null
                ? DateFormat('HH:mm').format(DateTime.parse(item.createdAt!))
                : '-');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Detail Request'),
        centerTitle: true,
        backgroundColor: statusColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Banner
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(_statusIcon(item.status), color: statusColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Status: ${item.status ?? '-'}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Request Info (minimal container)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      item.kodeRequestService ?? '-',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  const Divider(height: 24, thickness: 1),
                  _buildDetailRow(
                    context,
                    Icons.place,
                    'No Polisi',
                    item.noPolisi,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    Icons.person,
                    'Pelanggan',
                    item.kodePelanggan,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    Icons.directions_car,
                    'Keluhan',
                    item.keluhan,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    Icons.calendar_today,
                    'Tanggal Service',
                    tanggal,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    Icons.access_time,
                    'Jam Service',
                    jam,
                  ),

                  // Media Section
                  if (item.mediaFiles != null &&
                      item.mediaFiles!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Media:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: item.mediaFiles!.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder:
                            (ctx, i) => ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                item.mediaFiles![i],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                    onPressed: () {
                      Get.defaultDialog(
                        title: 'Konfirmasi Approve',
                        middleText:
                            'Apakah Anda yakin ingin menyetujui permintaan ini?',
                        textConfirm: 'Ya',
                        textCancel: 'Tidak',
                        confirmTextColor: Colors.white,
                        onConfirm: () async {
                          Get.back();
                          try {
                            await API.postApproveRequesService(
                              item.kodeRequestService!,
                            );
                            // Kalau berhasil, kembali ke halaman home:
                            Get.snackbar(
                              'Approved',
                              'Permintaan disetujui',
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );

                            Get.offAllNamed(Routes.HOME_P_I_C);
                          } catch (e) {
                            Get.snackbar('Warning', e.toString());
                          }
                        },
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.green),
                      foregroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                    onPressed: () {
                      Get.defaultDialog(
                        title: 'Konfirmasi Reject',
                        middleText:
                            'Apakah Anda yakin ingin menolak permintaan ini?',
                        textConfirm: 'Ya',
                        textCancel: 'Tidak',
                        confirmTextColor: Colors.white,
                        onConfirm: () async {
                          Get.back();
                          try {
                            await API.postRejectRequesService(
                              item.kodeRequestService!,
                            );
                            // Kalau berhasil, kembali ke halaman home:
                            Get.snackbar(
                              'Rejected',
                              'Permintaan ditolak',
                              backgroundColor: Colors.redAccent,
                              colorText: Colors.white,
                            );
                          } catch (e) {
                            Get.snackbar('Warning', e.toString());
                          }
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String? value,
  ) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final iconColor = Theme.of(context).iconTheme.color;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: '$label: ',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: textColor,
                fontSize: 14,
              ),
              children: [
                TextSpan(
                  text: value ?? '-',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
