import 'package:flutter/foundation.dart';
import '../data/models/product_model.dart';
import '../data/models/cart_item_model.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItemModel> _items = {};

  Map<String, CartItemModel> get items => Map.unmodifiable(_items);

  List<CartItemModel> get cartList => _items.values.toList();

  int get totalItemsCount =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get deliveryFee => subtotal > 0 ? 1.50 : 0.0;

  double get total => subtotal + deliveryFee;

  int getItemQuantity(String productId) {
    return _items[productId]?.quantity ?? 0;
  }

  bool isInCart(String productId) => _items.containsKey(productId);

  void addItem(ProductModel product, [int quantity = 1]) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity += quantity;
    } else {
      _items[product.id] = CartItemModel(product: product, quantity: quantity);
    }
    notifyListeners();
  }

  void removeItem(ProductModel product) {
    if (!_items.containsKey(product.id)) return;

    if (_items[product.id]!.quantity > 1) {
      _items[product.id]!.quantity--;
    } else {
      _items.remove(product.id);
    }
    notifyListeners();
  }

  void removeItemCompletely(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  void setQuantity(ProductModel product, int quantity) {
    if (quantity <= 0) {
      _items.remove(product.id);
    } else {
      if (_items.containsKey(product.id)) {
        _items[product.id]!.quantity = quantity;
      } else {
        _items[product.id] = CartItemModel(product: product, quantity: quantity);
      }
    }
    notifyListeners();
  }
}
