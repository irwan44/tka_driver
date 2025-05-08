import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app/modules/booking/controllers/booking_controller.dart';
import 'app/modules/home/views/home_view.dart';
import 'app/routes/app_pages.dart';

class AssetsRes {
  AssetsRes._();
  static String get LOGO {
    const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'tka');
    debugPrint('>>> Running with FLAVOR=$flavor');
    switch (flavor) {
      case 'dev':
        return 'assets/logo/logo_dev.png';
      case 'rusco':
        return 'assets/logo/logo-rusco.png';
      case 'uniquip':
        return 'assets/logo/logo_uniquip.png';
      case 'tka':
      default:
        return 'assets/logo/logo-ottogo.png';
    }
  }
}

class AppConfig {
  static const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'tka');
  static String get baseUrl {
    switch (flavor) {
      case 'dev':
        return 'https://api-cartune.abeng.id';
      case 'rusco':
        return 'https://api.rusco.id';
      case 'uniquip':
        return 'https://api.uniquip.abeng.id';
      case 'tka':
      default:
        return 'https://api-cartune.abeng.id';
    }
  }
}

class OneSignalConfig {
  OneSignalConfig._();
  static const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'tka');
  static String get appId {
    switch (flavor) {
      case 'dev':
        return 'DEV-ONESIGNAL-APPID-XXXX';
      case 'rusco':
        return '1835b652-321b-470f-b08f-e5a010b026f3';
      case 'uniquip':
        return 'f93db1e6-1219-47f7-b7bc-51e6ae2029cb';
      case 'tka':
      default:
        return 'f0dddd10-dfe8-4579-927e-442da28c635c';
    }
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init('token-mekanik');
  await GetStorage.init('preferences-mekanik');
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  Get.put(ThemeController());
  Get.put<BookingController>(BookingController(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OttoGo Driver',
      theme: ThemeData.light().copyWith(
        textTheme: GoogleFonts.nunitoTextTheme(ThemeData.light().textTheme),
      ),
      darkTheme: ThemeData.dark().copyWith(
        textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme),
      ),
      themeMode: ThemeMode.system,
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          ),
        );
        return child!;
      },
      initialRoute: Routes.SPLASHSCREEN,
      getPages: AppPages.routes,
    );
  }
}

// flutter run --flavor dev -t lib/main.dart --dart-define=FLAVOR=dev
// flutter build apk --flavor dev -t lib/main.dart --dart-define=FLAVOR=dev
// flutter build appbundle --flavor dev -t lib/main.dart --dart-define=FLAVOR=dev
//
// flutter run --flavor tka -t lib/main.dart --dart-define=FLAVOR=tka
// flutter build apk --flavor tka -t lib/main.dart --dart-define=FLAVOR=tka
// flutter build appbundle --flavor tka -t lib/main.dart --dart-define=FLAVOR=tka
//
// flutter run --flavor rusco -t lib/main.dart --dart-define=FLAVOR=rusco
// flutter build apk --flavor rusco -t lib/main.dart --dart-define=FLAVOR=rusco
// flutter build appbundle --flavor rusco -t lib/main.dart --dart-define=FLAVOR=rusco
