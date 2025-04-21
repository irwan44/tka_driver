// emergency_controller.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:tka_customer/app/routes/app_pages.dart';
import 'package:tka_customer/app/data/data_respon/list_emergency.dart';
import 'package:tka_customer/app/data/localstorage.dart';
import 'package:tka_customer/app/data/endpoint.dart';
import '../../../data/data_respon/meknaikposisi.dart';

// Tambahan kompres
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:video_compress/video_compress.dart';

class EmergencyController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  var allEmergencyList = <Data>[].obs;
  var emergencyList = <Data>[].obs;
  var searchQuery = ''.obs;
  DateTime? dateFilter;

  final searchController = TextEditingController();

  // Keluhan
  final complaintController = TextEditingController();
  RxString complaintText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEmergencyList();
    fetchVehicles();
  }

  @override
  void onClose() {
    // Tidak ada lagi timer lacak di sini
    super.onClose();
  }

  void performAction(Data data) {
    data.status = 'Diterima';
    print("Status diubah menjadi: ${data.status}");
    update();
  }

  Future<void> fetchEmergencyList() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      if (LocalStorages.getToken.isEmpty) {
        throw Exception('Token is empty! Mohon login terlebih dahulu.');
      }
      final response = await API.fetchListEmergency();
      allEmergencyList.value = response.data ?? [];
      emergencyList.value = allEmergencyList;
    } catch (e) {
      if (e.toString().toLowerCase().contains("tidak ada jaringan") ||
          e.toString().toLowerCase().contains("no internet")) {
        errorMessage.value = '';
      } else {
        errorMessage.value = e.toString();
      }
      allEmergencyList.clear();
      emergencyList.clear();
    } finally {
      isLoading.value = false;
    }
  }

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
        errorMessage.value = '';
      } else {
        errorMessage.value = e.toString();
      }
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    List<Data> filtered = allEmergencyList.toList();
    if (searchQuery.value.trim().isNotEmpty) {
      final queryLower = searchQuery.value.trim().toLowerCase();
      filtered = filtered.where((item) {
        final kodeLower = (item.kode ?? '').toLowerCase();
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
        return (tglParsed.year == dateFilter!.year &&
            tglParsed.month == dateFilter!.month &&
            tglParsed.day == dateFilter!.day);
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

  var currentLocation = ''.obs;
  var fullAddress = ''.obs;
  var mediaList = <XFile>[].obs;
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
      if (file != null) {
        int currentPhotoCount = mediaList.where((x) => !_isVideo(x)).length;
        int currentVideoCount = mediaList.where((x) => _isVideo(x)).length;

        // Logika batas foto/video
        if (currentVideoCount > 0 && currentPhotoCount >= 1) {
          Get.snackbar(
            'Warning',
            'Jika sudah ada video, hanya boleh mengupload 1 foto.',
            backgroundColor: Colors.yellow,
            colorText: Colors.black,
          );
          return;
        }
        if (currentVideoCount == 0 && currentPhotoCount >= 2) {
          Get.snackbar(
            'Warning',
            'Maksimal 2 foto yang dapat diupload.',
            backgroundColor: Colors.yellow,
            colorText: Colors.black,
          );
          return;
        }
        mediaList.add(file);
      }
    } catch (e) {
      Get.snackbar(
        'Warning',
        'Gagal mengambil foto: $e',
        backgroundColor: Colors.yellow,
        colorText: Colors.black,
      );
    }
  }

  Future<void> pickVideo() async {
    try {
      final XFile? file = await _picker.pickVideo(source: ImageSource.camera);
      if (file != null) {
        int currentVideoCount = mediaList.where((x) => _isVideo(x)).length;
        if (currentVideoCount >= 1) {
          Get.snackbar(
            'Warning',
            'Hanya dapat mengupload 1 video.',
            backgroundColor: Colors.yellow,
            colorText: Colors.black,
          );
          return;
        }
        int currentPhotoCount = mediaList.where((x) => !_isVideo(x)).length;
        if (currentPhotoCount >= 2) {
          Get.snackbar(
            'Warning',
            'Jika ingin mengupload video, maksimal foto yang diperbolehkan adalah 1.',
            backgroundColor: Colors.yellow,
            colorText: Colors.black,
          );
          return;
        }
        mediaList.add(file);
      }
    } catch (e) {
      Get.snackbar(
        'Warning',
        'Gagal merekam video: $e',
        backgroundColor: Colors.yellow,
        colorText: Colors.black,
      );
    }
  }

  void removeMedia(XFile file) {
    mediaList.remove(file);
  }

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
        desiredAccuracy: LocationAccuracy.high,
      );
      currentLocation.value = '${position.latitude}, ${position.longitude}';
      Get.snackbar(
        'Sukses',
        'Berhasil mendapatkan lokasi Anda',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Warning',
        'Gagal mendapatkan lokasi: $e',
        backgroundColor: Colors.yellow,
        colorText: Colors.black,
      );
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
          List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
          if (placemarks.isNotEmpty) {
            final place = placemarks.first;
            fullAddress.value =
            '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
          }
        }
      }
    } catch (e) {
      Get.snackbar(
        'Warning',
        'Gagal mendapatkan alamat: $e',
        backgroundColor: Colors.yellow,
        colorText: Colors.black,
      );
    }
  }

  var availableVehicles = <String>[];
  var selectedVehicle = ''.obs;

  Future<void> submitEmergencyRepair() async {
    // Validasi tambahan
    if (selectedVehicle.value.isEmpty) {
      Get.snackbar(
        'Warning',
        'Kendaraan harus dipilih.',
        backgroundColor: Colors.yellow,
        colorText: Colors.black,
      );
      return;
    }
    if (complaintController.text.trim().isEmpty) {
      Get.snackbar(
        'Warning',
        'Keluhan harus diisi.',
        backgroundColor: Colors.yellow,
        colorText: Colors.black,
      );
      return;
    }
    if (currentLocation.value.isEmpty) {
      Get.snackbar(
        'Warning',
        'Lokasi belum ditentukan.',
        backgroundColor: Colors.yellow,
        colorText: Colors.black,
      );
      return;
    }

    final now = DateTime.now();
    final strTgl = DateFormat('yyyy-MM-dd').format(now);
    final strJam = DateFormat('HH:mm').format(now);
    final locSplit = currentLocation.value.split(',');
    final lat = locSplit.isNotEmpty ? locSplit[0].trim() : '';
    final long = locSplit.length > 1 ? locSplit[1].trim() : '';

    // Kompres media
    List<File> mediaFiles = [];
    try {
      mediaFiles = await _validateAndCompressMediaFiles();
    } catch (e) {
      Get.snackbar(
        'Warning',
        e.toString(),
        backgroundColor: Colors.yellow,
        colorText: Colors.black,
      );
      return;
    }

    try {
      isLoading.value = true;
      await API.createEmergency(
        noPolisi: selectedVehicle.value,
        tgl: strTgl,
        jam: strJam,
        keluhan: complaintController.text.trim(),
        latitude: lat,
        longitude: long,
        mediaFiles: mediaFiles,
      );
      Get.snackbar(
        'Sukses',
        'Emergency berhasil dibuat!',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
      Get.delete<EmergencyController>(force: true);
      Get.toNamed(Routes.HOME);
      // Reset form
      mediaList.clear();
      complaintController.clear();
      complaintText.value = '';
      currentLocation.value = '';
      fullAddress.value = '';
      selectedVehicle.value = '';
      fetchEmergencyList();
    } catch (e) {
      final errorString = e.toString().toLowerCase();
      if (e is SocketException ||
          errorString.contains("tidak ada jaringan") ||
          errorString.contains("no internet") ||
          errorString.contains("failed host lookup") ||
          errorString.contains("no address associated with hostname")) {
        print("Error jaringan: ${e.toString()}");
      } else {
        Get.snackbar(
          'Warning',
          e.toString(),
          backgroundColor: Colors.yellow,
          colorText: Colors.black,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
  bool get hasEmergencyForSelectedVehicle {
    if (selectedVehicle.value.isEmpty) return true; // tombol disable kalau belum pilih
    return allEmergencyList.any((data) =>
    data.noPolisi == selectedVehicle.value
    );
  }
  bool get disableBuatEmergencyServiceButton => hasEmergencyForSelectedVehicle;
  // Kompres & Validasi media
  Future<List<File>> _validateAndCompressMediaFiles() async {
    int photoCount = mediaList.where((x) => !_isVideo(x)).length;
    int videoCount = mediaList.where((x) => _isVideo(x)).length;

    if (photoCount < 1) {
      throw 'Minimal harus ada 1 foto.';
    }
    if (videoCount > 1) {
      throw 'Hanya boleh mengupload 1 video.';
    }
    if (videoCount == 1 && mediaList.length != 2) {
      throw 'Jika mengupload video, harus ada 1 foto dan 1 video saja.';
    }
    if (videoCount == 0 && mediaList.length > 2) {
      throw 'Maksimal 2 foto yang dapat diupload.';
    }

    List<File> compressedFiles = [];
    for (var file in mediaList) {
      if (_isVideo(file)) {
        final mediaInfo = await VideoCompress.getMediaInfo(file.path);

        if (mediaInfo.duration != null && mediaInfo.duration! < 60000) {
          compressedFiles.add(File(file.path));
          continue; // lanjut ke file berikut
        }

        final compressedVideo = await VideoCompress.compressVideo(
          file.path,
          quality: VideoQuality.MediumQuality,
          deleteOrigin: false,
          includeAudio: true,
        );
        if (compressedVideo != null && compressedVideo.file != null) {
          compressedFiles.add(compressedVideo.file!);
        } else {
          compressedFiles.add(File(file.path));
        }
      } else {
        final result = await FlutterImageCompress.compressWithFile(
          file.path,
          quality: 80,
        );
        if (result != null) {
          final fileName = file.path.split(Platform.pathSeparator).last;
          final targetPath =
              '${Directory.systemTemp.path}/${DateTime.now().millisecondsSinceEpoch}_$fileName';
          final compressedImage =
          await File(targetPath).writeAsBytes(result);
          compressedFiles.add(compressedImage);
        } else {
          compressedFiles.add(File(file.path));
        }
      }
    }
    return compressedFiles;
  }
}
