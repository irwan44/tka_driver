import 'dart:async';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tka_customer/app/data/endpoint.dart';
import 'package:tka_customer/app/data/data_respon/meknaikposisi.dart';

class TrackMekanikController extends GetxController {
  final String kode; // Kode emergency, misalnya "EM020001"

  // Posisi mekanik yang disiarkan secara realtime (bisa jadi 0,0)
  var mechanicLocation = const LatLng(0, 0).obs;

  // Lokasi mekanik terakhir yang valid, misalnya null kalau belum pernah dapat data
  var lastKnownMechanicLocation = Rx<LatLng?>(null);

  // Apakah sudah pernah berhasil fetch lat/long mekanik yang valid
  var isFirstFetchCompleted = false.obs;

  Timer? _timer;

  TrackMekanikController(this.kode);

  @override
  void onInit() {
    super.onInit();
    startTracking();
  }

  void startTracking() {
    // Fetch pertama kali
    _fetchMechanicPosition();

    // Timer periodic tiap 5 detik (real-time fetch di background)
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchMechanicPosition();
    });
  }

  Future<void> _fetchMechanicPosition() async {
    try {
      final MekanikPosisi posisi = await API.fetchMekanikPosisi(kode);

      if (posisi.latitude == null || posisi.longitude == null) {
        print("[$kode] Lat/Long dari API null. Tidak memperbarui mechanicLocation.");
        return;
      }

      final double? newLat = double.tryParse(posisi.latitude!);
      final double? newLon = double.tryParse(posisi.longitude!);

      if (newLat == null || newLon == null) {
        print("[$kode] Gagal parsing lat/long. Tidak memperbarui mechanicLocation.");
        return;
      }

      // Update mechanicLocation (meskipun 0,0, tapi kita skip penyimpanan lastKnown jika 0,0)
      mechanicLocation.value = LatLng(newLat, newLon);
      print("[$kode] API.fetchMekanikPosisi => lat=$newLat, lon=$newLon");

      // Jika lat, lon bukan 0,0 => simpan di lastKnownMechanicLocation
      // (Menandakan data valid)
      if (!(newLat == 0 && newLon == 0)) {
        lastKnownMechanicLocation.value = LatLng(newLat, newLon);

        // Tandai bahwa fetch pertama sudah sukses (hanya jika data valid)
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
