import "package:antinote_app/frontend/routing/router.dart";
import "package:antinote_app/frontend/theme/theme.dart";
import "package:antinote_app/l10n/app_localizations.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

class App extends StatelessWidget {
  final String initialLocation;
  late final GoRouter _router;

  App({super.key, required this.initialLocation}) {
    _router = makeRouter(initialLocation: initialLocation);
  }

  static final navigatorKey = GlobalKey<NavigatorState>();

  static const BorderRadiusGeometry borderRadius = BorderRadius.all(Radius.circular(20));
  static const String fontFamily = "SNPro";

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,

      title: "ANTINOTE",
      theme: buildTheme(),

      routerConfig: _router,

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale("fr"),
    );
  }
}
