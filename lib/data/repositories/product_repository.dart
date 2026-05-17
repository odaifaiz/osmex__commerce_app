import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../../core/constants/app_constants.dart';

/// Handles all Firestore CRUD operations for the products collection.
/// UI never calls Firestore directly — it goes through this repository.
class ProductRepository {
  final FirebaseFirestore _firestore;

  ProductRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(FirestoreCollections.products);

  // ── Real-time stream ───────────────────────────────────────────────────────

  /// Emits the full product list whenever Firestore changes.
  Stream<List<ProductModel>> productsStream() {
    return _col.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => ProductModel.fromDoc(doc))
              .toList(),
        );
  }

  // ── One-time seed ──────────────────────────────────────────────────────────

  /// Returns true if the products collection already has documents.
  Future<bool> hasProducts() async {
    final snap = await _col.limit(1).get();
    return snap.docs.isNotEmpty;
  }

  /// Fetches products from FakeStoreAPI and batch-writes them to Firestore.
  /// Safe to call multiple times — Firestore set() is idempotent.
  Future<void> seedFromApi() async {
    final response = await http
        .get(Uri.parse('${ApiConfig.baseUrl}${ApiConfig.productsEndpoint}'))
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('FakeStoreAPI returned ${response.statusCode}');
    }

    final List<dynamic> raw = jsonDecode(response.body);
    final products = raw
        .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
        .where((p) => p.id.isNotEmpty)
        .toList();

    // Batch write — max 500 per batch, FakeStore only has 20 items
    final batch = _firestore.batch();
    for (final product in products) {
      final ref = _col.doc(product.id);
      batch.set(ref, product.toMap(), SetOptions(merge: true));
    }
    await batch.commit();
  }

  // ── Distinct categories ───────────────────────────────────────────────────

  /// Returns distinct category strings from all product documents.
  Future<List<String>> fetchCategories() async {
    final snap = await _col.get();
    final categories = snap.docs
        .map((d) => (d.data()['category'] as String?) ?? '')
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return categories;
  }
}
