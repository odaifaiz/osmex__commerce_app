import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/auth_service.dart';

/// State management for authentication.
/// Wraps [AuthService] and exposes reactive state to the UI.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService();

  // ── State ──────────────────────────────────────────────────────────────────
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  User? get currentUser => _authService.currentUser;
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  // ── Actions ────────────────────────────────────────────────────────────────

  /// Creates a new Firebase account and stores profile in Firestore.
  /// Returns true on success, false on failure.
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      await _authService.signUp(name: name, email: email, password: password);
      _clearError();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_authService.getErrorMessage(e));
      return false;
    } catch (e) {
      _setError('Unexpected error. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Signs the user in with email/password.
  /// Returns true on success, false on failure.
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      await _authService.signIn(email: email, password: password);
      _clearError();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_authService.getErrorMessage(e));
      return false;
    } catch (e) {
      _setError('Unexpected error. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Signs the current user out.
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _clearError();
    } catch (e) {
      _setError('Failed to sign out. Please try again.');
    } finally {
      _setLoading(false);
    }
  }

  /// Clears any displayed error message.
  void clearError() => _clearError();

  // ── Private helpers ────────────────────────────────────────────────────────
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
