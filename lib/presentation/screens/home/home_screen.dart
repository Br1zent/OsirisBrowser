import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/browser_tab.dart';
import '../../bloc/browser/browser_bloc.dart';
import '../../bloc/privacy/privacy_bloc.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/osiris_logo.dart';
import '../../widgets/privacy_indicator.dart';
import '../../widgets/tab_card_switcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  bool _isSearchFocused = false;
  final int _navIndex = 0;

  late AnimationController _heroController;
  late Animation<double> _heroFade;

  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _heroFade =
        CurvedAnimation(parent: _heroController, curve: Curves.easeOut);
    _heroController.forward();

    _searchFocus.addListener(() {
      setState(() => _isSearchFocused = _searchFocus.hasFocus);
    });

    context.read<PrivacyBloc>().add(const PrivacyLoadSettings());
  }

  @override
  void dispose() {
    _heroController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    if (query.trim().isEmpty) return;

    String url;
    final isUrl = query.startsWith('http://') ||
        query.startsWith('https://') ||
        (query.contains('.') &&
            !query.contains(' ') &&
            query.length > 4);

    if (isUrl) {
      url = query.startsWith('http') ? query : 'https://$query';
    } else {
      final engine =
          AppConstants.searchEngines['DuckDuckGo']!;
      url = '$engine${Uri.encodeComponent(query)}';
    }

    _searchController.clear();
    _searchFocus.unfocus();

    context.read<BrowserBloc>().add(BrowserLoadUrl(url));
    context.read<BrowserBloc>().add(const BrowserShow());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      extendBody: true,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            bottom: false,
            child: FadeTransition(
              opacity: _heroFade,
              child: Column(
                children: [
                  _buildTopBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          _buildSearchBar(),
                          const SizedBox(height: 32),
                          _buildQuickLinksSection(),
                          const SizedBox(height: 32),
                          _buildTabsSection(),
                          const SizedBox(height: 32),
                          _buildPrivacyStatus(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBackground() {
    final accent = Theme.of(context).colorScheme.primary;
    return Stack(
      children: [
        Container(color: AppColors.black),
        Positioned(
          top: -120,
          left: -80,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                accent.withOpacity(0.06),
                Colors.transparent,
              ]),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          right: -100,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.accentPurple.withOpacity(0.05),
                Colors.transparent,
              ]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          const OsirisLogo(size: 36, animate: false),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Osiris',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
              ),
              const PrivacyIndicator(isSecure: true, showLabel: true),
            ],
          ),
          const Spacer(),
          // Tab count badge
          BlocBuilder<BrowserBloc, BrowserState>(
            builder: (context, state) {
              final accent = Theme.of(context).colorScheme.primary;
              return GlassCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                borderRadius: 10,
                onTap: () => _showTabsSheet(context),
                child: Row(
                  children: [
                    Icon(Icons.tab_rounded,
                        color: accent, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '${state.tabs.length}',
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.white),
            onPressed: () {
              context.read<BrowserBloc>().add(const BrowserNewTab());
            },
            tooltip: 'New Tab',
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded,
                color: AppColors.whiteAlpha70),
            onPressed: () => context.go('/home/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final accent = Theme.of(context).colorScheme.primary;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: GlassCard(
        padding: EdgeInsets.zero,
        borderRadius: 16,
        borderColor: _isSearchFocused
            ? accent.withOpacity(0.5)
            : AppColors.glassBorder,
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(
              Icons.search_rounded,
              color: _isSearchFocused ? accent : AppColors.grayMid,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                onSubmitted: _handleSearch,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: AppStrings.of(context).searchOrEnterUrl,
                  hintStyle: const TextStyle(
                    color: AppColors.grayMid,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16),
                  filled: false,
                ),
                textInputAction: TextInputAction.go,
              ),
            ),
            if (_searchController.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: AppColors.grayMid, size: 18),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickLinksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.of(context).quickAccess.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.grayMid,
                letterSpacing: 1.2,
              ),
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: AppConstants.defaultQuickLinks.length,
          itemBuilder: (context, index) {
            final link = AppConstants.defaultQuickLinks[index];
            return _buildQuickLinkCard(link);
          },
        ),
      ],
    );
  }

  Widget _buildQuickLinkCard(Map<String, String> link) {
    final iconMap = {
      'search': Icons.search_rounded,
      'email': Icons.email_outlined,
      'book': Icons.menu_book_rounded,
      'security': Icons.security_rounded,
      'shield': Icons.shield_outlined,
      'chat_bubble': Icons.chat_bubble_outline_rounded,
    };

    final icon = iconMap[link['icon']] ?? Icons.link_rounded;

    final accent = Theme.of(context).colorScheme.primary;
    return AnimatedGlassCard(
      borderRadius: 14,
      padding: const EdgeInsets.all(12),
      onTap: () {
        context.read<BrowserBloc>().add(BrowserLoadUrl(link['url']!));
        context.read<BrowserBloc>().add(const BrowserShow());
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            link['title']!,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTabsSection() {
    return BlocBuilder<BrowserBloc, BrowserState>(
      builder: (context, state) {
        if (state.tabs.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  AppStrings.of(context).openTabs.toUpperCase(),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.grayMid,
                        letterSpacing: 1.2,
                      ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    for (final tab in state.tabs) {
                      context
                          .read<BrowserBloc>()
                          .add(BrowserCloseTab(tab.id));
                    }
                  },
                  child: Text(
                    AppStrings.of(context).closeAll,
                    style: TextStyle(
                      color: AppColors.error.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: state.tabs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final tab = state.tabs[index];
                  final isActive = tab.id == state.activeTabId;
                  return _buildTabCard(tab, isActive, context);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabCard(BrowserTab tab, bool isActive, BuildContext ctx) {
    final accent = Theme.of(ctx).colorScheme.primary;
    return GlassCard(
      width: 160,
      padding: const EdgeInsets.all(10),
      borderRadius: 12,
      borderColor: isActive
          ? accent.withOpacity(0.4)
          : AppColors.glassBorder,
      backgroundColor: isActive
          ? accent.withOpacity(0.10)
          : AppColors.glassSurface,
      onTap: () {
        ctx.read<BrowserBloc>().add(BrowserSwitchTab(tab.id));
        ctx.read<BrowserBloc>().add(const BrowserShow());
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.language_rounded,
                  color: isActive ? accent : AppColors.grayMid,
                  size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  tab.displayTitle,
                  style: TextStyle(
                    color: isActive ? accent : AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () =>
                    ctx.read<BrowserBloc>().add(BrowserCloseTab(tab.id)),
                child: const Icon(Icons.close_rounded,
                    color: AppColors.grayMid, size: 14),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            tab.url,
            style: const TextStyle(
              color: AppColors.grayMid,
              fontSize: 10,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyStatus() {
    return BlocBuilder<PrivacyBloc, PrivacyState>(
      builder: (context, state) {
        final settings = state.settings;
        final protections = [
          ('WebRTC', settings.blockWebRtc),
          ('Canvas', settings.blockCanvasFingerprint),
          ('WebGL', settings.blockWebGLFingerprint),
          ('Audio', settings.blockAudioFingerprint),
        ];
        final activeCount = protections.where((p) => p.$2).length;

        return GlassCard(
          padding: const EdgeInsets.all(16),
          borderRadius: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.shield_rounded,
                      color: AppColors.privacyGreen, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.of(context).privacyShield,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(color: AppColors.white),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.privacyGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$activeCount/4 Active',
                      style: const TextStyle(
                        color: AppColors.privacyGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: protections.map((p) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: p.$2
                          ? AppColors.privacyGreen.withOpacity(0.12)
                          : AppColors.whiteAlpha05,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: p.$2
                            ? AppColors.privacyGreen.withOpacity(0.3)
                            : AppColors.anthraciteLight,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          p.$2 ? Icons.check_circle_rounded : Icons.circle_outlined,
                          size: 12,
                          color: p.$2
                              ? AppColors.privacyGreen
                              : AppColors.grayMid,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          p.$1,
                          style: TextStyle(
                            color: p.$2
                                ? AppColors.privacyGreen
                                : AppColors.grayMid,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.anthracite.withOpacity(0.8),
            border: const Border(
              top: BorderSide(
                color: AppColors.glassBorder,
                width: 0.5,
              ),
            ),
          ),
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedIndex: _navIndex,
            onDestinationSelected: (index) {
              if (index == 1) {
                context.go('/home/privacy-hub');
              } else if (index == 2) {
                context.go('/home/settings');
              }
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home_rounded),
                label: AppStrings.of(context).navHome,
              ),
              NavigationDestination(
                icon: const Icon(Icons.security_outlined),
                selectedIcon: const Icon(Icons.security_rounded),
                label: AppStrings.of(context).navPrivacy,
              ),
              NavigationDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings_rounded),
                label: AppStrings.of(context).navSettings,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTabsSheet(BuildContext context) {
    final state = context.read<BrowserBloc>().state;
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (ctx, animation, _) {
          return FadeTransition(
            opacity: animation,
            child: TabCardSwitcher(
              tabs: state.tabs,
              activeTabId: state.activeTabId,
              onTabSelected: (tab) {
                context.read<BrowserBloc>().add(BrowserSwitchTab(tab.id));
                Navigator.of(ctx).pop();
                context.read<BrowserBloc>().add(const BrowserShow());
              },
              onTabClosed: (id) {
                context.read<BrowserBloc>().add(BrowserCloseTab(id));
              },
              onNewTab: () {
                context.read<BrowserBloc>().add(const BrowserNewTab());
                context.read<BrowserBloc>().add(const BrowserShow());
              },
              onDismiss: () => Navigator.of(ctx).pop(),
            ),
          );
        },
      ),
    );
  }
}
