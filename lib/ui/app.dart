import 'package:antinote_app/data/src/settings/registry.dart';
import 'package:antinote_app/ui/l10n/app_localizations.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:material_ui/material_ui.dart';

class App extends StatefulWidget {
  final SettingsRegistry registry;
  final Widget home;

  const App({super.key, required this.home, required this.registry});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
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

              return MaterialApp(
                debugShowCheckedModeBanner: false,

                home: widget.home,
                title: 'ANTINOTE',

                theme: light,
                highContrastTheme: lightHighContrast,
                darkTheme: dark,
                highContrastDarkTheme: darkHighContrast,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
              );
            },
          ),
        );
      },
    );
  }
}
