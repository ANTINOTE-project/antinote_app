import "package:antinote_app/backend/src/accounts/storage/base.dart";
import "package:antinote_app/backend/src/session/manager.dart";
import "package:antinote_app/frontend/screens/shell/shell.dart";
import "package:antinote_app/frontend/theme.dart";
import "package:antinote_app/l10n/app_localizations.dart";
import "package:flutter/material.dart";

extension BuildContextExtensions on BuildContext {
  AccountStorage get as => AccountStorage.of(this);
  ColorScheme get c => ColorScheme.of(this);
  AppLocalizations get l10n => AppLocalizations.of(this)!;
  SessionManager get sm => SessionManager.of(this);
  ThemeNotifier get tn => ThemeScope.of(this);
  ShellController get sc => ShellController.of(this);
}
