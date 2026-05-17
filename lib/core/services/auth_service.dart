import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Wraps FirebaseAuth — all auth logic lives here, never in UI widgets.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Streams / Getters ──────────────────────────────────────────────────────

  /// Real-time stream of auth state changes (User or null).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Currently signed-in user (null if signed out).
  User? get currentUser => _auth.currentUser;

  // ── Authentication ─────────────────────────────────────────────────────────

  /// Creates a new account and stores the user profile in Firestore.
  Future<UserCredential> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // Set the display name immediately
    await credential.user?.updateDisplayName(name.trim());

    // Persist additional user data in Firestore
    await _firestore
        .collection('users')
        .doc(credential.user!.uid)
        .set({
      'uid': credential.user!.uid,
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return credential;
  }

  /// Signs in with email and password.
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Signs the current user out.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ── Error Handling ─────────────────────────────────────────────────────────

  /// Converts a [FirebaseAuthException] into a user-friendly message.
  String getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection and retry.';
      case 'invalid-credential':
        return 'Invalid email or password. Please try again.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
