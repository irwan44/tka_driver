import 'dart:io';

import 'package:get/get.dart';

import '../../../data/data_respon/list_emergency.dart'; // berisi Listemergency & Data
import '../../../data/data_respon/listservice.dart';
import '../../../data/data_respon/reques_service.dart';
import '../../../data/endpoint.dart';

class ProfileController extends GetxController {
  /* ---------- DATA ---------- */
  final listRequestService = <RequestService>[].obs;
  final listStatusService = <ListService>[].obs;
  final listEmergency = <Data>[].obs; // << simpan item-nya saja

  final isLoading = false.obs;

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
  Future<void> fetchAll() async {
    try {
      isLoading.value = true;

      final results = await Future.wait([
        API.fetchListRequestService(), // Future<List<RequestService>>
        API.fetchListService(), // Future<List<ListService>>
        API.fetchListEmergency(), // Future<Listemergency>
      ]);

      listRequestService.assignAll(results[0] as List<RequestService>);
      listStatusService.assignAll(results[1] as List<ListService>);

      // ── emergency ──
      final Listemergency emgWrapper = results[2] as Listemergency;
      listEmergency.assignAll(emgWrapper.data ?? []);
    } on SocketException {
      Get.snackbar('Oops', 'Tidak ada koneksi internet');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }
}
