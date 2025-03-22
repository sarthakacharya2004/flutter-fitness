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