import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class GlassmorphismCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double padding;
  final EdgeInsetsGeometry? customPadding;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Color? borderColor;

  const GlassmorphismCard({
    super.key,
    required this.child,
    this.borderRadius = 12,
    this.padding = 16,
    this.customPadding,
    this.onTap,
    this.gradient,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: customPadding ?? EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? AppColors.surface : null,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? AppColors.glassBorder,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.glassShadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: card,
        ),
      );
    }
    return card;
  }
}
