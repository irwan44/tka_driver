import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../main.dart';
import '../../../data/endpoint.dart';
import '../../../routes/app_pages.dart';

class HomeController extends GetxController {
  var tabIndex = 0;
  RxInt diterimaCount = 0.obs;
  bool showBars = true;

  void changeTabIndex(int index) {
    tabIndex = index;
    update();
  }

  void setShowBars(bool v) {
    if (showBars != v) {
      showBars = v;
      update();
    }
  }

  Future<void> fetchDiterimaCount() async {
    try {
      final listEmergency = await API.fetchListEmergency();
      if (listEmergency.data != null) {
        diterimaCount.value =
            listEmergency.data!
                .where(
                  (e) => e.status?.toLowerCase() == 'mekanik dalam perjalanan',
                )
                .length;
      } else {
        diterimaCount.value = 0;
      }
    } catch (e) {
      diterimaCount.value = 0;
      print("Error fetching emergency count: $e");
    }
  }

  Future<void> initOneSignal() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      final result = await Permission.notification.request();
      if (!result.isGranted) {
        debugPrint('Notification permission denied');
        return;
      }
    }
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.Debug.setAlertLevel(OSLogLevel.none);
    OneSignal.consentRequired(false);
    OneSignal.initialize(OneSignalConfig.appId);
    OneSignal.LiveActivities.setupDefault();
    OneSignal.Notifications.clearAll();
    OneSignal.Notifications.addClickListener((event) {
      print('Notification clicked: ${event.notification.jsonRepresentation()}');
    });

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      if (Get.currentRoute == Routes.LOGIN) {
        event.preventDefault();
        return;
      }
      event.preventDefault();
      event.notification.display();
    });

    final boxPrefs = GetStorage('preferences-mekanik');
    final storedEmail = boxPrefs.read('user_email') ?? "";
    if (storedEmail.isNotEmpty) {
      OneSignal.User.addEmail(storedEmail);
      print(storedEmail);
    }
  }

  @override
  void onInit() {
    super.onInit();
    initOneSignal();
    final args = Get.arguments;
    if (args is Map<String, dynamic> && args['initialTab'] != null) {
      tabIndex = args['initialTab'] as int;
      update();
    }
    fetchDiterimaCount();
  }
}
