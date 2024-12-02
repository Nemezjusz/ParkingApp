import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_parking/navigation/app_router_paths.dart';
import 'package:smart_parking/navigation/auth_guard.dart';
import 'package:smart_parking/screens/login_screen.dart';
import 'package:smart_parking/screens/views/settings_view/settings_view.dart';
import 'package:smart_parking/screens/views_screen.dart';

class AppRouter {
  static final authGuard = AuthGuard();

  static final router = GoRouter(
    initialLocation: AppRouterPaths.views,
    redirect: (context, state) async => await authGuard.redirect(state),
    routes: [
      GoRoute(
        name: 'login',
        path: AppRouterPaths.login,
        builder: (BuildContext context, GoRouterState state) =>
            const LoginScreen(),
      ),
      GoRoute(
        name: 'parkingMap',
        path: AppRouterPaths.views,
        builder: (BuildContext context, GoRouterState state) =>
            const ViewsScreen(),
      ),
      GoRoute(
        name: 'settings',
        path: AppRouterPaths.settings,
        builder: (BuildContext context, GoRouterState state) =>
            const SettingsView(),
      ),
    ],
  );
}
