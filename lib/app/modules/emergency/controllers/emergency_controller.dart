// lib/app/modules/emergency/controllers/emergency_controller.dart
import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import 'package:tka_customer/app/routes/app_pages.dart';
import 'package:tka_customer/app/data/data_respon/list_emergency.dart';
import 'package:tka_customer/app/data/localstorage.dart';
import 'package:tka_customer/app/data/endpoint.dart';
import '../../../data/data_respon/meknaikposisi.dart';

// Tambahan kompres
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:video_compress/video_compress.dart';

class EmergencyController extends GetxController {
  var isLoading     = false.obs;
  var errorMessage  = ''.obs;

  var allEmergencyList = <Data>[].obs;
  var emergencyList    = <Data>[].obs;
  var searchQuery      = ''.obs;
  DateTime? dateFilter;
  var isCompressingVideo = false.obs;
  final searchController = TextEditingController();
  final complaintController = TextEditingController();
  RxString complaintText = ''.obs;
  Timer? _debounceTimer;
  final Rx<ConnectivityResult> connectivityStatus =
      ConnectivityResult.mobile.obs;
  late final StreamSubscription _connectSub;
  @override
  void onInit() {
    super.onInit();
    _connectSub = Connectivity()
        .onConnectivityChanged
        .listen((dynamic event) {
      ConnectivityResult status;
      if (event is ConnectivityResult) {
        status = event;
      } else if (event is List<ConnectivityResult>) {
        status = event.isNotEmpty ? event.first : ConnectivityResult.none;
      } else {
        status = ConnectivityResult.none;
      }

      connectivityStatus.value = status;
      _setStatusDebounced(status);
    });

    fetchEmergencyList();
    fetchVehicles();
  }

