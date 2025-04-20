// Phone Sign In - Step 1: Send OTP
Future<void> verifyPhoneNumber({
  required String phoneNumber,
  required void Function(PhoneAuthCredential) onVerificationCompleted,
  required void Function(FirebaseAuthException) onVerificationFailed,
  required void Function(String, int?) onCodeSent,
  required void Function(String) onCodeAutoRetrievalTimeout,
}) async {
  await _auth.verifyPhoneNumber(
    phoneNumber: phoneNumber,
    verificationCompleted: onVerificationCompleted,
    verificationFailed: onVerificationFailed,
    codeSent: onCodeSent,
    codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
    timeout: const Duration(seconds: 60),
  );
}

// Phone Sign In - Step 2: Sign in using SMS code
Future<UserCredential> signInWithSmsCode({
  required String verificationId,
  required String smsCode,
}) async {
  try {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return await _auth.signInWithCredential(credential);
  } catch (e) {
    print("Phone sign-in failed: $e");
    rethrow;
  }
}
