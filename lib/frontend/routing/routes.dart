abstract final class Routes {
  const Routes._();

  static const appShell = "/app_shell";
  static const news = "/news";
  static const auth = _AuthRoute();
}

class _AuthRoute {
  const _AuthRoute();

  String get login => "/auth/login";
  String get pick => "/auth/pick";
  String get qrCode => "/auth/qr_code";

  final search = const _SearchRoute();
}

class _SearchRoute {
  const _SearchRoute();

  String get city => "/auth/search/city";
  String get url => "/auth/search/url";
  String get school => "/auth/search/school";
  String get select => "/auth/search/select";
  String get webview => "/auth/search/webview";
}
