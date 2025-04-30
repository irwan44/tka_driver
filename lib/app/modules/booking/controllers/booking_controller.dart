import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tka_customer/app/data/data_respon/list_emergency.dart';
import 'package:tka_customer/app/routes/app_pages.dart';
import 'package:video_compress/video_compress.dart';

import '../../../data/data_respon/detailservice.dart';
import '../../../data/data_respon/listservice.dart';
import '../../../data/data_respon/reques_service.dart';
import '../../../data/endpoint.dart';

class BookingController extends GetxController {
  var currentStep = 0.obs;
  var isLoading = true.obs;
  var listService = <ListService>[].obs;
  var detailService = Rxn<DetailService>();
  var errorMessage = ''.obs;
  var isLoadingRequest = true.obs;
  var listRequestService = <RequestService>[].obs;
  var errorRequest = ''.obs;
  var confirmedPlanningSvcs = <String>{}.obs;
  final RxBool isConfirming = false.obs;
  DateTime? _selectedDate;
  Timer? _ticker;
  final isLoadingServices = false.obs;
  final isLoadingVehicles = false.obs;
  final RxBool isLoadingDetail = false.obs;
  final RxBool disableSubmitButton = true.obs;

  bool isPlanningConfirmed(String? kodeSvc) =>
      kodeSvc != null && confirmedPlanningSvcs.contains(kodeSvc);
  DateTime _toLocalDateTime(String utcString) {
    return DateTime.parse(utcString).toLocal();
  }

  List<RequestService> get filteredRequests {
    return listRequestService.where((r) {
      final nopol = (r.noPolisi ?? '').toLowerCase();
      final q = searchQuery.toLowerCase();
      final matchSearch = q.isEmpty || nopol.contains(q);

      bool matchDate = true;
      if (_selectedDate != null) {
        final created = _toLocalDateTime(r.createdAt ?? '');
        final sel = _selectedDate!;
        matchDate =
            created.year == sel.year &&
            created.month == sel.month &&
            created.day == sel.day;
      }
      return matchSearch && matchDate;
    }).toList();
  }

  List<ListService> get filteredServices {
    return listService.where((s) {
      final nopol = (s.noPolisi ?? '').toLowerCase();
      final q = searchQuery.toLowerCase();
      final matchSearch = q.isEmpty || nopol.contains(q);

      bool matchDate = true;
      if (_selectedDate != null) {
        matchDate = false;
        for (final t in [s.tglEstimasi, s.tglPkb]) {
          if (t == null) continue;
          final d = DateFormat('yyyy-MM-dd').parse(t);
          if (DateFormat('yyyy-MM-dd').format(d) ==
              DateFormat('yyyy-MM-dd').format(_selectedDate!)) {
            matchDate = true;
            break;
          }
        }
      }
      return matchSearch && matchDate;
    }).toList();
  }

  Future<void> confirmPlanningService(BuildContext ctx, String kodeSvc) async {
    if (isPlanningConfirmed(kodeSvc)) return;
    isConfirming.value = true;
    try {
      await API.confirmPlanning(kodeSvc);
      confirmedPlanningSvcs.add(kodeSvc);
      Get.delete<BookingController>(force: true);
      Get.toNamed(Routes.HOME);
      await QuickAlert.show(
        context: ctx,
        type: QuickAlertType.success,
        text: 'Planning service berhasil dikonfirmasi',
      );
    } on SilentException catch (_) {
      Get.snackbar('Error', 'Tidak ada koneksi internet');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isConfirming.value = false;
    }
  }

  @override
  void onClose() {
    _ticker?.cancel();
    _debounceTimer?.cancel();
    _connectSub.cancel();
    super.onClose();
  }

  final RxSet<String> _openedRequestIds = <String>{}.obs;
  final RxSet<String> _openedServiceIds = <String>{}.obs;

  bool requestOpened(String? id) {
    if (id == null) return false;
    return _openedRequestIds.contains(id.trim().toUpperCase());
  }

  bool serviceOpened(String? id) {
    if (id == null) return false;
    return _openedServiceIds.contains(id.trim().toUpperCase());
  }

