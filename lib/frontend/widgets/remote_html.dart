import "package:flutter/material.dart";
import "package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart";
import "package:html/dom.dart" as html;
import "package:url_launcher/url_launcher_string.dart";

class RemoteHtml extends StatelessWidget {
  const RemoteHtml({
    super.key,
    required this.rawHtml,
    this.style,
    this.compact = false,
    this.maxLines,
  });

  final String rawHtml;
  final TextStyle? style;
  // TODO: Bring back those custom styles
  // static final _defaultStyle = {
  //   ...Style.fromCss(""":root {
  //                 --taille-l: 1.4rem;
  //                 --taille-m: 1.3rem;
  //                 --taille-s: 1.1rem;
  //               }""", null),
  //   "*": Style(margin: Margins.zero),
  // };

  final bool compact;
  final int? maxLines;

  String get compactHtml {
    final element = html.Element.html(rawHtml);

    return element.text;
  }

  @override
  Widget build(BuildContext context) {
    var finalHtml = compact ? compactHtml : rawHtml;

    if (maxLines != null) {
      finalHtml =
          '<div style="max-lines: $maxLines; text-overflow: ellipsis">$finalHtml</div>';
    }

    return HtmlWidget(
      finalHtml,
      textStyle: style,
      // style: {
      //   ..._defaultStyle,
      //   if (style != null)
      //     "*": Style.fromTextStyle(style!).copyWith(margin: Margins.zero),
      // },
      onTapUrl: (url) async {
        return await launchUrlString(url);
      },
    );
  }
}
