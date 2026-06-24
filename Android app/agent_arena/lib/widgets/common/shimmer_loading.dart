import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/colors.dart';

class ShimmerLoading extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const ShimmerLoading({super.key, this.itemCount = 3, this.itemHeight = 80});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.cardBackground,
      highlightColor: AppColors.surfaceLight,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            height: itemHeight,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}
