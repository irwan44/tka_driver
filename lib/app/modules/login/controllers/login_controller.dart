import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:tka_customer/app/routes/app_pages.dart';

import '../../../data/data_respon/profile2.dart';
import '../../../data/data_respon/token.dart';
import '../../../data/endpoint.dart';
import '../../../data/localstorage.dart';
import '../../booking/controllers/booking_controller.dart';

class LoginController extends GetxController {
  // ───────────────────────── FORM
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // ───────────────────────── STATE
  final isLoading = false.obs;
  final selectedTab = 0.obs; // 0 = Driver, 1 = PIC
  void changeTab(int idx) => selectedTab.value = idx;

  // ───────────────────────── LOGIN DRIVER
  Future<void> doLogin() async => _login(expectedRole: 'DRIVER');

  // ───────────────────────── LOGIN PIC
  Future<void> doLoginPIC() async => _login(expectedRole: 'PIC');

  // ───────────────────────── COMMON LOGIN LOGIC
  Future<void> _login({required String expectedRole}) async {
    if (emailController.text.isEmpty) {
      Get.snackbar("Login Gagal", "Email tidak boleh kosong");
      return;
    }
    if (passwordController.text.isEmpty) {
      Get.snackbar("Login Gagal", "Password tidak boleh kosong");
      return;
    }

    try {
      isLoading.value = true;

      // 1. ambil token
      Token _ = await API.login(
        email: emailController.text,
        password: passwordController.text,
      );

      // 2. cek profil & peran
      Profile2 profile = await API.getProfile();
      final posisi = (profile.posisi ?? '').trim().toUpperCase();

      if (posisi != expectedRole) {
        await LocalStorages.deleteToken();
        OneSignal.logout();
        final msg =
            expectedRole == 'DRIVER'
                ? "Anda login bukan Driver"
                : "Anda login bukan sebagai PIC";
        Get.snackbar("Login Gagal", msg);
        return;
      }

      // 3. sukses
      GetStorage(
        'preferences-mekanik',
      ).write('user_email', emailController.text);
      OneSignal.login(emailController.text);
      OneSignal.User.addEmail(emailController.text);

      Get.delete<BookingController>(force: true);

      if (expectedRole == 'DRIVER') {
        Get.offAllNamed(Routes.HOME);
      } else {
        Get.offAllNamed(Routes.HOME_P_I_C);
      }
    } catch (e) {
      Get.snackbar("Login Gagal", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
