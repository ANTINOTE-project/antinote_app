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
            customBuilder: (schemes) {
              final dynamic = widget.registry.theme.isDynamic;

              final ThemeData light;
              final ThemeData lightHighContrast;
              final ThemeData dark;
              final ThemeData darkHighContrast;

              if (dynamic) {
                light = widget.registry.theme.create(
                  schemes?.light ?? widget.registry.theme.light,
                );
                lightHighContrast = widget.registry.theme.create(
                  schemes?.lightHighContrast ??
                      widget.registry.theme.lightHighContrast,
                );
                dark = widget.registry.theme.create(
                  schemes?.dark ?? widget.registry.theme.dark,
                );
                darkHighContrast = widget.registry.theme.create(
                  schemes?.darkHighContrast ??
                      widget.registry.theme.darkHighContrast,
                );
              } else {
                light = widget.registry.theme.create(
                  widget.registry.theme.light,
                );
                lightHighContrast = widget.registry.theme.create(
                  widget.registry.theme.lightHighContrast,
                );
                dark = widget.registry.theme.create(widget.registry.theme.dark);
                darkHighContrast = widget.registry.theme.create(
                  widget.registry.theme.darkHighContrast,
                );
              }

              return MaterialApp(
                builder: (context, child) {
                  return MaterialUiCompatibilityBridge(child: child!);
                },
                debugShowCheckedModeBanner: false,
                home: widget.home,
                title: 'ANTINOTE',

                theme: light,
                highContrastTheme: lightHighContrast,
                darkTheme: dark,
                highContrastDarkTheme: darkHighContrast,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  ...GlobalMaterialLocalizations.delegates,
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
