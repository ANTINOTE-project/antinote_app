import "package:antinote_app/frontend/routing/router.dart";
import "package:antinote_app/frontend/theme.dart";
import "package:antinote_app/l10n/app_localizations.dart";
import "package:dynamic_color/dynamic_color.dart";
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

          child: DynamicColorBuilder(
            builder: (dynamicLight, dynamicDark) {
              final dynamic = _themeNotifier.isDynamic;

              final ThemeData light;
              final ThemeData dark;
              if (dynamic) {
                light = _themeNotifier.theme(
                  dynamicLight ?? _themeNotifier.light,
                );
                dark = _themeNotifier.theme(dynamicDark ?? _themeNotifier.dark);
              } else {
                light = _themeNotifier.theme(_themeNotifier.light);
                dark = _themeNotifier.theme(_themeNotifier.dark);
              }

              final lightHighContrast = _themeNotifier.theme(
                _themeNotifier.lightHighContrast,
              );
              final darkHighContrast = _themeNotifier.theme(
                _themeNotifier.darkHighContrast,
              );

              return MaterialApp.router(
                debugShowCheckedModeBanner: false,

                title: "ANTINOTE",

                theme: light,
                highContrastTheme: lightHighContrast,
                darkTheme: dark,
                highContrastDarkTheme: darkHighContrast,

                routerConfig: _router,

                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],

                supportedLocales: AppLocalizations.supportedLocales,
              );
            },
          ),
        );
      },
    );
  }
}
