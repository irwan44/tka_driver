import 'dart:async';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tka_customer/app/data/data_respon/meknaikposisi.dart';
import 'package:tka_customer/app/data/endpoint.dart';

class TrackMekanikController extends GetxController {
  final String kode;
  var mechanicLocation = const LatLng(0, 0).obs;
  var lastKnownMechanicLocation = Rx<LatLng?>(null);
  var isFirstFetchCompleted = false.obs;

  Timer? _timer;

  TrackMekanikController(this.kode);

  @override
  void onInit() {
    super.onInit();
    startTracking();
  }

  void startTracking() {
    _fetchMechanicPosition();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchMechanicPosition();
    });
  }

  Future<void> _fetchMechanicPosition() async {
    try {
      final MekanikPosisi posisi = await API.fetchMekanikPosisi(kode);

      if (posisi.latitude == null || posisi.longitude == null) {
        print(
          "[$kode] Lat/Long dari API null. Tidak memperbarui mechanicLocation.",
        );
        return;
      }
      final double? newLat = double.tryParse(posisi.latitude!);
      final double? newLon = double.tryParse(posisi.longitude!);

      if (newLat == null || newLon == null) {
        print(
          "[$kode] Gagal parsing lat/long. Tidak memperbarui mechanicLocation.",
        );
        return;
      }
      mechanicLocation.value = LatLng(newLat, newLon);
      print("[$kode] API.fetchMekanikPosisi => lat=$newLat, lon=$newLon");
      if (!(newLat == 0 && newLon == 0)) {
        lastKnownMechanicLocation.value = LatLng(newLat, newLon);
        if (!isFirstFetchCompleted.value) {
          isFirstFetchCompleted.value = true;
        }
      }
    } catch (e) {
      print("[$kode] Gagal update posisi mekanik: $e");
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
