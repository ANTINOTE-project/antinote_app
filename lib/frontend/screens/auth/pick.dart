import "package:antinote_app/frontend/extensions/l10n.dart";
import "package:antinote_app/frontend/widgets/customs/app_bar.dart";
import "package:flutter/material.dart";

class LoginPickScreen extends StatelessWidget {
  const LoginPickScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBarWidget(title: context.l10n.choseAnAccount));
  }
}
