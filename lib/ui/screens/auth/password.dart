import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/data/src/session/wrapper.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/customs/app_bar.dart';
import 'package:antinote_app/ui/widgets/customs/button.dart';
import 'package:antinote_app/ui/widgets/customs/field.dart';
import 'package:antinote_app/ui/widgets/customs/icon.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:material_ui/material_ui.dart';

class PasswordLoginScreen extends StatefulWidget {
  final Workspace workspace;
  final Uri baseUrl;

  const PasswordLoginScreen({
    super.key,
    required this.workspace,
    required this.baseUrl,
  });

  @override
  State<PasswordLoginScreen> createState() => _PasswordLoginScreenState();
}

class _PasswordLoginScreenState extends State<PasswordLoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _showPassword = false;
  bool loginJustFailed = false;

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

                  keyboardType: .name,
                  autofillHints: const [AutofillHints.username],
                  autoCorrect: false,
                  inputAction: .next,
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

                  keyboardType: .visiblePassword,
                  autofillHints: const [AutofillHints.password],
                  autoCorrect: false,
                  inputAction: .done,
                  obscureText: !_showPassword,
                ),

                const SizedBox(height: 4),

                ButtonWidget(
                  onPressed: () async {
                    final credentials = PasswordCredentials(
                      username: _usernameController.text.trim(),
                      password: _passwordController.text.trim(),

                      workspace: widget.workspace,
                      baseUrl: widget.baseUrl,
                      cookies: [],

                      deviceUuid: Credentials.generateDeviceUuid(),
                    );

                    try {
                      final result = await credentials.login(
                        options: context.s.networking.sessionOptions,
                      );

                      if (context.mounted) {
                        TextInput.finishAutofillContext();

                        Navigator.pop(
                          context,
                          SessionWrapper.register(result, credentials),
                        );
                      }
                    } catch (e, st) {
                      logger.severe('Could not login using password', e, st);
                      loginJustFailed = true;
                    }
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
