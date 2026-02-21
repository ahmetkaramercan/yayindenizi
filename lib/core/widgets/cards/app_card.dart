import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../constants/app_constants.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      color: color ?? AppColors.surface,
      elevation: elevation ?? 2,
      margin: margin ?? const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingM,
        vertical: AppConstants.paddingS,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppConstants.paddingM),
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(AppConstants.radiusL),
        child: card,
      );
    }

    return card;
  }
}

