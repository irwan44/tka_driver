// lib/app/modules/home_p_i_c/views/request_detail_page.dart

import 'package:chewie/chewie.dart';
import 'package:dotted_line/dotted_line.dart'; // <-- tambahkan di pubspec.yaml: dotted_line: ^3.0.0
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
    final statusColor = _statusColor(item.status);
    final tanggal =
        item.tanggalService?.isNotEmpty == true
            ? item.tanggalService!
            : (item.createdAt != null
                ? DateFormat(
                  'dd MMM yyyy',
                ).format(DateTime.parse(item.createdAt!))
                : '-');
    final jam =
        item.jamService?.isNotEmpty == true
            ? item.jamService!
            : (item.createdAt != null
                ? DateFormat('HH:mm').format(DateTime.parse(item.createdAt!))
                : '-');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Detail Request',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: statusColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Ticket Header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Row(
              children: [
                Icon(_statusIcon(item.status), color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.status?.toUpperCase() ?? '-',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.kodeRequestService ?? '-',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Body as a "ticket"
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Ticket stub shape using Row of circles & line
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      CircleAvatar(radius: 6, backgroundColor: Colors.grey),
                      Expanded(
                        child: DottedLine(
                          dashLength: 4,
                          dashColor: Colors.grey,
                          lineThickness: 1,
                        ),
                      ),
                      CircleAvatar(radius: 6, backgroundColor: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Detail Table
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(3),
                        },
                        children: [
                          _buildRow('No. Polisi', item.noPolisi),
                          _buildDividerRow(),
                          _buildRow('Pelanggan', item.kodePelanggan),
                          _buildDividerRow(),
                          _buildRow('Keluhan', item.keluhan),
                          _buildDividerRow(),
                          _buildRow('Tanggal', tanggal),
                          _buildDividerRow(),
                          _buildRow('Jam', jam),
                        ],
                      ),
                    ),
                  ),

                  // Media Preview
                  if (mediaFiles.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Bukti Media',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: mediaFiles.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, i) {
                          final url = mediaFiles[i];
                          return GestureDetector(
                            onTap: () => _openViewer(context, url),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Stack(
                                children: [
                                  Image.network(
                                    url,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) => Container(
                                          width: 120,
                                          height: 120,
                                          color: Colors.grey.shade200,
                                          child: const Icon(
                                            Icons.broken_image,
                                            size: 36,
                                          ),
                                        ),
                                  ),
                                  if (_isVideo(url))
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black38,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.play_circle_fill,
                                            size: 36,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _confirmApprove(context),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.green),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text('Approve'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _confirmReject(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildRow(String label, String? value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(value ?? '-'),
        ),
      ],
    );
  }

  TableRow _buildDividerRow() {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: SizedBox(height: 1, child: Container(color: Colors.grey[300])),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: SizedBox(height: 1, child: Container(color: Colors.grey[300])),
        ),
      ],
    );
  }

  void _confirmApprove(BuildContext context) {
    Get.defaultDialog(
      title: 'Konfirmasi Approve',
      middleText: 'Yakin ingin menyetujui?',
      textConfirm: 'Ya',
      textCancel: 'Tidak',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back();
        await API.postApproveRequesService(item.kodeRequestService!);
        Get.snackbar(
          'Approved',
          'Permintaan disetujui',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offAllNamed(Routes.HOME_P_I_C);
      },
    );
  }

  void _confirmReject(BuildContext context) {
    Get.defaultDialog(
      title: 'Konfirmasi Reject',
      middleText: 'Yakin ingin menolak?',
      textConfirm: 'Ya',
      textCancel: 'Tidak',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back();
        await API.postRejectRequesService(item.kodeRequestService!);
        Get.snackbar(
          'Rejected',
          'Permintaan ditolak',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      },
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
