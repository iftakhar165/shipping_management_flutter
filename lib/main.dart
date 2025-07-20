import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:shipping_management_app/routes/app_routes.dart';
import 'package:shipping_management_app/utils/theme.dart';
import 'package:shipping_management_app/services/auth_service.dart';
import 'package:shipping_management_app/controllers/auth_controller.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Firebase App Check
  await FirebaseAppCheck.instance.activate(
    // Use debug provider for development, SafetyNet for production
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.safetyNet,
    appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
  );
  
  // Initialize services
  Get.put(AuthService(), permanent: true);
  Get.put(AuthController(), permanent: true);
  
  runApp(const ShippingManagementApp());
}

class ShippingManagementApp extends StatelessWidget {
  const ShippingManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Shipping Management',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}