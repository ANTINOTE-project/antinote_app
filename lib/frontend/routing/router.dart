import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/routing/routes.dart";
import "package:antinote_app/frontend/screens/auth/accounts.dart";
import "package:antinote_app/frontend/screens/auth/city.dart";
import "package:antinote_app/frontend/screens/auth/pick.dart";
import "package:antinote_app/frontend/screens/auth/school.dart";
import "package:antinote_app/frontend/screens/auth/url.dart";
import "package:antinote_app/frontend/screens/auth/webview.dart";
import "package:antinote_app/frontend/screens/auth/workspace.dart";
import "package:antinote_app/frontend/screens/shell/shell.dart";
import "package:go_router/go_router.dart";

GoRouter makeRouter({String initialLocation = Routes.appShell}) => GoRouter(
  initialLocation: initialLocation,
  routes: [
    GoRoute(
      path: Routes.appShell,
      builder: (context, state) => const AppShell(),
    ),
    GoRoute(
      path: Routes.auth.accounts,
      builder: (context, state) => const AccountsScreen(),
    ),
    GoRoute(
      path: Routes.auth.pick,
      builder: (context, state) => const LoginPickScreen(),
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
          lat: extra["lat"] as double,
          long: extra["long"] as double,
        );
      },
    ),
    GoRoute(
      path: Routes.auth.workspace,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return LoginSelectWorkspace(
          parameters: extra["parameters"] as MobileInstanceParameters,
        );
      },
    ),
    GoRoute(
      path: Routes.auth.webview,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return LoginWebview(
          parameters: extra["parameters"] as MobileInstanceParameters,
          workspace: extra["workspace"] as Workspace,
        );
      },
    ),
  ],
);
