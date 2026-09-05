import 'dart:io';

import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/data/src/session/wrapper.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/customs/app_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewLoginScreen extends StatefulWidget {
  final MobileInstanceParameters parameters;
  final Workspace workspace;

  const WebviewLoginScreen({
    super.key,
    required this.parameters,
    required this.workspace,
  });

  @override
  State<WebviewLoginScreen> createState() => _WebviewLoginScreenState();
}

class _WebviewLoginScreenState extends State<WebviewLoginScreen> {
  late final WebViewController _controller;
  double _loadingProgress = 0;
  bool _loginHandled = false;

  Uri get _loginUrl {
    return widget.workspace
        .toSpecificAccountKind(widget.parameters.baseUrl)
        .replace(queryParameters: {...RemoteSession.redirectBypassParameters});
  }

  bool _matchesCriteria(Uri? url) {
    return url != null &&
        widget.parameters.baseUrl.authority == url.authority &&
        (url.queryParameters.containsKey('ticket') ||
            url.queryParameters.containsKey('identifiant'));
  }

  @override
  void initState() {
    super.initState();

    final manager = WebViewCookieManager();
    if (!kDebugMode) {
      manager.clearCookies();
    }

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
                final result = await TicketCredentials.loginFromTicketOrId(
                  url!,
                  widget.parameters.casToken,
                  widget.workspace,
                  Platform.localeName,
                );

                if (mounted) {
                  Navigator.pop(context, SessionWrapper.register(result));
                } else {
                  return NavigationDecision.navigate;
                }
              } catch (e, st) {
                _loginHandled = false;
                logger.severe(
                  'Failed to login although matched criterion',
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
      appBar: AppBarWidget(title: Text(context.l10n.loginToAccount)),

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
