// lib/app/modules/home_p_i_c/controllers/home_p_i_c_controller.dart

import 'dart:async';

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

  Timer? _pollTimer; // <-- Timer untuk polling

  void setShowBars(bool v) {
    if (showBars.value != v) showBars.value = v;
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
    // fetch pertama kali dengan loading
    fetchRequests();

    // setup polling tiap 30 detik, silent (tanpa loading indicator)
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _pollFetchRequests();
    });
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchRequests() async {
    isLoading.value = true;
    error.value = '';
    update();

    try {
      final data = await API.fetchPICRequestService();
      list.assignAll(data);
      filteredList.assignAll(data);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
      update();
    }
  }

  /// Versi polling: fetch data tanpa men-toggle isLoading
  Future<void> _pollFetchRequests() async {
    try {
      final data = await API.fetchPICRequestService();
      list.assignAll(data);
      // tetap pertahankan filter saat ini
      _applyFiltersSilent();
      final now = DateTime.now();
      print('[Realtime] fetchRequests success at $now');
    } catch (_) {
      // ignore errors untuk polling
    }
  }

  /// Terapkan filter tanpa menyalakan loading/refresh
  void _applyFiltersSilent() {
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

  Future<void> pickFilterDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dateFilter ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      dateFilter = picked;
      applyFilters();
    }
  }

  void resetFilter() {
    dateFilter = null;
    searchController.clear();
    update();
  }

  /// Filter manual via UI
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
