import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';

/// Handles all Firestore operations for per-user favorites.
/// Path: users/{uid}/favorites/{productId}
class FavoritesRepository {
  final FirebaseFirestore _firestore;

  FavoritesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Returns the favorites subcollection reference for a given user.
  CollectionReference<Map<String, dynamic>> _favCol(String uid) => _firestore
      .collection(FirestoreCollections.users)
      .doc(uid)
      .collection(FirestoreCollections.favorites);

  // ── Real-time stream ───────────────────────────────────────────────────────

  /// Emits the set of favorited product IDs whenever Firestore changes.
  Stream<Set<String>> favoritesStream(String uid) {
    return _favCol(uid).snapshots().map(
          (snap) => snap.docs.map((d) => d.id).toSet(),
        );
  }

  // ── Write operations ───────────────────────────────────────────────────────

  /// Adds a product to the user's favorites.
  /// Stores minimal metadata alongside the ID for potential list displays.
  Future<void> addFavorite({
    required String uid,
    required String productId,
    String? productName,
    double? productPrice,
    String? imageUrl,
  }) async {
    await _favCol(uid).doc(productId).set({
      'productId': productId,
      'name': productName ?? '',
      'price': productPrice ?? 0,
      'imageUrl': imageUrl ?? '',
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Removes a product from the user's favorites.
  Future<void> removeFavorite({
    required String uid,
    required String productId,
  }) async {
    await _favCol(uid).doc(productId).delete();
  }

  /// Removes all favorites for a user.
  Future<void> clearAll(String uid) async {
    final snap = await _favCol(uid).get();
    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
