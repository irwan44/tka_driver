import 'package:get/get.dart';

import '../modules/booking/bindings/booking_binding.dart';
import '../modules/booking/componen/create_service.dart';
import '../modules/booking/componen/detail_history.dart';
import '../modules/booking/views/booking_view.dart';
import '../modules/emergency/bindings/emergency_binding.dart';
import '../modules/emergency/componen/create_emergency.dart';
import '../modules/emergency/componen/detail_history_emergency.dart';
import '../modules/emergency/views/emergency_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/splashscreen/bindings/splashscreen_binding.dart';
import '../modules/splashscreen/views/splashscreen_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASHSCREEN;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.EMERGENCY,
      page: () => const EmergencyView(),
      binding: EmergencyBinding(),
    ),
    GetPage(
      name: _Paths.BOOKING,
      page: () => const BookingView(),
      binding: BookingBinding(),
    ),
    GetPage(
      name: _Paths.SPLASHSCREEN,
      page: () => const SplashscreenView(),
      binding: SplashscreenBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.DETAILHISTOTY,
      page: () => const StepperPage(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.FORMEMERGENCY,
      page: () =>  EmergencyRepairPage(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.FORMREGULER,
      page: () => RegularRepairPage(),
      binding: ProfileBinding(),
    ),
    GetPage(
      transition: Transition.rightToLeftWithFade,
      name: _Paths.DETAILEMERGENCY,
      page: () => const EmergencyDetailView(),
      binding: ProfileBinding(),
    ),
  ];
}
