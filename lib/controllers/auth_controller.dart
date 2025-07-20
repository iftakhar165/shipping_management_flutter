import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shipping_management_app/services/auth_service.dart';
import 'package:shipping_management_app/models/user_model.dart';
import 'package:shipping_management_app/models/delivery_man_model.dart';
import 'package:shipping_management_app/routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final Rx<User?> _firebaseUser = Rx<User?>(null);
  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);
  final Rx<DeliveryManModel?> _deliveryManData = Rx<DeliveryManModel?>(null);
  final RxBool _isLoading = false.obs;

  User? get firebaseUser => _firebaseUser.value;
  UserModel? get currentUser => _currentUser.value;
  DeliveryManModel? get deliveryManData => _deliveryManData.value;
  bool get isLoading => _isLoading.value;
  bool get isLoggedIn => _firebaseUser.value != null;

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    _firebaseUser.bindStream(_authService.authStateChanges);
    
    // Load user data when auth state changes
    ever(_firebaseUser, _handleAuthStateChange);
  }

  void _handleAuthStateChange(User? user) async {
    if (user != null) {
      await _loadUserData();
      // Navigate to dashboard if user is logged in
      if (Get.currentRoute == AppRoutes.splash || 
          Get.currentRoute == AppRoutes.login) {
        Get.offAllNamed(AppRoutes.dashboard);
      }
    } else {
      // Clear user data
      _currentUser.value = null;
      _deliveryManData.value = null;
      // Navigate to login if user is not logged in
      if (Get.currentRoute != AppRoutes.login && 
          Get.currentRoute != AppRoutes.signup &&
          Get.currentRoute != AppRoutes.splash) {
        Get.offAllNamed(AppRoutes.login);
      }
    }
  }

  Future<void> _loadUserData() async {
    try {
      _isLoading.value = true;
      
      // Load user data
      final userData = await _authService.getCurrentUserData();
      _currentUser.value = userData;

      // Load delivery man data if user is a delivery person
      if (userData?.role == UserRole.deliveryMan) {
        final deliveryManData = await _authService.getDeliveryManData();
        _deliveryManData.value = deliveryManData;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load user data: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phoneNumber,
  }) async {
    try {
      _isLoading.value = true;
      
      await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        role: role,
        phoneNumber: phoneNumber,
      );

      Get.snackbar(
        'Success',
        'Account created successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading.value = true;
      
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _isLoading.value = true;
      
      final userCredential = await _authService.signInWithGoogle();
      
      if (userCredential != null) {
        Get.snackbar(
          'Success',
          'Signed in successfully with Google!',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading.value = true;
      await _authService.signOut();
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _isLoading.value = true;
      
      await _authService.resetPassword(email);
      
      Get.snackbar(
        'Success',
        'Password reset email sent!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateProfile({
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    try {
      _isLoading.value = true;
      
      await _authService.updateUserProfile(
        name: name,
        phoneNumber: phoneNumber,
        profileImageUrl: profileImageUrl,
      );

      // Reload user data
      await _loadUserData();

      Get.snackbar(
        'Success',
        'Profile updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> registerAsDeliveryMan({
    required String vehicleType,
    required String vehicleNumber,
    required String licenseNumber,
  }) async {
    try {
      _isLoading.value = true;
      
      await _authService.registerAsDeliveryMan(
        vehicleType: vehicleType,
        vehicleNumber: vehicleNumber,
        licenseNumber: licenseNumber,
      );

      // Reload user data
      await _loadUserData();

      Get.snackbar(
        'Success',
        'Registered as delivery man successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }
}