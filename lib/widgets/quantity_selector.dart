import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(
            icon: Icons.remove_rounded,
            onTap: onDecrement,
            isEnabled: quantity > 1,
          ),
          const SizedBox(width: 12),
          Text(
            quantity.toString(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          _buildButton(
            icon: Icons.add_rounded,
            onTap: onIncrement,
            isEnabled: true,
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isEnabled,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isEnabled ? AppColors.surfaceColor : AppColors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16,
          color: isEnabled ? AppColors.primary : AppColors.textTertiary,
        ),
      ),
    );
  }
}
