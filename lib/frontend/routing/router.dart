import "package:antinote_app/frontend/app.dart";
import "package:antinote_app/frontend/routing/routes.dart";
import "package:antinote_app/frontend/screens/auth/search/city.dart";
import "package:antinote_app/frontend/screens/auth/pick.dart";
import "package:antinote_app/frontend/screens/auth/login.dart";
import "package:antinote_app/frontend/screens/auth/search/school.dart";
import "package:antinote_app/frontend/screens/home.dart";
import "package:go_router/go_router.dart";

GoRouter makeRouter({String initialLocation = Routes.home}) => GoRouter(
  initialLocation: initialLocation,
  navigatorKey: App.navigatorKey,

  routes: [
    GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen()),

    GoRoute(path: Routes.auth.login, builder: (_, _) => const LoginScreen()),
    GoRoute(path: Routes.auth.pick, builder: (_, _) => const LoginPickScreen()),

    GoRoute(path: Routes.auth.search.city, builder: (_, _) => const LoginSearchCityScreen()),
    GoRoute(
      path: Routes.auth.search.school,

      builder: (_, s) {
        final extra = s.extra as Map<String, dynamic>;
        return LoginSearchSchoolScreen(lat: extra["lat"] as double, long: extra["long"] as double);
      },
    ),
  ],
);
