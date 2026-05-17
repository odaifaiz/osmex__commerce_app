import 'package:cloud_firestore/cloud_firestore.dart';

/// Thin wrapper around FirebaseFirestore providing typed collection references
/// and shared error handling. Repositories use this instead of calling
/// FirebaseFirestore.instance directly.
class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance {
    // Enable offline persistence (Firestore handles this automatically on
    // mobile; this call configures it explicitly for reliability).
    _db.settings = const Settings(persistenceEnabled: true);
  }

  /// Returns a reference to a top-level collection.
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      _db.collection(path);

  /// Returns a reference to a document.
  DocumentReference<Map<String, dynamic>> doc(String path) => _db.doc(path);

  /// Runs a batched write — useful for seeding or multi-document updates.
  WriteBatch batch() => _db.batch();

  /// Exposes the raw Firestore instance when needed.
  FirebaseFirestore get instance => _db;
}
