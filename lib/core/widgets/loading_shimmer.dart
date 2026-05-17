import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';

/// Reusable shimmer skeleton for product cards in a 2-column grid.
class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Expanded(
              flex: 3,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.shimmerBase,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                ),
              ),
            ),
            // Text placeholders
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ShimmerBox(width: double.infinity, height: 12),
                    _ShimmerBox(width: 90, height: 10),
                    _ShimmerBox(width: 60, height: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grid of product card shimmer placeholders.
class ProductGridShimmer extends StatelessWidget {
  final int count;
  const ProductGridShimmer({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 14,
          childAspectRatio: 0.72,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, _) => const ProductCardShimmer(),
          childCount: count,
        ),
      ),
    );
  }
}

/// Shimmer for a list row (used in favorites / cart).
class ListRowShimmer extends StatelessWidget {
  const ListRowShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 110,
              decoration: const BoxDecoration(
                color: AppColors.shimmerBase,
                borderRadius:
                    BorderRadius.horizontal(left: Radius.circular(20)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _ShimmerBox(width: double.infinity, height: 12),
                  SizedBox(height: 8),
                  _ShimmerBox(width: 120, height: 10),
                  SizedBox(height: 8),
                  _ShimmerBox(width: 70, height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  const _ShimmerBox({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.shimmerBase,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
