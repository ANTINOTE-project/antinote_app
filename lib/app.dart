import "package:antinote_app/l10n/app_localizations.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:flutter/material.dart";

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "ANTINOTE",

      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale("fr"),

      home: Scaffold(),
    );
  }
}
