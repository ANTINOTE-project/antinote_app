import "package:antinote_app/frontend/routing/routes.dart";
import "package:antinote_app/frontend/screens/login/screen.dart";
import "package:go_router/go_router.dart";

GoRouter makeRouter({String initialLocation = "/"}) => GoRouter(
  initialLocation: initialLocation,
  routes: [GoRoute(path: Routes.auth.login, builder: (_, _) => const LoginScreen())],
);
