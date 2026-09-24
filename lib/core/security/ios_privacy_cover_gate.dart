import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../router/app_router.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/bloc/browser/browser_bloc.dart';

/// Releases the native app-switcher cover only after a safe Flutter frame.
class IosPrivacyCoverGate extends StatefulWidget {
  final Widget child;

  const IosPrivacyCoverGate({super.key, required this.child});

  @override
  State<IosPrivacyCoverGate> createState() => _IosPrivacyCoverGateState();
}

class _IosPrivacyCoverGateState extends State<IosPrivacyCoverGate>
    with WidgetsBindingObserver {
  StreamSubscription<AuthState>? _authSubscription;
  StreamSubscription<BrowserState>? _browserSubscription;
  Timer? _releaseTimer;
  bool _observing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_observing) return;
    _observing = true;
    _authSubscription = context
        .read<AuthBloc>()
        .stream
        .listen((_) => _scheduleRelease());
    _browserSubscription =
        context.read<BrowserBloc>().stream.listen((_) => _scheduleRelease());
    AppRouter.router.routeInformationProvider.addListener(_scheduleRelease);
    _scheduleRelease();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _scheduleRelease();
    } else {
      _releaseTimer?.cancel();
    }
  }

  void _scheduleRelease() {
    _releaseTimer?.cancel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isSafeFrame()) {
        // Allow the browser overlay's hide animation to finish before lifting
        // the native cover.
        _releaseTimer = Timer(const Duration(milliseconds: 250), _releaseIfSafe);
      }
    });
  }

  bool _isSafeFrame() {
    if (!mounted ||
        !Platform.isIOS ||
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed ||
        context.read<BrowserBloc>().state.isBrowserVisible) {
      return false;
    }

    final status = context.read<AuthBloc>().state.status;
    final route = AppRouter.router.routeInformationProvider.value.uri.path;
    if (route == AppRouter.welcomeRoute) {
      return status != AuthStatus.initial && status != AuthStatus.loading;
    }
    final isProtectedRoute =
        route == AppRouter.homeRoute || route.startsWith('${AppRouter.homeRoute}/');
    return isProtectedRoute && status == AuthStatus.authenticated;
  }

  Future<void> _releaseIfSafe() async {
    if (!_isSafeFrame()) return;
    try {
      await const MethodChannel('osiris/platform_security')
          .invokeMethod<void>('resolvePrivacyCover');
    } on PlatformException {
      // Fail closed: the native cover remains if release cannot be confirmed.
    } on MissingPluginException {
      // Fail closed: this method is expected only on iOS.
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _releaseTimer?.cancel();
    _authSubscription?.cancel();
    _browserSubscription?.cancel();
    AppRouter.router.routeInformationProvider.removeListener(_scheduleRelease);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
