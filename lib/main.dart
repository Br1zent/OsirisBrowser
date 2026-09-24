import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/security/ios_privacy_cover_gate.dart';
import 'core/security/master_password_service.dart';
import 'core/services/app_state_service.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'data/datasources/local/app_database.dart';
import 'data/repositories/bookmark_repository_impl.dart';
import 'data/repositories/history_repository_impl.dart';
import 'data/repositories/privacy_settings_repository_impl.dart';
import 'domain/repositories/bookmark_repository.dart';
import 'domain/repositories/history_repository.dart';
import 'domain/repositories/privacy_settings_repository.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/browser/browser_bloc.dart';
import 'presentation/bloc/privacy/privacy_bloc.dart';
import 'presentation/screens/browser/browser_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF000000),
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  MasterPasswordService.instance.initialize();

  final results = await Future.wait([
    AppDatabase.getInstance(),
    SharedPreferences.getInstance(),
  ]);

  final db    = results[0] as AppDatabase;
  final prefs = results[1] as SharedPreferences;

  final BookmarkRepository bookmarkRepo = BookmarkRepositoryImpl(db);
  final HistoryRepository  historyRepo  = HistoryRepositoryImpl(db);
  final PrivacySettingsRepository privacyRepo =
      PrivacySettingsRepositoryImpl(prefs);

  final appState = AppStateService(prefs);

  runApp(OsirisApp(
    bookmarkRepository: bookmarkRepo,
    historyRepository: historyRepo,
    privacySettingsRepository: privacyRepo,
    appState: appState,
  ));
}

class OsirisApp extends StatelessWidget {
  final BookmarkRepository bookmarkRepository;
  final HistoryRepository  historyRepository;
  final PrivacySettingsRepository privacySettingsRepository;
  final AppStateService appState;

  const OsirisApp({
    super.key,
    required this.bookmarkRepository,
    required this.historyRepository,
    required this.privacySettingsRepository,
    required this.appState,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppStateService>.value(
      value: appState,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) => AuthBloc()..add(const AuthCheckStatus()),
          ),
          BlocProvider<BrowserBloc>(
            create: (_) => BrowserBloc(
              bookmarkRepository: bookmarkRepository,
              historyRepository: historyRepository,
            ),
          ),
          BlocProvider<PrivacyBloc>(
            create: (_) => PrivacyBloc(
              settingsRepository: privacySettingsRepository,
              historyRepository: historyRepository,
              bookmarkRepository: bookmarkRepository,
            ),
          ),
        ],
        child: IosPrivacyCoverGate(
          child: Consumer<AppStateService>(
            builder: (context, state, _) {
              return MaterialApp.router(
                title: 'Osiris Browser',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.buildTheme(state.accent),
                locale: state.locale,
                supportedLocales: const [Locale('en'), Locale('ru')],
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                routerConfig: AppRouter.router,
                builder: (context, child) {
                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: TextScaler.linear(
                        MediaQuery.of(context)
                            .textScaler
                            .scale(1.0)
                            .clamp(0.85, 1.3),
                      ),
                    ),
                    child: Stack(
                      children: [
                        child!,
                        BlocBuilder<BrowserBloc, BrowserState>(
                          buildWhen: (p, c) =>
                              p.isBrowserVisible != c.isBrowserVisible ||
                              p.hasBeenOpened != c.hasBeenOpened,
                          builder: (context, state) => Positioned.fill(
                            child: IgnorePointer(
                              ignoring: !state.isBrowserVisible,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeInOut,
                                opacity: state.isBrowserVisible ? 1.0 : 0.0,
                                child: state.hasBeenOpened
                                    ? const BrowserScreen()
                                    : const SizedBox.shrink(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
