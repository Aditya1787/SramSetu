import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum NeuButtonVariant {
  primary,   // Vibrant red gradient (#D84040 -> #8E1616)
  secondary, // Dark red embossed surface (#1D1616)
  danger,    // Solid warning / urgent action
}

class NeuButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final NeuButtonVariant variant;
  final bool isLoading;
  final Widget? icon;
  final double height;
  final double? width;
  final double borderRadius;

  const NeuButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = NeuButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.height = 56.0,
    this.width,
    this.borderRadius = 18.0,
  });

  @override
  State<NeuButton> createState() => _NeuButtonState();
}

class _NeuButtonState extends State<NeuButton> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = false);
    }
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    List<BoxShadow> shadows;
    Gradient? gradient;
    Color bgColor;
    Border? border;

    if (_isPressed) {
      // Pressed / Inset tactile state
      shadows = [
        BoxShadow(
          color: AppColors.shadowDark.withValues(alpha: 0.9),
          offset: const Offset(2, 2),
          blurRadius: 4,
        ),
        BoxShadow(
          color: AppColors.shadowLight.withValues(alpha: 0.2),
          offset: const Offset(-1, -1),
          blurRadius: 3,
        ),
      ];
    } else {
      // Elevated / Embossed tactile state
      switch (widget.variant) {
        case NeuButtonVariant.primary:
          shadows = [
            const BoxShadow(
              color: AppColors.shadowLight,
              offset: Offset(-4, -4),
              blurRadius: 8,
            ),
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              offset: const Offset(4, 5),
              blurRadius: 14,
              spreadRadius: 1,
            ),
          ];
          break;
        case NeuButtonVariant.secondary:
        case NeuButtonVariant.danger:
          shadows = [
            const BoxShadow(
              color: AppColors.shadowLight,
              offset: Offset(-4, -4),
              blurRadius: 8,
            ),
            const BoxShadow(
              color: AppColors.shadowDark,
              offset: Offset(4, 5),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ];
          break;
      }
    }

    switch (widget.variant) {
      case NeuButtonVariant.primary:
        bgColor = AppColors.primary;
        gradient = _isPressed
            ? const LinearGradient(
                colors: [Color(0xFF8E1616), Color(0xFFC03030)],
              )
            : AppColors.primaryGradient;
        border = Border.all(
          color: AppColors.primary.withValues(alpha: 0.8),
          width: 1.2,
        );
        break;
      case NeuButtonVariant.secondary:
        bgColor = AppColors.surface;
        gradient = _isPressed ? null : AppColors.surfaceGradient;
        border = Border.all(
          color: AppColors.divider,
          width: 1,
        );
        break;
      case NeuButtonVariant.danger:
        bgColor = AppColors.accent;
        gradient = null;
        border = Border.all(
          color: AppColors.accent,
          width: 1,
        );
        break;
    }

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: isEnabled ? widget.onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: widget.width ?? double.infinity,
        height: widget.height,
        decoration: BoxDecoration(
          color: bgColor,
          gradient: gradient,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: border,
          boxShadow: shadows,
        ),
        child: Center(
          child: widget.isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      widget.icon!,
                      const SizedBox(width: 10),
                    ],
                    Text(
                      widget.text,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
