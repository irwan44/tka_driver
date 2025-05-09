import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';

import '../../../data/data_respon/list_emergency.dart'; // berisi Listemergency & Data
import '../../../data/data_respon/listservice.dart';
import '../../../data/data_respon/profile2.dart';
import '../../../data/data_respon/reques_service.dart';
import '../../../data/endpoint.dart';

class ProfileController extends GetxController {
  /* ---------- DATA ---------- */
  final listRequestService = <RequestService>[].obs;
  final listStatusService = <ListService>[].obs;
  final listEmergency = <Data>[].obs; // << simpan item-nya saja
  final profile = Rxn<Profile2>();
  final isLoading = false.obs;
  final listHistoryService = <ListService>[].obs;
  Timer? _ticker;
  final isLoadingfetchAll = false.obs;
  final isLoadingProfile = false.obs;
  /* ---------- COUNTER ---------- */
  int get requestCount => listRequestService.length;
  int get statusCount => listStatusService.length;

  int get historyCount =>
      listStatusService.where((e) {
        final s = (e.status ?? '').toUpperCase();
        return s == 'PKB TUTUP' || s == 'INVOICE';
      }).length;
  int get emergencyCount => listEmergency.length;

  /* ---------- FETCH ALL ---------- */
  Future<void> fetchAll({bool showLoader = true}) async {
    if (showLoader) isLoadingfetchAll(true);
    try {
      isLoading.value = true;

      final results = await Future.wait([
        API.fetchListRequestService(),
        API.fetchListService(),
        API.fetchListEmergency(),
      ]);

      listRequestService.assignAll(results[0] as List<RequestService>);

      final fullListService = results[1] as List<ListService>;

      // Simpan data non-history
      listStatusService.assignAll(
        fullListService.where((e) {
          final s = (e.status ?? '').toUpperCase();
          return s != 'INVOICE' && s != 'PKB TUTUP' && s != 'NOT CONFIRMED' ;
        }).toList(),
      );

      // Simpan data history (INVOICE dan PKB TUTUP)
      listHistoryService.assignAll(
        fullListService.where((e) {
          final s = (e.status ?? '').toUpperCase();
          return s == 'INVOICE' || s == 'PKB TUTUP';
        }).toList(),
      );

      final Listemergency emgWrapper = results[2] as Listemergency;
      listEmergency.assignAll(emgWrapper.data ?? []);
    } on SocketException {
      Get.snackbar('Oops', 'Tidak ada koneksi internet');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      if (showLoader) isLoadingfetchAll(false);
      isLoading.value = false;
    }
  }
  Future<void> fetchProfile({bool showLoader = true}) async {
    if (showLoader) isLoadingProfile(true);
    try {
      final result = await API.getProfile();
      profile.value = result;
    } catch (e) {
      profile.value = null;
      Get.snackbar('Gagal', 'Gagal memuat profil');
    } finally {
      if (showLoader) isLoadingProfile(false);
      isLoading.value = false;
    }
  }
  @override
  void onInit() {
    super.onInit();
    fetchAll();
    _firstLoad();
    fetchProfile();
  }
  @override
  void onClose() {
    _ticker?.cancel();
    super.onClose();
  }
  Future<void> _firstLoad() async {
    try {
      await Future.wait([
      _startRealtime()
      ] as Iterable<Future>);
    } finally {
      isLoading.value = false;
    }
  }

  void _startRealtime() {
    const interval = Duration(seconds: 5);
    _ticker?.cancel();
    _ticker = Timer.periodic(interval, (_) {
      fetchAll(showLoader: false);
      fetchProfile(showLoader: false);
    });
  }
}
