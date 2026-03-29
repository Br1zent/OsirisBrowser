import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.anthracite,
      highlightColor: AppColors.anthraciteLight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.anthracite,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ShimmerCard extends StatelessWidget {
  final double height;

  const ShimmerCard({super.key, this.height = 80});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.anthracite,
      highlightColor: AppColors.anthraciteLight,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.anthracite,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.anthraciteLight,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    color: AppColors.anthraciteLight,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 10,
                    width: 120,
                    color: AppColors.anthraciteLight,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
