import 'product_model.dart';

class CartItemModel {
  final ProductModel product;
  int quantity;

  CartItemModel({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;

  CartItemModel copyWith({int? quantity}) {
    return CartItemModel(
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }
}
