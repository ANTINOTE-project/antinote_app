import "package:antinote_app/backend/src/accounts/storage/base.dart";
import "package:flutter/widgets.dart";

class AccountScope extends InheritedWidget {
  const AccountScope({super.key, required this.storage, required super.child});

  final AccountStorage storage;

  static AccountScope of(BuildContext context) {
    final AccountScope? result = context
        .dependOnInheritedWidgetOfExactType<AccountScope>();
    assert(result != null, "No AccountScope found in context");
    return result!;
  }

  @override
  bool updateShouldNotify(AccountScope old) => old.storage != storage;
}
