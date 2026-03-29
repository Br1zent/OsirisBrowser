import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PrivacyIndicator extends StatelessWidget {
  final bool isSecure;
  final String? label;
  final bool showLabel;

  const PrivacyIndicator({
    super.key,
    this.isSecure = true,
    this.label,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isSecure ? AppColors.privacyGreen : AppColors.warning,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (isSecure ? AppColors.privacyGreen : AppColors.warning)
                    .withOpacity(0.5),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 6),
          Text(
            label ?? (isSecure ? 'Private' : 'Not Secure'),
            style: TextStyle(
              color: isSecure ? AppColors.privacyGreen : AppColors.warning,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ],
    );
  }
}

class PulsatingDot extends StatefulWidget {
  final Color color;
  final double size;

  const PulsatingDot({super.key, required this.color, this.size = 10});

  @override
  State<PulsatingDot> createState() => _PulsatingDotState();
}

class _PulsatingDotState extends State<PulsatingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(_animation.value * 0.6),
                blurRadius: widget.size * _animation.value,
                spreadRadius: widget.size * 0.1 * _animation.value,
              ),
            ],
          ),
        );
      },
    );
  }
}
