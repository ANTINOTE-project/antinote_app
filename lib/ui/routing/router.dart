import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/ui/routing/routes.dart';
import 'package:antinote_app/ui/screens/auth/accounts.dart';
import 'package:antinote_app/ui/screens/auth/city.dart';
import 'package:antinote_app/ui/screens/auth/methods.dart';
import 'package:antinote_app/ui/screens/auth/password.dart';
import 'package:antinote_app/ui/screens/auth/qr_code.dart';
import 'package:antinote_app/ui/screens/auth/school.dart';
import 'package:antinote_app/ui/screens/auth/url.dart';
import 'package:antinote_app/ui/screens/auth/webview.dart';
import 'package:antinote_app/ui/screens/auth/workspace.dart';
import 'package:antinote_app/ui/screens/settings/screen.dart';
import 'package:antinote_app/ui/screens/shell/shell.dart';
import 'package:go_router/go_router.dart';

GoRouter makeRouter({String initialLocation = Routes.appShell}) => GoRouter(
  initialLocation: initialLocation,

  routes: [
    GoRoute(
      path: Routes.appShell,
      builder: (context, state) => const AppShell(),
    ),

    GoRoute(
      path: Routes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),

    // Auth routes
    GoRoute(
      path: Routes.auth.accounts,
      builder: (context, state) => const AccountsScreen(),
    ),
    GoRoute(
      path: Routes.auth.methods,
      builder: (context, state) => const MethodsScreen(),
    ),
    GoRoute(
      path: Routes.auth.city,
      builder: (context, state) => const LoginFindCityScreen(),
    ),
    GoRoute(
      path: Routes.auth.url,
      builder: (context, state) => const LoginUrlScreen(),
    ),
    GoRoute(
      path: Routes.auth.school,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return LoginSelectSchoolScreen(
          lat: extra['lat'] as double,
          long: extra['long'] as double,
        );
      },
    ),
    GoRoute(
      path: Routes.auth.workspace,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return LoginSelectWorkspaceScreen(
          parameters: extra['parameters'] as MobileInstanceParameters,
        );
      },
    ),
    GoRoute(
      path: Routes.auth.webview,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return LoginWebviewScreen(
          parameters: extra['parameters'] as MobileInstanceParameters,
          workspace: extra['workspace'] as Workspace,
        );
      },
    ),
    GoRoute(
      path: Routes.auth.password,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return LoginPasswordScreen(
          workspace: extra['workspace'] as Workspace,
          baseUrl: extra['baseUrl'] as Uri,
        );
      },
    ),
    GoRoute(
      path: Routes.auth.qrCode,
      builder: (context, state) => const LoginQrCodeScreen(),
    ),
  ],
);
