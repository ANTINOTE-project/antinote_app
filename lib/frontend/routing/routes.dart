abstract final class Routes {
  const Routes._();

  static const auth = _AuthRoute();
  static const home = "/home";
}

class _AuthRoute {
  const _AuthRoute();

  String get login => "/auth/login";
  String get pick => "/auth/pick";
  String get qrCode => "/auth/qr_code";

  final password = const _PasswordRoute();
}

class _PasswordRoute {
  const _PasswordRoute();

  String get search => "/auth/password/search";
  String get select => "/auth/password/select";
  String get credentials => "/auth/password/credentials";
}
