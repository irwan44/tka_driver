import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tka_customer/app/routes/app_pages.dart';

import '../../main.dart';
import 'data_respon/detailservice.dart';
import 'data_respon/list_emergency.dart';
import 'data_respon/listkendaraan.dart';
import 'data_respon/listservice.dart';
import 'data_respon/meknaikposisi.dart';
import 'data_respon/profile2.dart';
import 'data_respon/reques_service.dart';
import 'data_respon/token.dart';
import 'localstorage.dart';

class SilentException implements Exception {
  final String message;
  SilentException(this.message);
  @override
  String toString() => message;
}

class API {
  static final _url = AppConfig.baseUrl;
  static String get _postLogin => '$_url/login';
  static String get _getListEmergency => '$_url/driver/emergency';
  static String get _postListEmergency => '$_url/driver/emergency';
  static String get _getListrequest => '$_url/driver/request_service';
  static String get _postrequest => '$_url/driver/request_service';
  static String get _getKendaraan => '$_url/driver/vehicles';
  static String get _getProfile => '$_url/user';
  static String get _getListService => '$_url/driver/services';
  static String get _getDetailService => '$_url/driver/services/';
  static String get _getMekanikPosisi => '$_url/driver/mechanic_position/';
  static String get _PutKonfirmasiPlanning =>
      '$_url/driver/service/konfirmasi/';

  static Future<void> _handleTokenExpiration(
    int statusCode,
    String responseBody,
  ) async {
    if (statusCode == 401) {
      await LocalStorages.deleteToken();
      Get.offAllNamed(Routes.LOGIN);
      throw Exception("Session expired. Please login again.");
    }
  }

