import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/security/master_password_service.dart';
import '../../presentation/screens/welcome/welcome_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/privacy_hub/privacy_hub_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';

class AppRouter {
  AppRouter._();

  static const String welcomeRoute = '/welcome';
  static const String homeRoute = '/home';
  static const String privacyHubRoute = '/privacy-hub';
  static const String settingsRoute = '/settings';

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: welcomeRoute,
      debugLogDiagnostics: false,
      redirect: (BuildContext context, GoRouterState state) async {
        final isPasswordSet =
            await MasterPasswordService.instance.isMasterPasswordSet();

        final isGoingToWelcome = state.matchedLocation == welcomeRoute;

        // If no password set, force to welcome
        if (!isPasswordSet && !isGoingToWelcome) {
          return welcomeRoute;
        }

        // If password is set and going to welcome (but already unlocked), go home
        if (isPasswordSet && isGoingToWelcome) {
          // Check if already unlocked in memory
          // This will be handled by the WelcomeScreen itself
          return null;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: welcomeRoute,
          name: 'welcome',
          builder: (context, state) => const WelcomeScreen(),
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const WelcomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),
        GoRoute(
          path: homeRoute,
          name: 'home',
          builder: (context, state) => const HomeScreen(),
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const HomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
          ),
          routes: [
            GoRoute(
              path: 'privacy-hub',
              name: 'privacy-hub',
              builder: (context, state) => const PrivacyHubScreen(),
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const PrivacyHubScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: child,
                  );
                },
              ),
            ),
            GoRoute(
              path: 'settings',
              name: 'settings',
              builder: (context, state) => const SettingsScreen(),
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const SettingsScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: child,
                  );
                },
              ),
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text(
                'Page not found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                state.error?.toString() ?? 'Unknown error',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(homeRoute),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
}
