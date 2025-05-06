import 'package:get/get.dart';

import '../controllers/home_p_i_c_controller.dart';

class HomePICBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomePICController>(
      () => HomePICController(),
    );
  }
}
