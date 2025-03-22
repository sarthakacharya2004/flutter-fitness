import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled the sign-in

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print("Error signing in with Google: $e");
      throw e; // Throw the exception to handle it in the UI
    }
  }

  // Sign up with email and password
  Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      print("Signing up with email: $email, password: $password"); // Debug print
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user; // Return the created user
    } on FirebaseAuthException catch (e) {
      print("Signup Failed: ${e.code} - ${e.message}"); // Detailed error
      throw e; // Throw the exception to handle it in the UI
    } catch (e) {
      print("Signup Failed: $e"); // General error
      throw e; // Throw the exception to handle it in the UI
    }
  }

  // Sign in with email and password
  Future<User?> loginWithEmailAndPassword(String email, String password) async {
    try {
      print("Logging in with email: $email, password: $password"); // Debug print
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("Login Failed: ${e.code} - ${e.message}"); // Detailed error
      throw e; // Throw the exception to handle it in the UI
    } catch (e) {
      print("Login Failed: $e"); // General error
      throw e; // Throw the exception to handle it in the UI
    }
  }

  // Send verification code to email
  Future<void> sendVerificationCode(String email) async {
    try {
      // Check if the email exists in Firebase
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      if (methods.isEmpty) {
        throw FirebaseAuthException(
          code: "user-not-found",
          message: "No user found with this email.",
        );
      }

      // Send a password reset email (this will include a verification code)
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print("Verification Code Failed: ${e.code} - ${e.message}");
      throw e;
    } catch (e) {
      print("Verification Code Failed: $e");
      throw e;
    }
  }

  // Verify the code and update the password
  Future<void> verifyCodeAndUpdatePassword(String email, String code, String newPassword) async {
    try {
      // Verify the code (this is a placeholder; Firebase doesn't natively support code verification for password reset)
      // You can use a custom implementation or a third-party service for code verification.
      // For now, we'll assume the code is correct and update the password directly.

      // Reauthenticate the user (if needed)
      final user = _auth.currentUser;
      if (user != null && user.email == email) {
        await user.updatePassword(newPassword);
      } else {
        throw FirebaseAuthException(
          code: "invalid-user",
          message: "Unable to update password for this user.",
        );
      }
    } on FirebaseAuthException catch (e) {
      print("Password Update Failed: ${e.code} - ${e.message}");
      throw e;
    } catch (e) {
      print("Password Update Failed: $e");
      throw e;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut(); // Sign out from Google as well
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }
}