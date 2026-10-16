import 'package:antinote_app/data/src/accounts/registry.dart';
import 'package:antinote_app/data/src/accounts/storage/widget.dart';
import 'package:antinote_app/data/src/settings/registry.dart';
import 'package:antinote_app/ui/features/shell/shell.dart';
import 'package:antinote_app/ui/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

extension BuildContextExtensions on BuildContext {
  ColorScheme get c => ColorScheme.of(this);

  AppLocalizations get l10n => AppLocalizations.of(this)!;

  AccountRegistry get ar => AccountScope.of(this).registry;

  SettingsRegistry get s => SettingsScope.of(this).registry;

  TextTheme get tt => TextTheme.of(this);

  ShellController get sc => ShellController.of(this);
}

extension CustomTextThemeStyles on TextTheme {
  TextStyle? get classTitle => titleLarge?.copyWith(
    fontVariations: const [
      .new('ROND', 100),
      .weight(700),
      .width(110),
      .opticalSize(100),
    ],
  );

  TextStyle? get classStatus => titleSmall?.copyWith(
    fontVariations: const [.weight(800), .new('ROND', 50), .width(105)],
  );

  TextStyle? get classSubtitle => bodyLarge?.copyWith(
    fontVariations: const [.weight(450), .new('ROND', 100), .width(90)],
  );
}
