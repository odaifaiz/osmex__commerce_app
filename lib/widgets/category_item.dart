import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/category_model.dart';

class CategoryItem extends StatefulWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryItem({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
  });

  @override
  State<CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
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
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: SizedBox(
          width: 72,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: widget.isSelected
                      ? AppColors.primaryGradient
                      : null,
                  color: widget.isSelected ? null : AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: widget.isSelected
                          ? AppColors.primary.withOpacity(0.3)
                          : Colors.black.withOpacity(0.06),
                      blurRadius: widget.isSelected ? 12 : 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  widget.category.icon,
                  color: widget.isSelected
                      ? AppColors.white
                      : AppColors.primary,
                  size: 26,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.category.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: widget.isSelected
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: widget.isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
