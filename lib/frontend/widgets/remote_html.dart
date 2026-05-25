import "package:flutter/material.dart";
import "package:flutter_html/flutter_html.dart";
import "package:html/dom.dart";
import "package:url_launcher/url_launcher_string.dart";

class RemoteHtml extends StatelessWidget {
  const RemoteHtml({super.key, required this.rawHtml});

  final String rawHtml;
  static final _defaultStyle = {
    ...Style.fromCss(""":root {
                  --taille-l: 1.4rem;
                  --taille-m: 1.3rem;
                  --taille-s: 1.1rem;
                }""", null),
    "*": Style(margin: Margins.zero),
  };

  @override
  Widget build(BuildContext context) {
    // TODO: Do a proper fix in flutter_html when the author is active again
    // last checked: 05 april 2026
    var actualHtml = rawHtml.replaceAll("font-feature-settings: revert;", "");

    final document = Document.html(actualHtml);
    return Html.fromDom(
      document: document,
      style: _defaultStyle,
      onLinkTap: (url, attributes, element) {
        if (url == null) return;
        launchUrlString(url);
      },
    );
  }
}
