import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/browser_tab.dart';
import '../../bloc/browser/browser_bloc.dart';
import '../../bloc/privacy/privacy_bloc.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/osiris_logo.dart';
import '../../widgets/tab_card_switcher.dart';
import 'anti_fingerprint_js.dart';

// Per-tab runtime display state (URL bar, loading, navigation)
class _TabDisplay {
  String url;
  String title = '';
  bool canGoBack = false;
  bool canGoForward = false;
  bool isLoading = false;
  double progress = 0.0;
  bool isHttps = true;

  _TabDisplay({this.url = ''});
}

class BrowserScreen extends StatefulWidget {
  const BrowserScreen({super.key});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // Controller per tab id
  final Map<String, InAppWebViewController> _controllers = {};
  // Display state per tab id
  final Map<String, _TabDisplay> _displays = {};

  String _prevActiveTabId = '';
  bool _isEditingUrl = false;
  bool _showControls = true;
  bool _showingTabSwitcher = false;
  bool _showingMoreMenu = false;
  double _lastScrollY = 0;
  Timer? _autoClearTimer;
  int _lastClearInterval = -2; // sentinel: not yet initialized
  final _urlController = TextEditingController();

  late AnimationController _controlsController;
  late Animation<double> _controlsAnimation;

  late AnimationController _moreMenuController;
  late Animation<Offset> _moreMenuSlide;
  late Animation<double> _moreMenuFade;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controlsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1.0,
    );
    _controlsAnimation = CurvedAnimation(
      parent: _controlsController,
      curve: Curves.easeOut,
    );
    _moreMenuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _moreMenuSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _moreMenuController,
      curve: Curves.easeOutCubic,
    ));
    _moreMenuFade = CurvedAnimation(
      parent: _moreMenuController,
      curve: Curves.easeOut,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _restartAutoClearTimer());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoClearTimer?.cancel();
    _controlsController.dispose();
    _moreMenuController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    if (lifecycle == AppLifecycleState.paused ||
        lifecycle == AppLifecycleState.detached) {
      if (!mounted) return;
      final settings = context.read<PrivacyBloc>().state.settings;
      if (settings.clearOnExit) _clearAllBrowserData();
    }
  }

  void _restartAutoClearTimer() {
    if (!mounted) return;
    final interval = context.read<PrivacyBloc>().state.settings.autoClearInterval;
    if (interval == _lastClearInterval) return;
    _lastClearInterval = interval;
    _autoClearTimer?.cancel();
    _autoClearTimer = null;
    if (interval > 0) {
      _autoClearTimer = Timer.periodic(Duration(seconds: interval), (_) {
        if (mounted) _clearAllBrowserData();
      });
    }
  }

  Future<void> _clearAllBrowserData() async {
    await InAppWebViewController.clearAllCache();
    if (!mounted) return;
    context.read<PrivacyBloc>().add(const PrivacyClearHistory());
  }

  void _showMoreMenu() {
    setState(() => _showingMoreMenu = true);
    _moreMenuController.forward(from: 0);
  }

  void _hideMoreMenu() {
    _moreMenuController.reverse().then((_) {
      if (mounted) setState(() => _showingMoreMenu = false);
    });
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String _getDisplayUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host + (uri.path.length > 1 ? uri.path : '');
    } catch (_) {
      return url;
    }
  }

  _TabDisplay _activeDisplay(BrowserState state) =>
      _displays[state.activeTabId] ?? _TabDisplay();

  void _navigateTo(String input) {
    final isUrl = input.startsWith('http://') ||
        input.startsWith('https://') ||
        (input.contains('.') && !input.contains(' ') && input.length > 4);

    final String url;
    if (isUrl) {
      url = input.startsWith('http') ? input : 'https://$input';
    } else {
      final engine = AppConstants.searchEngines[
              context.read<PrivacyBloc>().state.settings.searchEngine] ??
          AppConstants.searchEngines['DuckDuckGo']!;
      url = '$engine${Uri.encodeComponent(input)}';
    }

    setState(() => _isEditingUrl = false);
    final activeId = context.read<BrowserBloc>().state.activeTabId;
    _controllers[activeId]
        ?.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
    context.read<BrowserBloc>().add(BrowserLoadUrl(url, tabId: activeId));
  }

  InAppWebViewSettings _buildSettings() {
    final settings = context.read<PrivacyBloc>().state.settings;
    final ua = AppConstants.userAgents[settings.userAgent] ??
        AppConstants.userAgents['Chrome (Windows)']!;
    return InAppWebViewSettings(
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: true,
      allowsInlineMediaPlayback: false,
      javaScriptEnabled: settings.javascriptEnabled,
      userAgent: ua,
      cacheEnabled: false,
      clearCache: true,
      thirdPartyCookiesEnabled: !settings.blockThirdPartyCookies,
      blockNetworkImage: false,
      disableHorizontalScroll: false,
      disableVerticalScroll: false,
      supportZoom: true,
      builtInZoomControls: true,
      displayZoomControls: false,
      allowContentAccess: false,
      allowFileAccess: false,
      allowFileAccessFromFileURLs: false,
      allowUniversalAccessFromFileURLs: false,
      geolocationEnabled: false,
      useHybridComposition: true,
      loadWithOverviewMode: true,
      useWideViewPort: true,
      mixedContentMode: MixedContentMode.MIXED_CONTENT_NEVER_ALLOW,
      safeBrowsingEnabled: true,
    );
  }

  Future<void> _injectAntiFingerprint(
      InAppWebViewController ctrl) async {
    final settings = context.read<PrivacyBloc>().state.settings;
    final script = AntiFingerprintJS.buildScript(
      blockCanvas: settings.blockCanvasFingerprint,
      blockAudio: settings.blockAudioFingerprint,
      blockWebGL: settings.blockWebGLFingerprint,
      blockWebRtc: settings.blockWebRtc,
      spoofTimezone: settings.spoofTimezone,
      blockNavigatorProps: true,
    );
    await ctrl.evaluateJavascript(source: script);
    if (!settings.cookiesEnabled) {
      await ctrl.evaluateJavascript(source: '''
        (function(){
          try {
            Object.defineProperty(document, 'cookie', {
              get: function() { return ''; },
              set: function() { return true; },
              configurable: true
            });
          } catch(e) {}
        })();
      ''');
    }
  }

  bool _isTrackerUrl(String url) {
    const blocked = [
      'google-analytics.com', 'googletagmanager.com', 'doubleclick.net',
      'facebook.com/tr', 'connect.facebook.net', 'analytics.twitter.com',
      'static.ads-twitter.com', 'snap.licdn.com', 'scorecardresearch.com',
      'quantserve.com', 'adnxs.com', 'adsrvr.org', 'googlesyndication.com',
      'rubiconproject.com', 'openx.net', 'pubmatic.com', 'advertising.com',
    ];
    final l = url.toLowerCase();
    return blocked.any((d) => l.contains(d));
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<PrivacyBloc, PrivacyState>(
      listenWhen: (prev, curr) =>
          prev.settings.autoClearInterval != curr.settings.autoClearInterval,
      listener: (context, _) => _restartAutoClearTimer(),
      child: BlocConsumer<BrowserBloc, BrowserState>(
      listenWhen: (prev, curr) =>
          prev.activeTabId != curr.activeTabId ||
          prev.tabs.length != curr.tabs.length ||
          prev.activeTab?.url != curr.activeTab?.url,
      listener: (context, state) {
        // Sync display states
        for (final tab in state.tabs) {
          _displays.putIfAbsent(tab.id, () => _TabDisplay(url: tab.url));
        }
        final ids = state.tabs.map((t) => t.id).toSet();
        _displays.removeWhere((id, _) => !ids.contains(id));
        _controllers.removeWhere((id, _) => !ids.contains(id));

        // Tab switched — update URL bar
        if (state.activeTabId != _prevActiveTabId) {
          _prevActiveTabId = state.activeTabId;
          final d = _displays[state.activeTabId];
          if (d != null && !_isEditingUrl) {
            setState(() {
              _urlController.text = _getDisplayUrl(d.url);
            });
          }
        }

        // URL changed externally (home screen navigation) — drive WebView
        final activeTab = state.activeTab;
        if (activeTab != null) {
          final d = _displays[activeTab.id];
          final ctrl = _controllers[activeTab.id];
          if (ctrl != null &&
              d != null &&
              activeTab.url.isNotEmpty &&
              activeTab.url != d.url) {
            ctrl.loadUrl(
                urlRequest: URLRequest(url: WebUri(activeTab.url)));
          }
        }
      },
      builder: (context, state) {
        _prevActiveTabId = state.activeTabId;

        for (final tab in state.tabs) {
          _displays.putIfAbsent(tab.id, () => _TabDisplay(url: tab.url));
        }

        final display = _activeDisplay(state);
        final activeIdx = state.tabs.isEmpty
            ? 0
            : state.tabs
                .indexWhere((t) => t.id == state.activeTabId)
                .clamp(0, state.tabs.length - 1);

        return Scaffold(
          backgroundColor: AppColors.black,
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    _buildTopBar(state, display),
                    _buildProgressBar(display),
                    Expanded(
                      child: state.tabs.isEmpty
                          ? const SizedBox()
                          : RepaintBoundary(
                              child: IndexedStack(
                                index: activeIdx,
                                children: state.tabs
                                    .map((tab) => _buildWebView(tab, state))
                                    .toList(),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _controlsAnimation,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(
                        0, (1 - _controlsAnimation.value) * 80),
                    child: child,
                  ),
                  child: _buildBottomBar(state, display),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: _showingTabSwitcher
                    ? TabCardSwitcher(
                        key: const ValueKey('tab_switcher'),
                        tabs: state.tabs,
                        activeTabId: state.activeTabId,
                        onTabSelected: (tab) {
                          context.read<BrowserBloc>().add(BrowserSwitchTab(tab.id));
                          setState(() => _showingTabSwitcher = false);
                        },
                        onTabClosed: (id) {
                          context.read<BrowserBloc>().add(BrowserCloseTab(id));
                        },
                        onNewTab: () {
                          context.read<BrowserBloc>().add(const BrowserNewTab());
                        },
                        onDismiss: () => setState(() => _showingTabSwitcher = false),
                      )
                    : const SizedBox.shrink(key: ValueKey('tab_switcher_empty')),
              ),
              if (_showingMoreMenu)
                _buildMoreMenuOverlay(state, display),
            ],
          ),
        );
      },
      ),
    );
  }

  // ── WebView per tab ───────────────────────────────────────────────────────────

  Widget _buildWebView(BrowserTab tab, BrowserState state) {
    return InAppWebView(
          key: ValueKey(tab.id),
          initialUrlRequest:
              URLRequest(url: WebUri(tab.url.isEmpty ? 'https://duckduckgo.com' : tab.url)),
          initialSettings: _buildSettings(),
          onWebViewCreated: (ctrl) {
            _controllers[tab.id] = ctrl;
          },
          onLoadStart: (ctrl, url) async {
            final urlStr = url?.toString() ?? '';
            final bloc = context.read<BrowserBloc>();
            await _injectAntiFingerprint(ctrl);
            if (!mounted) return;
            setState(() {
              final d = _displays[tab.id] ??= _TabDisplay();
              d.url = urlStr;
              d.isLoading = true;
              d.progress = 0.1;
              d.isHttps = urlStr.startsWith('https://');
              if (tab.id == state.activeTabId && !_isEditingUrl) {
                _urlController.text = _getDisplayUrl(urlStr);
              }
            });
            bloc.add(BrowserPageStarted(urlStr, tab.id));
          },
          onLoadStop: (ctrl, url) async {
            final urlStr = url?.toString() ?? '';
            final bloc = context.read<BrowserBloc>();
            final privacyBloc = context.read<PrivacyBloc>();
            final title = await ctrl.getTitle() ?? '';
            final cbk = await ctrl.canGoBack();
            final cfw = await ctrl.canGoForward();
            await _injectAntiFingerprint(ctrl);
            if (!mounted) return;
            setState(() {
              final d = _displays[tab.id] ??= _TabDisplay();
              d.url = urlStr;
              d.title = title;
              d.isLoading = false;
              d.progress = 1.0;
              d.canGoBack = cbk;
              d.canGoForward = cfw;
              d.isHttps = urlStr.startsWith('https://');
              if (tab.id == state.activeTabId && !_isEditingUrl) {
                _urlController.text = _getDisplayUrl(urlStr);
              }
            });
            bloc.add(BrowserPageFinished(urlStr, title, tab.id));
            if (privacyBloc.state.settings.saveHistory) {
              bloc.add(BrowserAddToHistory(urlStr, title));
            }
          },
          onProgressChanged: (ctrl, progress) {
            if (!mounted) return;
            setState(() {
              (_displays[tab.id] ??= _TabDisplay()).progress = progress / 100;
            });
            context.read<BrowserBloc>().add(
                BrowserProgressChanged(progress / 100, tab.id));
          },
          onReceivedError: (ctrl, req, err) {
            if (!mounted) return;
            setState(() {
              (_displays[tab.id] ??= _TabDisplay()).isLoading = false;
            });
          },
          shouldOverrideUrlLoading: (ctrl, action) async {
            final url = action.request.url?.toString() ?? '';
            if (_isTrackerUrl(url)) return NavigationActionPolicy.CANCEL;
            return NavigationActionPolicy.ALLOW;
          },
          onScrollChanged: (ctrl, x, y) {
            if (tab.id != state.activeTabId) return;
            final delta = y - _lastScrollY;
            _lastScrollY = y.toDouble();
            if (delta > 20 && _showControls) {
              setState(() => _showControls = false);
              _controlsController.reverse();
            } else if (delta < -20 && !_showControls) {
              setState(() => _showControls = true);
              _controlsController.forward();
            }
          },
    );
  }

  // ── Top Bar ───────────────────────────────────────────────────────────────────

  Widget _buildTopBar(BrowserState state, _TabDisplay display) {
    final accent = Theme.of(context).colorScheme.primary;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          color: AppColors.surfaceBlack.withOpacity(0.88),
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Row(
            children: [
              // Back button
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                color: display.canGoBack ? AppColors.white : AppColors.grayMid,
                onPressed: display.canGoBack
                    ? () => _controllers[state.activeTabId]?.goBack()
                    : null,
              ),

              // Osiris logo
              const OsirisLogo(size: 28, animate: false),
              const SizedBox(width: 6),

              // URL Bar
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _isEditingUrl = true;
                    _urlController.text = display.url;
                    _urlController.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: _urlController.text.length,
                    );
                  }),
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    borderRadius: 10,
                    child: Row(
                      children: [
                        Icon(
                          display.isHttps
                              ? Icons.lock_rounded
                              : Icons.lock_open_rounded,
                          color: display.isHttps
                              ? AppColors.privacyGreen
                              : AppColors.warning,
                          size: 13,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _isEditingUrl
                              ? TextField(
                                  controller: _urlController,
                                  autofocus: true,
                                  style: const TextStyle(
                                      color: AppColors.white, fontSize: 13),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    filled: false,
                                  ),
                                  textInputAction: TextInputAction.go,
                                  onSubmitted: _navigateTo,
                                )
                              : Text(
                                  _getDisplayUrl(display.url),
                                  style: const TextStyle(
                                      color: AppColors.white, fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                        if (display.isLoading)
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: AppColors.accent,
                            ),
                          )
                        else if (_isEditingUrl)
                          GestureDetector(
                            onTap: () =>
                                setState(() => _isEditingUrl = false),
                            child: const Icon(Icons.close_rounded,
                                color: AppColors.grayMid, size: 14),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Reload / Stop
              IconButton(
                icon: Icon(
                  display.isLoading
                      ? Icons.close_rounded
                      : Icons.refresh_rounded,
                  size: 20,
                ),
                color: AppColors.white,
                onPressed: () {
                  final ctrl = _controllers[state.activeTabId];
                  if (display.isLoading) {
                    ctrl?.stopLoading();
                  } else {
                    ctrl?.reload();
                  }
                },
              ),

              // Bookmark
              IconButton(
                icon: Icon(
                  state.isCurrentPageBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  size: 20,
                  color: state.isCurrentPageBookmarked
                      ? accent
                      : AppColors.white,
                ),
                onPressed: () {
                  context.read<BrowserBloc>().add(
                      BrowserToggleBookmark(display.url, display.title));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Progress Bar ──────────────────────────────────────────────────────────────

  Widget _buildProgressBar(_TabDisplay display) {
    if (!display.isLoading) return const SizedBox.shrink();
    return LinearProgressIndicator(
      value: display.progress,
      backgroundColor: Colors.transparent,
      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
      minHeight: 2,
    );
  }

  // ── Bottom Bar ────────────────────────────────────────────────────────────────

  Widget _buildBottomBar(BrowserState state, _TabDisplay display) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 28),
          decoration: BoxDecoration(
            color: AppColors.surfaceBlack.withOpacity(0.92),
            border: const Border(
              top: BorderSide(color: AppColors.glassBorder, width: 0.5),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _navButton(
                icon: Icons.arrow_back_ios_new_rounded,
                enabled: display.canGoBack,
                onTap: () =>
                    _controllers[state.activeTabId]?.goBack(),
              ),
              _navButton(
                icon: Icons.arrow_forward_ios_rounded,
                enabled: display.canGoForward,
                onTap: () =>
                    _controllers[state.activeTabId]?.goForward(),
              ),
              _navButton(
                icon: Icons.home_rounded,
                enabled: true,
                onTap: () => context.read<BrowserBloc>().add(const BrowserHide()),
              ),
              _navButton(
                icon: Icons.tab_rounded,
                enabled: true,
                onTap: () => setState(() => _showingTabSwitcher = true),
              ),
              _navButton(
                icon: Icons.more_vert_rounded,
                enabled: true,
                onTap: _showMoreMenu,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: enabled ? AppColors.whiteAlpha05 : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: enabled ? AppColors.white : AppColors.grayMid,
          size: 20,
        ),
      ),
    );
  }

  // ── More Menu Overlay (in-tree, no Navigator needed) ─────────────────────────

  Widget _buildMoreMenuOverlay(BrowserState state, _TabDisplay display) {
    return Stack(
      children: [
        // Animated scrim
        Positioned.fill(
          child: FadeTransition(
            opacity: _moreMenuFade,
            child: GestureDetector(
              onTap: _hideMoreMenu,
              child: Container(color: Colors.black54),
            ),
          ),
        ),
        // Animated panel — slides up from bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SlideTransition(
            position: _moreMenuSlide,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  color: AppColors.anthracite.withOpacity(0.95),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.grayMid,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _menuItem(
                        icon: Icons.share_rounded,
                        label: 'Share',
                        onTap: () {
                          _hideMoreMenu();
                          Clipboard.setData(ClipboardData(text: display.url));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('URL copied')),
                          );
                        },
                      ),
                      _menuItem(
                        icon: Icons.bookmark_add_rounded,
                        label: 'Add Bookmark',
                        onTap: () {
                          _hideMoreMenu();
                          context.read<BrowserBloc>().add(
                              BrowserToggleBookmark(display.url, display.title));
                        },
                      ),
                      _menuItem(
                        icon: Icons.security_rounded,
                        label: 'Privacy Hub',
                        onTap: () {
                          _hideMoreMenu();
                          context.read<BrowserBloc>().add(const BrowserHide());
                          context.go('/home/privacy-hub');
                        },
                      ),
                      _menuItem(
                        icon: Icons.cleaning_services_rounded,
                        label: 'Clear Session Data',
                        color: AppColors.nukeRed,
                        onTap: () async {
                          _hideMoreMenu();
                          final messenger = ScaffoldMessenger.of(context);
                          await _controllers[state.activeTabId]
                              ?.evaluateJavascript(
                                  source: 'window.__osiris?.clearSession()');
                          await InAppWebViewController.clearAllCache();
                          if (mounted) {
                            messenger.showSnackBar(
                              const SnackBar(content: Text('Session cleared')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.whiteAlpha70, size: 22),
      title: Text(label,
          style: TextStyle(color: color ?? AppColors.white, fontSize: 15)),
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
