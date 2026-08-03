import 'package:antinote_app/data/src/accounts/registry.dart';
import 'package:flutter/material.dart';

class AccountScope extends InheritedWidget {
  const AccountScope({super.key, required this.registry, required super.child});

  final AccountRegistry registry;

  static AccountScope of(BuildContext context) {
    final AccountScope? result = context
        .dependOnInheritedWidgetOfExactType<AccountScope>();
    assert(result != null, 'No AccountScope found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(AccountScope old) => old.registry != registry;
}
