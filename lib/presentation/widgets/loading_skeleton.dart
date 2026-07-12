import 'package:flutter/material.dart';

import '../../core/theme/app_design_tokens.dart';

class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({
    this.itemCount = 4,
    super.key,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = colorScheme.surfaceContainerHighest;
    final highlightColor = colorScheme.surfaceContainerHigh;

    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = responsivePagePadding(constraints);
        return ListView.separated(
          padding: EdgeInsets.fromLTRB(
            padding.left,
            AppSpacing.md,
            padding.right,
            padding.bottom,
          ),
          itemCount: itemCount,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            return DecoratedBox(
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: AppRadii.card,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    _SkeletonBlock(
                      width: 48,
                      height: 48,
                      color: highlightColor,
                      radius: AppRadii.pill,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SkeletonBlock(
                            width: double.infinity,
                            height: 16,
                            color: highlightColor,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          _SkeletonBlock(
                            width: 140,
                            height: 12,
                            color: highlightColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({
    required this.width,
    required this.height,
    required this.color,
    this.radius,
  });

  final double width;
  final double height;
  final Color color;
  final BorderRadius? radius;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppDurations.emphasized,
      curve: AppCurves.emphasized,
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: radius ?? AppRadii.card,
      ),
    );
  }
}
