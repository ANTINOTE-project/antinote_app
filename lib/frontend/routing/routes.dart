abstract final class Routes {
  const Routes._();

  static const auth = _AuthRoute();

  static const home = "/home";
}

class _AuthRoute {
  const _AuthRoute();

  String get login => "/auth/login";
  String get pick => "/auth/pick";
}
