abstract final class Routes {
  const Routes._();

  static const appShell = "/app_shell";
  static const news = "/news";
  static const homework = "/homework";

  static const auth = _AuthRoute();
}

class _AuthRoute {
  const _AuthRoute();

  String get accounts => "/auth/accounts";

  String get methods => "/auth/methods";

  String get city => "/auth/city";

  String get url => "/auth/url";

  String get school => "/auth/school";

  String get workspace => "/auth/workspace";

  String get webview => "/auth/webview";
}
