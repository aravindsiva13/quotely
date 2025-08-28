
// presentation/widgets/common/custom_button.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

enum ButtonType { primary, secondary, outlined, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingButton();
    }

    switch (type) {
      case ButtonType.primary:
        return _buildElevatedButton();
      case ButtonType.secondary:
        return _buildFilledTonalButton();
      case ButtonType.outlined:
        return _buildOutlinedButton();
      case ButtonType.text:
        return _buildTextButton();
    }
  }

  Widget _buildElevatedButton() {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: AppSizes.buttonHeight,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon ?? const SizedBox.shrink(),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primaryColor,
          foregroundColor: foregroundColor ?? Colors.white,
        ),
      ),
    );
  }

  Widget _buildFilledTonalButton() {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: AppSizes.buttonHeight,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: icon ?? const SizedBox.shrink(),
        label: Text(text),
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primaryLightColor.withOpacity(0.1),
          foregroundColor: foregroundColor ?? AppColors.primaryColor,
        ),
      ),
    );
  }

  Widget _buildOutlinedButton() {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: AppSizes.buttonHeight,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon ?? const SizedBox.shrink(),
        label: Text(text),
        style: OutlinedButton.styleFrom(
          foregroundColor: foregroundColor ?? AppColors.primaryColor,
          side: BorderSide(
            color: backgroundColor ?? AppColors.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildTextButton() {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: AppSizes.buttonHeight,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: icon ?? const SizedBox.shrink(),
        label: Text(text),
        style: TextButton.styleFrom(
          foregroundColor: foregroundColor ?? AppColors.primaryColor,
        ),
      ),
    );
  }

  Widget _buildLoadingButton() {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: AppSizes.buttonHeight,
      child: ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primaryColor,
        ),
        child: const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }
}
