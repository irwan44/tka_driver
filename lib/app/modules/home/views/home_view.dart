import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tka_customer/app/data/localstorage.dart';
import 'package:tka_customer/app/routes/app_pages.dart';

import '../../../../main.dart';
import '../../../data/data_respon/profile2.dart';
import '../../../data/endpoint.dart';
import '../../booking/views/booking_view.dart';
import '../../emergency/views/emergency_view.dart';
import '../controllers/home_controller.dart';

class ThemeController extends GetxController {
  RxBool isDark = false.obs;

  @override
  void onInit() {
    isDark.value =
        WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
    super.onInit();
  }

  void toggleTheme(bool value) {
    isDark.value = value;
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }
}

class HomeView extends StatelessWidget {
  HomeView({Key? key}) : super(key: key) {
    // Ensure HomeController is registered
    Get.put(HomeController());
  }
  final List<Widget> _pages = [BookingView(), EmergencyView()];

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.put(ThemeController());
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GetBuilder<HomeController>(
      builder: (c) {
        return Scaffold(
          backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
          body: Column(
            children: [
              const _HeaderSection(),
              Expanded(child: _pages[c.tabIndex]),
            ],
          ),
          bottomNavigationBar:
              c.showBars
                  ? BottomNavigationBar(
                    currentIndex: c.tabIndex,
                    onTap: c.changeTabIndex,
                    selectedItemColor: Colors.blueAccent,
                    unselectedItemColor: Colors.grey,
                    backgroundColor: isDark ? Colors.grey[850] : Colors.white,
                    items: [
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.build_circle_outlined),
                        label: 'Service',
                      ),
                      BottomNavigationBarItem(
                        icon: Obx(() {
                          final count = c.diterimaCount.value;
                          if (count > 0) {
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                const Icon(Icons.warning_amber_outlined),
                                Positioned(
                                  right: -6,
                                  top: -6,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 18,
                                      minHeight: 18,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$count',
                                        style: GoogleFonts.nunito(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                          return const Icon(Icons.warning_amber_outlined);
                        }),
                        label: 'Darurat',
                      ),
                    ],
                  )
                  : null,
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
                    color: Colors.white,
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
  const _LogoutButton({required this.showLabel, required this.isDark});
  final bool showLabel;
  final bool isDark;

  void _showSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Logout',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Apakah Anda yakin ingin logout? Anda akan keluar dan data session akan dihapus.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.grey[700] : Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                  onPressed: Get.back,
                  child: Text(
                    'Batal',
                    style: GoogleFonts.nunito(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                  onPressed: () async {
                    await LocalStorages.logout();
                    Get.offAllNamed(Routes.LOGIN);
                  },
                  child: Text(
                    'Logout',
                    style: GoogleFonts.nunito(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isDismissible: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ElevatedButton.icon(
        onPressed: () => _showSheet(context),
        icon: const Icon(Icons.logout_rounded, size: 18, color: Colors.white),
        label:
            showLabel
                ? const Text(
                  'Logout',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                )
                : const SizedBox.shrink(),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.red,
          padding: EdgeInsets.symmetric(horizontal: showLabel ? 16 : 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
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
