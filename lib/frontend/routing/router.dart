import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/routing/routes.dart";
import "package:antinote_app/frontend/screens/auth/login.dart";
import "package:antinote_app/frontend/screens/auth/pick.dart";
import "package:antinote_app/frontend/screens/auth/search/city.dart";
import "package:antinote_app/frontend/screens/auth/search/school.dart";
import "package:antinote_app/frontend/screens/auth/search/select.dart";
import "package:antinote_app/frontend/screens/auth/search/webview.dart";
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
      path: Routes.auth.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: Routes.auth.pick,
      builder: (context, state) => const LoginPickScreen(),
    ),

    GoRoute(
      path: Routes.auth.search.city,
      builder: (context, state) => const LoginSearchCityScreen(),
    ),
    GoRoute(
      path: Routes.auth.search.school,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return LoginSearchSchoolScreen(
          lat: extra["lat"] as double,
          long: extra["long"] as double,
        );
      },
    ),
    GoRoute(
      path: Routes.auth.search.select,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return LoginSearchSelect(
          parameters: extra["parameters"] as MobileInstanceParameters,
        );
      },
    ),
    GoRoute(
      path: Routes.auth.search.webview,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return LoginSearchWebview(
          parameters: extra["parameters"] as MobileInstanceParameters,
          workspace: extra["workspace"] as Workspace,
        );
      },
    ),
  ],
);
