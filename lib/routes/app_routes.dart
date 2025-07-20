import 'package:get/get.dart';
import 'package:shipping_management_app/views/screens/splash_screen.dart';
import 'package:shipping_management_app/views/screens/auth/login_screen.dart';
import 'package:shipping_management_app/views/screens/auth/signup_screen.dart';
import 'package:shipping_management_app/views/screens/dashboard/dashboard_screen.dart';
import 'package:shipping_management_app/views/screens/parcel/parcel_list_screen.dart';
import 'package:shipping_management_app/views/screens/parcel/parcel_detail_screen.dart';
import 'package:shipping_management_app/views/screens/parcel/create_parcel_screen.dart';
import 'package:shipping_management_app/views/screens/delivery/delivery_screen.dart';
import 'package:shipping_management_app/views/screens/history/history_screen.dart';
import 'package:shipping_management_app/views/screens/notifications/notifications_screen.dart';
import 'package:shipping_management_app/views/screens/profile/profile_screen.dart';
import 'package:shipping_management_app/views/screens/analytics/analytics_dashboard_screen.dart';
import 'package:shipping_management_app/views/screens/tracking/real_time_tracking_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String dashboard = '/dashboard';
  static const String parcelList = '/parcel-list';
  static const String parcelDetail = '/parcel-detail';
  static const String createParcel = '/create-parcel';
  static const String delivery = '/delivery';
  static const String history = '/history';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String analytics = '/analytics';
  static const String tracking = '/tracking';

  static List<GetPage> get routes => [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: signup,
      page: () => const SignupScreen(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: dashboard,
      page: () => const DashboardScreen(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: parcelList,
      page: () => const ParcelListScreen(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: parcelDetail,
      page: () => const ParcelDetailScreen(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: createParcel,
      page: () => const CreateParcelScreen(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: delivery,
      page: () => const DeliveryScreen(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: history,
      page: () => const HistoryScreen(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: notifications,
      page: () => const NotificationsScreen(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: profile,
      page: () => const ProfileScreen(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: analytics,
      page: () => const AnalyticsDashboardScreen(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: tracking,
      page: () => RealTimeTrackingScreen(
        parcelId: Get.parameters['parcelId'] ?? '',
      ),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}