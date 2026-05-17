import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/custom_button.dart';

class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({super.key});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnim = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Success icon
              AnimatedBuilder(
                animation: _scaleAnim,
                builder: (_, child) =>
                    Transform.scale(scale: _scaleAnim.value, child: child),
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.white,
                    size: 70,
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Text content
              AnimatedBuilder(
                animation: _controller,
                builder: (_, child) => Opacity(
                  opacity: _fadeAnim.value,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnim.value),
                    child: child,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Order Placed!',
                      style: TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Thank you! Your order has\nbeen placed successfully.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Order number
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Order Number',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '#SMB${DateTime.now().millisecondsSinceEpoch % 1000000}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Buttons
              AnimatedBuilder(
                animation: _fadeAnim,
                builder: (_, child) =>
                    Opacity(opacity: _fadeAnim.value, child: child),
                child: Column(
                  children: [
                    CustomButton(
                      label: 'Track Order',
                      isFullWidth: true,
                      height: 54,
                      leading: const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.white,
                        size: 18,
                      ),
                      onPressed: () {},
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      label: 'Back to Home',
                      isFullWidth: true,
                      isOutlined: true,
                      height: 54,
                      onPressed: () {
                        context.read<CartProvider>().clearCart();
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
