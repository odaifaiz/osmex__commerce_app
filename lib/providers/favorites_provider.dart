import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/models/product_model.dart';
import '../data/repositories/favorites_repository.dart';

/// Cloud-backed favorites provider.
///
/// Replaces the previous Hive-based implementation.
/// Keeps the same public surface (isFavorite, toggle, remove, clear, count)
/// so all existing screens (FavoritesScreen, ProductCard, etc.) work unchanged.
///
/// Usage:
///   • Call [setUser] after login with the Firebase UID.
///   • Call [setUser(null)] after logout.
class FavoritesProvider extends ChangeNotifier {
  final FavoritesRepository _repository;

  FavoritesProvider({FavoritesRepository? repository})
      : _repository = repository ?? FavoritesRepository();

  // ── State ──────────────────────────────────────────────────────────────────
  Set<String> _favoriteIds = {};
  String? _uid;
  StreamSubscription<Set<String>>? _subscription;
  bool _isLoading = false;

  // ── Getters ────────────────────────────────────────────────────────────────
  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);
  bool get isLoading => _isLoading;
  int get count => _favoriteIds.length;

  bool isFavorite(String productId) => _favoriteIds.contains(productId);

  List<ProductModel> favoriteProducts(List<ProductModel> allProducts) =>
      allProducts.where((p) => _favoriteIds.contains(p.id)).toList();

  // ── Auth wiring ────────────────────────────────────────────────────────────

  /// Called when a user signs in. Subscribes to their Firestore favorites.
  /// Called with [null] on sign-out to cancel the subscription and clear state.
  void setUser(String? uid) {
    if (_uid == uid) return; // no change
    _uid = uid;

    // Cancel any previous subscription
    _subscription?.cancel();
    _subscription = null;
    _favoriteIds = {};

    if (uid == null) {
      notifyListeners();
      return;
    }

    // Subscribe to real-time favorites for this user
    _isLoading = true;
    notifyListeners();

    _subscription = _repository.favoritesStream(uid).listen(
      (ids) {
        _favoriteIds = ids;
        _isLoading = false;
        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  /// Toggles the favorite state for [product]. Optimistic UI update.
  Future<void> toggle(ProductModel product) async {
    if (_uid == null) return;

    final wasAdded = _favoriteIds.contains(product.id);

    // Optimistic update
    if (wasAdded) {
      _favoriteIds = Set.from(_favoriteIds)..remove(product.id);
    } else {
      _favoriteIds = Set.from(_favoriteIds)..add(product.id);
    }
    notifyListeners();

    // Persist to Firestore
    try {
      if (wasAdded) {
        await _repository.removeFavorite(uid: _uid!, productId: product.id);
      } else {
        await _repository.addFavorite(
          uid: _uid!,
          productId: product.id,
          productName: product.name,
          productPrice: product.price,
          imageUrl: product.imageUrl,
        );
      }
    } catch (_) {
      // Roll back on failure
      if (wasAdded) {
        _favoriteIds = Set.from(_favoriteIds)..add(product.id);
      } else {
        _favoriteIds = Set.from(_favoriteIds)..remove(product.id);
      }
      notifyListeners();
    }
  }

  /// Removes a single product from favorites.
  Future<void> remove(String productId) async {
    if (_uid == null) return;

    _favoriteIds = Set.from(_favoriteIds)..remove(productId);
    notifyListeners();

    try {
      await _repository.removeFavorite(uid: _uid!, productId: productId);
    } catch (_) {
      _favoriteIds = Set.from(_favoriteIds)..add(productId);
      notifyListeners();
    }
  }

  /// Clears all favorites for the current user.
  Future<void> clear() async {
    if (_uid == null) return;

    final backup = Set<String>.from(_favoriteIds);
    _favoriteIds = {};
    notifyListeners();

    try {
      await _repository.clearAll(_uid!);
    } catch (_) {
      _favoriteIds = backup;
      notifyListeners();
    }
  }

  // ── Legacy compatibility (called by main.dart previously) ─────────────────
  Future<void> initialize() async {
    // No-op: initialization now happens via setUser() after Firebase auth.
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
