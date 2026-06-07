import "dart:async";

import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/widgets/customs/app_bar.dart";
import "package:antinote_app/frontend/widgets/customs/button.dart";
import "package:antinote_app/frontend/widgets/customs/field.dart";
import "package:antinote_app/frontend/widgets/customs/loading.dart";
import "package:antinote_app/utils/utils.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:hugeicons_pro/hugeicons.dart";
import "package:mobile_scanner/mobile_scanner.dart";

class LoginQrCodeScreen extends StatefulWidget {
  const LoginQrCodeScreen({super.key});

  @override
  State<LoginQrCodeScreen> createState() => _LoginQrCodeScreenState();
}

class _LoginQrCodeScreenState extends State<LoginQrCodeScreen> {
  final _scanController = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
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
        padding: const EdgeInsets.all(16),

        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;

            final scanWindow = Rect.fromCenter(
              center: size.center(Offset.zero),
              width: 250,
              height: 250,
            );

            return ClipRRect(
              borderRadius: BorderRadius.circular(24),

              child: MobileScanner(
                controller: _scanController,
                scanWindow: scanWindow,
                tapToFocus: true,

                errorBuilder: (context, _) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: .center,
                      spacing: 6,

                      children: [
                        Icon(
                          HugeIconsSolid.securityWarning,
                          color: context.c.errorContainer,
                          size: 32,
                        ),

                        Text(
                          context.l10n.anErrorOccurred,

                          style: TextStyle(
                            fontWeight: .w800,
                            color: context.c.errorContainer,
                            fontSize: 17,
                          ),
                        ),

                        const SizedBox(height: 10),

                        ButtonWidget(
                          onPressed: () => _scanController.start(),
                          label: context.l10n.retry,
                        ),
                      ],
                    ),
                  );
                },

                overlayBuilder: (context, _) {
                  return Stack(
                    children: [
                      ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          context.c.scrim.withAlpha(128),
                          BlendMode.srcOut,
                        ),

                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                backgroundBlendMode: BlendMode.dstOut,
                                color: context.c.surface,
                              ),
                            ),

                            Center(
                              child: Container(
                                height: 250,
                                width: 250,

                                decoration: BoxDecoration(
                                  borderRadius: .circular(20),
                                  color: context.c.surface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Align(
                        child: CustomPaint(
                          size: const Size(250, 250),

                          painter: _ScannerOverlayPainter(
                            borderColor: context.c.primary,
                            borderRadius: 20,
                          ),
                        ),
                      ),
                    ],
                  );
                },

                placeholderBuilder: (context) {
                  return const LoadingWidget();
                },

                onDetect: (result) async {
                  if (_isProcessing) return;
                  _isProcessing = true;

                  final readValue = result.barcodes.first.rawValue;

                  if (readValue == null) {
                    _isProcessing = false;
                    return;
                  }

                  final createdCredentials = await _askForPin(readValue);

                  if (createdCredentials != null && context.mounted) {
                    context.pop(createdCredentials);
                  }

                  _isProcessing = false;
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  final Color borderColor;
  final double borderRadius;

  _ScannerOverlayPainter({
    required this.borderColor,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..style = .stroke
      ..strokeCap = .round
      ..strokeWidth = 4;

    final arcSize = borderRadius * 2;

    // Top Left
    canvas.drawArc(
      Rect.fromLTWH(0, 0, arcSize, arcSize),
      3.14,
      1.57,
      false,
      paint,
    );
    canvas.drawLine(
      Offset(borderRadius, 0),
      Offset(borderRadius + 20, 0),
      paint,
    );
    canvas.drawLine(
      Offset(0, borderRadius),
      Offset(0, borderRadius + 20),
      paint,
    );

    // Top Right
    canvas.drawArc(
      Rect.fromLTWH(size.width - arcSize, 0, arcSize, arcSize),
      -1.57,
      1.57,
      false,
      paint,
    );
    canvas.drawLine(
      Offset(size.width - borderRadius, 0),
      Offset(size.width - borderRadius - 20, 0),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, borderRadius),
      Offset(size.width, borderRadius + 20),
      paint,
    );

    // Bottom Left
    canvas.drawArc(
      Rect.fromLTWH(0, size.height - arcSize, arcSize, arcSize),
      1.57,
      1.57,
      false,
      paint,
    );
    canvas.drawLine(
      Offset(borderRadius, size.height),
      Offset(borderRadius + 20, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height - borderRadius),
      Offset(0, size.height - borderRadius - 20),
      paint,
    );

    // Bottom Right
    canvas.drawArc(
      Rect.fromLTWH(
        size.width - arcSize,
        size.height - arcSize,
        arcSize,
        arcSize,
      ),
      0,
      1.57,
      false,
      paint,
    );
    canvas.drawLine(
      Offset(size.width - borderRadius, size.height),
      Offset(size.width - borderRadius - 20, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height - borderRadius),
      Offset(size.width, size.height - borderRadius - 20),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: .circular(24)),
      backgroundColor: context.c.surfaceContainerHigh,

      child: Padding(
        padding: const .all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          spacing: 14,

          children: [
            Text(
              context.l10n.loginPinCode,

              style: const TextStyle(fontWeight: .w900, fontSize: 22),
              textAlign: .center,
            ),

            Text(
              context.l10n.loginPinCodeSubtitle,

              textAlign: .center,
              style: TextStyle(
                fontWeight: .bold,
                color: context.c.onSurfaceVariant,
              ),
            ),

            FieldWidget(
              controller: _pinCodeController,
              keyboardType: .number,
              hintText: "0000",
            ),

            Row(
              spacing: 12,

              children: [
                Expanded(
                  child: TextButton(
                    onPressed: context.pop,

                    child: Text(
                      context.l10n.cancel,
                      style: const TextStyle(fontWeight: .w800),
                    ),
                  ),
                ),

                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      final text = _pinCodeController.text.trim();

                      if (text.length == 4) {
                        context.pop(text);
                      }
                    },

                    child: Text(
                      context.l10n.validate,
                      style: const TextStyle(fontWeight: .w800),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
