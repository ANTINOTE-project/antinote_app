import "package:antinote_app/frontend/screens/shell/manager.dart";
import "package:flutter/material.dart";

extension ScreenManagerExtension on BuildContext {
  ScreenManager get sm => ScreenManager.of(this);
}
