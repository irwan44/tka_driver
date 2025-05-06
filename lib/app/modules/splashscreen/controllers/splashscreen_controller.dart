import 'package:get/get.dart';
import 'package:tka_customer/app/data/endpoint.dart'; // ← pastikan ini tempat API.getProfile()
import 'package:tka_customer/app/data/localstorage.dart';
import 'package:tka_customer/app/routes/app_pages.dart';

import '../../../data/data_respon/profile2.dart';

class SplashscreenController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _decideWhereToGo();
  }

  Future<void> _decideWhereToGo() async {
    // Animasi splash ±3 detik
    await Future.delayed(const Duration(seconds: 3));

    // 1. Jika belum punya token ➜ WelcomeView
    final hasToken = await LocalStorages.hasToken();
    if (!hasToken) {
      Get.toNamed(Routes.LOGIN);
      return;
    }

    // 2. Sudah login ➜ ambil profil & tentukan rute
    try {
      final Profile2 profile = await API.getProfile();

      final String posisi = (profile.posisi ?? '').trim().toUpperCase();

      if (posisi == 'DRIVER') {
        // Driver ➜ HOME
        Get.offAllNamed(Routes.HOME);
      } else if (posisi == 'PIC') {
        // PIC ➜ HOME_P_I_C
        Get.offAllNamed(Routes.HOME_P_I_C);
      } else {
        // Posisi lain / tidak diketahui ➜ fallback ke HOME
        Get.offAllNamed(Routes.HOME);
      }
    } catch (e) {
      // Gagal ambil profil ➜ fallback ke HOME
      Get.offAllNamed(Routes.HOME);
    }
  }
}
