import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tka_customer/app/routes/app_pages.dart';
import '../../../data/data_respon/token.dart';
import '../../../data/endpoint.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../booking/controllers/booking_controller.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isLoading = false.obs;

  Future<void> doLogin() async {
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

      Token tokenResponse = await API.login(
        email: emailController.text,
        password: passwordController.text,
      );

      isLoading.value = false;
      GetStorage boxPreferences = GetStorage('preferences-mekanik');
      await boxPreferences.write('user_email', emailController.text);
      OneSignal.User.addEmail(emailController.text);
      print("OneSignal email updated to: ${emailController.text}");
      Get.delete<BookingController>(force: true);
      Get.offAllNamed(Routes.HOME);

    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Login Gagal", e.toString());
    }
  }
}
