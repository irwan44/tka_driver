import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../main.dart';
import '../../booking/views/booking_view.dart';
import '../../emergency/views/emergency_view.dart';
import '../../profile/views/profile_view.dart';
import '../controllers/home_controller.dart';

class ThemeController extends GetxController {
  final RxBool isDark = false.obs;

  @override
  void onInit() {
    super.onInit();
    Get.changeThemeMode(ThemeMode.system);
    _updateFromPlatform();
    WidgetsBinding.instance.window.onPlatformBrightnessChanged = () {
      Get.changeThemeMode(ThemeMode.system);
      _updateFromPlatform();
    };
  }

  void toggleTheme(bool value) {
    isDark.value = value;
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  void _updateFromPlatform() {
    final brightness = WidgetsBinding.instance.window.platformBrightness;
    isDark.value = brightness == Brightness.dark;
  }
}

class HomeView extends StatelessWidget {
  HomeView({Key? key}) : super(key: key) {
    Get.put(HomeController());
  }

  final List<Widget> _pages = [BookingView(), EmergencyView(), ProfileView()];

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final HomeController c = Get.find<HomeController>();

    return Scaffold(
      extendBody: true,
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      body: BottomBar(
        barColor: Colors.transparent,
        showIcon: false,
        hideOnScroll: false,
        body:
            (_, __) => GetBuilder<HomeController>(
              builder:
                  (c2) => Column(
                    children: [
                      const _HeaderSection(),
                      Expanded(child: _pages[c2.tabIndex]),
                    ],
                  ),
            ),
        child: GetBuilder<HomeController>(
          builder:
              (c1) =>
                  c1.showBars
                      ? _FloatingNavBar(controller: c1)
                      : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({required this.controller});
  final HomeController controller;

  // tinggi bar & diameter FAB dipatok agar mudah dihitung
  static const double _navBarHeight = 60;
  static const double _fabSize = 70;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      // tinggi = bar + ½ FAB + sedikit margin
      height: _navBarHeight + _fabSize / 2 + 16,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // ---------- BACKGROUND NAV BAR ----------
          Positioned(
            bottom: 0,
            left: -30,
            right: -30,
            child: Container(
              height: _navBarHeight,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color:
                    isDark ? Colors.grey[850] : Colors.white, // serupa gambar
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NavItemSmall(
                    index: 0,
                    icon: Icons.home, // contoh ikon “rumah”
                    label: 'Service',
                    controller: controller,
                  ),
                  const SizedBox(width: 60), // ruang FAB
                  _NavItemSmall(
                    index: 2,
                    icon: Icons.person,
                    label: 'Profile',
                    controller: controller,
                  ),
                ],
              ),
            ),
          ),
          // ---------- EMERGENCY / FAB ----------
          Positioned(
            // ½ FAB nongol di luar nav bar
            bottom: _navBarHeight - _fabSize / 2,
            child: Obx(() {
              final badge = controller.diterimaCount.value;
              final bool selected = controller.tabIndex == 1;

              return GestureDetector(
                onTap: () => controller.changeTabIndex(1),
                child: Container(
                  width: _fabSize,
                  height: _fabSize,
                  decoration: BoxDecoration(
                    color: Colors.red, // ganti biru jika mau sama dengan gambar
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border:
                        selected
                            ? Border.all(color: Colors.white, width: 4)
                            : null,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.warning_amber_outlined,
                        color: Colors.white,
                        size: 38,
                      ),
                      if (badge > 0)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Center(
                              child: Text(
                                '$badge',
                                style: GoogleFonts.nunito(
                                  color: Colors.red,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _NavItemSmall extends StatelessWidget {
  const _NavItemSmall({
    required this.index,
    required this.icon,
    required this.label,
    required this.controller,
  });

  final int index;
  final IconData icon;
  final String label;
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final bool selected = controller.tabIndex == index;
    final Color color = selected ? Colors.blueAccent : Colors.grey;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => controller.changeTabIndex(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.nunito(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}

// ---------------- HEADER ----------------
class _HeaderSection extends StatelessWidget {
  const _HeaderSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: 10),
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
            child: Obx(
              () => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Light',
                    style: GoogleFonts.nunito(
                      color: isDark ? Colors.white70 : Colors.black,
                    ),
                  ),
                  Switch(
                    value: themeController.isDark.value,
                    onChanged: themeController.toggleTheme,
                    activeColor: Colors.blue,
                  ),
                  Text(
                    'Dark',
                    style: GoogleFonts.nunito(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
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
        ],
      ),
    );
  }
}
