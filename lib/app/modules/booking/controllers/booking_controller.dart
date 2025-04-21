import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:video_compress/video_compress.dart';
import '../../../data/data_respon/detailservice.dart';
import '../../../data/data_respon/listservice.dart';
import '../../../data/data_respon/reques_service.dart';
import '../../../data/endpoint.dart';
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

import '../../home/controllers/home_controller.dart';

class BookingController extends GetxController {
  var currentStep = 0.obs;
  var isLoading = true.obs;
  var listService = <ListService>[].obs;
  var detailService = Rxn<DetailService>();
  var errorMessage = ''.obs;
  var isLoadingRequest     = true.obs;
  var listRequestService   = <RequestService>[].obs;
  var errorRequest         = ''.obs;
  var confirmedPlanningSvcs = <String>{}.obs;
  final RxBool isConfirming = false.obs;
  bool isPlanningConfirmed(String? kodeSvc) =>
      kodeSvc != null && confirmedPlanningSvcs.contains(kodeSvc);

  Future<void> confirmPlanningService(String kodeSvc) async {
    if (isPlanningConfirmed(kodeSvc)) return;
    isConfirming.value = true;
    try {
      await API.confirmPlanning(kodeSvc);
      confirmedPlanningSvcs.add(kodeSvc);
      Get.delete<BookingController>(force: true);
      Get.toNamed(Routes.HOME);
      Get.snackbar('Sukses', 'Planning service berhasil dikonfirmasi',backgroundColor: Colors.blue,
        colorText: Colors.white,);
    } on SilentException catch (_) {
      Get.snackbar('Error', 'Tidak ada koneksi internet');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isConfirming.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchServices();
    fetchRequestService();
    fetchVehicles();
  }
  Future<void> refreshAll() async {
    await Future.wait([
      fetchRequestService(),
      fetchServices(),
    ]);
  }
  var allEmergencyList = <Data>[].obs;
  var emergencyList = <Data>[].obs;
  var searchQuery = ''.obs;
  DateTime? dateFilter;

  final searchController = TextEditingController();
  final complaintController = TextEditingController();
  RxString complaintText = ''.obs;


  @override
  void onClose() {
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
      if (file == null) return;

      int currentPhotoCount = mediaList.where((x) => !_isVideo(x)).length;

      // Batasi maksimal 4 foto
      if (currentPhotoCount >= 4) {
        Get.snackbar(
          'Warning',
          'Maksimal 4 foto yang dapat diupload.',
          backgroundColor: Colors.yellow,
          colorText: Colors.black,
        );
        return;
      }

      mediaList.add(file);
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
      if (file == null) return;

      int currentVideoCount = mediaList.where((x) => _isVideo(x)).length;

      // Batasi hanya 1 video
      if (currentVideoCount >= 1) {
        Get.snackbar(
          'Warning',
          'Hanya boleh mengupload 1 video.',
          backgroundColor: Colors.yellow,
          colorText: Colors.black,
        );
        return;
      }

      mediaList.add(file);
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
  var availableVehicles = <String>[];
  var selectedVehicle = ''.obs;

  Future<void> submitEmergencyRepair() async {
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

    final now = DateTime.now();
    final strTgl = DateFormat('yyyy-MM-dd').format(now);
    final strJam = DateFormat('HH:mm').format(now);
    final locSplit = currentLocation.value.split(',');
    final lat = locSplit.isNotEmpty ? locSplit[0].trim() : '';
    final long = locSplit.length > 1 ? locSplit[1].trim() : '';

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
      await API.createRequest(
        noPolisi: selectedVehicle.value,
        keluhan: complaintController.text.trim(),
        mediaFiles: mediaFiles,
      );
      Get.snackbar(
        'Sukses',
        'Request berhasil dibuat!',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
      Get.delete<BookingController>(force: true);
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
  Future<void> fetchRequestService() async {
    isLoadingRequest.value = true;
    errorRequest.value = '';
    try {
      listRequestService.assignAll(await API.fetchListRequestService());
    } on SilentException catch (e) {
      errorRequest.value = e.message;
    } catch (e) {
      errorRequest.value = e.toString();
    } finally {
      isLoadingRequest.value = false;
    }
  }
  bool get disableBuatEmergencyServiceButton {
    return selectedVehicle.value.isEmpty ||
        complaintText.value.trim().isEmpty ||
        isLoading.value;
  }

  String get currentEmergencyActiveStatus {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    try {
      final record = allEmergencyList.firstWhere((data) =>
      data.tgl == today && (data.status != "Derek" && data.status != "Storing"));
      return record.status ?? "-";
    } catch (e) {
      return "-";
    }
  }

  String get currentEmergencyActiveStatusdetail {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    try {
      final record = allEmergencyList.firstWhere((data) =>
      data.tgl == today && data.status?.trim().toLowerCase() == "diterima");
      return record.status ?? '-';
    } catch (e) {
      return "-";
    }
  }

  Future<List<File>> _validateAndCompressMediaFiles() async {
    final photoCount = mediaList.where((x) => !_isVideo(x)).length;
    final videoCount = mediaList.where((x) => _isVideo(x)).length;

    // ===== VALIDASI =====
    if (photoCount < 1) {
      throw 'Minimal harus ada 1 foto.';
    }
    if (photoCount > 4) {
      throw 'Maksimal foto yang dapat diupload adalah 4.';
    }
    if (videoCount < 1) {
      throw 'Minimal harus ada 1 video.';
    }
    if (videoCount > 1) {
      throw 'Hanya boleh mengupload 1 video.';
    }

    // ===== PROSES KOMPRIM =====
    List<File> compressedFiles = [];

    for (var file in mediaList) {
      if (_isVideo(file)) {
        final mediaInfo = await VideoCompress.getMediaInfo(file.path);

        // kalau durasi ≥ 1 menit, coba kompres dulu
        if (mediaInfo.duration != null && mediaInfo.duration! >= 60000) {
          final compressedVideo = await VideoCompress.compressVideo(
            file.path,
            quality: VideoQuality.MediumQuality,
            deleteOrigin: false,
            includeAudio: true,
          );
          if (compressedVideo?.file != null) {
            compressedFiles.add(compressedVideo!.file!);
            continue;
          }
        }
        // default pakai file asli
        compressedFiles.add(File(file.path));

      } else {
        // kompres gambar
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

  Future<void> fetchDetail(String kodeSvc) async {
    try {
      isLoading.value = true;
      var result = await API.fetchDetailService(kodeSvc);
      detailService.value = result;
    } on SocketException catch (e) {
      errorMessage.value = "Tidak ada koneksi internet";
      print("SocketException: $e");
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchServices() async {
    try {
      isLoading.value = true;
      errorMessage.value = "";
      var services = await API.fetchListService();
      listService.assignAll(services);
      print("Services berhasil diambil, jumlah: ${services.length}");
    } on SocketException catch (e) {
      errorMessage.value = "Tidak ada koneksi internet";
      print("SocketException: $e");
    } catch (e) {
      errorMessage.value = e.toString();
      print("Generic Exception: $e");
    } finally {
      isLoading.value = false;
    }
  }


}
