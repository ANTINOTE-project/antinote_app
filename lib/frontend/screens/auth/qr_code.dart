import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/widgets/customs/app_bar.dart";
import "package:antinote_app/frontend/widgets/customs/field.dart";
import "package:antinote_app/utils.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:mobile_scanner/mobile_scanner.dart";

class LoginQrCodeScreen extends StatefulWidget {
  const LoginQrCodeScreen({super.key});

  @override
  State<LoginQrCodeScreen> createState() => _LoginQrCodeScreenState();
}

class _LoginQrCodeScreenState extends State<LoginQrCodeScreen> {
  final _scanController = MobileScannerController();

  @override
  void dispose() {
    super.dispose();
    _scanController.dispose();
  }

  Future<Future<LoginResult>?> _askForPin(String qrCodeContent) async {
    final pinCode = await showDialog<String?>(
      context: context,
      builder: (context) => _PinCodeDialog(qrCodeContent: qrCodeContent),
    );

    if (pinCode == null) return null;

    return QrCodeCredentials.loginFromQrCode(qrCodeContent, pinCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: context.l10n.loginQrCode),

      body: Padding(
        padding: const .all(12),

        child: ClipRRect(
          borderRadius: .circular(20),

          child: MobileScanner(
            controller: _scanController,

            onDetect: (result) async {
              final readValue = result.barcodes.first.rawValue;
              await _scanController.pause();

              final createdCredentials = await _askForPin(readValue!);

              if (createdCredentials != null && context.mounted) {
                context.pop(createdCredentials);
              } else {
                await _scanController.start();
              }
            },
          ),
        ),
      ),
    );
  }
}

class _PinCodeDialog extends StatefulWidget {
  final String qrCodeContent;

  const _PinCodeDialog({required this.qrCodeContent});

  @override
  State<_PinCodeDialog> createState() => _PinCodeDialogState();
}

class _PinCodeDialogState extends State<_PinCodeDialog> {
  final _pinCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.loginPinCode),

      content: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          Text(context.l10n.loginPinCodeSubtitle),

          FieldWidget(
            controller: _pinCodeController,
            hintText: context.l10n.loginPinCode,
            keyboardType: .number,
          ),
        ],
      ),

      actions: [
        TextButton(
          onPressed: () {
            context.pop();
          },

          child: Text(context.l10n.cancel),
        ),

        TextButton(
          onPressed: () {
            final text = _pinCodeController.text.trim();

            if (text.length == 4) {
              context.pop(text);
            }
          },

          child: Text(context.l10n.validate),
        ),
      ],
    );
  }
}
