import "package:antinote_app/backend/src/session/manager.dart";
import "package:flutter/material.dart";

extension SessionManagerExtension on BuildContext {
  SessionManager get sm => SessionManager.of(this);
}
