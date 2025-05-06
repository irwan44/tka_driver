// lib/app/modules/home_p_i_c/controllers/home_p_i_c_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../main.dart';
import '../../../data/data_respon/listrequestPIC.dart';
import '../../../data/endpoint.dart';

class HomePICController extends GetxController {
  RxInt diterimaCount = 0.obs;
  final RxBool showBars = true.obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final list = <ListRequesServicePIC>[].obs;
  final filteredList = <ListRequesServicePIC>[].obs;

  DateTime? dateFilter;
  final searchController = TextEditingController();

  void setShowBars(bool v) {
    if (showBars.value != v) showBars.value = v;
    // tidak perlu update() di sini untuk AppBar, karena AppBar masih pakai Obx
  }

  Future<void> initOneSignal() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      final result = await Permission.notification.request();
      if (!result.isGranted) return;
    }
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.consentRequired(false);
    OneSignal.initialize(OneSignalConfig.appId);
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      event.preventDefault();
      event.notification.display();
    });
    final box = GetStorage('preferences-mekanik');
    final email = box.read('user_email') ?? "";
    if (email.isNotEmpty) OneSignal.User.addEmail(email);
  }

  @override
  void onInit() {
    super.onInit();
    initOneSignal();

    fetchRequests();
  }

  Future<void> fetchRequests() async {
    isLoading.value = true;
    error.value = '';
    update();

    try {
      final data = await API.fetchPICRequestService();
      list.assignAll(data);
      // awalnya tampilkan semua
      filteredList.assignAll(data);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> pickFilterDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dateFilter ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      dateFilter = picked;
      update();
    }
  }

  void resetFilter() {
    dateFilter = null;
    searchController.clear();
    update();
  }

  void applyFilters() {
    final text = searchController.text.toLowerCase();
    final filtered =
        list.where((r) {
          final matchSearch =
              text.isEmpty ||
              (r.kodeSvc?.toLowerCase().contains(text) ?? false) ||
              (r.noPolisi?.toLowerCase().contains(text) ?? false);
          final matchDate =
              dateFilter == null ||
              (r.createdAt != null &&
                  DateTime.parse(r.createdAt!).difference(dateFilter!).inDays ==
                      0);
          return matchSearch && matchDate;
        }).toList();
    filteredList.assignAll(filtered);
    update();
  }
}
