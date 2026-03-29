import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/browser_tab.dart';
import '../../core/l10n/app_strings.dart';

/// Telegram-style card stack tab switcher.
/// Cards are shown in a horizontal PageView with 3D perspective tilt.
class TabCardSwitcher extends StatefulWidget {
  final List<BrowserTab> tabs;
  final String? activeTabId;
  final ValueChanged<BrowserTab> onTabSelected;
  final ValueChanged<String> onTabClosed;
  final VoidCallback onNewTab;
  final VoidCallback onDismiss;

  const TabCardSwitcher({
    super.key,
    required this.tabs,
    required this.activeTabId,
    required this.onTabSelected,
    required this.onTabClosed,
    required this.onNewTab,
    required this.onDismiss,
  });

  @override
  State<TabCardSwitcher> createState() => _TabCardSwitcherState();
}

class _TabCardSwitcherState extends State<TabCardSwitcher>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    final initial = widget.tabs.isEmpty
        ? 0
        : widget.tabs.indexWhere((t) => t.id == widget.activeTabId).clamp(0, widget.tabs.length - 1);
    _pageController = PageController(
      initialPage: initial,
      viewportFraction: 0.74,
    );
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // Pick a unique color per tab based on its URL hash
  Color _cardAccent(BrowserTab tab) {
    const palette = [
      Color(0xFF8B5CF6),
      Color(0xFF3B82F6),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFFEF4444),
      Color(0xFFEC4899),
      Color(0xFF06B6D4),
      Color(0xFF00D4FF),
    ];
    return palette[tab.url.hashCode.abs() % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final tabs = widget.tabs;
    final accent = Theme.of(context).colorScheme.primary;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Blurred dark background
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(color: Colors.black.withOpacity(0.87)),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Row(
                    children: [
                      Text(
                        s.openTabsCount,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${tabs.length}',
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: widget.onDismiss,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: AppColors.whiteAlpha10,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded,
                              color: AppColors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Card Switcher ────────────────────────────────────────────
                Expanded(
                  child: tabs.isEmpty
                      ? _buildEmpty(s)
                      : PageView.builder(
                          controller: _pageController,
                          itemCount: tabs.length,
                          itemBuilder: (context, index) {
                            final delay = (index * 0.08).clamp(0.0, 0.56);
                            final end = (delay + 0.44).clamp(0.0, 1.0);
                            final cardAnim = CurvedAnimation(
                              parent: _animController,
                              curve: Interval(delay, end, curve: Curves.easeOutCubic),
                            );
                            return FadeTransition(
                              opacity: cardAnim,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.12),
                                  end: Offset.zero,
                                ).animate(cardAnim),
                                child: _buildCard(tabs[index], index),
                              ),
                            );
                          },
                        ),
                ),

                const SizedBox(height: 28),

                // ── Footer ───────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _FooterButton(
                          icon: Icons.add_rounded,
                          label: s.newTab,
                          onTap: () {
                            widget.onNewTab();
                            widget.onDismiss();
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _FooterButton(
                          icon: Icons.check_rounded,
                          label: s.done2,
                          primary: true,
                          onTap: widget.onDismiss,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    ),
    );
  }

  Widget _buildEmpty(AppStrings s) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.tab_rounded, color: AppColors.grayMid, size: 56),
          const SizedBox(height: 16),
          Text(
            s.noTabs,
            style: const TextStyle(color: AppColors.grayMid, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BrowserTab tab, int index) {
    final accent = _cardAccent(tab);
    final isActive = tab.id == widget.activeTabId;

    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double page = index.toDouble();
        try {
          page = _pageController.page ?? index.toDouble();
        } catch (_) {}
        final delta = page - index;

        // 3D perspective matrix
        final matrix = Matrix4.identity()
          ..setEntry(3, 2, 0.0008)       // perspective depth
          ..rotateX(-0.07)               // tilt toward viewer (constant)
          ..rotateY(delta * 0.14)        // lean based on position
          ..scale(1.0 - (delta.abs() * 0.04).clamp(0.0, 0.12));

        return Transform(
          alignment: Alignment.center,
          transform: matrix,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () => widget.onTabSelected(tab),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isActive
                  ? accent.withOpacity(0.7)
                  : AppColors.glassBorderStrong,
              width: isActive ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(isActive ? 0.25 : 0.08),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: Stack(
              children: [
                // Gradient background
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.anthracite,
                          Color.lerp(AppColors.anthracite, accent, 0.18)!,
                        ],
                      ),
                    ),
                  ),
                ),

                // Glow orb
                Positioned(
                  top: -40,
                  right: -40,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          accent.withOpacity(0.14),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Card content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Top row: favicon + title + close ──
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.language_rounded,
                                color: accent, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              tab.displayTitle,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => widget.onTabClosed(tab.id),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: AppColors.whiteAlpha10,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close_rounded,
                                  color: AppColors.whiteAlpha70, size: 14),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // ── Fake browser preview ──
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.whiteAlpha10,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              // Fake URL bar
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(13)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.lock_rounded,
                                        color: AppColors.privacyGreen,
                                        size: 10),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        _cleanUrl(tab.url),
                                        style: const TextStyle(
                                          color: AppColors.whiteAlpha70,
                                          fontSize: 10,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Fake content lines
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: _FakeContent(accent: accent),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Active indicator ──
                      if (isActive)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _cleanUrl(String url) {
    return url
        .replaceAll('https://', '')
        .replaceAll('http://', '')
        .replaceAll('www.', '');
  }
}

class _FakeContent extends StatelessWidget {
  final Color accent;
  const _FakeContent({required this.accent});

  @override
  Widget build(BuildContext context) {
    // Generate fake content lines using accent color tints
    final rng = math.Random(accent.value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(7, (i) {
        final width = 0.4 + rng.nextDouble() * 0.55;
        final isHighlight = i == 0;
        return Container(
          height: isHighlight ? 12 : 8,
          margin: const EdgeInsets.only(bottom: 8),
          width: double.infinity,
          child: FractionallySizedBox(
            widthFactor: width,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: isHighlight
                    ? accent.withOpacity(0.35)
                    : AppColors.whiteAlpha10,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _FooterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool primary;
  final VoidCallback onTap;

  const _FooterButton({
    required this.icon,
    required this.label,
    this.primary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: primary ? Theme.of(context).colorScheme.primary : AppColors.whiteAlpha10,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: primary
                ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                : AppColors.glassBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: primary ? AppColors.black : AppColors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: primary ? AppColors.black : AppColors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
