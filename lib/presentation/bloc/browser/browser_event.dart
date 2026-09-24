part of 'browser_bloc.dart';

abstract class BrowserEvent extends Equatable {
  const BrowserEvent();

  @override
  List<Object?> get props => [];
}

class BrowserLoadUrl extends BrowserEvent {
  final String url;
  final String? tabId;
  const BrowserLoadUrl(this.url, {this.tabId});

  @override
  List<Object?> get props => [url, tabId];
}

class BrowserPageStarted extends BrowserEvent {
  final String url;
  final String tabId;
  const BrowserPageStarted(this.url, this.tabId);

  @override
  List<Object?> get props => [url, tabId];
}

class BrowserPageFinished extends BrowserEvent {
  final String url;
  final String title;
  final String tabId;
  const BrowserPageFinished(this.url, this.title, this.tabId);

  @override
  List<Object?> get props => [url, title, tabId];
}

class BrowserProgressChanged extends BrowserEvent {
  final double progress;
  final String tabId;
  const BrowserProgressChanged(this.progress, this.tabId);

  @override
  List<Object?> get props => [progress, tabId];
}

class BrowserNewTab extends BrowserEvent {
  final String url;
  const BrowserNewTab({this.url = 'https://duckduckgo.com'});

  @override
  List<Object?> get props => [url];
}

class BrowserCloseTab extends BrowserEvent {
  final String tabId;
  const BrowserCloseTab(this.tabId);

  @override
  List<Object?> get props => [tabId];
}

class BrowserSwitchTab extends BrowserEvent {
  final String tabId;
  const BrowserSwitchTab(this.tabId);

  @override
  List<Object?> get props => [tabId];
}

class BrowserGoBack extends BrowserEvent {
  const BrowserGoBack();
}

class BrowserGoForward extends BrowserEvent {
  const BrowserGoForward();
}

class BrowserRefresh extends BrowserEvent {
  const BrowserRefresh();
}

class BrowserStopLoading extends BrowserEvent {
  const BrowserStopLoading();
}

class BrowserToggleBookmark extends BrowserEvent {
  final String url;
  final String title;
  const BrowserToggleBookmark(this.url, this.title);

  @override
  List<Object?> get props => [url, title];
}

class BrowserAddToHistory extends BrowserEvent {
  final String url;
  final String title;
  final bool isPrivate;
  // Default to private so callers must explicitly opt into persistent history.
  const BrowserAddToHistory(this.url, this.title, {this.isPrivate = true});

  @override
  List<Object?> get props => [url, title, isPrivate];
}

class BrowserShow extends BrowserEvent {
  const BrowserShow();
}

class BrowserHide extends BrowserEvent {
  const BrowserHide();
}
