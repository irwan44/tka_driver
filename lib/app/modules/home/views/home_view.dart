import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tka_customer/app/routes/app_pages.dart';
import '../../../../main.dart';
import '../../../data/data_respon/profile2.dart';
import '../../../data/endpoint.dart';
import '../../booking/views/booking_view.dart';
import '../../emergency/views/emergency_view.dart';
import '../controllers/home_controller.dart';
import 'package:tka_customer/app/data/localstorage.dart';

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

class HomeView extends GetView<HomeController> {
  HomeView({Key? key}) : super(key: key);

  final List<Widget> _pages = const [
    BookingView(),
    EmergencyView(),
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.put(ThemeController());
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GetBuilder<HomeController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
          body: Column(
            children: [
              const _HeaderSection(),
              Expanded(child: _pages[controller.tabIndex]),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: controller.tabIndex,
            onTap: controller.changeTabIndex,
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
                  final count = controller.diterimaCount.value;
                  // Jika count > 0, tampilkan badge + icon
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
                  // Kalau count null atau 0, kembalikan ikon standar
                  return const Icon(Icons.warning_amber_outlined);
                }),
                label: 'Darurat',
              ),

            ],
          ),
        );
      },
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({Key? key}) : super(key: key);

  Future<String> _getFullAddress() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.locality}, ${place.administrativeArea}, ${place.country}';
      }
      return 'Alamat tidak ditemukan';
    } catch (e) {
      return 'Gagal mendapatkan alamat';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 160,
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
                        color: isDark ? Colors.white70 : Colors.black),
                  ),
                  Switch(
                    value: themeController.isDark.value,
                    onChanged: (value) => themeController.toggleTheme(value),
                    activeColor: Colors.blue,
                  ),
                  Text(
                    "Dark",
                    style: GoogleFonts.nunito(
                        color: isDark ? Colors.white : Colors.black),
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
                  child: Image.asset(
                    AssetsRes.LOGO,
                    height: 30,
                  ),
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

class _DriverProfileCard extends StatelessWidget {
  const _DriverProfileCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return FutureBuilder<Profile2>(
      future: API.getProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Shimmer.fromColors(
            baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
            highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(10),
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 150,
                          height: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 100,
                          height: 14,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 30,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(10),
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
            child: Center(
              child: Text(
                'Tidak ada koneksi internet',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        } else if (snapshot.hasData) {
          final profile = snapshot.data!;
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(10),
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CircleAvatar(
                  radius: 30,
                  child: ClipOval(
                    child: Image.asset(
                      "assets/icon/driver.png",
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name ?? 'N/A',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.email ?? 'N/A',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.posisi ?? '',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Get.bottomSheet(
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[850] : Colors.white,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
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
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                    ),
                                    onPressed: () {
                                      Get.back();
                                    },
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
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                    },
                    icon: const Icon(
                      Icons.logout_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Logout',
                      style: GoogleFonts.nunito(fontSize: 12, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      minimumSize: const Size(100, 48),
                      tapTargetSize: MaterialTapTargetSize.padded,
                    ),
                  ),
                )
              ],
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}




