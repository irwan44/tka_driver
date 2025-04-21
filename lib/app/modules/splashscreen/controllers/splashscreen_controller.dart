import 'package:get/get.dart';
import 'package:tka_customer/app/data/localstorage.dart';
import 'package:tka_customer/app/routes/app_pages.dart';

class SplashscreenController extends GetxController {
  final isLoggedIn = false.obs;

  @override
  void onReady() {
    super.onReady();
    _checkTokenAndNavigate();
  }

  Future<void> _checkTokenAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3));

    bool hasToken = await LocalStorages.hasToken();
    if (hasToken) {
      Get.offNamed(Routes.HOME);
    } else {
      Get.offNamed(Routes.LOGIN);
    }
  }
}
