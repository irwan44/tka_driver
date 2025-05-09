import 'dart:ui';

import 'package:app_settings/app_settings.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tka_customer/app/data/localstorage.dart';
import 'package:tka_customer/app/routes/app_pages.dart';

import '../../../../main.dart';
import '../../../data/data_respon/profile2.dart';
import '../../../data/endpoint.dart';
import '../../home/views/home_view.dart';
import '../compenen/listrequest.dart';
import '../controllers/home_p_i_c_controller.dart';

class HomePICView extends StatelessWidget {
  HomePICView({Key? key}) : super(key: key) {
    Get.put(HomePICController());
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GetBuilder<HomePICController>(
      builder: (c) {
        return Scaffold(
          backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
          body: Column(children: [_HeaderSection(), ListrequestService()]),
        );
      },
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 175,
      margin: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black54 : Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 40,
            right: 20,
            child: Obx(() {
              return Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Light",
                        style: GoogleFonts.nunito(
                          color: isDark ? Colors.white70 : Colors.black,
                        ),
                      ),
                      Switch(
                        value: themeController.isDark.value,
                        onChanged:
                            (value) => themeController.toggleTheme(value),
                        activeColor: Colors.blue,
                      ),
                      Text(
                        "Dark",
                        style: GoogleFonts.nunito(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(AssetsRes.LOGO, height: 30),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
          const Positioned(
            bottom: -20,
            left: 0,
            right: 0,
            child: _DriverProfileCard(),
          ),
        ],
      ),
    );
  }
}

class DriverProfileCard extends StatelessWidget {
  const DriverProfileCard({super.key});

  @override
  Widget build(BuildContext context) => const _DriverProfileCard();
}

class _DriverProfileCard extends StatelessWidget {
  const _DriverProfileCard({Key? key}) : super(key: key);

  bool _isNarrow(double w) => w < 360;
  double _avatar(double w) =>
      w < 350
          ? 40
          : w < 500
          ? 50
          : 60;
  double _pad(double w) => w < 350 ? 8 : 12;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (ctx, c) {
        final w = c.maxWidth;
        final narrow = _isNarrow(w);
        final avatar = _avatar(w);
        final pad = _pad(w);

        return FutureBuilder<Profile2>(
          future: API.getProfile(),
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return _SkeletonCard(
                isDark: isDark,
                pad: pad,
                avatar: avatar,
                vertical: narrow,
              );
            }

            if (snap.hasError) {
              return _ErrorCard(isDark: isDark, pad: pad);
            }

            if (snap.hasData) {
              final profile = snap.data!;
              final showLabel = w > 360;

              return Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: pad),
                padding: EdgeInsets.all(pad),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black54 : Colors.black12,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Flex(
                  direction: narrow ? Axis.vertical : Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: avatar / 2,
                      child: ClipOval(
                        child: Image.asset(
                          'assets/icon/driver.png',
                          width: avatar,
                          height: avatar,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: narrow ? 0 : 16, height: narrow ? 12 : 0),
                    if (narrow)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: _InfoColumn(profile: profile),
                      )
                    else
                      Expanded(child: _InfoColumn(profile: profile)),

                    if (!narrow) const SizedBox(width: 8),
                    _LogoutButton(showLabel: showLabel, isDark: isDark),
                  ],
                ),
              );
            }
            return const SizedBox.shrink(); // fallback
          },
        );
      },
    );
  }
}

class _InfoColumn extends StatelessWidget {
  const _InfoColumn({required this.profile});
  final Profile2 profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoSizeText(
          profile.name ?? 'N/A',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          maxLines: 2,
          minFontSize: 10,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          profile.posisi ?? '',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        AutoSizeText(
          profile.email ?? 'N/A',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          maxLines: 1,
          minFontSize: 8,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({
    required this.showLabel,
    super.key,
    required bool isDark,
  });
  final bool showLabel;

  void _openSettings(BuildContext context) {
    final box = GetStorage('preferences-mekanik');
    bool notifEnabled = box.read('notifications_enabled') ?? true;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                color:
                    isDark
                        ? Colors.grey[900]!.withOpacity(0.8)
                        : Colors.white.withOpacity(0.8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[700] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pengaturan',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Menu: Notifikasi
                    ListTile(
                      leading: Icon(
                        Icons.notifications_active_rounded,
                        color: Colors.redAccent,
                        size: 28,
                      ),
                      title: Text(
                        'Pengaturan Notifikasi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        'Kelola izin notifikasi aplikasi',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      onTap: () {
                        AppSettings.openAppSettings(
                          type: AppSettingsType.notification,
                        );
                      },
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      tileColor: isDark ? Colors.grey[800] : Colors.grey[100],
                    ),

                    const Spacer(),

                    // Logout Button
                    ElevatedButton.icon(
                      onPressed: () async {
                        await LocalStorages.logout();
                        await OneSignal.logout();
                        Get.offAllNamed(Routes.LOGIN);
                      },
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _openSettings(context),
      icon: const Icon(Icons.settings),
      label: showLabel ? const Text('Menu') : const SizedBox.shrink(),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.blueAccent,
        side: BorderSide(color: Colors.blueAccent.withOpacity(0.7)),
        shape: const StadiumBorder(),
        padding: EdgeInsets.symmetric(
          horizontal: showLabel ? 10 : 6,
          vertical: 6,
        ),
        backgroundColor: Colors.transparent,
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({
    required this.isDark,
    required this.pad,
    required this.avatar,
    required this.vertical,
  });

  final bool isDark;
  final double pad, avatar;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: pad),
        padding: EdgeInsets.all(pad),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Flex(
          direction: vertical ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: avatar,
              height: avatar,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
            SizedBox(width: vertical ? 0 : 16, height: vertical ? 12 : 0),
            Flexible(
              fit: FlexFit.loose, // <- aman di Column
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(width: 150, height: 14, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(width: 100, height: 14, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.isDark, required this.pad});
  final bool isDark;
  final double pad;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: pad),
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          'Tidak ada koneksi internet',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
