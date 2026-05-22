import "package:antinote_app/backend/src/accounts/storage/base.dart";
import "package:flutter/material.dart";

extension AccountStorageExtension on BuildContext {
  AccountStorage get AS => AccountStorage.of(this);
}
