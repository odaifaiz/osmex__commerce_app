import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum SnackBarType { success, error, info, warning }

/// Shows a styled snack bar. Call from any widget via:
///   AppSnackBar.show(context, 'Message', type: SnackBarType.success);
class AppSnackBar {
  static void show(
    BuildContext context,
    String message, {
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final (color, icon) = switch (type) {
      SnackBarType.success => (AppColors.success, Icons.check_circle_rounded),
      SnackBarType.error   => (AppColors.error, Icons.error_rounded),
      SnackBarType.warning => (AppColors.warning, Icons.warning_rounded),
      SnackBarType.info    => (AppColors.primary, Icons.info_rounded),
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.textPrimary,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}
