import 'package:flutter/material.dart';

class OsirisLogo extends StatefulWidget {
  final double size;
  final bool animate;

  const OsirisLogo({super.key, this.size = 80, this.animate = true});

  @override
  State<OsirisLogo> createState() => _OsirisLogoState();
}

class _OsirisLogoState extends State<OsirisLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Animated glow behind logo
              if (widget.animate)
                Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary.withOpacity(0.22),
                          Theme.of(context).colorScheme.primary.withOpacity(0.06),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),

              // Actual logo image
              ClipOval(
                child: Image.asset(
                  'assets/icons/osiris_logo.png',
                  width: widget.size * 0.88,
                  height: widget.size * 0.88,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
