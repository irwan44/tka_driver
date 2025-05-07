// lib/app/modules/home_p_i_c/views/request_detail_page.dart

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

import '../../../data/data_respon/listrequestPIC.dart';
import '../../../data/endpoint.dart';
import '../../../routes/app_pages.dart';

class RequestDetailPage extends StatelessWidget {
  final ListRequesServicePIC item;
  final List<String> mediaFiles;
  const RequestDetailPage({
    Key? key,
    required this.item,
    required this.mediaFiles,
  }) : super(key: key);

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

  bool _isVideo(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.mp4') || lower.endsWith('.mov');
  }

  void _openViewer(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MediaViewerPage(url: url)),
    );
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
                    mediaFiles.isEmpty
                        ? Center(
                          child: Text(
                            'Tidak ada media',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        )
                        : SizedBox(
                          height: 100,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: mediaFiles.length,
                            separatorBuilder:
                                (_, __) => const SizedBox(width: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemBuilder: (ctx, i) {
                              final url = mediaFiles[i];
                              final isVideo = _isVideo(url);
                              return GestureDetector(
                                onTap: () => _openViewer(context, url),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.network(
                                        url,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (_, __, ___) => Container(
                                              width: 100,
                                              height: 100,
                                              color: Colors.grey,
                                              child: const Icon(
                                                Icons.broken_image,
                                                color: Colors.white,
                                              ),
                                            ),
                                      ),
                                    ),
                                    if (isVideo)
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black45,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.play_circle_fill,
                                              color: Colors.white,
                                              size: 32,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
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

class MediaViewerPage extends StatefulWidget {
  final String url;
  const MediaViewerPage({Key? key, required this.url}) : super(key: key);

  @override
  State<MediaViewerPage> createState() => _MediaViewerPageState();
}

class _MediaViewerPageState extends State<MediaViewerPage> {
  late final bool _isVideo;
  late double _realAspect;
  VideoPlayerController? _vCtrl;
  ChewieController? _cCtrl;

  @override
  void initState() {
    super.initState();
    _isVideo =
        widget.url.toLowerCase().endsWith('.mp4') ||
        widget.url.toLowerCase().endsWith('.mov');
    if (_isVideo) _initVideo();
  }

  Future<void> _initVideo() async {
    _vCtrl = VideoPlayerController.network(widget.url);
    await _vCtrl!.initialize();

    final size = _vCtrl!.value.size;
    int rot = 0;
    try {
      rot = (_vCtrl!.value.rotationCorrection) ?? 0;
    } catch (_) {}

    double w = size.width;
    double h = size.height;
    if (rot == 90 || rot == 270) {
      final tmp = w;
      w = h;
      h = tmp;
    }
    _realAspect = (w == 0 || h == 0) ? 9 / 16 : w / h;

    _cCtrl = ChewieController(
      videoPlayerController: _vCtrl!,
      autoPlay: true,
      looping: false,
      aspectRatio: _realAspect,
      additionalOptions: (context) => [],
    );
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _cCtrl?.dispose();
    _vCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(child: _isVideo ? _videoView() : _imageView()),
    );
  }

  Widget _videoView() {
    if (_cCtrl == null || !_vCtrl!.value.isInitialized) {
      return const CircularProgressIndicator(color: Colors.white);
    }
    return LayoutBuilder(
      builder: (ctx, c) {
        double h = c.maxHeight;
        double w = h * _realAspect;
        if (w > c.maxWidth) {
          w = c.maxWidth;
          h = w / _realAspect;
        }
        return SizedBox(
          width: w,
          height: h,
          child: Chewie(controller: _cCtrl!),
        );
      },
    );
  }

  Widget _imageView() {
    return PhotoView(
      imageProvider: NetworkImage(widget.url),
      backgroundDecoration: const BoxDecoration(color: Colors.black),
    );
  }
}
