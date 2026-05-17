import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/product_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HeroBanner extends StatelessWidget {
  final ProductModel featuredProduct;
  final VoidCallback onOrderNow;

  const HeroBanner({
    super.key,
    required this.featuredProduct,
    required this.onOrderNow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      height: 180,
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            
            right: -10,
            bottom: -10,
            child: SizedBox(
              width: 220,
              height: 220,
              child: Opacity(
                opacity: 0.85,
                child: Hero(
                  tag: 'hero_${featuredProduct.id}',
                  child: CachedNetworkImage(
                    imageUrl: featuredProduct.imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Freshly baked \n with trusted quality',
                  
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Crafted with trusted quality',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.white.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: onOrderNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: AppColors.white,
                      elevation: 1,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'Order Now',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
