import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/product_model.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../product_detail/product_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<FavoritesProvider, ProductProvider>(
      builder: (context, favorites, productProvider, _) {
        final products = favorites.favoriteProducts(productProvider.products);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, products.length),
                Expanded(
                  child: products.isEmpty
                      ? _buildEmptyState(context)
                      : _buildList(context, products, favorites),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Favorites',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (count > 0)
                Text(
                  '$count item${count == 1 ? '' : 's'} saved',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          const Spacer(),
          if (count > 0)
            GestureDetector(
              onTap: () => context.read<FavoritesProvider>().clear(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Clear all',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
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
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.primaryLight.withValues(alpha: 0.15),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              color: AppColors.primary,
              size: 50,
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'No favorites yet',
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the ♡ on any product\nto save it here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<ProductModel> products,
      FavoritesProvider favorites) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      physics: const BouncingScrollPhysics(),
      itemCount: products.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _FavoriteCard(
        product: products[i],
        onTap: () => Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, animation, _) =>
                ProductDetailScreen(product: products[i]),
            transitionsBuilder: (_, animation, _, child) => FadeTransition(
              opacity: animation,
              child: child,
            ),
            transitionDuration: const Duration(milliseconds: 300),
          ),
        ),
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const _FavoriteCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Product image
            Hero(
              tag: 'fav_${product.id}',
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(20)),
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  width: 110,
                  height: 110,
                  fit: BoxFit.cover,
                  errorWidget: (_, _, _) => Container(
                    width: 110,
                    height: 110,
                    color: AppColors.shimmerBase,
                    child: const Icon(Icons.bakery_dining,
                        color: AppColors.primary, size: 36),
                  ),
                ),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product.hasDiscount)
                      Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '-${product.discountPercent}%',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        if (product.hasDiscount) ...[
                          const SizedBox(width: 6),
                          Text(
                            '\$${product.oldPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Action buttons column
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Remove from favorites
                  Consumer<FavoritesProvider>(
                    builder: (_, favs, _) => GestureDetector(
                      onTap: () => favs.remove(product.id),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: AppColors.primary,
                          size: 17,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Add to cart
                  Consumer<CartProvider>(
                    builder: (_, cart, _) => GestureDetector(
                      onTap: () => cart.addItem(product),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add_shopping_cart_rounded,
                          color: AppColors.white,
                          size: 17,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
