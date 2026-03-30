import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/constants/app_colors.dart';

class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface2,
      highlightColor: AppColors.surface,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class LoadingSkeletonList extends StatelessWidget {
  const LoadingSkeletonList({
    super.key,
    this.itemCount = 3,
    this.itemHeight = 72,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
  });

  final int itemCount;
  final double itemHeight;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        children: List.generate(
          itemCount,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: LoadingSkeleton(
              width: double.infinity,
              height: itemHeight,
            ),
          ),
        ),
      ),
    );
  }
}
