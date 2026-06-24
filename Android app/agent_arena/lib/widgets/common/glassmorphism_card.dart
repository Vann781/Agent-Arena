import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class GlassmorphismCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double padding;
  final EdgeInsetsGeometry? customPadding;
  final VoidCallback? onTap;
  final Gradient? gradient;

  const GlassmorphismCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding = 16,
    this.customPadding,
    this.onTap,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: customPadding ?? EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient:
            gradient ??
            LinearGradient(
              colors: [
                AppColors.glassBackground,
                AppColors.glassBackground.withValues(alpha: 0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.glassBorder),
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
