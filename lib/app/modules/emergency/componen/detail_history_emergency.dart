// emergency_detail_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tka_customer/app/data/data_respon/list_emergency.dart';
import 'package:geocoding/geocoding.dart';

import '../controllers/emergency_controller.dart';
import 'lacak_mekanik.dart';

// Fullscreen Video
class FullscreenVideoView extends StatefulWidget {
  final String url;
  const FullscreenVideoView({Key? key, required this.url}) : super(key: key);

  @override
  State<FullscreenVideoView> createState() => _FullscreenVideoViewState();
}

class _FullscreenVideoViewState extends State<FullscreenVideoView> {
  late VideoPlayerController _videoController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() => _initialized = true);
        _videoController.play();
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _videoController.value.isPlaying
          ? _videoController.pause()
          : _videoController.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          'Preview Video',
          style: GoogleFonts.nunito(color: isDark ? Colors.white : Colors.black),
        ),
        backgroundColor: isDark ? Colors.black : Colors.white,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: BackButton(color: isDark ? Colors.white : Colors.black),
      ),
      body: GestureDetector(
        onTap: _togglePlayPause,
        child: _initialized
            ? SizedBox(
          width: mq.width,
          height: mq.height,
          child: FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.center,
            child: SizedBox(
              width: _videoController.value.size.width,
              height: _videoController.value.size.height,
              child: VideoPlayer(_videoController),
            ),
          ),
        )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}


