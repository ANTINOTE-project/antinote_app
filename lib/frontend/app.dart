import "package:antinote_app/backend/src/settings/registry.dart";
import "package:antinote_app/frontend/routing/router.dart";
import "package:antinote_app/l10n/app_localizations.dart";
import "package:dynamic_color/dynamic_color.dart";
import "package:flutter/material.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:go_router/go_router.dart";

class App extends StatefulWidget {
  final String initialLocation;
  final SettingsRegistry registry;

  const App({super.key, required this.initialLocation, required this.registry});

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
  void dispose() {
    widget.registry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.registry,

      builder: (context, child) {
        return SettingsScope(
          registry: widget.registry,

          child: DynamicColorBuilder(
            builder: (dynamicLight, dynamicDark) {
              final dynamic = widget.registry.theme.isDynamic;

              final ThemeData light;
              final ThemeData dark;
              if (dynamic) {
                light = widget.registry.theme.create(
                  dynamicLight ?? widget.registry.theme.light,
                );
                dark = widget.registry.theme.create(
                  dynamicDark ?? widget.registry.theme.dark,
                );
              } else {
                light = widget.registry.theme.create(
                  widget.registry.theme.light,
                );
                dark = widget.registry.theme.create(widget.registry.theme.dark);
              }

              final lightHighContrast = widget.registry.theme.create(
                widget.registry.theme.lightHighContrast,
              );
              final darkHighContrast = widget.registry.theme.create(
                widget.registry.theme.darkHighContrast,
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
