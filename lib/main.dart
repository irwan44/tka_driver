import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
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
        return 'https://api-cartune.abeng.id';
      case 'tka':
      default:
        return 'https://api-cartune.abeng.id';
    }
  }
}

Future<void> initOneSignal() async {
  final status = await Permission.notification.status;
  if (!status.isGranted) {
    final result = await Permission.notification.request();
    if (!result.isGranted) {
      debugPrint('Notification permission denied');
      return; // skip OneSignal init if no permission
    }
  }
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.Debug.setAlertLevel(OSLogLevel.none);
  OneSignal.consentRequired(false);
  OneSignal.initialize("632556d8-c839-43be-8b93-9973bb7de550");
  OneSignal.LiveActivities.setupDefault();
  OneSignal.Notifications.clearAll();
  OneSignal.Notifications.addClickListener((event) {
    print('Notification clicked: ${event.notification.jsonRepresentation()}');
  });

  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    if (Get.currentRoute == Routes.LOGIN) {
      event.preventDefault();
      return;
    }
    event.preventDefault();
    event.notification.display();
  });

  final boxPrefs = GetStorage('preferences-mekanik');
  final storedEmail = boxPrefs.read('user_email') ?? "";
  if (storedEmail.isNotEmpty) {
    OneSignal.User.addEmail(storedEmail);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init('token-mekanik');
  await GetStorage.init('preferences-mekanik');
  await initOneSignal();

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
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
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