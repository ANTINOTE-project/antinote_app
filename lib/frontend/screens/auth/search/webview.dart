import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/extensions/l10n.dart";
import "package:antinote_app/frontend/widgets/customs/app_bar.dart";
import "package:antinote_app/main.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:webview_flutter/webview_flutter.dart";

class LoginSearchWebview extends StatefulWidget {
  final MobileInstanceParameters parameters;
  final Workspace workspace;

  const LoginSearchWebview({super.key, required this.parameters, required this.workspace});

  @override
  State<LoginSearchWebview> createState() => _LoginSearchWebviewState();
}

class _LoginSearchWebviewState extends State<LoginSearchWebview> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    // TODO: Ajouter cookies dans credential car pas uuidAppliMobile == pronote pas content
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) async {
            final url = Uri.tryParse(request.url);

            if (widget.parameters.baseUrl.authority == url?.authority &&
                ((url?.queryParameters.containsKey("ticket") ?? false) ||
                    (url?.queryParameters.containsKey("identifiant") ?? false))) {
              try {
                final result = await CasCredentials.loginFromTicketOrId(
                  url!,
                  widget.parameters.casToken,
                  widget.workspace,
                );

                if (!mounted) return .navigate;
                context.pop(result);

                // catch
              } catch (e, st) {
                talker.error("Failed to login although matched criterion", e, st);
              }

              return .prevent;
            }

            return .navigate;
          },
        ),
      )
      ..loadRequest(
        widget.workspace
            .toSpecificAccountKind(widget.parameters.baseUrl)
            .replace(queryParameters: {...PronoteSession.redirectBypassParameters}),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: context.l10n.loginWebview),
      body: WebViewWidget(controller: _controller),
    );
  }
}
