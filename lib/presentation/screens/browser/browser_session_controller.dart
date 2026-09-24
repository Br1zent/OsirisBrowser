/// Coordinates destruction of WebViews before app-wide data wipes.
class BrowserSessionController {
  BrowserSessionController._();

  static final BrowserSessionController instance = BrowserSessionController._();

  final Set<Future<void> Function()> _closeHandlers = {};

  void register(Future<void> Function() closeHandler) {
    _closeHandlers.add(closeHandler);
  }

  void unregister(Future<void> Function() closeHandler) {
    _closeHandlers.remove(closeHandler);
  }

  Future<void> closeAll() async {
    if (_closeHandlers.isEmpty) {
      throw StateError('No WebView close handler is registered');
    }
    for (final closeHandler in _closeHandlers.toList()) {
      await closeHandler();
    }
  }
}
