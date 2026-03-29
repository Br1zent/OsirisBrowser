import 'package:equatable/equatable.dart';

class BrowserTab extends Equatable {
  final String id;
  final String title;
  final String url;
  final String? faviconUrl;
  final bool isLoading;
  final double loadingProgress;
  final bool isPrivate;
  final DateTime createdAt;
  final DateTime lastAccessedAt;

  const BrowserTab({
    required this.id,
    required this.title,
    required this.url,
    this.faviconUrl,
    this.isLoading = false,
    this.loadingProgress = 0.0,
    this.isPrivate = true,
    required this.createdAt,
    required this.lastAccessedAt,
  });

  BrowserTab copyWith({
    String? id,
    String? title,
    String? url,
    String? faviconUrl,
    bool? isLoading,
    double? loadingProgress,
    bool? isPrivate,
    DateTime? createdAt,
    DateTime? lastAccessedAt,
  }) {
    return BrowserTab(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      faviconUrl: faviconUrl ?? this.faviconUrl,
      isLoading: isLoading ?? this.isLoading,
      loadingProgress: loadingProgress ?? this.loadingProgress,
      isPrivate: isPrivate ?? this.isPrivate,
      createdAt: createdAt ?? this.createdAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
    );
  }

  String get displayTitle {
    if (title.isEmpty) {
      if (url.startsWith('http')) {
        try {
          final uri = Uri.parse(url);
          return uri.host.replaceAll('www.', '');
        } catch (_) {
          return url;
        }
      }
      return 'New Tab';
    }
    return title;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        url,
        faviconUrl,
        isLoading,
        loadingProgress,
        isPrivate,
        createdAt,
        lastAccessedAt,
      ];
}
