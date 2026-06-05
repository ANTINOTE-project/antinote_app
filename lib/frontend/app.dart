import "package:antinote_app/frontend/routing/router.dart";
import "package:antinote_app/frontend/theme.dart";
import "package:antinote_app/l10n/app_localizations.dart";
import "package:flutter/material.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:go_router/go_router.dart";

class App extends StatefulWidget {
  final String initialLocation;

  const App({super.key, required this.initialLocation});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _themeNotifier = ThemeNotifier();
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = makeRouter(initialLocation: widget.initialLocation);
  }

  @override
  void dispose() {
    _themeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeNotifier,

      builder: (context, child) {
        return ThemeScope(
          notifier: _themeNotifier,

          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,

            title: "ANTINOTE",

            theme: _themeNotifier.light,
            darkTheme: _themeNotifier.dark,

            routerConfig: _router,

            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            supportedLocales: AppLocalizations.supportedLocales,
          ),
        );
      },
    );
  }
}
