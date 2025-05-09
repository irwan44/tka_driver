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
  final listHistoryService = <ListService>[].obs;

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
          return s != 'INVOICE' && s != 'PKB TUTUP';
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
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }
}
