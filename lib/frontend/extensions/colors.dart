import "package:flutter/material.dart";

extension ColorsExtension on BuildContext {
  ColorScheme get c => ColorScheme.of(this);
}
