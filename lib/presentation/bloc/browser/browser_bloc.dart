import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/browser_tab.dart';
import '../../../domain/entities/history_entry.dart';
import '../../../domain/repositories/bookmark_repository.dart';
import '../../../domain/repositories/history_repository.dart';
import '../../../domain/entities/bookmark.dart';

part 'browser_event.dart';
part 'browser_state.dart';

class BrowserBloc extends Bloc<BrowserEvent, BrowserState> {
  final BookmarkRepository bookmarkRepository;
  final HistoryRepository historyRepository;
  final _uuid = const Uuid();

  BrowserBloc({
    required this.bookmarkRepository,
    required this.historyRepository,
  }) : super(const BrowserState()) {
    on<BrowserNewTab>(_onNewTab);
    on<BrowserCloseTab>(_onCloseTab);
    on<BrowserSwitchTab>(_onSwitchTab);
    on<BrowserLoadUrl>(_onLoadUrl);
    on<BrowserPageStarted>(_onPageStarted);
    on<BrowserPageFinished>(_onPageFinished);
    on<BrowserProgressChanged>(_onProgressChanged);
    on<BrowserGoBack>(_onGoBack);
    on<BrowserGoForward>(_onGoForward);
    on<BrowserRefresh>(_onRefresh);
    on<BrowserToggleBookmark>(_onToggleBookmark);
    on<BrowserAddToHistory>(_onAddToHistory);
    on<BrowserShow>(_onBrowserShow);
    on<BrowserHide>(_onBrowserHide);

    // Create initial tab
    add(const BrowserNewTab());
  }

  void _onNewTab(BrowserNewTab event, Emitter<BrowserState> emit) {
    final now = DateTime.now();
    final newTab = BrowserTab(
      id: _uuid.v4(),
      title: 'New Tab',
      url: event.url,
      isLoading: false,
      createdAt: now,
      lastAccessedAt: now,
    );

    emit(state.copyWith(
      tabs: [...state.tabs, newTab],
      activeTabId: newTab.id,
    ));
  }

  void _onCloseTab(BrowserCloseTab event, Emitter<BrowserState> emit) {
    final updatedTabs = state.tabs.where((t) => t.id != event.tabId).toList();

    if (updatedTabs.isEmpty) {
      // Create a new tab if we close the last one
      final now = DateTime.now();
      final newTab = BrowserTab(
        id: _uuid.v4(),
        title: 'New Tab',
        url: 'https://duckduckgo.com',
        createdAt: now,
        lastAccessedAt: now,
      );
      emit(state.copyWith(
        tabs: [newTab],
        activeTabId: newTab.id,
      ));
      return;
    }

    final newActiveId = event.tabId == state.activeTabId
        ? updatedTabs.last.id
        : state.activeTabId;

    emit(state.copyWith(tabs: updatedTabs, activeTabId: newActiveId));
  }

  void _onSwitchTab(BrowserSwitchTab event, Emitter<BrowserState> emit) {
    final updatedTabs = state.tabs.map((t) {
      if (t.id == event.tabId) {
        return t.copyWith(lastAccessedAt: DateTime.now());
      }
      return t;
    }).toList();

    emit(state.copyWith(tabs: updatedTabs, activeTabId: event.tabId));
  }

  void _onLoadUrl(BrowserLoadUrl event, Emitter<BrowserState> emit) {
    final tabId = event.tabId ?? state.activeTabId;
    final updatedTabs = state.tabs.map((t) {
      if (t.id == tabId) {
        return t.copyWith(url: event.url, isLoading: true, loadingProgress: 0.0);
      }
      return t;
    }).toList();
    emit(state.copyWith(tabs: updatedTabs));
  }

  void _onPageStarted(BrowserPageStarted event, Emitter<BrowserState> emit) {
    final updatedTabs = state.tabs.map((t) {
      if (t.id == event.tabId) {
        return t.copyWith(
          url: event.url,
          isLoading: true,
          loadingProgress: 0.1,
          lastAccessedAt: DateTime.now(),
        );
      }
      return t;
    }).toList();
    emit(state.copyWith(tabs: updatedTabs));
  }

  void _onPageFinished(BrowserPageFinished event, Emitter<BrowserState> emit) {
    final updatedTabs = state.tabs.map((t) {
      if (t.id == event.tabId) {
        return t.copyWith(
          url: event.url,
          title: event.title,
          isLoading: false,
          loadingProgress: 1.0,
          lastAccessedAt: DateTime.now(),
        );
      }
      return t;
    }).toList();
    emit(state.copyWith(tabs: updatedTabs));
  }

  void _onProgressChanged(
      BrowserProgressChanged event, Emitter<BrowserState> emit) {
    final updatedTabs = state.tabs.map((t) {
      if (t.id == event.tabId) {
        return t.copyWith(loadingProgress: event.progress);
      }
      return t;
    }).toList();
    emit(state.copyWith(tabs: updatedTabs));
  }

  void _onGoBack(BrowserGoBack event, Emitter<BrowserState> emit) {
    // Navigation is handled by the InAppWebView controller directly
    // This event just signals the intent
  }

  void _onGoForward(BrowserGoForward event, Emitter<BrowserState> emit) {
    // Navigation is handled by the InAppWebView controller directly
  }

  void _onRefresh(BrowserRefresh event, Emitter<BrowserState> emit) {
    // Handled by InAppWebView controller
  }

  Future<void> _onToggleBookmark(
      BrowserToggleBookmark event, Emitter<BrowserState> emit) async {
    try {
      final isBookmarked = await bookmarkRepository.isBookmarked(event.url);

      if (isBookmarked) {
        final bookmarks = await bookmarkRepository.getAllBookmarks();
        final existing = bookmarks.firstWhere((b) => b.url == event.url);
        await bookmarkRepository.deleteBookmark(existing.id);
        emit(state.copyWith(isCurrentPageBookmarked: false));
      } else {
        final now = DateTime.now();
        await bookmarkRepository.addBookmark(Bookmark(
          id: _uuid.v4(),
          title: event.title,
          url: event.url,
          createdAt: now,
          updatedAt: now,
        ));
        emit(state.copyWith(isCurrentPageBookmarked: true));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to update bookmark'));
    }
  }

  void _onBrowserShow(BrowserShow event, Emitter<BrowserState> emit) {
    emit(state.copyWith(isBrowserVisible: true, hasBeenOpened: true));
  }

  void _onBrowserHide(BrowserHide event, Emitter<BrowserState> emit) {
    emit(state.copyWith(isBrowserVisible: false));
  }

  Future<void> _onAddToHistory(
      BrowserAddToHistory event, Emitter<BrowserState> emit) async {
    if (event.isPrivate) return;
    try {
      await historyRepository.addEntry(HistoryEntry(
        id: _uuid.v4(),
        title: event.title,
        url: event.url,
        visitedAt: DateTime.now(),
      ));
    } catch (_) {
      // History is best-effort, don't propagate errors
    }
  }
}
