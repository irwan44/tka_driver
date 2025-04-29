import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tka_customer/app/data/endpoint.dart';

class TrackMekanikController extends GetxController {
  final String kode;
  var mechanicLocation = const LatLng(0, 0).obs;
  var lastKnownMechanicLocation = Rx<LatLng?>(null);
  var mechanicAddress = ''.obs; // Rx untuk alamat
  var isFirstFetchCompleted = false.obs;

  Timer? _timer;
  bool _isFetching = false;
  DateTime? _lastRouteUpdate;

  TrackMekanikController(this.kode);

  @override
  void onInit() {
    super.onInit();
    startTracking();
  }

  void startTracking() {
    _fetchMechanicPosition();
    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _fetchMechanicPosition(),
    );
  }

  Future<void> _fetchMechanicPosition() async {
    if (_isFetching) return; // proteksi overlapping
    _isFetching = true;

    try {
      final pos = await API.fetchMekanikPosisi(kode);
      final lat = double.tryParse(pos.latitude ?? '');
      final lon = double.tryParse(pos.longitude ?? '');
      if (lat == null || lon == null) return;

      final newLoc = LatLng(lat, lon);
      mechanicLocation.value = newLoc;
      if (lat != 0 || lon != 0) {
        lastKnownMechanicLocation.value = newLoc;
        if (!isFirstFetchCompleted.value) isFirstFetchCompleted.value = true;

        // update alamat hanya jika berubah >50m
        final last = lastKnownMechanicLocation.value;
        if (last == null ||
            _distance(lat, lon, last.latitude, last.longitude) > 0.05) {
          _updateAddress(newLoc);
        }

        // throttle rute: minimal tiap 10 detik
        final now = DateTime.now();
        if (_lastRouteUpdate == null ||
            now.difference(_lastRouteUpdate!) > const Duration(seconds: 10)) {
          _lastRouteUpdate = now;
          update(); // trigger rebuild untuk route via worker di view
        }
      }
    } catch (e) {
      debugPrint("[$kode] Gagal update posisi: $e");
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _updateAddress(LatLng loc) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        loc.latitude,
        loc.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        mechanicAddress.value = "${p.street}, ${p.locality}, ${p.country}";
      }
    } catch (_) {
      mechanicAddress.value = "Alamat tidak tersedia";
    }
  }

  double _distance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a =
        0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // km
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
