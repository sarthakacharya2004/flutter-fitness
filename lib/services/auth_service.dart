import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Store pending user data until email verification
  final Map<String, Map<String, dynamic>> _pendingUserData = {};

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  DateTime? lastVerificationEmailSent;

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

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        await _saveUserData(
          user.uid,
          googleUser.displayName ?? 'Google User',
          user.email ?? '',
          'Not Set', // Default goal for Google Sign In
        );
      }

      return userCredential;
    } catch (e) {
      print("Error signing in with Google: $e");
      rethrow;
    }
  }

  // Sign up with email/password
  Future<User?> signUpWithEmailAndPassword(String email, String password, String name, String goal) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null && !user.emailVerified) {
        await _sendVerificationWithCooldown(user);
        // Store user data in memory until verification
        _pendingUserData[user.uid] = {
          'name': name,
          'email': email,
          'goal': goal,
        };
        
        // Save user data to Firestore with the same format as Google sign-in
        await _saveUserData(
          user.uid,
          name,
          email,
          goal
        );
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

  // Save user data to Firestore
  Future<void> _saveUserData(String userId, String name, String? email, String goal) async {
    await _firestore.collection('users').doc(userId).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
      'goal': goal,
      'profileComplete': false,  // Flag for profile completion status
      'lastWeightUpdate': FieldValue.serverTimestamp()
    });
  }

  // Login with email/password
  Future<User?> loginWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null && !user.emailVerified) {
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'Please verify your email before logging in.',
        );
      }
      
      // Update last login timestamp on successful login
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }
      
      return user;
    } on FirebaseAuthException catch (e) {
      print("Login Failed: ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      print("Login Failed: $e");
      rethrow;
    }
  }

  // Check if email is verified and update verification status if needed
  Future<void> _checkEmailVerification(User? user) async {
    if (user != null) {
      await user.reload();
      user = _auth.currentUser;

      if (user != null) {
        if (user.emailVerified) {
          // User is verified - no need to create new data since we already saved it
          // We could update a verification status field if needed
          await _firestore.collection('users').doc(user.uid).update({
            'emailVerified': true,
          });
          
          // Clean up pending data
          _pendingUserData.remove(user.uid);
        } else {
          await _auth.signOut();
          throw FirebaseAuthException(
            code: 'email-not-verified',
            message: 'Email not verified. Please check your inbox.',
          );
        }
      }
    }
  }

  // Send verification email with cooldown
  Future<void> _sendVerificationWithCooldown(User user) async {
    try {
      await user.sendEmailVerification();
      print("✅ Verification email sent to ${user.email}");
      lastVerificationEmailSent = DateTime.now();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'too-many-requests') {
        throw FirebaseAuthException(
          code: 'verification-cooldown',
          message: 'Please wait before requesting another verification email',
        );
      }
      rethrow;
    }
  }

  // Resend verification email
  Future<void> resendEmailVerification() async {
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        if (lastVerificationEmailSent != null &&
            DateTime.now().difference(lastVerificationEmailSent!) < const Duration(minutes: 5)) {
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

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print("Failed to send password reset email: $e");
      rethrow;
    }
  }

  // Verify password reset code and update password
  Future<void> verifyPasswordResetCode(String code) async {
    try {
      await _auth.verifyPasswordResetCode(code);
    } catch (e) {
      print("Failed to verify reset code: $e");
      rethrow;
    }
  }

  // Confirm password reset
  Future<void> confirmPasswordReset(String code, String newPassword) async {
    try {
      await _auth.confirmPasswordReset(code: code, newPassword: newPassword);
    } catch (e) {
      print("Failed to reset password: $e");
      rethrow;
    }
  }

  // Check if email exists before sending reset email
  Future<void> checkEmailExists(String email) async {
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

  // Get current user data from Firestore
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data();
  }

  // Stream user data
  Stream<Map<String, dynamic>?> get userDataStream {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) return Stream.value(null);
      return _firestore.collection('users').doc(user.uid).snapshots().map(
            (snapshot) => snapshot.data(),
          );
    });
  }

  // Check if email is verified
  Future<bool> isEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  // Check if the user is logged in
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  // Update profile name
  Future<void> updateProfileName(String newName) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'name': newName,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print("Failed to update profile name: $e");
      rethrow;
    }
  }
}