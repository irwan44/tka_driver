// lib/app/modules/track_mekanik/controllers/track_mekanik_controller.dart
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tka_customer/app/data/endpoint.dart';

class TrackMekanikController extends GetxController {
  TrackMekanikController(this.kode);

  // ─────–– PUBLIC STATE ––––––
  final String kode;
  final mechanicLocation = const LatLng(0, 0).obs;
  final lastKnownMechanicLocation = Rx<LatLng?>(null);
  final mechanicAddress = ''.obs;
  final isFirstFetchCompleted = false.obs;

  // ─────–– PRIVATE ––––––
  static const _fetchInterval = Duration(seconds: 3);
  static const _routeRefreshGap = Duration(seconds: 10);
  Timer? _timer;
  bool _isFetching = false;
  DateTime? _lastRouteUpdate;

  // ────────────────────────
  @override
  void onInit() {
    super.onInit();
    _fetchMechanicPosition();
    _timer = Timer.periodic(_fetchInterval, (_) => _fetchMechanicPosition());
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  // ───────── FETCH POSISI ─────────
  Future<void> _fetchMechanicPosition() async {
    if (_isFetching) return;
    _isFetching = true;

    try {
      final pos = await API.fetchMekanikPosisi(kode);
      final lat = double.tryParse(pos.latitude ?? '');
      final lon = double.tryParse(pos.longitude ?? '');
      if (lat == null || lon == null) return;

      final newLoc = LatLng(lat, lon);
      mechanicLocation.value = newLoc;

      if (lat != 0 || lon != 0) {
        lastKnownMechanicLocation.value ??= newLoc;
        if (!isFirstFetchCompleted.value) isFirstFetchCompleted.value = true;

        if (_haversineKm(lastKnownMechanicLocation.value!, newLoc) > 0.05) {
          _updateAddress(newLoc);
        }
        lastKnownMechanicLocation.value = newLoc;

        final now = DateTime.now();
        if (_lastRouteUpdate == null ||
            now.difference(_lastRouteUpdate!) > _routeRefreshGap) {
          _lastRouteUpdate = now;
          update(); // beri sinyal ke view
        }
      }
    } catch (e) {
      debugPrint('[$kode] Gagal update posisi: $e');
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
        mechanicAddress.value = '${p.street}, ${p.locality}, ${p.country}';
      }
    } catch (_) {
      mechanicAddress.value = 'Alamat tidak tersedia';
    }
  }

  double _haversineKm(LatLng a, LatLng b) {
    const p = 0.017453292519943295; // π/180
    final c =
        0.5 -
        cos((b.latitude - a.latitude) * p) / 2 +
        cos(a.latitude * p) *
            cos(b.latitude * p) *
            (1 - cos((b.longitude - a.longitude) * p)) /
            2;
    return 12742 * asin(sqrt(c)); // diameter bumi km
  }
}
