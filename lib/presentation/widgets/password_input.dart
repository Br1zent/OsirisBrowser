import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

class PasswordInput extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;

  const PasswordInput({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      obscureText: _obscureText,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted != null ? (_) => widget.onSubmitted!() : null,
      style: const TextStyle(
        color: AppColors.white,
        fontSize: 16,
        letterSpacing: 1.2,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        errorText: widget.errorText,
        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.grayLight),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: AppColors.grayMid,
            size: 20,
          ),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'\s')), // No spaces
      ],
    );
  }
}

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({super.key, required this.password});

  int get _strength {
    if (password.isEmpty) return 0;
    int score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) score++;
    return score;
  }

  String get _label {
    final s = _strength;
    if (s <= 1) return 'Weak';
    if (s <= 2) return 'Fair';
    if (s <= 3) return 'Good';
    if (s <= 4) return 'Strong';
    return 'Very Strong';
  }

  Color get _color {
    final s = _strength;
    if (s <= 1) return AppColors.error;
    if (s <= 2) return AppColors.warning;
    if (s <= 3) return const Color(0xFFFFD60A);
    if (s <= 4) return AppColors.success;
    return AppColors.privacyGreen;
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: _strength / 5,
                  backgroundColor: AppColors.anthraciteLight,
                  valueColor: AlwaysStoppedAnimation<Color>(_color),
                  minHeight: 3,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _label,
              style: TextStyle(
                color: _color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
