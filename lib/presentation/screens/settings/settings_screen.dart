import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/services/app_state_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/glass_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _version = '${info.version} (${info.buildNumber})');
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final appState = context.watch<AppStateService>();
    final accent = appState.accent;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, s, accent),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _sectionHeader(s.sectionAppearance),
                const SizedBox(height: 8),
                _buildColorPicker(context, s, appState, accent),
                const SizedBox(height: 12),
                _buildLanguageTile(context, s, appState),
                const SizedBox(height: 24),
                _sectionHeader(s.sectionBrowser),
                const SizedBox(height: 8),
                _buildPrivacyHubTile(context, s, accent),
                const SizedBox(height: 24),
                _sectionHeader(s.sectionAbout),
                const SizedBox(height: 8),
                _buildAboutCard(context, s, accent),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context, AppStrings s, Color accent) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 100,
      backgroundColor: AppColors.black,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.white),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          s.settings,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                accent.withOpacity(0.10),
                AppColors.black,
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Section Header ───────────────────────────────────────────────────────────
  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.grayMid,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // ── Color Picker ─────────────────────────────────────────────────────────────
  Widget _buildColorPicker(
    BuildContext context,
    AppStrings s,
    AppStateService appState,
    Color accent,
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette_rounded, color: accent, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.accentColor,
                        style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(s.accentColorDesc,
                        style: const TextStyle(
                            color: AppColors.grayLight, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: AppColors.accentPresets.map((preset) {
              final selected = accent.value == preset.color.value;
              return GestureDetector(
                onTap: () => appState.setAccent(preset.color),
                child: Tooltip(
                  message: preset.name,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: preset.color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected
                            ? AppColors.white
                            : preset.color.withOpacity(0.3),
                        width: selected ? 2.5 : 1,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: preset.color.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 1,
                              )
                            ]
                          : null,
                    ),
                    child: selected
                        ? const Icon(Icons.check_rounded,
                            color: AppColors.white, size: 18)
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Language Tile ─────────────────────────────────────────────────────────────
  Widget _buildLanguageTile(
      BuildContext context, AppStrings s, AppStateService appState) {
    final isRu = appState.locale.languageCode == 'ru';
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const Icon(Icons.language_rounded,
              color: AppColors.grayLight, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.language,
                    style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(s.languageDesc,
                    style: const TextStyle(
                        color: AppColors.grayLight, fontSize: 12)),
              ],
            ),
          ),
          _LangToggle(
            isRu: isRu,
            onChanged: (ru) =>
                appState.setLocale(Locale(ru ? 'ru' : 'en')),
          ),
        ],
      ),
    );
  }

  // ── Privacy Hub Link ─────────────────────────────────────────────────────────
  Widget _buildPrivacyHubTile(
      BuildContext context, AppStrings s, Color accent) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: () => context.go('/home/privacy-hub'),
      child: Row(
        children: [
          Icon(Icons.security_rounded, color: accent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.privacyHubLink,
                    style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(s.privacyHubDesc,
                    style: const TextStyle(
                        color: AppColors.grayLight, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.grayMid, size: 20),
        ],
      ),
    );
  }

  // ── About Card ───────────────────────────────────────────────────────────────
  Widget _buildAboutCard(
      BuildContext context, AppStrings s, Color accent) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // App Icon + Name
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [accent, AppColors.accentPurple],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.public_rounded,
                    color: AppColors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Osiris Browser',
                        style: TextStyle(
                            color: AppColors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(s.osirisDesc,
                        style: const TextStyle(
                            color: AppColors.grayLight, fontSize: 12),
                        maxLines: 2),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.glassBorder, height: 1),
          const SizedBox(height: 12),
          // Version
          _aboutRow(
            icon: Icons.info_outline_rounded,
            label: s.appVersion,
            value: _version.isEmpty ? '...' : _version,
            accent: accent,
          ),
          const SizedBox(height: 10),
          // Author
          _aboutRow(
            icon: Icons.person_rounded,
            label: s.author,
            value: '@Br1zProject',
            accent: accent,
            onTap: () async {
              final uri = Uri.parse('https://t.me/Br1zProject');
              if (await canLaunchUrl(uri)) launchUrl(uri);
            },
            trailing: Icon(Icons.open_in_new_rounded,
                size: 14, color: accent),
          ),
        ],
      ),
    );
  }

  Widget _aboutRow({
    required IconData icon,
    required String label,
    required String value,
    required Color accent,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppColors.grayLight, size: 17),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(
                  color: AppColors.grayLight, fontSize: 14)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  color: onTap != null ? accent : AppColors.whiteAlpha70,
                  fontSize: 14,
                  fontWeight: onTap != null
                      ? FontWeight.w600
                      : FontWeight.w400)),
          if (trailing != null) ...[
            const SizedBox(width: 4),
            trailing,
          ],
        ],
      ),
    );
  }
}

// ── Language Toggle Widget ────────────────────────────────────────────────────
class _LangToggle extends StatelessWidget {
  final bool isRu;
  final ValueChanged<bool> onChanged;

  const _LangToggle({required this.isRu, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final accent = context.watch<AppStateService>().accent;
    return GestureDetector(
      onTap: () => onChanged(!isRu),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.anthraciteMid,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _tab('EN', !isRu, accent),
            const SizedBox(width: 2),
            _tab('RU', isRu, accent),
          ],
        ),
      ),
    );
  }

  Widget _tab(String label, bool active, Color accent) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: active ? accent : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? AppColors.white : AppColors.grayMid,
          fontSize: 13,
          fontWeight: active ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    );
  }
}
