// lib/app/modules/profile/views/profile_view.dart
import 'package:app_settings/app_settings.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shimmer/shimmer.dart';

import '../../../data/data_respon/profile2.dart';
import '../../../data/endpoint.dart';
import '../../../data/localstorage.dart';
import '../../../routes/app_pages.dart';
import '../../booking/componen/langkah_penggunaan.dart';
import '../../emergency/componen/langkah_penggunaan.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends StatelessWidget {
  ProfileView({Key? key}) : super(key: key) {
    Get.put(ProfileController());
  }
  bool _isNarrow(double w) => w < 360;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF2B2B2B) : const Color(0xFFF6F7FB);
    final cardColor = isDark ? const Color(0xFF393939) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      body: LayoutBuilder(
        builder: (_, c) {
          final w = c.maxWidth;
          final narrow = _isNarrow(w);
          final pad = narrow ? 12.0 : 16.0;
          final avatar = narrow ? 48.0 : 60.0;

          return SingleChildScrollView(
            padding: EdgeInsets.all(pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── HEADER ──────────────────────────────────────────────
                _ProfileHeader(
                  isDark: isDark,
                  avatar: avatar,
                  pad: pad,
                  cardColor: cardColor,
                ),

                const SizedBox(height: 20),

                // ── STATISTICS CARD ─────────────────────────────────────
                _StatisticsCard(isDark: isDark, cardColor: cardColor),

                const SizedBox(height: 20),

                // ── MENU LIST ──────────────────────────────────────────
                _MenuSection(isDark: isDark, cardColor: cardColor),
                SizedBox(height: 180),
              ],
            ),
          );
        },
      ),
    );
  }
}

