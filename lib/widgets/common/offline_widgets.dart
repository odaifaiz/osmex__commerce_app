import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

// Note: ConnectivityStatus and DataState (Hive/Dio era) have been removed.
// Offline support is now handled by Cloud Firestore's built-in persistence.

/// Offline mode banner shown when the device loses connectivity.
class OfflineBanner extends StatefulWidget {
  final bool isOffline;
  final DateTime? lastUpdated;
  final VoidCallback? onRetry;

  const OfflineBanner({
    super.key,
    required this.isOffline,
    this.lastUpdated,
    this.onRetry,
  });

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    if (widget.isOffline) _controller.forward();
  }

  @override
  void didUpdateWidget(OfflineBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOffline && !oldWidget.isOffline) {
      _controller.forward();
    } else if (!widget.isOffline && oldWidget.isOffline) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatLastUpdated() {
    if (widget.lastUpdated == null) return '';
    final diff = DateTime.now().difference(widget.lastUpdated!);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.warning.withValues(alpha: 0.95),
                AppColors.warning.withValues(alpha: 0.85),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.warning.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.wifi_off_rounded,
                      color: AppColors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Offline Mode',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white)),
                      if (widget.lastUpdated != null)
                        Text(
                          'Last updated: ${_formatLastUpdated()}',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.white.withValues(alpha: 0.8)),
                        ),
                    ],
                  ),
                ),
                if (widget.onRetry != null)
                  GestureDetector(
                    onTap: widget.onRetry,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.refresh_rounded,
                              size: 14, color: AppColors.warning),
                          const SizedBox(width: 4),
                          const Text('Retry',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.warning)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated shimmer loading placeholder.
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, _) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            begin: Alignment(_animation.value - 1, 0),
            end: Alignment(_animation.value, 0),
            colors: const [
              AppColors.shimmerBase,
              AppColors.shimmerHighlight,
              AppColors.shimmerBase,
            ],
          ),
        ),
      ),
    );
  }
}

/// Product card loading skeleton.
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLoading(height: 140, borderRadius: 20),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoading(height: 14, borderRadius: 4),
                SizedBox(height: 8),
                ShimmerLoading(height: 16, borderRadius: 4),
                SizedBox(height: 8),
                ShimmerLoading(height: 14, borderRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Generic empty-state widget.
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.primaryLight.withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 56),
            ),
            const SizedBox(height: 24),
            Text(title,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                textAlign: TextAlign.center),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Generic error-state widget.
class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorStateWidget({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded,
                  color: AppColors.error, size: 48),
            ),
            const SizedBox(height: 20),
            const Text('Oops! Something went wrong',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Loading indicator widget with optional message.
class LoadingWidget extends StatelessWidget {
  final String? message;
  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
              strokeWidth: 3, color: AppColors.primary),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}

/// Simple error display with optional retry.
class ErrorStateDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const ErrorStateDisplay({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded,
                  color: AppColors.error, size: 40),
            ),
            const SizedBox(height: 16),
            Text(message,
                style: const TextStyle(
                    fontSize: 16, color: AppColors.textPrimary),
                textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Pull-to-refresh wrapper widget.
class OfflineRefreshIndicator extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final bool isRefreshing;
  final Widget child;

  const OfflineRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.isRefreshing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      child: child,
    );
  }
}

/// Displays a human-readable "last updated" timestamp.
class LastUpdatedText extends StatelessWidget {
  final DateTime? lastUpdated;
  const LastUpdatedText({super.key, this.lastUpdated});

  String _format() {
    if (lastUpdated == null) return 'Never';
    final diff = DateTime.now().difference(lastUpdated!);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.access_time_rounded,
            size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text('Updated: ${_format()}',
            style: const TextStyle(
                fontSize: 12, color: AppColors.textTertiary)),
      ],
    );
  }
}