  Future<void> markRequestOpened(String? id) async {
    if (id == null) return;
    final normalized = id.trim().toUpperCase();
    if (_openedRequestIds.add(normalized)) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'opened_request_ids',
        _openedRequestIds.toList(),
      );
    }
  }

  Future<void> markServiceOpened(String? id) async {
    if (id == null) return;
    final normalized = id.trim().toUpperCase();
    if (_openedServiceIds.add(normalized)) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'opened_service_ids',
        _openedServiceIds.toList(),
      );
    }
  }

  int get unreadRequestCount =>
      listRequestService
          .where((e) => !requestOpened(e.kodeRequestService))
          .length;
  int get unreadStatusServiceCount =>
      listService.where((s) {
        final st = (s.status ?? '').trim().toUpperCase();
        return st != 'PKB TUTUP' &&
            st != 'INVOICE' &&
            !serviceOpened(s.kodeSvc);
      }).length;
  int get unreadHistoryServiceCount =>
      listService.where((s) {
        final st = (s.status ?? '').trim().toUpperCase();
        return (st == 'PKB TUTUP' || st == 'INVOICE') &&
            !serviceOpened(s.kodeSvc);
      }).length;

  Set<String> get _busyPlates {
    return listRequestService
        .where((r) => (r.status ?? '').toLowerCase() != 'selesai')
        .map((r) => (r.noPolisi ?? '').toUpperCase())
        .toSet();
  }

  bool vehicleAlreadyRequested(String? nopol) =>
      nopol != null && _busyPlates.contains(nopol.toUpperCase());

  void onVehicleChanged(String? value) {
    selectedVehicle.value = value ?? '';
    disableSubmitButton.value =
        value == null || value.isEmpty || vehicleAlreadyRequested(value);
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  int _prevNotConfirmedCount = 0;
  bool _hasPlayedNotification = false;

  @override
  void onInit() {
    super.onInit();
    _loadOpenedIds();
    _firstLoad();
    _startRealtime();
    _prevNotConfirmedCount =
        listService
            .where((s) => (s.status ?? '').toUpperCase() == 'NOT CONFIRMED')
            .length;
    ever<List<ListService>>(listService, _onListServiceChanged);
    _connectSub = Connectivity().onConnectivityChanged.listen((event) {});
  }

  void _onListServiceChanged(List<ListService> newList) {
    final currentNotConfirmed =
        newList
            .where((s) => (s.status ?? '').toUpperCase() == 'NOT CONFIRMED')
            .toList();
    final currentCount = currentNotConfirmed.length;

    if (currentCount > _prevNotConfirmedCount && !_hasPlayedNotification) {
      _hasPlayedNotification = true;
      _playNotificationSound();
    }

    _prevNotConfirmedCount = currentCount;
  }

  Future<void> _playNotificationSound() async {
    try {
      await _audioPlayer.play(
        AssetSource('sounds/notifikasi_planning.mp3'),
        volume: 1.0,
      );
    } catch (e) {
      print('Gagal memainkan suara: $e');
    }
  }

  Future<void> _loadOpenedIds() async {
    final prefs = await SharedPreferences.getInstance();

    final req = prefs.getStringList('opened_request_ids') ?? [];
    _openedRequestIds.addAll(req.map((e) => e.trim().toUpperCase()));

    final svc = prefs.getStringList('opened_service_ids') ?? [];
    _openedServiceIds.addAll(svc.map((e) => e.trim().toUpperCase()));
  }

  Future<void> _firstLoad() async {
    try {
      await Future.wait([
        fetchServices(),
        fetchRequestService(),
        fetchVehicles(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  void _startRealtime() {
    const interval = Duration(seconds: 5);
    _ticker?.cancel();
    _ticker = Timer.periodic(interval, (_) {
      fetchServices(showLoader: false);
      fetchRequestService(showLoader: false);
      fetchVehicles(showLoader: false);
    });
  }

  Future<void> refreshAll() async {
    await Future.wait([fetchRequestService()]);
    await Future.wait([fetchServices()]);
  }

  final Rx<ConnectivityResult> debouncedStatus = ConnectivityResult.mobile.obs;
  late StreamSubscription _connectSub;
  Timer? _debounceTimer;

  var allEmergencyList = <Data>[].obs;
  var emergencyList = <Data>[].obs;
  var searchQuery = ''.obs;
  DateTime? dateFilter;

  final searchController = TextEditingController();
  final complaintController = TextEditingController();
  RxString complaintText = ''.obs;

  void performAction(Data data) {
    data.status = 'Diterima';
    print("Status diubah menjadi: ${data.status}");
    update();
  }

  Future<void> fetchVehicles({bool showLoader = true}) async {
    if (showLoader) isLoadingVehicles(true);
    try {
      isLoadingVehicles.value = true;
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
      if (showLoader) isLoadingVehicles.value = false;
    }
  }

  void applyFilters() {
    List<Data> filtered = allEmergencyList.toList();
    if (searchQuery.value.trim().isNotEmpty) {
      final queryLower = searchQuery.value.trim().toLowerCase();
      filtered =
          filtered.where((item) {
            final kodeLower = (item.kode ?? '').toLowerCase();
            final noPolisiLower = (item.noPolisi ?? '').toLowerCase();
            return kodeLower.contains(queryLower) ||
                noPolisiLower.contains(queryLower);
          }).toList();
    }
    if (dateFilter != null) {
      filtered =
          filtered.where((item) {
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

  Future<void> submitRequest(BuildContext ctx) async {
    if (vehicleAlreadyRequested(selectedVehicle.value)) {
      Get.snackbar(
        'Gagal',
        'Nomor polisi ini masih punya Request Service',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
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

      Get.delete<BookingController>(force: true);
      Get.put<BookingController>(BookingController(), permanent: true);
      Get.offAllNamed(Routes.HOME);
      await QuickAlert.show(
        context: ctx,
        type: QuickAlertType.success,
        text: 'Request berhasil dibuat!',
      );
    } catch (e) {
      final err = e.toString().toLowerCase();
      if (e is SocketException ||
          err.contains('tidak ada jaringan') ||
          err.contains('no internet') ||
          err.contains('failed host lookup') ||
          err.contains('no address associated with hostname')) {
        debugPrint('📡 Error jaringan: $e');
      } else {
        Get.snackbar(
          'Error',
          e.toString(),
          backgroundColor: Colors.yellow,
          colorText: Colors.black,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  final RxBool networkError = false.obs;

  Future<void> fetchRequestService({bool showLoader = true}) async {
    errorRequest.value = '';
    if (showLoader) isLoadingRequest(true);

    try {
      networkError(false);
      final list = await API.fetchListRequestService();
      listRequestService.assignAll(list);
    } on SocketException {
      errorRequest.value = 'Tidak ada koneksi internet';
      networkError(true);
    } on SilentException catch (e) {
      errorRequest.value = e.message;
      networkError(true);
    } catch (e) {
      errorRequest.value = e.toString();
      networkError(false);
    } finally {
      if (showLoader) isLoadingRequest(false);
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
      final record = allEmergencyList.firstWhere(
        (data) =>
            data.tgl == today &&
            (data.status != "Derek" && data.status != "Storing"),
      );
      return record.status ?? "-";
    } catch (e) {
      return "-";
    }
  }

  String get currentEmergencyActiveStatusdetail {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    try {
      final record = allEmergencyList.firstWhere(
        (data) =>
            data.tgl == today &&
            data.status?.trim().toLowerCase() == "diterima",
      );
      return record.status ?? '-';
    } catch (e) {
      return "-";
    }
  }

  Future<List<File>> _validateAndCompressMediaFiles() async {
    final photoCount = mediaList.where((x) => !_isVideo(x)).length;
    final videoCount = mediaList.where((x) => _isVideo(x)).length;

    if (photoCount < 1) {
      throw 'Minimal harus ada 1 foto.';
    }
    if (photoCount > 4) {
      throw 'Maksimal foto yang dapat diupload adalah 4.';
    }

    if (videoCount > 1) {
      throw 'Hanya boleh mengupload 1 video.';
    }

    List<File> compressedFiles = [];

    for (var file in mediaList) {
      if (_isVideo(file)) {
        final mediaInfo = await VideoCompress.getMediaInfo(file.path);
        if (mediaInfo.duration != null && mediaInfo.duration! >= 120000) {
          final compressedVideo = await VideoCompress.compressVideo(
            file.path,
            quality: VideoQuality.DefaultQuality,
            deleteOrigin: false,
            includeAudio: true,
          );
          if (compressedVideo?.file != null) {
            compressedFiles.add(compressedVideo!.file!);
            continue;
          }
        }
        compressedFiles.add(File(file.path));
      } else {
        final result = await FlutterImageCompress.compressWithFile(
          file.path,
          quality: 80,
        );
        if (result != null) {
          final fileName = file.path.split(Platform.pathSeparator).last;
          final targetPath =
              '${Directory.systemTemp.path}/${DateTime.now().millisecondsSinceEpoch}_$fileName';
          final compressedImage = await File(targetPath).writeAsBytes(result);
          compressedFiles.add(compressedImage);
        } else {
          compressedFiles.add(File(file.path));
        }
      }
    }

    return compressedFiles;
  }

  Future<void> fetchDetail(String kodeSvc, {bool showLoader = true}) async {
    if (showLoader) isLoadingDetail(true);
    errorMessage.value = '';

    try {
      final result = await API.fetchDetailService(kodeSvc);
      detailService.value = result;
    } on SocketException {
      errorMessage.value = 'Tidak ada koneksi internet';
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      if (showLoader) isLoadingDetail(false);
    }
  }

  Future<void> fetchServices({bool showLoader = true}) async {
    if (showLoader) isLoadingServices(true);
    errorMessage.value = '';

    try {
      final services = await API.fetchListService();
      listService.assignAll(services);
      debugPrint('✅ Services fetched: ${services.length}');
    } on SocketException {
      errorMessage.value = 'Tidak ada koneksi internet';
    } catch (e) {
      errorMessage.value = e.toString();
      debugPrint('❌ fetchServices error → $e');
    } finally {
      if (showLoader) isLoadingServices(false);
    }
  }
}
