import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Auth wrapper with user-friendly error messages.
class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> register({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  bool get hasValidSession => _auth.currentUser != null;

  String mapException(Object error) {
    if (error is String) return error;
    if (error is FirebaseAuthException) return _mapError(error);
    return 'Something went wrong. Please try again.';
  }

  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account with this email already exists. Try logging in.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'invalid-credential':
        return 'Incorrect email or password. Please try again.';
      case 'network-request-failed':
        return 'Check your internet connection and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