// Fullscreen Image
class FullscreenImageView extends StatelessWidget {
  final String url;
  const FullscreenImageView({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final overlayStyle = isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        appBar: AppBar(
          backgroundColor: isDark ? Colors.black : Colors.white,
          title: Text(
            'Preview Foto',
            style: GoogleFonts.nunito(color: isDark ? Colors.white : Colors.black),
          ),
          iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 5.0,
              child: Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stack) {
                  return Center(
                    child: Text(
                      'Gagal memuat gambar',
                      style: GoogleFonts.nunito(color: Colors.red),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Emergency Detail View
class EmergencyDetailView extends StatefulWidget {
  const EmergencyDetailView({Key? key}) : super(key: key);

  @override
  State<EmergencyDetailView> createState() => _EmergencyDetailViewState();
}

class _EmergencyDetailViewState extends State<EmergencyDetailView>
    with SingleTickerProviderStateMixin {
  late EmergencyController detailController;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    detailController = Get.put(EmergencyController());
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // Fungsi bantu get address
  Future<String> _getAddress(String? lat, String? lng) async {
    double? latitude = double.tryParse(lat ?? '');
    double? longitude = double.tryParse(lng ?? '');
    if (latitude == null || longitude == null) {
      return "Alamat tidak tersedia";
    }
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address =
            "${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}";
        return address;
      }
      return "Alamat tidak ditemukan";
    } catch (e) {
      return "Error: $e";
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final overlayStyle = isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;

    final Data data = Get.arguments as Data; // data emergency
    final mediaList = data.emergencyMedia ?? [];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: isDark ? Colors.grey[900] : const Color(0xFFF6F7FB),
          elevation: 1,
          title: Text(
            'Detail Emergency',
            style: GoogleFonts.nunito(color: isDark ? Colors.white : Colors.black),
          ),
          iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        backgroundColor: isDark ? Colors.grey[900] : const Color(0xFFF6F7FB),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              // Logic refresh (jika diperlukan)
            },
            child: Obx(() {
              if (detailController.isLoading.value) {
                return _buildShimmerLoading();
              }
              if (detailController.errorMessage.value.isNotEmpty) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'Error: ${detailController.errorMessage.value}',
                      style: GoogleFonts.nunito(color: Colors.red),
                    ),
                  ),
                );
              }
              // Animasi transisi
              _animController.forward();
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: SingleChildScrollView(
                  key: const ValueKey('emergency_content'),
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildTicketInfoSection(data, isDark),
                      const SizedBox(height: 20),
                      _buildTicketMediaSection(mediaList, isDark),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  /// Bagian Info
  Widget _buildTicketInfoSection(Data data, bool isDark) {
    // Daftar status yang mem-**disable** tombol lacak
    final disableStatuses = [
      'Diterima',
      'Mekanik Ditugaskan',
    ];

    // Tombol lacak disable jika status ada di daftar di atas
    final isTrackingDisabled = disableStatuses.contains(data.status);

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.5 : 0.07),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Text(
                    'Informasi Emergency',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.grey[300] : Colors.grey[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildRowInfo(Icons.calendar_today, 'Tanggal', data.tgl ?? '-', isDark),
              _buildRowInfo(Icons.access_time, 'Jam', data.jam ?? '-', isDark),
              _buildRowInfo(Icons.directions_car, 'No. Polisi', data.noPolisi ?? '-', isDark),
              _buildDottedSeparator(),
              _buildRowInfo(Icons.person, 'Nama', data.nama ?? '-', isDark),
              _buildRowInfo(Icons.phone, 'HP', data.hp ?? '-', isDark),
              _buildRowInfo(Icons.email, 'Email', data.email ?? '-', isDark),
              _buildRowInfo(Icons.report_problem, 'Keluhan', data.keluhan ?? '-', isDark),
              _buildDottedSeparator(),
              // Alamat
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on, size: 18, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 100,
                      child: Text(
                        "Alamat",
                        style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      child: FutureBuilder<String>(
                        future: _getAddress(data.latitude, data.longitude),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Text(
                              "Mengambil alamat...",
                              style: GoogleFonts.nunito(fontSize: 14),
                            );
                          } else if (snapshot.hasError) {
                            return Text(
                              "Error: ${snapshot.error}",
                              style: GoogleFonts.nunito(fontSize: 14),
                            );
                          } else {
                            return Text(
                              snapshot.data ?? "-",
                              style: GoogleFonts.nunito(fontSize: 14),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              _buildDottedSeparator(),
              _buildRowInfo(Icons.build, 'Kode Service', data.kode ?? '-', isDark),
              _buildRowInfo(Icons.person_pin, 'Kode Forman', data.kodeForman ?? '-', isDark),
              _buildRowInfo(Icons.handyman, 'Kode Ottogo', data.kodeOttogo ?? '-', isDark),
              _buildDottedSeparator(),
              _buildRowInfo(Icons.edit_note, 'Catatan Mekanik', data.catatanMekanik ?? '-', isDark),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Status: ${data.status ?? '-'}',
                      style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Bagian TOMBOL LACAK
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  // onPressed = null => button disable
                  onPressed: isTrackingDisabled
                      ? null
                      : () {
                    // Jika status "Mekanik Dalam Perjalanan", misal,
                    // user boleh ke LacakMekanik
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LacakMekanik(data: data),
                        maintainState: false,

                      ),
                    );
                  },
                  icon: const Icon(Icons.location_searching, color: Colors.white),
                  label: Text(
                    'Lacak Posisi Mekanik',
                    style: GoogleFonts.nunito(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    // Jika disable => warna abu-abu; jika enable => warna biru
                    backgroundColor: isTrackingDisabled ? Colors.grey : Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              )
            ],
          ),
        ),
        Positioned(
          left: 0,
          top: 30,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          bottom: 30,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Bagian Media
  Widget _buildTicketMediaSection(List<EmergencyMedia> mediaList, bool isDark) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.5 : 0.07),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.photo_library, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Text(
                    'Foto/Video Emergency',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.grey[300] : Colors.grey[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (mediaList.isEmpty)
                Text(
                  'Tidak ada media untuk emergency ini.',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey,
                  ),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final double itemWidth =
                    constraints.maxWidth < 450 ? 150.0 : 200.0;
                    return SizedBox(
                      height: itemWidth + 10,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: mediaList.length,
                        separatorBuilder: (ctx, i) => const SizedBox(width: 12),
                        itemBuilder: (ctx, i) {
                          final EmergencyMedia media = mediaList[i];
                          return _buildMediaItem(context, media, itemWidth, isDark);
                        },
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          top: 30,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          bottom: 30,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper widget
  Widget _buildRowInfo(IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: isDark ? Colors.grey[400] : Colors.grey[600]),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.nunito(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDottedSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: List.generate(80 ~/ 2, (index) {
          return Expanded(
            child: Container(
              color: index % 2 == 0 ? Colors.transparent : Colors.grey[400],
              height: 1,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMediaItem(BuildContext context, EmergencyMedia media, double size, bool isDark) {
    final String url = media.media ?? '';
    final String type = media.type?.toLowerCase() ?? '';
    final bool isVideo = type.contains('video') || type.contains('mp4');

    if (isVideo) {
      return InkWell(
        onTap: () => Get.to(() => FullscreenVideoView(url: url)),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.videocam, size: 48, color: Colors.grey),
        ),
      );
    } else {
      return InkWell(
        onTap: () => Get.to(() => FullscreenImageView(url: url)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            url,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (ctx, error, stack) {
              return Container(
                width: size,
                height: size,
                color: Colors.black12,
                alignment: Alignment.center,
                child: Text(
                  'Gagal memuat gambar',
                  style: GoogleFonts.nunito(color: Colors.red),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: const [
          _ShimmerInfoSection(),
          SizedBox(height: 16),
          _ShimmerMediaSection(),
        ],
      ),
    );
  }
}

class _ShimmerInfoSection extends StatelessWidget {
  const _ShimmerInfoSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade600 : Colors.grey.shade100,
      child: Container(
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

class _ShimmerMediaSection extends StatelessWidget {
  const _ShimmerMediaSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade600 : Colors.grey.shade100,
      child: Container(
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
