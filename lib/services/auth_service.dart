import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:shipping_management_app/models/user_model.dart';
import 'package:shipping_management_app/models/delivery_man_model.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  // Stream to listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phoneNumber,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Create user document in Firestore
        final userModel = UserModel(
          id: credential.user!.uid,
          email: email,
          name: name,
          phoneNumber: phoneNumber,
          role: role,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(userModel.toMap());

        // Update display name
        await credential.user!.updateDisplayName(name);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google user credential
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Check if this is a new user and create user document
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _createUserDocument(userCredential.user!, UserRole.customer);
      }

      return userCredential;
    } catch (e) {
      throw 'Google sign-in failed: $e';
    }
  }

  // Create user document for social sign-in
  Future<void> _createUserDocument(User user, UserRole role) async {
    try {
      final userModel = UserModel(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? 'User',
        phoneNumber: user.phoneNumber,
        profileImageUrl: user.photoURL,
        role: role,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toMap());
    } catch (e) {
      throw 'Error creating user document: $e';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Sign out from Firebase
      await _auth.signOut();
      // Sign out from Google
      await _googleSignIn.signOut();
    } catch (e) {
      throw 'Error signing out. Please try again.';
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Get current user data
  Future<UserModel?> getCurrentUserData() async {
    try {
      if (currentUser == null) return null;

      final doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw 'Error fetching user data.';
    }
  }

  // Get delivery man data if user is a delivery person
  Future<DeliveryManModel?> getDeliveryManData() async {
    try {
      if (currentUser == null) return null;

      final doc = await _firestore
          .collection('deliveryMen')
          .doc(currentUser!.uid)
          .get();

      if (doc.exists) {
        return DeliveryManModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw 'Error fetching delivery man data.';
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    try {
      if (currentUser == null) throw 'No user logged in';

      final updates = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (name != null) {
        updates['name'] = name;
        await currentUser!.updateDisplayName(name);
      }

      if (phoneNumber != null) {
        updates['phoneNumber'] = phoneNumber;
      }

      if (profileImageUrl != null) {
        updates['profileImageUrl'] = profileImageUrl;
        await currentUser!.updatePhotoURL(profileImageUrl);
      }

      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .update(updates);
    } catch (e) {
      throw 'Error updating profile. Please try again.';
    }
  }

  // Register as delivery man
  Future<void> registerAsDeliveryMan({
    required String vehicleType,
    required String vehicleNumber,
    required String licenseNumber,
  }) async {
    try {
      if (currentUser == null) throw 'No user logged in';

      // Get current user data
      final userData = await getCurrentUserData();
      if (userData == null) throw 'User data not found';

      // Create delivery man document
      final deliveryMan = DeliveryManModel(
        id: userData.id,
        email: userData.email,
        name: userData.name,
        phoneNumber: userData.phoneNumber,
        profileImageUrl: userData.profileImageUrl,
        createdAt: userData.createdAt,
        updatedAt: DateTime.now(),
        isActive: userData.isActive,
        vehicleType: vehicleType,
        vehicleNumber: vehicleNumber,
        licenseNumber: licenseNumber,
      );

      await _firestore
          .collection('deliveryMen')
          .doc(currentUser!.uid)
          .set(deliveryMan.toMap());

      // Update user role
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .update({
        'role': 'deliveryMan',
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw 'Error registering as delivery man. Please try again.';
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'Operation not allowed.';
      case 'invalid-email':
        return 'The email address is not valid.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}