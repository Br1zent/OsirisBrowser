import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blurSigma;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final List<BoxShadow>? shadows;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.blurSigma = 10,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.onTap,
    this.onLongPress,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final card = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? Colors.white.withOpacity(0.1),
              width: borderWidth,
            ),
            boxShadow: shadows,
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null || onLongPress != null) {
      return Container(
        margin: margin,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(borderRadius),
            splashColor: AppColors.whiteAlpha10,
            highlightColor: AppColors.whiteAlpha05,
            child: card,
          ),
        ),
      );
    }

    return Container(margin: margin, child: card);
  }
}

class GlassButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? width;
  final double? height;

  const GlassButton({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    this.borderRadius = 12,
    this.backgroundColor,
    this.borderColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: padding,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      width: width,
      height: height,
      onTap: onTap,
      child: Center(child: child),
    );
  }
}

class AnimatedGlassCard extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final Duration animationDuration;

  const AnimatedGlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 150),
  });

  @override
  State<AnimatedGlassCard> createState() => _AnimatedGlassCardState();
}

class _AnimatedGlassCardState extends State<AnimatedGlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GlassCard(
          width: widget.width,
          height: widget.height,
          padding: widget.padding,
          margin: widget.margin,
          borderRadius: widget.borderRadius,
          child: widget.child,
        ),
      ),
    );
  }
}
