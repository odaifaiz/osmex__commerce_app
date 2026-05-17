import 'package:cloud_firestore/cloud_firestore.dart';

/// Product model supporting both FakeStoreAPI JSON and Firestore documents.
class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double oldPrice;
  final String imageUrl;
  final String categoryId;
  final List<String> tags;
  final bool isBestSeller;
  final int discountPercent;
  // Transient — derived from user's favorites subcollection, not stored per-product
  final bool isFavorite;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.oldPrice,
    required this.imageUrl,
    required this.categoryId,
    this.tags = const [],
    this.isBestSeller = false,
    this.discountPercent = 0,
    this.isFavorite = false,
  });

  // ── Factory: from FakeStoreAPI JSON (used for seeding) ────────────────────
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final price = (json['price'] is num)
        ? (json['price'] as num).toDouble()
        : double.tryParse(json['price']?.toString() ?? '0') ?? 0.0;

    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['title'] ?? json['name'] ?? '',
      description: json['description'] ?? '',
      price: price,
      oldPrice: price * 1.2,
      imageUrl: json['image'] ?? json['imageUrl'] ?? '',
      categoryId: json['category'] ?? json['categoryId'] ?? '',
      tags: [],
      isBestSeller: (json['rating']?['rate'] ?? 0) > 4.0,
      discountPercent: 0,
    );
  }

  // ── Factory: from Firestore DocumentSnapshot ───────────────────────────────
  factory ProductModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      oldPrice: (data['oldPrice'] as num?)?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'] ?? '',
      categoryId: data['category'] ?? data['categoryId'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      isBestSeller: data['isBestSeller'] ?? false,
      discountPercent: (data['discountPercent'] as num?)?.toInt() ?? 0,
    );
  }

  // ── Serialize to Firestore map ────────────────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'oldPrice': oldPrice,
      'imageUrl': imageUrl,
      'category': categoryId,
      'tags': tags,
      'isBestSeller': isBestSeller,
      'discountPercent': discountPercent,
      // isFavorite is per-user, not stored here
    };
  }

  /// Legacy JSON for any components that still call toJson()
  Map<String, dynamic> toJson() => toMap();

  // ── Computed properties ────────────────────────────────────────────────────
  double get discountAmount => oldPrice - price;
  bool get hasDiscount => discountPercent > 0;

  /// Returns a copy with the given fields replaced.
  ProductModel copyWith({bool? isFavorite}) {
    return ProductModel(
      id: id,
      name: name,
      description: description,
      price: price,
      oldPrice: oldPrice,
      imageUrl: imageUrl,
      categoryId: categoryId,
      tags: tags,
      isBestSeller: isBestSeller,
      discountPercent: discountPercent,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
