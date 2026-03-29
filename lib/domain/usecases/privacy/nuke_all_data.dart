import '../../repositories/history_repository.dart';
import '../../repositories/bookmark_repository.dart';

class NukeAllData {
  final HistoryRepository historyRepository;
  final BookmarkRepository bookmarkRepository;

  NukeAllData({
    required this.historyRepository,
    required this.bookmarkRepository,
  });

  Future<void> call({bool clearBookmarks = false}) async {
    // Always clear history
    await historyRepository.clearAllHistory();

    // Optionally clear bookmarks
    if (clearBookmarks) {
      await bookmarkRepository.deleteAllBookmarks();
    }
  }
}
