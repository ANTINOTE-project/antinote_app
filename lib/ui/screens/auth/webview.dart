import 'dart:io';

import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/data/src/session/wrapper.dart';
import 'package:antinote_app/ui/utils/src/context.dart';
import 'package:antinote_app/ui/widgets/customs/app_bar.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:material_ui/material_ui.dart';

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
    CookieManager.instance().deleteAllCookies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: Text(context.l10n.loginToAccount)),

      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri.uri(_loginUrl)),

            onProgressChanged: (controller, progress) {
              setState(() => _loadingProgress = progress / 100);
            },

            shouldOverrideUrlLoading: (controller, action) async {
              if (_loginHandled) return NavigationActionPolicy.CANCEL;
              final url = action.request.url?.uriValue;

              if (_matchesCriteria(url)) {
                _loginHandled = true;

                try {
                  final result = await TicketCredentials.loginFromTicketOrId(
                    url!,
                    widget.parameters.casToken,
                    widget.workspace,
                    Platform.localeName,
                  );

                  if (context.mounted) {
                    Navigator.pop(context, SessionWrapper.register(result));
                  } else {
                    return NavigationActionPolicy.ALLOW;
                  }
                } catch (e, st) {
                  _loginHandled = false;
                  logger.severe(
                    'Failed to login although matched criterion',
                    e,
                    st,
                  );
                }

                return NavigationActionPolicy.CANCEL;
              }

              return NavigationActionPolicy.ALLOW;
            },
          ),

          if (_loadingProgress < 1)
            LinearProgressIndicator(value: _loadingProgress),
        ],
      ),
    );
  }
}
