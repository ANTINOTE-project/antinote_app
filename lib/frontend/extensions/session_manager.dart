// ignore_for_file: non_constant_identifier_names

import "package:antinote_app/backend/src/session/manager.dart";
import "package:flutter/material.dart";

extension SessionManagerExtension on BuildContext {
  SessionManager get SM => SessionManager.of(this);
}
