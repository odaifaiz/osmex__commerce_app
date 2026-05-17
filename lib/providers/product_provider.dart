import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/product_model.dart';
import '../data/models/category_model.dart';
import '../data/repositories/product_repository.dart';
// ignore_for_file: unused_import

/// Manages product state using a real-time Firestore stream.
/// Public API is kept identical to the previous offline-first version
/// so all existing screens work without changes.
class ProductProvider extends ChangeNotifier {
  final ProductRepository _repository;

  ProductProvider({ProductRepository? repository})
      : _repository = repository ?? ProductRepository();

  // ── State ──────────────────────────────────────────────────────────────────
  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<ProductModel>>? _subscription;

  // ── Getters ────────────────────────────────────────────────────────────────
  List<ProductModel> get products => _products;
  List<ProductModel> get bestSellers =>
      _products.where((p) => p.isBestSeller).toList();
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ── Initialisation ─────────────────────────────────────────────────────────

  /// Called once from the HomeTab. Seeds products from API if Firestore is
  /// empty, then subscribes to the real-time stream.
  Future<void> loadData() async {
    if (_subscription != null) return; // already subscribed

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Seed on first run
      final hasData = await _repository.hasProducts();
      if (!hasData) {
        await _repository.seedFromApi();
      }

      // Subscribe to real-time stream
      _subscription = _repository.productsStream().listen(
        (products) {
          _products = products;
          _isLoading = false;
          _buildCategories();
          notifyListeners();
        },
        onError: (Object e) {
          _error = 'Failed to load products: $e';
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = 'Failed to initialise products: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Derives category list from the current product list.
  void _buildCategories() {
    final seen = <String>{};
    _categories = _products
        .map((p) => p.categoryId)
        .where((id) => id.isNotEmpty && seen.add(id))
        .map((id) => CategoryModel(
              id: id,
              name: _capitalize(id),
              icon: _iconForCategory(id),
              itemCount: _products.where((p) => p.categoryId == id).length,
            ))
        .toList();
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  IconData _iconForCategory(String name) {
    final n = name.toLowerCase();
    if (n.contains('electronics')) return Icons.devices_rounded;
    if (n.contains('jewelery')) return Icons.diamond_outlined;
    if (n.contains("men's")) return Icons.man_rounded;
    if (n.contains("women's")) return Icons.woman_rounded;
    if (n.contains('clothing')) return Icons.checkroom_rounded;
    return Icons.category_rounded;
  }

  List<ProductModel> getProductsByCategory(String categoryId) {
    if (categoryId.isEmpty || categoryId == 'all') return _products;
    return _products.where((p) => p.categoryId == categoryId).toList();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}