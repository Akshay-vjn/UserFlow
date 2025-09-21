import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'features/user/presentation/home_screen.dart';
import 'features/user/presentation/create_user_screen.dart';
import 'features/user/presentation/user_detail_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'core/widgets/no_network_screen.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'core/services/connectivity_service.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:userflow/features/user/domain/user_model.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final localeProvider = StateProvider<Locale?>((ref) => null);

final routerProvider = Provider<GoRouter>((ref) {
  final routerNotifier = RouterNotifier(ref);
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    refreshListenable: routerNotifier,
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/create-user', builder: (_, __) => const CreateUserScreen()),
      GoRoute(
        path: '/user-detail/:userId',
        builder: (_, state) {
          final extra = state.extra;
          return UserDetailScreen(
            userId: int.parse(state.pathParameters['userId']!),
            initialUser: extra is User ? extra : null,
          );
        },
      ),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/no-network', builder: (_, __) => const NoNetworkScreen()),
    ],
    redirect: routerNotifier.redirectLogic,
  );
});

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  String? _lastValidPath;
  Timer? _offlineTimer;
  bool _isTrulyOffline = false;

  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());
    _ref.listen<AsyncValue<bool>>(
      connectivityStatusProvider,
      (previous, next) {
        final nextOnline = next.asData?.value == true;
        final nextOffline = next.asData?.value == false;

        final isFirstEvent = previous == null;
        if (isFirstEvent && nextOffline) {
          _offlineTimer?.cancel();
          if (_isTrulyOffline != true) {
            _isTrulyOffline = true;
            notifyListeners();
          }
          return;
        }

        if (nextOnline) {
          _offlineTimer?.cancel();
          if (_isTrulyOffline) {
            _isTrulyOffline = false;
            notifyListeners();
          } else {
            notifyListeners();
          }
          return;
        }

        if (nextOffline) {
          _offlineTimer?.cancel();
          _offlineTimer = Timer(const Duration(seconds: 1), () {
            final latest = _ref.read(connectivityStatusProvider).maybeWhen(
                  data: (v) => v,
                  orElse: () => true,
                );
            if (!latest && !_isTrulyOffline) {
              _isTrulyOffline = false;
            }
            if (!latest) {
              _isTrulyOffline = true;
              notifyListeners();
            }
          });
          return;
        }
      },
    );
  }

  String? redirectLogic(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authProvider);

    final onNoNetwork = state.uri.path == '/no-network';
    final onSplash = state.uri.path == '/';

    final isOffline = _isTrulyOffline;

    if (isOffline) {
      if (onNoNetwork || onSplash) return null;
      _lastValidPath = state.uri.path;
      return '/no-network';
    }

    if (onNoNetwork) {
      if (_lastValidPath != null && authState is AuthAuthenticated) {
        final pathToReturn = _lastValidPath!;
        _lastValidPath = null;
        return pathToReturn;
      }
      return authState is AuthAuthenticated ? '/home' : '/login';
    }

    if ((authState is AuthUnauthenticated || authState is AuthInitial || authState is AuthError)
        && state.uri.path != '/login' && state.uri.path != '/') {
      return '/login';
    }

    if (authState is AuthAuthenticated && state.uri.path == '/login') return '/home';

    return null;
  }

  @override
  void dispose() {
    _offlineTimer?.cancel();
    super.dispose();
  }
}

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).restoreFromLocal();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      routerConfig: router,
      title: 'UserFlow',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
      ),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      builder: (context, child) => child!,
    );
  }
}