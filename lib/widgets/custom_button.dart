import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CustomButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final Widget? trailing;
  final bool isFullWidth;
  final bool isOutlined;
  final double? height;
  final double? fontSize;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leading,
    this.trailing,
    this.isFullWidth = false,
    this.isOutlined = false,
    this.height,
    this.fontSize,
    this.padding,
    this.borderRadius,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) => _controller.forward();
  void _onTapUp(TapUpDetails details) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: _buildButton(),
      ),
    );
  }

  Widget _buildButton() {
    if (widget.isOutlined) {
      return Container(
        width: widget.isFullWidth ? double.infinity : null,
        height: widget.height ?? 52,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(30),
          border: Border.all(color: AppColors.primary, width: 2),
          color: Colors.transparent,
        ),
        padding: widget.padding ??
            const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: _buildContent(AppColors.primary),
      );
    }

    return Container(
      width: widget.isFullWidth ? double.infinity : null,
      height: widget.height ?? 52,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: widget.padding ??
          const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: _buildContent(AppColors.white),
    );
  }

  Widget _buildContent(Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.leading != null) ...[
          widget.leading!,
          const SizedBox(width: 8),
        ],
        Text(
          widget.label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: widget.fontSize ?? 15,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        if (widget.trailing != null) ...[
          const SizedBox(width: 8),
          widget.trailing!,
        ],
      ],
    );
  }
}
