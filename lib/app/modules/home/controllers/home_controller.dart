import 'package:get/get.dart';
import 'package:tka_customer/app/data/data_respon/list_emergency.dart';

import '../../../data/endpoint.dart';

class HomeController extends GetxController {
  var tabIndex = 0;
  RxInt diterimaCount = 0.obs;
  void changeTabIndex(int index) {
    tabIndex = index;
    update();
  }
  Future<void> fetchDiterimaCount() async {
    try {
      final listEmergency = await API.fetchListEmergency();
      if (listEmergency.data != null) {
        diterimaCount.value = listEmergency.data!
            .where((e) => e.status?.toLowerCase() == 'diterima')
            .length;
      } else {
        diterimaCount.value = 0;
      }
    } catch (e) {
      diterimaCount.value = 0;
      print("Error fetching emergency count: $e");
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchDiterimaCount();
  }
}
