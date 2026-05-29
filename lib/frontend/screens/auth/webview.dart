import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/extensions/l10n.dart";
import "package:antinote_app/frontend/widgets/customs/app_bar.dart";
import "package:antinote_app/main.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:webview_flutter/webview_flutter.dart";

class LoginWebview extends StatefulWidget {
  final MobileInstanceParameters parameters;
  final Workspace workspace;

  const LoginWebview({
    super.key,
    required this.parameters,
    required this.workspace,
  });

  @override
  State<LoginWebview> createState() => _LoginWebviewState();
}

class _LoginWebviewState extends State<LoginWebview> {
  late final WebViewController _controller;
  double _loadingProgress = 0;
  bool _loginHandled = false;

  Uri get _loginUrl {
    return widget.workspace
        .toSpecificAccountKind(widget.parameters.baseUrl)
        .replace(queryParameters: {...PronoteSession.redirectBypassParameters});
  }

  bool _matchesCriteria(Uri? url) {
    return url != null &&
        widget.parameters.baseUrl.authority == url.authority &&
        (url.queryParameters.containsKey("ticket") ||
            url.queryParameters.containsKey("identifiant"));
  }

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) => setState(() => _loadingProgress = p / 100),
          onNavigationRequest: (request) async {
            if (_loginHandled) return NavigationDecision.prevent;

            final url = Uri.tryParse(request.url);

            if (_matchesCriteria(url)) {
              _loginHandled = true;

              try {
                final result = await CasCredentials.loginFromTicketOrId(
                  url!,
                  widget.parameters.casToken,
                  widget.workspace,
                );

                if (mounted) {
                  context.pop(result);
                } else {
                  return NavigationDecision.navigate;
                }
              } catch (e, st) {
                _loginHandled = false;
                talker.error(
                  "Failed to login although matched criterion",
                  e,
                  st,
                );
              }

              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(_loginUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: context.l10n.loginWebview),

      body: Stack(
        children: [
          WebViewWidget(controller: _controller),

          if (_loadingProgress < 1)
            LinearProgressIndicator(value: _loadingProgress),
        ],
      ),
    );
  }
}