  // LOGIN
  static Future<Token> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_postLogin),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = Token.fromJson(data);

        if (token.token != null) {
          await LocalStorages.setToken(token.token!);
        }
        return token;
      } else if (response.statusCode == 401) {
        final data = jsonDecode(response.body);
        await _handleTokenExpiration(response.statusCode, response.body);
        throw Exception(data['message']);
      } else {
        throw Exception(
          'Failed to login (code: ${response.statusCode}) -> ${response.body}',
        );
      }
    } on SocketException catch (e) {
      print("No internet connection: $e");
      throw SilentException("Tidak ada koneksi internet");
    }
  }

  // Ambil Profile User
  static Future<Profile2> getProfile() async {
    try {
      final token = LocalStorages.getToken;
      if (token.isEmpty) {
        throw Exception("Token kosong. Harap login terlebih dahulu.");
      }
      final response = await http.get(
        Uri.parse(_getProfile),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        await LocalStorages.setProfile(response.body);
        final data = jsonDecode(response.body);
        return Profile2.fromJson(data);
      } else {
        await _handleTokenExpiration(response.statusCode, response.body);
        throw Exception(
          'Gagal mengambil profile (code: ${response.statusCode}) -> ${response.body}',
        );
      }
    } on SocketException catch (e) {
      print("No internet connection: $e");
      String cachedProfile = LocalStorages.getProfileData;
      if (cachedProfile.isNotEmpty) {
        final data = jsonDecode(cachedProfile);
        return Profile2.fromJson(data);
      } else {
        throw Exception(
          "Tidak ada koneksi internet dan data cache tidak tersedia",
        );
      }
    }
  }

  // Ambil List Emergency
  static Future<Listemergency> fetchListEmergency() async {
    try {
      final token = LocalStorages.getToken;
      if (token.isEmpty) {
        throw Exception("Token is empty. Please login first.");
      }

      final response = await http.get(
        Uri.parse(_getListEmergency),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Listemergency.fromJson(data);
      } else {
        await _handleTokenExpiration(response.statusCode, response.body);
        throw Exception(
          'Failed to fetch list emergency (code: ${response.statusCode}) -> ${response.body}',
        );
      }
    } on SocketException catch (e) {
      print("No internet connection: $e");
      throw SilentException("Tidak ada koneksi internet");
    }
  }

  // ------------- LIST REQUEST SERVICE ---------------
  static Future<List<RequestService>> fetchListRequestService() async {
    try {
      final token = LocalStorages.getToken;
      if (token.isEmpty) throw Exception("Token kosong. Harap login.");

      final r = await http.get(
        Uri.parse(_getListrequest),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        return (data as List).map((e) => RequestService.fromJson(e)).toList();
      } else {
        await _handleTokenExpiration(r.statusCode, r.body);
        throw Exception(
          'Fetch request service gagal (${r.statusCode}) -> ${r.body}',
        );
      }
    } on SocketException {
      throw SilentException("Tidak ada koneksi internet");
    }
  }

  // Create Request (POST dengan form-data)
  static Future<void> createRequest({
    required String noPolisi,
    required String keluhan,
    required List<File> mediaFiles,
  }) async {
    try {
      final token = LocalStorages.getToken;
      if (token.isEmpty) {
        throw Exception("Token is empty! Mohon login terlebih dahulu.");
      }

      final uri = Uri.parse(_postrequest);
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['no_polisi'] = noPolisi;
      request.fields['keluhan'] = keluhan;
      for (final file in mediaFiles) {
        final fileName = file.path.split('/').last;
        request.files.add(
          await http.MultipartFile.fromPath(
            'media[]',
            file.path,
            filename: fileName,
          ),
        );
      }
      final streamedResponse = await request.send();
      final responseBody = await http.Response.fromStream(streamedResponse);

      if (streamedResponse.statusCode == 200 ||
          streamedResponse.statusCode == 201) {
        return;
      } else {
        await _handleTokenExpiration(
          streamedResponse.statusCode,
          responseBody.body,
        );
        throw Exception(
          'Failed to create emergency. Code: ${streamedResponse.statusCode} -> ${responseBody.body}',
        );
      }
    } on SocketException catch (e) {
      print("No internet connection: $e");
      throw SilentException("Tidak ada koneksi internet");
    }
  }

  static Future<void> createEmergency({
    required String noPolisi,
    required String tgl,
    required String jam,
    required String keluhan,
    required String latitude,
    required String longitude,
    required List<File> mediaFiles,
  }) async {
    try {
      final token = LocalStorages.getToken;
      if (token.isEmpty) {
        throw Exception("Token is empty! Mohon login terlebih dahulu.");
      }

      final uri = Uri.parse(_postListEmergency);
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['no_polisi'] = noPolisi;
      request.fields['tgl'] = tgl;
      request.fields['jam'] = jam;
      request.fields['keluhan'] = keluhan;
      request.fields['latitude'] = latitude;
      request.fields['longitude'] = longitude;
      for (final file in mediaFiles) {
        final fileName = file.path.split('/').last;
        request.files.add(
          await http.MultipartFile.fromPath(
            'media[]',
            file.path,
            filename: fileName,
          ),
        );
      }
      final streamedResponse = await request.send();
      final responseBody = await http.Response.fromStream(streamedResponse);

      if (streamedResponse.statusCode == 200 ||
          streamedResponse.statusCode == 201) {
        return;
      } else {
        await _handleTokenExpiration(
          streamedResponse.statusCode,
          responseBody.body,
        );
        throw Exception(
          'Failed to create emergency. Code: ${streamedResponse.statusCode} -> ${responseBody.body}',
        );
      }
    } on SocketException catch (e) {
      print("No internet connection: $e");
      throw SilentException("Tidak ada koneksi internet");
    }
  }

  // Ambil List Kendaraan
  static Future<ListKendaraan> fetchListKendaraan() async {
    try {
      final token = LocalStorages.getToken;
      if (token.isEmpty) {
        throw Exception("Token is empty. Please login first.");
      }

      final response = await http.get(
        Uri.parse(_getKendaraan),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ListKendaraan.fromJson(data);
      } else {
        await _handleTokenExpiration(response.statusCode, response.body);
        throw Exception(
          'Failed to fetch list kendaraan (code: ${response.statusCode}) -> ${response.body}',
        );
      }
    } on SocketException catch (e) {
      print("No internet connection: $e");
      throw SilentException("Tidak ada koneksi internet");
    }
  }

  // Ambil List Service
  static Future<List<ListService>> fetchListService() async {
    try {
      final token = LocalStorages.getToken;
      if (token.isEmpty) {
        throw Exception("Token kosong. Harap login terlebih dahulu.");
      }
      final response = await http.get(
        Uri.parse(_getListService),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print("Status Code: ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data as List)
            .map((json) => ListService.fromJson(json))
            .toList();
      } else {
        await _handleTokenExpiration(response.statusCode, response.body);
        throw Exception(
          'Failed to fetch list service (code: ${response.statusCode}) -> ${response.body}',
        );
      }
    } on SocketException catch (e) {
      print("SocketException di API.fetchListService: $e");
      throw e;
    }
  }

  // Ambil Detail Service berdasarkan kodeSvc
  static Future<DetailService> fetchDetailService(String kodeSvc) async {
    try {
      final token = LocalStorages.getToken;
      if (token.isEmpty) {
        throw Exception("Token kosong. Harap login terlebih dahulu.");
      }
      final response = await http.get(
        Uri.parse(_getDetailService + kodeSvc),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DetailService.fromJson(data);
      } else {
        await _handleTokenExpiration(response.statusCode, response.body);
        throw Exception(
          'Gagal mengambil detail service (code: ${response.statusCode}) -> ${response.body}',
        );
      }
    } on SocketException catch (e) {
      print("No internet connection: $e");
      throw SilentException("Tidak ada koneksi internet");
    }
  }

  // ─── Dalam class API ───
  static Future<void> confirmPlanning(String kodeSvc) async {
    try {
      final token = LocalStorages.getToken;
      if (token.isEmpty) {
        throw Exception("Token kosong. Harap login terlebih dahulu.");
      }

      final response = await http.put(
        Uri.parse(_PutKonfirmasiPlanning + kodeSvc),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return;
      } else {
        await _handleTokenExpiration(response.statusCode, response.body);
        throw Exception(
          'Gagal konfirmasi planning (code: ${response.statusCode}) -> ${response.body}',
        );
      }
    } on SocketException {
      throw SilentException("Tidak ada koneksi internet");
    }
  }

  static Future<MekanikPosisi> fetchMekanikPosisi(String kode) async {
    try {
      final token = LocalStorages.getToken;
      if (token.isEmpty) {
        throw Exception("Token kosong, harap login terlebih dahulu.");
      }
      final url = _getMekanikPosisi + kode;
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return MekanikPosisi.fromJson(data);
      } else {
        await _handleTokenExpiration(response.statusCode, response.body);
        throw Exception(
          "Gagal mengambil posisi mekanik (code: ${response.statusCode})",
        );
      }
    } on SocketException catch (e) {
      print("No internet connection: $e");
      throw SilentException("Tidak ada koneksi internet");
    }
  }
}
