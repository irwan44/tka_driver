import 'package:get_storage/get_storage.dart';
import 'package:tka_customer/app/data/publik.dart';

class LocalStorages {
  static GetStorage boxToken = GetStorage('token-mekanik');
  static GetStorage boxPreferences = GetStorage('preferences-mekanik');
  static Future<bool> hasToken() async {
    String token = getToken;
    return token.isNotEmpty;
  }

  static Future<void> setToken(String token) async {
    await boxToken.write('token', token);
    Publics.controller.getToken.value = getToken;
  }

  static String get getToken => boxToken.read('token') ?? '';
  static Future<void> deleteToken() async {
    await boxToken.remove('token');
    Publics.controller.getToken.value = '';
  }

  static Future<void> setProfile(String profileJson) async {
    await boxPreferences.write('profile', profileJson);
  }

  static String get getProfileData => boxPreferences.read('profile') ?? '';

  static Future<void> setUserEmail(String email) async {
    await boxPreferences.write('user_email', email);
  }

  static String get getUserEmail => boxPreferences.read('user_email') ?? '';

  static Future<void> deleteUserEmail() async {
    await boxPreferences.remove('user_email');
  }

  static Future<void> setKeepMeSignedIn(bool keepSignedIn) async {
    await boxPreferences.write('keepMeSignedIn', keepSignedIn);
  }

  static Future<bool> getKeepMeSignedIn() async {
    return boxPreferences.read('keepMeSignedIn') ?? false;
  }

  static Future<void> deleteKeepMeSignedIn() async {
    await boxPreferences.remove('keepMeSignedIn');
  }

  static Future<void> setPosisi(dynamic posisi) async {
    await boxPreferences.write('posisi', posisi);
  }

  static dynamic get getPosisi => boxPreferences.read('posisi');

  static Future<void> deletePosisi() async {
    await boxPreferences.remove('posisi');
  }

  static Future<void> logout() async {
    await deleteToken();
    await deleteKeepMeSignedIn();
    await deletePosisi();
  }
}
