// ignore_for_file: non_constant_identifier_names

import "package:antinote_app/backend/src/accounts/storage/base.dart";
import "package:flutter/material.dart";

extension AccountStorageExtension on BuildContext {
  AccountStorage get AS => AccountStorage.of(this);
}
