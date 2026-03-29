part of 'browser_bloc.dart';

class BrowserState extends Equatable {
  final List<BrowserTab> tabs;
  final String activeTabId;
  final bool canGoBack;
  final bool canGoForward;
  final bool isCurrentPageBookmarked;
  final String? errorMessage;
  final bool isBrowserVisible;
  final bool hasBeenOpened;

  const BrowserState({
    this.tabs = const [],
    this.activeTabId = '',
    this.canGoBack = false,
    this.canGoForward = false,
    this.isCurrentPageBookmarked = false,
    this.errorMessage,
    this.isBrowserVisible = false,
    this.hasBeenOpened = false,
  });

  BrowserTab? get activeTab {
    if (tabs.isEmpty || activeTabId.isEmpty) return null;
    try {
      return tabs.firstWhere((t) => t.id == activeTabId);
    } catch (_) {
      return tabs.isNotEmpty ? tabs.first : null;
    }
  }

  BrowserState copyWith({
    List<BrowserTab>? tabs,
    String? activeTabId,
    bool? canGoBack,
    bool? canGoForward,
    bool? isCurrentPageBookmarked,
    String? errorMessage,
    bool? isBrowserVisible,
    bool? hasBeenOpened,
  }) {
    return BrowserState(
      tabs: tabs ?? this.tabs,
      activeTabId: activeTabId ?? this.activeTabId,
      canGoBack: canGoBack ?? this.canGoBack,
      canGoForward: canGoForward ?? this.canGoForward,
      isCurrentPageBookmarked:
          isCurrentPageBookmarked ?? this.isCurrentPageBookmarked,
      errorMessage: errorMessage,
      isBrowserVisible: isBrowserVisible ?? this.isBrowserVisible,
      hasBeenOpened: hasBeenOpened ?? this.hasBeenOpened,
    );
  }

  @override
  List<Object?> get props => [
        tabs,
        activeTabId,
        canGoBack,
        canGoForward,
        isCurrentPageBookmarked,
        errorMessage,
        isBrowserVisible,
        hasBeenOpened,
      ];
}
