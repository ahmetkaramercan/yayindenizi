import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

enum AppButtonType { primary, secondary, outline, text, danger }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double? width;
  final double? height;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final buttonWidget = _buildButton(context);

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        height: height ?? 48,
        child: buttonWidget,
      );
    }

    if (width != null || height != null) {
      return SizedBox(
        width: width,
        height: height ?? 48,
        child: buttonWidget,
      );
    }

    return buttonWidget;
  }

  Widget _buildButton(BuildContext context) {
    if (isLoading) {
      return _buildLoadingButton();
    }

    switch (type) {
      case AppButtonType.primary:
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
          ),
          child: _buildButtonContent(),
        );
      case AppButtonType.secondary:
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondaryDark,
            foregroundColor: AppColors.textPrimary,
          ),
          child: _buildButtonContent(),
        );
      case AppButtonType.outline:
        return OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
          ),
          child: _buildButtonContent(),
        );
      case AppButtonType.text:
        return TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
          ),
          child: _buildButtonContent(),
        );
      case AppButtonType.danger:
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.textOnPrimary,
          ),
          child: _buildButtonContent(),
        );
    }
  }

  Widget _buildButtonContent() {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(text, style: AppTextStyles.button),
        ],
      );
    }
    return Text(text, style: AppTextStyles.button);
  }

  Widget _buildLoadingButton() {
    Color? backgroundColor;
    Color? foregroundColor;

    switch (type) {
      case AppButtonType.primary:
        backgroundColor = AppColors.primary;
        foregroundColor = AppColors.textOnPrimary;
        break;
      case AppButtonType.secondary:
        backgroundColor = AppColors.secondaryDark;
        foregroundColor = AppColors.textPrimary;
        break;
      case AppButtonType.outline:
      case AppButtonType.text:
        backgroundColor = Colors.transparent;
        foregroundColor = AppColors.primary;
        break;
      case AppButtonType.danger:
        backgroundColor = AppColors.error;
        foregroundColor = AppColors.textOnPrimary;
        break;
    }

    return ElevatedButton(
      onPressed: null,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
      ),
      child: SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            foregroundColor ?? AppColors.textOnPrimary,
          ),
        ),
      ),
    );
  }
}

