import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/security/encryption_service.dart';
import '../../../domain/entities/privacy_settings.dart';
import '../../bloc/privacy/privacy_bloc.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/privacy_indicator.dart';

class PrivacyHubScreen extends StatefulWidget {
  const PrivacyHubScreen({super.key});

  @override
  State<PrivacyHubScreen> createState() => _PrivacyHubScreenState();
}

class _PrivacyHubScreenState extends State<PrivacyHubScreen>
    with TickerProviderStateMixin {
  late AnimationController _nukeController;
  late AnimationController _nukeGlowController;
  late Animation<double> _nukePulse;
  late Animation<double> _nukeGlow;

  @override
  void initState() {
    super.initState();

    _nukeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _nukeGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _nukePulse = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _nukeController, curve: Curves.easeInOut),
    );

    _nukeGlow = Tween<double>(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(parent: _nukeGlowController, curve: Curves.easeInOut),
    );

    context.read<PrivacyBloc>().add(const PrivacyLoadSettings());
  }

  @override
  void dispose() {
    _nukeController.dispose();
    _nukeGlowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: BlocConsumer<PrivacyBloc, PrivacyState>(
                    listener: (context, state) {
                      if (state.status == PrivacyStatus.nuked) {
                        final s = AppStrings.of(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded,
                                    color: AppColors.nukeRed, size: 18),
                                const SizedBox(width: 8),
                                Text(s.allTracesWiped,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                            backgroundColor: AppColors.anthracite,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            const SizedBox(height: 24),
                            _buildNukeButton(context, state),
                            const SizedBox(height: 32),
                            _buildEncryptionStatus(),
                            const SizedBox(height: 20),
                            _buildFingerprintSection(context, state),
                            const SizedBox(height: 20),
                            _buildNetworkSection(context, state),
                            const SizedBox(height: 20),
                            _buildBrowsingSection(context, state),
                            const SizedBox(height: 20),
                            _buildAutoCleanSection(context, state),
                            const SizedBox(height: 20),
                            _buildUserAgentSection(context, state),
                            const SizedBox(height: 20),
                            _buildDangerZone(context),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Container(color: AppColors.black),
        Positioned(
          top: -80,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.nukeRed.withOpacity(0.04),
                  Colors.transparent
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -60,
          left: -60,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accentPurple.withOpacity(0.05),
                  Colors.transparent
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.white, size: 18),
            onPressed: () => context.go('/home'),
          ),
          const Expanded(
            child: Text(
              'Privacy Hub',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const PrivacyIndicator(isSecure: true, showLabel: true),
        ],
      ),
    );
  }

  // ─── NUKE BUTTON ──────────────────────────────────────────────────────────

  Widget _buildNukeButton(BuildContext context, PrivacyState state) {
    final s = AppStrings.of(context);
    final isNuking = state.status == PrivacyStatus.nuking;

    return Column(
      children: [
        // Section label
        Text(
          s.emergencyWipe,
          style: TextStyle(
            color: AppColors.nukeRed.withOpacity(0.8),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 20),

        // Outer glow ring (animated)
        AnimatedBuilder(
          animation: _nukeGlowController,
          builder: (context, child) {
            return Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.nukeRed.withOpacity(0.06 * _nukeGlow.value),
                    AppColors.nukeRed.withOpacity(0.02 * _nukeGlow.value),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: child,
            );
          },
          child: AnimatedBuilder(
            animation: _nukeController,
            builder: (context, child) {
              return Transform.scale(
                scale: _nukePulse.value,
                child: child,
              );
            },
            child: _buildNukeCore(context, isNuking),
          ),
        ),

        const SizedBox(height: 20),

        // Warning text
        Text(
          s.nukeWarning,
          style: const TextStyle(
            color: AppColors.grayMid,
            fontSize: 12,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNukeCore(BuildContext context, bool isNuking) {
    final s = AppStrings.of(context);
    return GestureDetector(
      onTap: () => _showNukeConfirmation(context),
      child: Container(
        width: 170,
        height: 170,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            center: Alignment(-0.3, -0.3),
            colors: [
              Color(0xFFFF3333),
              AppColors.nukeRed,
              AppColors.nukeRedDark,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
          border: Border.all(
            color: AppColors.nukeRedBright.withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.nukeRed.withOpacity(0.5),
              blurRadius: 30,
              spreadRadius: 5,
            ),
            BoxShadow(
              color: AppColors.nukeRed.withOpacity(0.2),
              blurRadius: 60,
              spreadRadius: 15,
            ),
          ],
        ),
        child: isNuking
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    s.wiping,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Warning icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.12),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.2), width: 1),
                    ),
                    child: const Icon(
                      Icons.warning_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'NUKE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s.tapToWipe,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showNukeConfirmation(BuildContext context) {
    bool clearBookmarks = false;
    final s = AppStrings.of(context);

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.anthracite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                  color: AppColors.nukeRed.withOpacity(0.3), width: 1),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.nukeRed.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_rounded,
                      color: AppColors.nukeRed, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  s.nukeConfirmTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.nukeWillDelete,
                  style: const TextStyle(
                      color: AppColors.whiteAlpha70, fontSize: 14),
                ),
                const SizedBox(height: 12),
                _nukeListItem(s.nukeHistory),
                _nukeListItem(s.nukeCookies),
                _nukeListItem(s.nukeLocalStorage),
                _nukeListItem(s.nukeCache),
                const SizedBox(height: 16),
                GlassCard(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  borderRadius: 10,
                  child: Row(
                    children: [
                      Checkbox(
                        value: clearBookmarks,
                        onChanged: (v) =>
                            setDialogState(() => clearBookmarks = v ?? false),
                        activeColor: AppColors.nukeRed,
                        side: const BorderSide(
                            color: AppColors.grayMid, width: 1.5),
                      ),
                      Text(
                        s.nukeClearBookmarks,
                        style: const TextStyle(
                          color: AppColors.whiteAlpha70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.nukeRed.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.nukeRed.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: AppColors.nukeRed.withOpacity(0.8),
                          size: 14),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          s.nukeCannotUndo,
                          style: const TextStyle(
                            color: AppColors.grayLight,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  s.cancel,
                  style: const TextStyle(color: AppColors.grayLight),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.read<PrivacyBloc>().add(
                      PrivacyNukeAllData(clearBookmarks: clearBookmarks));
                },
                icon: const Icon(Icons.local_fire_department_rounded,
                    size: 16),
                label: Text(s.nukeNow),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.nukeRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _nukeListItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.remove_circle_outline_rounded,
              color: AppColors.nukeRed, size: 14),
          const SizedBox(width: 8),
          Text(text,
              style: const TextStyle(
                  color: AppColors.whiteAlpha70, fontSize: 13)),
        ],
      ),
    );
  }

  // ─── Encryption Status ──────────────────────────────────────────────────

  Widget _buildEncryptionStatus() {
    final s = AppStrings.of(context);
    final isEncrypted = EncryptionService.instance.isInitialized;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      borderColor: isEncrypted
          ? AppColors.privacyGreen.withOpacity(0.3)
          : AppColors.warning.withOpacity(0.3),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (isEncrypted ? AppColors.privacyGreen : AppColors.warning)
                  .withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEncrypted ? Icons.enhanced_encryption_rounded : Icons.no_encryption_rounded,
              color: isEncrypted ? AppColors.privacyGreen : AppColors.warning,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Encryption Manager',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  isEncrypted
                      ? s.encryptionActive
                      : s.encryptionInactive,
                  style: TextStyle(
                    color: isEncrypted
                        ? AppColors.privacyGreen
                        : AppColors.warning,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          PulsatingDot(
            color: isEncrypted ? AppColors.privacyGreen : AppColors.warning,
            size: 10,
          ),
        ],
      ),
    );
  }

  // ─── Section builder helper ─────────────────────────────────────────────

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 16),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    Color? activeColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppColors.grayMid, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor ?? AppColors.accent,
          ),
        ],
      ),
    );
  }

  // ─── Fingerprint Section ────────────────────────────────────────────────

  Widget _buildFingerprintSection(BuildContext context, PrivacyState state) {
    final str = AppStrings.of(context);
    final s = state.settings;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Fingerprinting Protection', Icons.fingerprint),
          _buildToggleRow(
            title: 'Canvas Blocking',
            subtitle: str.canvasDesc,
            value: s.blockCanvasFingerprint,
            onChanged: (v) => _updateSettings(
                context, 'blockCanvasFingerprint', v),
          ),
          const Divider(height: 16, color: AppColors.anthraciteLight),
          _buildToggleRow(
            title: 'AudioContext Blocking',
            subtitle: str.audioDesc,
            value: s.blockAudioFingerprint,
            onChanged: (v) => _updateSettings(
                context, 'blockAudioFingerprint', v),
          ),
          const Divider(height: 16, color: AppColors.anthraciteLight),
          _buildToggleRow(
            title: 'WebGL Blocking',
            subtitle: str.webglDesc,
            value: s.blockWebGLFingerprint,
            onChanged: (v) => _updateSettings(
                context, 'blockWebGLFingerprint', v),
          ),
          const Divider(height: 16, color: AppColors.anthraciteLight),
          _buildToggleRow(
            title: 'Timezone Spoofing',
            subtitle: str.timezoneDesc,
            value: s.spoofTimezone,
            onChanged: (v) =>
                _updateSettings(context, 'spoofTimezone', v),
          ),
        ],
      ),
    );
  }

  // ─── Network Section ────────────────────────────────────────────────────

  Widget _buildNetworkSection(BuildContext context, PrivacyState state) {
    final str = AppStrings.of(context);
    final s = state.settings;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Network Privacy', Icons.network_check_rounded),
          _buildToggleRow(
            title: 'WebRTC Blocking',
            subtitle: str.webrtcDesc,
            value: s.blockWebRtc,
            onChanged: (v) =>
                _updateSettings(context, 'blockWebRtc', v),
          ),
        ],
      ),
    );
  }

  // ─── Browsing Section ───────────────────────────────────────────────────

  Widget _buildBrowsingSection(BuildContext context, PrivacyState state) {
    final str = AppStrings.of(context);
    final s = state.settings;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Browsing Settings', Icons.language_rounded),
          _buildToggleRow(
            title: 'JavaScript',
            subtitle: str.javascriptDesc,
            value: s.javascriptEnabled,
            onChanged: (v) =>
                _updateSettings(context, 'javascriptEnabled', v),
          ),
          const Divider(height: 16, color: AppColors.anthraciteLight),
          _buildToggleRow(
            title: 'Cookies',
            subtitle: str.cookiesDesc,
            value: s.cookiesEnabled,
            onChanged: (v) =>
                _updateSettings(context, 'cookiesEnabled', v),
          ),
          const Divider(height: 16, color: AppColors.anthraciteLight),
          _buildToggleRow(
            title: 'Block 3rd-Party Cookies',
            subtitle: str.thirdPartyCookiesDesc,
            value: s.blockThirdPartyCookies,
            onChanged: (v) => _updateSettings(
                context, 'blockThirdPartyCookies', v),
          ),
          const Divider(height: 16, color: AppColors.anthraciteLight),
          _buildToggleRow(
            title: 'Save History',
            subtitle: str.historyDesc,
            value: s.saveHistory,
            onChanged: (v) =>
                _updateSettings(context, 'saveHistory', v),
          ),
          const SizedBox(height: 12),
          Text(
            str.searchEngine,
            style: const TextStyle(color: AppColors.grayLight, fontSize: 12),
          ),
          const SizedBox(height: 8),
          _buildDropdown<String>(
            value: s.searchEngine,
            items: AppConstants.searchEngines.keys.toList(),
            onChanged: (v) {
              if (v != null) {
                _updateSettings(context, 'searchEngine', v);
              }
            },
          ),
        ],
      ),
    );
  }

  // ─── Auto-Clean Section ─────────────────────────────────────────────────

  Widget _buildAutoCleanSection(BuildContext context, PrivacyState state) {
    final str = AppStrings.of(context);
    final s = state.settings;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Auto-Clean', Icons.cleaning_services_rounded),
          _buildToggleRow(
            title: 'Clear on Exit',
            subtitle: str.clearOnExitDesc,
            value: s.clearOnExit,
            onChanged: (v) =>
                _updateSettings(context, 'clearOnExit', v),
          ),
          const Divider(height: 16, color: AppColors.anthraciteLight),
          Text(
            str.autoResetTimer,
            style: const TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            str.autoResetDesc,
            style: const TextStyle(color: AppColors.grayMid, fontSize: 12),
          ),
          const SizedBox(height: 10),
          _buildDropdown<String>(
            value: AppConstants.autoClearIntervals.entries
                    .firstWhere(
                      (e) => e.value == s.autoClearInterval,
                      orElse: () => const MapEntry('Session only', 0),
                    )
                    .key,
            items: AppConstants.autoClearIntervals.keys.toList(),
            onChanged: (v) {
              if (v != null) {
                final interval = AppConstants.autoClearIntervals[v] ?? 0;
                _updateSettings(
                    context, 'autoClearInterval', interval);
              }
            },
          ),
        ],
      ),
    );
  }

  // ─── User Agent Section ─────────────────────────────────────────────────

  Widget _buildUserAgentSection(BuildContext context, PrivacyState state) {
    final str = AppStrings.of(context);
    final s = state.settings;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Identity Masking', Icons.person_outline_rounded),
          Text(
            str.userAgentString,
            style: const TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            str.userAgentDesc,
            style: const TextStyle(color: AppColors.grayMid, fontSize: 12),
          ),
          const SizedBox(height: 10),
          _buildDropdown<String>(
            value: s.userAgent,
            items: AppConstants.userAgents.keys.toList(),
            onChanged: (v) {
              if (v != null) {
                _updateSettings(context, 'userAgent', v);
              }
            },
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.accent.withOpacity(0.2)),
            ),
            child: Text(
              AppConstants.userAgents[s.userAgent] ?? '',
              style: TextStyle(
                color: AppColors.accent.withOpacity(0.8),
                fontSize: 10,
                fontFamily: 'monospace',
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Danger Zone ────────────────────────────────────────────────────────

  Widget _buildDangerZone(BuildContext context) {
    final str = AppStrings.of(context);
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      borderColor: AppColors.nukeRed.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: AppColors.nukeRed, size: 16),
              SizedBox(width: 8),
              Text(
                'Danger Zone',
                style: TextStyle(
                  color: AppColors.nukeRed,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDangerButton(
            label: str.resetSettings,
            icon: Icons.settings_backup_restore_rounded,
            onTap: () {
              _showConfirmDialog(
                context,
                title: str.resetSettings,
                message: str.resetSettingsMsg,
                onConfirm: () => context
                    .read<PrivacyBloc>()
                    .add(const PrivacyResetToDefaults()),
              );
            },
          ),
          const SizedBox(height: 10),
          _buildDangerButton(
            label: str.clearHistory,
            icon: Icons.history_rounded,
            onTap: () {
              _showConfirmDialog(
                context,
                title: str.clearHistory,
                message: str.clearHistoryMsg,
                onConfirm: () => context
                    .read<PrivacyBloc>()
                    .add(const PrivacyClearHistory()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDangerButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderRadius: 10,
      borderColor: AppColors.nukeRed.withOpacity(0.2),
      backgroundColor: AppColors.nukeRed.withOpacity(0.05),
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppColors.nukeRed, size: 18),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.nukeRed,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Icon(Icons.chevron_right_rounded,
              color: AppColors.nukeRed.withOpacity(0.5), size: 18),
        ],
      ),
    );
  }

  // ─── Dropdown helper ────────────────────────────────────────────────────

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteAlpha05,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.anthraciteLight),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.anthraciteMid,
          iconEnabledColor: AppColors.grayLight,
          style: const TextStyle(color: AppColors.white, fontSize: 14),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(item.toString()),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────

  void _updateSettings(BuildContext context, String key, Object value) {
    context.read<PrivacyBloc>().add(PrivacyUpdateSettings(key, value));
  }

  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    final s = AppStrings.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.anthracite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(title,
            style: const TextStyle(
                color: AppColors.white, fontWeight: FontWeight.w700)),
        content: Text(message,
            style: const TextStyle(
                color: AppColors.whiteAlpha70, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.cancel,
                style: const TextStyle(color: AppColors.grayLight)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.nukeRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(s.confirm),
          ),
        ],
      ),
    );
  }
}
