import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream to track authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print("Error signing in with Google: $e");
      rethrow;
    }
  }

  // Enhanced sign up with email verification
  Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      print("Signing up with email: $email");
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      // Add delay to avoid Firebase spam detection
      await Future.delayed(const Duration(seconds: 1));

      if (user != null && !user.emailVerified) {
        await _sendVerificationWithCooldown(user);
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print("Signup Failed: ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      print("Signup Failed: $e");
      rethrow;
    }
  }

  // Enhanced login with email verification check
  Future<User?> loginWithEmailAndPassword(String email, String password) async {
    try {
      print("Logging in with email: $email");
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      await _checkEmailVerification(user);

      return user;
    } on FirebaseAuthException catch (e) {
      print("Login Failed: ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      print("Login Failed: $e");
      rethrow;
    }
  }

  // Check email verification status
  Future<void> _checkEmailVerification(User? user) async {
    if (user != null && !user.emailVerified) {
      // Reload user to get latest verification status
      await user.reload();
      user = _auth.currentUser;

      if (user != null && !user.emailVerified) {
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'Email not verified. Please check your inbox.',
        );
      }
    }
  }

  // Send verification email with cooldown
  Future<void> _sendVerificationWithCooldown(User user) async {
    try {
      await user.sendEmailVerification();
      print("✅ Verification email sent to ${user.email}");
      
      // Store last sent time to prevent spam
      // You might want to use shared_preferences for persistence
      lastVerificationEmailSent = DateTime.now();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'too-many-requests') {
        print("Verification email cooldown active");
        throw FirebaseAuthException(
          code: 'verification-cooldown',
          message: 'Please wait before requesting another verification email',
        );
      }
      rethrow;
    }
  }

  DateTime? lastVerificationEmailSent;

  // Enhanced resend verification email
  Future<void> resendEmailVerification() async {
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        // Check cooldown (5 minutes)
        if (lastVerificationEmailSent != null &&
            DateTime.now().difference(lastVerificationEmailSent!) <
                const Duration(minutes: 5)) {
          throw FirebaseAuthException(
            code: 'verification-cooldown',
            message: 'Please wait before requesting another verification email',
          );
        }

        await Future.delayed(const Duration(seconds: 1));
        await _sendVerificationWithCooldown(user);
      }
    } catch (e) {
      print("Failed to resend verification email: $e");
      rethrow;
    }
  }

  // Password reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      if (methods.isEmpty) {
        throw FirebaseAuthException(
          code: "user-not-found",
          message: "No user found with this email.",
        );
      }

      await _auth.sendPasswordResetEmail(email: email);
      print("🔑 Password reset email sent.");
    } on FirebaseAuthException catch (e) {
      print("Password Reset Failed: ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      print("Password Reset Failed: $e");
      rethrow;
    }
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      }
    } on FirebaseAuthException catch (e) {
      print("Password Update Failed: ${e.code} - ${e.message}");
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Check verification status
  Future<bool> isEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }
}