  final Rx<ConnectivityResult> debouncedStatus =
      ConnectivityResult.mobile.obs;
  void _setStatusDebounced(ConnectivityResult newStatus) {
    if (newStatus == ConnectivityResult.none) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 800), () {
        debouncedStatus.value = newStatus;
      });
    } else {
      _debounceTimer?.cancel();
      debouncedStatus.value = newStatus;
    }
  }
  @override
  void onClose() {
    _debounceTimer?.cancel();
    _connectSub.cancel();
    super.onClose();
  }

  Future<bool> _hasRealInternet() async {
    try {
      final result = await InternetAddress.lookup('example.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }

  void performAction(Data data) {
    data.status = 'Diterima';
    print("Status diubah menjadi: ${data.status}");
    update();
  }

  Future<void> fetchEmergencyList() async {
    if (!await _hasRealInternet()) {
      errorMessage.value =
      'Tidak ada jaringan\nMohon periksa kembali jaringan internet anda';
      allEmergencyList.clear();
      emergencyList.clear();
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    try {
      if (LocalStorages.getToken.isEmpty) {
        throw Exception('Token is empty! Mohon login terlebih dahulu.');
      }
      final response = await API.fetchListEmergency();
      allEmergencyList.value = response.data ?? [];
      emergencyList.value    = allEmergencyList;
    } catch (e) {
      if (e.toString().toLowerCase().contains("tidak ada jaringan") ||
          e.toString().toLowerCase().contains("no internet")) {
        errorMessage.value =
        'Tidak ada jaringan\nMohon periksa kembali jaringan internet anda';
      } else {
        errorMessage.value = e.toString();
      }
      allEmergencyList.clear();
      emergencyList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────── FETCH VEHICLES ──────────────────────────
  Future<void> fetchVehicles() async {
    try {
      isLoading.value = true;
      final resp = await API.fetchListKendaraan();
      final listKendaraan = resp.data ?? [];
      availableVehicles.clear();
      for (var item in listKendaraan) {
        if (item.noPolisi != null) {
          availableVehicles.add(item.noPolisi!);
        }
      }
    } catch (e) {
      if (e is SocketException ||
          e.toString().toLowerCase().contains("tidak ada jaringan") ||
          e.toString().toLowerCase().contains("no internet") ||
          e.toString().toLowerCase().contains("failed host lookup")) {
        errorMessage.value =
        'Tidak ada jaringan\nMohon periksa kembali jaringan internet anda';
      } else {
        errorMessage.value = e.toString();
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────── FILTER & SEARCH ────────────────────────
  void applyFilters() {
    List<Data> filtered = allEmergencyList.toList();
    if (searchQuery.value.trim().isNotEmpty) {
      final queryLower = searchQuery.value.trim().toLowerCase();
      filtered = filtered.where((item) {
        final kodeLower     = (item.kode ?? '').toLowerCase();
        final noPolisiLower = (item.noPolisi ?? '').toLowerCase();
        return kodeLower.contains(queryLower) || noPolisiLower.contains(queryLower);
      }).toList();
    }
    if (dateFilter != null) {
      filtered = filtered.where((item) {
        final tglStr = item.tgl ?? '';
        DateTime? tglParsed;
        try {
          tglParsed = DateFormat('yyyy-MM-dd').parse(tglStr);
        } catch (_) {
          return false;
        }
        return (tglParsed.year  == dateFilter!.year &&
            tglParsed.month == dateFilter!.month &&
            tglParsed.day   == dateFilter!.day);
      }).toList();
    }
    emergencyList.value = filtered;
  }

  Future<void> pickFilterDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dateFilter ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      dateFilter = DateTime(picked.year, picked.month, picked.day);
    }
  }

  void resetFilter() {
    searchQuery.value = '';
    dateFilter = null;
    searchController.clear();
    applyFilters();
  }

  // ─────────────────── MEDIA & LOKASI ────────────────────────
  var currentLocation = ''.obs;
  var fullAddress     = ''.obs;
  var mediaList       = <XFile>[].obs;
  final ImagePicker _picker = ImagePicker();

  bool _isVideo(XFile file) {
    final lowerPath = file.path.toLowerCase();
    return lowerPath.endsWith('.mp4') ||
        lowerPath.endsWith('.mov') ||
        lowerPath.endsWith('.avi');
  }

  Future<void> pickImage() async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.camera);
      if (file == null) return;

      final photoCount = mediaList.where((x) => !_isVideo(x)).length;
      if (photoCount >= 4) {
        Get.snackbar('Warning', 'Maksimal 4 foto yang dapat diupload.',
            backgroundColor: Colors.yellow, colorText: Colors.black);
        return;
      }
      mediaList.add(file);
    } catch (e) {
      Get.snackbar('Warning', 'Gagal mengambil foto: $e',
          backgroundColor: Colors.yellow, colorText: Colors.black);
    }
  }

  Future<void> pickVideo() async {
    try {
      final XFile? file = await _picker.pickVideo(source: ImageSource.camera);
      if (file == null) return;

      final videoCount = mediaList.where((x) => _isVideo(x)).length;
      if (videoCount >= 1) {
        Get.snackbar('Warning', 'Hanya boleh mengupload 1 video.',
            backgroundColor: Colors.yellow, colorText: Colors.black);
        return;
      }
      mediaList.add(file);
    } catch (e) {
      Get.snackbar('Warning', 'Gagal merekam video: $e',
          backgroundColor: Colors.yellow, colorText: Colors.black);
    }
  }

  void removeMedia(XFile file) => mediaList.remove(file);

  // ──────────────── LOKASI & PERMISSION ────────────────
  Future<void> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Lokasi tidak diizinkan oleh user.';
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw 'Lokasi ditolak permanen. Ubah di pengaturan.';
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      await checkLocationPermission();
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      currentLocation.value = '${position.latitude}, ${position.longitude}';
      Get.snackbar('Sukses', 'Berhasil mendapatkan lokasi Anda',
          backgroundColor: Colors.blue, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Warning', 'Gagal mendapatkan lokasi: $e',
          backgroundColor: Colors.yellow, colorText: Colors.black);
    }
  }

  Future<void> initLocation() async {
    try {
      await getCurrentLocation();
      if (currentLocation.value.isNotEmpty) {
        final parts = currentLocation.value.split(',');
        final lat = double.tryParse(parts[0].trim());
        final lng = double.tryParse(parts[1].trim());
        if (lat != null && lng != null) {
          final placemarks = await placemarkFromCoordinates(lat, lng);
          if (placemarks.isNotEmpty) {
            final p = placemarks.first;
            fullAddress.value =
            '${p.street}, ${p.subLocality}, ${p.locality}, ${p.postalCode}, ${p.country}';
          }
        }
      }
    } catch (e) {
      Get.snackbar('Warning', 'Gagal mendapatkan alamat: $e',
          backgroundColor: Colors.yellow, colorText: Colors.black);
    }
  }

  // ─────────────────── EMERGENCY SUBMIT ─────────────────────
  var availableVehicles = <String>[];
  var selectedVehicle   = ''.obs;

  Future<void> submitEmergencyRepair(BuildContext ctx) async {
    if (selectedVehicle.value.isEmpty) {
      Get.snackbar('Warning', 'Kendaraan harus dipilih.',
          backgroundColor: Colors.yellow, colorText: Colors.black);
      return;
    }
    if (complaintController.text.trim().isEmpty) {
      Get.snackbar('Warning', 'Keluhan harus diisi.',
          backgroundColor: Colors.yellow, colorText: Colors.black);
      return;
    }
    if (currentLocation.value.isEmpty) {
      Get.snackbar('Warning', 'Lokasi belum ditentukan.',
          backgroundColor: Colors.yellow, colorText: Colors.black);
      return;
    }

    final now    = DateTime.now();
    final strTgl = DateFormat('yyyy-MM-dd').format(now);
    final strJam = DateFormat('HH:mm').format(now);
    final loc    = currentLocation.value.split(',');
    final lat    = loc.isNotEmpty ? loc[0].trim() : '';
    final long   = loc.length > 1 ? loc[1].trim() : '';

    List<File> mediaFiles = [];
    try {
      mediaFiles = await _validateAndCompressMediaFiles();
    } catch (e) {
      Get.snackbar('Warning', e.toString(),
          backgroundColor: Colors.yellow, colorText: Colors.black);
      return;
    }

    try {
      isLoading.value = true;
      await API.createEmergency(
        noPolisi : selectedVehicle.value,
        tgl      : strTgl,
        jam      : strJam,
        keluhan  : complaintController.text.trim(),
        latitude : lat,
        longitude: long,
        mediaFiles: mediaFiles,
      );

      Get.delete<EmergencyController>(force: true);
      Get.toNamed(Routes.HOME, arguments: {'initialTab': 1});
      await QuickAlert.show(
        context: ctx,
        type: QuickAlertType.success,
        text: 'Emergency berhasil dibuat!',
      );
      mediaList.clear();
      complaintController.clear();
      complaintText.value  = '';
      currentLocation.value = '';
      fullAddress.value     = '';
      selectedVehicle.value = '';
      fetchEmergencyList();
    } catch (e) {
      final err = e.toString().toLowerCase();
      if (e is SocketException ||
          err.contains("tidak ada jaringan") ||
          err.contains("no internet")    ||
          err.contains("failed host lookup") ||
          err.contains("no address associated with hostname")) {
        print("Error jaringan: $e");
      } else {
        print("Warning: $e");
        Get.snackbar('Warning', e.toString(),
            backgroundColor: Colors.yellow, colorText: Colors.black);
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────── VALIDATION ───────────────────────────
  bool get hasActiveEmergencyForSelectedVehicle {
    if (selectedVehicle.value.isEmpty) return false;
    return allEmergencyList.any((data) {
      if (data.noPolisi != selectedVehicle.value) return false;
      final status = data.status?.toLowerCase() ?? '';
      return !(status == 'derek' || status == 'storing' || status == 'selesai');
    });
  }

  bool get disableBuatEmergencyServiceButton {
    if (selectedVehicle.value.isEmpty) return true;
    if (hasActiveEmergencyForSelectedVehicle) return true;
    return false;
  }

  Future<List<File>> _validateAndCompressMediaFiles() async {
    final photoCount = mediaList.where((x) => !_isVideo(x)).length;
    final videoCount = mediaList.where((x) => _isVideo(x)).length;

    if (photoCount < 1)  throw 'Minimal harus ada 1 foto.';
    if (photoCount > 4)  throw 'Maksimal foto yang dapat diupload adalah 4.';
    if (videoCount > 1)  throw 'Hanya boleh mengupload 1 video.';

    List<File> compressedFiles = [];

    for (var f in mediaList) {
      if (_isVideo(f)) {
        // Kompres video (jika durasi ≥ 2 menit)
        final info = await VideoCompress.getMediaInfo(f.path);
        if (info.duration != null && info.duration! >= 120000) {
          final comp = await VideoCompress.compressVideo(
            f.path,
            quality: VideoQuality.DefaultQuality,
            deleteOrigin: false,
            includeAudio: true,
          );
          if (comp?.file != null) {
            compressedFiles.add(comp!.file!);
            continue;
          }
        }
        compressedFiles.add(File(f.path)); // fallback
      } else {
        final result = await FlutterImageCompress.compressWithFile(
          f.path,
          quality: 80,
        );
        if (result != null) {
          final name = f.path.split(Platform.pathSeparator).last;
          final target =
              '${Directory.systemTemp.path}/${DateTime.now().millisecondsSinceEpoch}_$name';
          final imgFile = await File(target).writeAsBytes(result);
          compressedFiles.add(imgFile);
        } else {
          compressedFiles.add(File(f.path)); // fallback
        }
      }
    }
    return compressedFiles;
  }
}
