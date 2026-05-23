import "package:antinote_app/frontend/routing/router.dart";
import "package:antinote_app/frontend/theme/theme.dart";
import "package:antinote_app/l10n/app_localizations.dart";
import "package:flutter/material.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:go_router/go_router.dart";

class App extends StatefulWidget {
  final String initialLocation;

  const App({super.key, required this.initialLocation});

  static final navigatorKey = GlobalKey<NavigatorState>();

  static const borderRadius = BorderRadius.all(Radius.circular(20));
  static const String fontFamily = "SNPro";

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = makeRouter(initialLocation: widget.initialLocation);
  }

  @override
  Widget build(BuildContext context) {
    const theme = MaterialTheme();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,

      title: "ANTINOTE",

      highContrastDarkTheme: theme.darkHighContrast(),
      highContrastTheme: theme.lightHighContrast(),
      darkTheme: theme.dark(),
      theme: theme.light(),

      routerConfig: _router,

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
