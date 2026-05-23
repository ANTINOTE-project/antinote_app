import "package:antinote_app/frontend/app.dart";
import "package:antinote_app/frontend/routing/routes.dart";
import "package:antinote_app/frontend/screens/auth/password/search.dart";
import "package:antinote_app/frontend/screens/auth/pick.dart";
import "package:antinote_app/frontend/screens/auth/login.dart";
import "package:go_router/go_router.dart";

GoRouter makeRouter({String initialLocation = Routes.home}) => GoRouter(
  initialLocation: initialLocation,
  navigatorKey: App.navigatorKey,

  routes: [
    GoRoute(path: Routes.auth.login, builder: (_, _) => const LoginScreen()),
    GoRoute(path: Routes.auth.pick, builder: (_, _) => const LoginPickScreen()),
    GoRoute(path: Routes.auth.password.search, builder: (_, _) => const LoginSearchScreen()),
  ],
);
