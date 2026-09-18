import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum NeuDepthType {
  convex,  // Raised / Embossed with outer dual shadows
  flat,    // Subtle outer elevation
  sunken,  // Inset / Sunken effect for text inputs
  accent,  // Glowing red highlight
}

class NeuContainer extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final NeuDepthType depthType;
  final Color? baseColor;
  final Border? border;
  final BoxShape shape;
  final VoidCallback? onTap;

  const NeuContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 18.0,
    this.depthType = NeuDepthType.convex,
    this.baseColor,
    this.border,
    this.shape = BoxShape.rectangle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = baseColor ?? AppColors.surface;

    List<BoxShadow> shadows;
    Gradient? gradient;

    switch (depthType) {
      case NeuDepthType.convex:
        shadows = [
          const BoxShadow(
            color: AppColors.shadowLight,
            offset: Offset(-5, -5),
            blurRadius: 10,
            spreadRadius: 0,
          ),
          const BoxShadow(
            color: AppColors.shadowDark,
            offset: Offset(5, 5),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ];
        gradient = AppColors.surfaceGradient;
        break;

      case NeuDepthType.flat:
        shadows = [
          const BoxShadow(
            color: AppColors.shadowLight,
            offset: Offset(-3, -3),
            blurRadius: 7,
          ),
          const BoxShadow(
            color: AppColors.shadowDark,
            offset: Offset(3, 3),
            blurRadius: 7,
          ),
        ];
        gradient = null;
        break;

      case NeuDepthType.sunken:
        // Simulated inset/sunken depth
        shadows = [
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: 0.9),
            offset: const Offset(3, 3),
            blurRadius: 5,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: AppColors.shadowLight.withValues(alpha: 0.25),
            offset: const Offset(-2, -2),
            blurRadius: 4,
          ),
        ];
        gradient = AppColors.sunkenGradient;
        break;

      case NeuDepthType.accent:
        shadows = [
          const BoxShadow(
            color: AppColors.shadowLight,
            offset: Offset(-4, -4),
            blurRadius: 8,
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            offset: const Offset(4, 4),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ];
        gradient = AppColors.primaryGradient;
        break;
    }

    Widget container = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveColor,
        gradient: gradient,
        shape: shape,
        borderRadius: shape == BoxShape.rectangle ? BorderRadius.circular(borderRadius) : null,
        border: border ??
            Border.all(
              color: depthType == NeuDepthType.accent
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : AppColors.divider.withValues(alpha: 0.35),
              width: 1,
            ),
        boxShadow: shadows,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: container,
      );
    }

    return container;
  }
}
