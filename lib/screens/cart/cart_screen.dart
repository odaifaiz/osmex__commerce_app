import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/cart_provider.dart';
import '../../data/models/cart_item_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../widgets/quantity_selector.dart';
import '../checkout/order_success_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Consumer<CartProvider>(
              builder: (context, cart, _) {
                if (cart.items.isEmpty) {
                  return _buildEmptyState(context);
                }
                return Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        itemCount: cart.items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 16),
                        itemBuilder: (context, i) => _CartItem(
                          item: cart.items.values.toList()[i],
                          productId: cart.items.keys.toList()[i],
                        ),
                      ),
                    ),
                    _buildSummary(context, cart),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {}, // Handled by bottom nav in real app, or leave disabled
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            color: AppColors.textPrimary,
          ),
          const Text(
            'Your Cart',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<CartProvider>().clearCart();
            },
            child: const Text(
              'Clear',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 80, color: AppColors.textSecondary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Looks like you haven\'t added\nany pastries yet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context, CartProvider cart) {
    const deliveryFee = 1.50;
    final total = cart.subtotal + deliveryFee;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 110), // extra padding for nav bar
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              Text('\$${cart.subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Delivery Fee',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const Text('\$1.50',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: AppColors.divider),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              Text('\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                context.read<CartProvider>().clearCart();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OrderSuccessScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Checkout', style: TextStyle(fontSize: 16)),
                  Text('\$${total.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItem extends StatelessWidget {
  final CartItemModel item;
  final String productId;

  const _CartItem({required this.item, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CachedNetworkImage(
            imageUrl: item.product.imageUrl,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: AppColors.shimmerBase),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${item.product.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  QuantitySelector(
                    quantity: item.quantity,
                    onIncrement: () {
                      context.read<CartProvider>().setQuantity(item.product, item.quantity + 1);
                    },
                    onDecrement: () {
                      if (item.quantity > 1) {
                        context.read<CartProvider>().setQuantity(item.product, item.quantity - 1);
                      } else {
                        context.read<CartProvider>().removeItem(item.product);
                      }
                    },
                  ),
                  Text(
                    '\$${(item.totalPrice).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
