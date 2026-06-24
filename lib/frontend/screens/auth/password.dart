import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/widgets/customs/app_bar.dart";
import "package:antinote_app/frontend/widgets/customs/button.dart";
import "package:antinote_app/frontend/widgets/customs/field.dart";
import "package:antinote_app/frontend/widgets/customs/icon.dart";
import "package:antinote_app/utils/utils.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:hugeicons_pro/hugeicons.dart";

class LoginPasswordScreen extends StatefulWidget {
  final Workspace workspace;
  final Uri baseUrl;

  const LoginPasswordScreen({
    super.key,
    required this.workspace,
    required this.baseUrl,
  });

  @override
  State<LoginPasswordScreen> createState() => _LoginPasswordScreenState();
}

class _LoginPasswordScreenState extends State<LoginPasswordScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: Text(context.l10n.loginToAccount)),

      body: Center(
        child: SingleChildScrollView(
          padding: const .symmetric(horizontal: 12),

          child: AutofillGroup(
            child: Column(
              spacing: 8,

              children: [
                FieldWidget(
                  controller: _usernameController,

                  prefixIcon: const Icon(HugeIconsSolid.user),
                  hintText: context.l10n.loginUsername,

                  keyboardType: TextInputType.name,
                  autofillHints: const [AutofillHints.username],
                  inputAction: TextInputAction.next,
                ),

                FieldWidget(
                  controller: _passwordController,

                  prefixIcon: const Icon(HugeIconsSolid.lockPassword),

                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },

                    icon: IconWidget(
                      iconOn: HugeIconsSolid.view,
                      iconOff: HugeIconsSolid.viewOffSlash,
                      value: _showPassword,
                    ),
                  ),

                  hintText: context.l10n.loginPassword,

                  keyboardType: TextInputType.visiblePassword,
                  autofillHints: const [AutofillHints.password],
                  inputAction: TextInputAction.done,
                  obscureText: !_showPassword,
                ),

                const SizedBox(height: 4),

                ButtonWidget(
                  onPressed: () async {
                    final credentials = PasswordCredentials(
                      username: _usernameController.text.trim(),
                      password: _passwordController.text.trim(),

                      workspace: widget.workspace,
                      pronoteBaseUrl: widget.baseUrl,

                      deviceUuid: Credentials.generateDeviceUuid(),
                    );

                    final result = credentials.login(
                      options: context.s.networking.sessionOptions,
                    );
                    context.pop(result);
                  },

                  label: context.l10n.loginButton,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