/*────────────────────────────  STATISTICS  ────────────────────────────*/
/*──────────────── HEADER DENGAN DATA API ────────────────*/

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.isDark,
    required this.avatar,
    required this.pad,
    required this.cardColor,
  });

  final bool isDark;
  final double avatar;
  final double pad;
  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Profile2>(
      future: API.getProfile(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Shimmer.fromColors(
            baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
            highlightColor:
                isDark ? Colors.grey.shade700 : Colors.grey.shade100,
            child: Container(
              padding: EdgeInsets.all(pad),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: avatar,
                    height: avatar,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey, // lingkaran avatar abu-abu
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 16, color: Colors.grey),
                        const SizedBox(height: 6),
                        Container(height: 12, width: 120, color: Colors.grey),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (snap.hasError || !snap.hasData) {
          return Container(
            padding: EdgeInsets.all(pad),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Gagal memuat profil',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        final profile = snap.data!;
        return Container(
          padding: EdgeInsets.all(pad),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              if (!isDark)
                const BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: avatar / 2,
                backgroundImage: AssetImage('assets/icon/driver.png'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      profile.name ?? '-',
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.car_rental_rounded,
                          size: 14,
                          color: Colors.orange[400],
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            profile.posisi ?? '-', // <- sesuaikan field
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              color: isDark ? Colors.white70 : Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.email_rounded,
                          size: 14,
                          color: Colors.orange[400],
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            profile.email ?? '-', // <- sesuaikan field
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              color: isDark ? Colors.white70 : Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/*────────────────────────────  STATISTICS  ────────────────────────────*/

class _StatisticsCard extends GetView<ProfileController> {
  const _StatisticsCard({
    required this.isDark,
    required this.cardColor,
    super.key,
  });

  final bool isDark;
  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    TextStyle label = GoogleFonts.nunito(fontSize: 13, color: Colors.grey);
    TextStyle value = GoogleFonts.nunito(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: isDark ? Colors.white : Colors.black,
    );

    Widget stat(String title, int val, {Widget? extra}) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: label),
        const SizedBox(height: 2),
        Row(
          children: [
            Text(val.toString(), style: value),
            if (extra != null) ...[const SizedBox(width: 4), extra],
          ],
        ),
      ],
    );

    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (!isDark)
              const BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─ Header ─
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.query_stats_rounded,
                    size: 16,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Statistics',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ─ Content ─
            Row(
              children: [
                // kolom kiri
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      stat('Request Service', controller.requestCount),
                      const SizedBox(height: 8),
                      stat('Status Service', controller.statusCount),
                    ],
                  ),
                ),
                // kolom kanan
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(
                        () => stat(
                          'History Service',
                          controller.listHistoryService.length,
                        ),
                      ),
                      const SizedBox(height: 8),
                      stat('Emergency Service', controller.emergencyCount),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

/*────────────────────────────  MENU LIST  ─────────────────────────────*/

class _MenuSection extends StatelessWidget {
  _MenuSection({required this.isDark, required this.cardColor});
  final bool isDark;
  final Color cardColor;
  @override
  Widget build(BuildContext context) {
    final items = [
      _MenuItemData(
        'Notification Preference',
        FontAwesomeIcons.bell,
        color: Colors.amber,
        onTap: () async {
          await AppSettings.openAppSettings(type: AppSettingsType.notification);
        },
      ),
      _MenuItemData(
        'Panduan Penggunaan',
        FontAwesomeIcons.book,
        color: Colors.blueAccent,
        onTap: () {
          Get.bottomSheet(
            DraggableScrollableSheet(
              initialChildSize: 0.70,
              minChildSize: 0.25,
              maxChildSize: 0.7,
              expand: false,
              builder:
                  (_, scrollCtrl) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: SingleChildScrollView(
                      controller: scrollCtrl,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Grabber bar
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color:
                                    isDark
                                        ? Colors.grey[700]
                                        : Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Header
                          Center(
                            child: Text(
                              'Panduan Penggunaan',
                              style: GoogleFonts.nunito(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              'Pilih layanan yang kamu butuhkan di bawah ini',
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Grid tombol
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              GuideTile(
                                icon: Icons.build_circle,
                                title: 'Request Service',
                                subtitle: 'Ajukan permintaan maintenance',
                                color: Colors.blue,
                                onTap: () => Get.to(UsageGuidePage()),
                              ),
                              GuideTile(
                                icon: Icons.warning_amber_rounded,
                                title: 'Emergency Service',
                                subtitle: 'Layanan darurat 24/7',
                                color: Colors.red,
                                onTap: () => Get.to(EmergencyGuidePage()),
                              ),
                              // Tambahkan tile lain jika perlu
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Info footer
                          Text(
                            'Butuh bantuan lebih lanjut? Hubungi tim support kami melalui chat di pojok kanan bawah.',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
            ),
            isDismissible: true,
            backgroundColor: Colors.transparent,
          );
        },
      ),
      _MenuItemData(
        'Keluar Aplikasi',
        Icons.logout,
        color: Colors.redAccent,
        onTap: () {
          Get.bottomSheet(
            DraggableScrollableSheet(
              builder:
                  (_, scrollCtrl) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: SingleChildScrollView(
                      controller: scrollCtrl,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Grabber bar
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color:
                                  isDark ? Colors.grey[700] : Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Title
                          Text(
                            'Logout',
                            style: GoogleFonts.nunito(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Message
                          Text(
                            'Apakah Anda yakin ingin logout? Semua data session Anda akan dihapus.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color:
                                          isDark
                                              ? Colors.grey[700]!
                                              : Colors.grey[300]!,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor:
                                        isDark
                                            ? Colors.grey[850]
                                            : Colors.white,
                                  ),
                                  onPressed: Get.back,
                                  child: Text(
                                    'Batal',
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      color:
                                          isDark
                                              ? Colors.white
                                              : Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () async {
                                    await LocalStorages.logout();
                                    await OneSignal.logout();
                                    Get.offAllNamed(Routes.LOGIN);
                                  },
                                  child: Text(
                                    'Logout',
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
            ),
            isDismissible: true,
            backgroundColor: Colors.transparent,
          );
        },
      ),
    ];

    return Column(
      children: [for (final item in items) _MenuTile(item, isDark, cardColor)],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile(this.item, this.isDark, this.cardColor, {super.key});

  final _MenuItemData item;
  final bool isDark;
  final Color cardColor;

  Widget _buildLeading() {
    final isFa = item.icon.fontFamily?.startsWith('FontAwesome') ?? false;
    return isFa
        ? FaIcon(item.icon, size: 20, color: item.color)
        : Icon(item.icon, size: 20, color: item.color);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          if (!isDark)
            const BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
        ],
      ),
      child: ListTile(
        leading: _buildLeading(),
        title: Text(
          item.title,
          style: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        trailing:
            item.trailing ??
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey,
              size: 22,
            ),

        // ⬇︎  gunakan wrapper agar callback pasti dipanggil
        onTap: () {
          // tutup keyboard kalau ada
          FocusScope.of(context).unfocus();

          // panggil callback jika tersedia
          item.onTap?.call();
        },
      ),
    );
  }
}

class _MenuItemData {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap; // ← NEW
  final Widget? trailing;

  _MenuItemData(
    this.title,
    this.icon, {
    required this.color,
    this.onTap,
    this.trailing,
  });
}

class GuideTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const GuideTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: (Get.width - 64) / 2, // dua kotak per baris
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
