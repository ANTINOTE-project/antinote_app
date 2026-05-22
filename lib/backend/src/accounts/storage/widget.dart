import 'package:antinote_ui/backend/src/accounts/storage/base.dart';
import 'package:flutter/widgets.dart';

class AccountStorageWidget extends InheritedWidget {
  const AccountStorageWidget({
    super.key,
    required this.storage,
    required super.child,
  });

  final AccountStorage storage;

  static AccountStorageWidget of(BuildContext context) {
    final AccountStorageWidget? result = context
        .dependOnInheritedWidgetOfExactType<AccountStorageWidget>();
    assert(result != null, 'No AccountStorageWidget found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(AccountStorageWidget old) {
    return false;
  }
}
