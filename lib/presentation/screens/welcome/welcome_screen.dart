import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/security/master_password_service.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/osiris_logo.dart';
import '../../widgets/password_input.dart';

enum WelcomeMode { landing, setup, unlock }

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _passwordFocus = FocusNode();

  WelcomeMode _mode = WelcomeMode.landing;
  String? _passwordError;
  String? _confirmError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();

    _checkPasswordStatus();
  }

  Future<void> _checkPasswordStatus() async {
    final isSet = await MasterPasswordService.instance.isMasterPasswordSet();
    if (mounted) {
      setState(() {
        _mode = isSet ? WelcomeMode.unlock : WelcomeMode.setup;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _handleSetup() async {
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    setState(() {
      _passwordError = null;
      _confirmError = null;
    });

    if (!MasterPasswordService.instance.isPasswordValid(password)) {
      setState(() {
        _passwordError =
            'Password must be ${AppConstants.minPasswordLength}–${AppConstants.maxPasswordLength} characters';
      });
      return;
    }

    if (password != confirm) {
      setState(() => _confirmError = 'Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);
    context.read<AuthBloc>().add(AuthSetupPassword(password));
  }

  void _handleUnlock() {
    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      setState(() => _passwordError = 'Enter your password');
      return;
    }
    setState(() => _isLoading = true);
    context.read<AuthBloc>().add(AuthVerifyPassword(password));
  }

  Future<void> _handleReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.anthracite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset App',
            style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w700)),
        content: const Text(
          'All browsing data, bookmarks and history will be permanently deleted. This cannot be undone.',
          style: TextStyle(color: AppColors.grayLight, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.grayMid)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset',
                style: TextStyle(
                    color: AppColors.nukeRed, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await MasterPasswordService.instance.deleteAllCredentials();
      setState(() {
        _mode = WelcomeMode.setup;
        _passwordController.clear();
        _passwordError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          context.go('/home');
        } else if (state.status == AuthStatus.error) {
          setState(() {
            _isLoading = false;
            _passwordError = state.errorMessage;
          });
        } else if (state.status != AuthStatus.loading) {
          setState(() => _isLoading = false);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: Stack(
          children: [
            // Background gradient orbs
            _buildBackgroundOrbs(),

            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        _buildLogo(),
                        const SizedBox(height: 32),
                        _buildTitle(),
                        const SizedBox(height: 48),
                        if (_mode == WelcomeMode.setup) _buildSetupForm(),
                        if (_mode == WelcomeMode.unlock) _buildUnlockForm(),
                        if (_mode == WelcomeMode.landing)
                          const CircularProgressIndicator(
                            color: AppColors.accent,
                          ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundOrbs() {
    return Stack(
      children: [
        // Top-right orb
        Positioned(
          top: -100,
          right: -80,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accent.withOpacity(0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Bottom-left orb
        Positioned(
          bottom: -80,
          left: -60,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accentPurple.withOpacity(0.06),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        const OsirisLogo(size: 100),
        const SizedBox(height: 20),
        // Encryption badge
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          borderRadius: 20,
          backgroundColor: AppColors.accentSoft,
          borderColor: AppColors.accent.withOpacity(0.3),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield, color: AppColors.accent, size: 12),
              SizedBox(width: 6),
              Text(
                'AES-256 ENCRYPTED',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    final isSetup = _mode == WelcomeMode.setup;
    return Column(
      children: [
        Text(
          isSetup ? 'Create Your Key' : 'Welcome Back',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          isSetup
              ? 'Set a master password to encrypt and protect all your browsing data.'
              : 'Enter your master password to unlock Osiris.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.grayLight,
                height: 1.5,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSetupForm() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PasswordInput(
            controller: _passwordController,
            label: 'Master Password',
            hint: 'Enter a strong password',
            errorText: _passwordError,
            autofocus: true,
            onChanged: (_) => setState(() => _passwordError = null),
          ),
          PasswordStrengthIndicator(password: _passwordController.text),
          const SizedBox(height: 16),
          PasswordInput(
            controller: _confirmController,
            label: 'Confirm Password',
            hint: 'Repeat your password',
            errorText: _confirmError,
            onChanged: (_) => setState(() => _confirmError = null),
            onSubmitted: _handleSetup,
          ),
          const SizedBox(height: 8),
          _buildPasswordHints(),
          const SizedBox(height: 24),
          _buildPrimaryButton(
            label: 'Encrypt & Begin',
            icon: Icons.lock,
            onPressed: _isLoading ? null : _handleSetup,
          ),
        ],
      ),
    );
  }

  Widget _buildUnlockForm() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PasswordInput(
            controller: _passwordController,
            label: 'Master Password',
            hint: 'Enter your password',
            errorText: _passwordError,
            autofocus: true,
            focusNode: _passwordFocus,
            onChanged: (_) => setState(() => _passwordError = null),
            onSubmitted: _handleUnlock,
          ),
          const SizedBox(height: 24),
          _buildPrimaryButton(
            label: 'Unlock',
            icon: Icons.lock_open,
            onPressed: _isLoading ? null : _handleUnlock,
          ),
          const SizedBox(height: 12),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (!state.biometricAvailable) return const SizedBox.shrink();
              return TextButton.icon(
                onPressed: () =>
                    context.read<AuthBloc>().add(const AuthBiometricLogin()),
                icon: const Icon(Icons.fingerprint, size: 20),
                label: const Text('Use Biometrics'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.accent,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _handleReset,
            child: const Text(
              'Forgot password? Reset app',
              style: TextStyle(color: AppColors.grayMid, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordHints() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.whiteAlpha05,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.whiteAlpha10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Password Requirements',
            style: TextStyle(
              color: AppColors.grayLight,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          _buildHint('At least ${AppConstants.minPasswordLength} characters'),
          _buildHint('Mix letters, numbers & symbols for strength'),
          _buildHint('This password cannot be recovered if lost'),
        ],
      ),
    );
  }

  Widget _buildHint(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 4, color: AppColors.grayMid),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(color: AppColors.grayMid, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: _isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.black,
                ),
              )
            : Icon(icon, size: 18),
        label: Text(_isLoading ? 'Processing...' : label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
