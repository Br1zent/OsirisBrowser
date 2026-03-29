import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class NukeCountdownOverlay extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onCancel;

  const NukeCountdownOverlay({
    super.key,
    required this.onComplete,
    required this.onCancel,
  });

  @override
  State<NukeCountdownOverlay> createState() => _NukeCountdownOverlayState();
}

class _NukeCountdownOverlayState extends State<NukeCountdownOverlay>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  int _countdown = 3;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.linear),
    );

    _progressController.forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _countdown--);
      if (_countdown <= 0) {
        timer.cancel();
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        color: Colors.black87,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Countdown circle
              SizedBox(
                width: 150,
                height: 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return CircularProgressIndicator(
                          value: _progressAnimation.value,
                          strokeWidth: 4,
                          backgroundColor: AppColors.anthraciteLight,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.nukeRed),
                        );
                      },
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.warning_rounded,
                            color: AppColors.nukeRed, size: 36),
                        const SizedBox(height: 4),
                        Text(
                          '$_countdown',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'NUKING IN...',
                style: TextStyle(
                  color: AppColors.nukeRed,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3.0,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'All traces are being permanently erased',
                style: TextStyle(color: AppColors.grayLight, fontSize: 13),
              ),
              const SizedBox(height: 32),
              OutlinedButton(
                onPressed: () {
                  _timer?.cancel();
                  _progressController.stop();
                  widget.onCancel();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.white,
                  side: const BorderSide(color: AppColors.grayMid),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
