import "package:antinote_app/l10n/app_localizations.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:flutter/material.dart";

class App extends StatelessWidget {
  final Widget home;

  const App({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "ANTINOTE",

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale("fr"),

      home: home,
    );
  }
}
