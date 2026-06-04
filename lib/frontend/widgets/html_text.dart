import "package:flutter/material.dart";

// import "package:simple_html_css/simple_html_css.dart";

class HtmlText extends StatelessWidget {
  final bool removeStyleAndFontSize;
  final bool collapseLineBreaks;
  final String rawHtml;

  final TextOverflow overflow;
  final int? maxLines;
  final TextStyle? style;

  const HtmlText({
    super.key,
    required this.rawHtml,

    this.removeStyleAndFontSize = false,
    this.collapseLineBreaks = false,

    this.overflow = .clip,
    this.maxLines,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    var processedHtml = rawHtml;

    if (removeStyleAndFontSize) {
      processedHtml = processedHtml.replaceAll(
        RegExp(r'font-size\s*:\s*[^;>"]+;?\s*', caseSensitive: false),
        "",
      );

      processedHtml = processedHtml.replaceAll(
        RegExp(r'style="\s*"', caseSensitive: false),
        "",
      );
    }

    if (collapseLineBreaks) {
      processedHtml = processedHtml.replaceAll(
        RegExp(r"<br\s*/?>", caseSensitive: false),
        " ",
      );

      processedHtml = processedHtml.replaceAll("\n", "");
      processedHtml = processedHtml.replaceAll(RegExp(r" +"), " ").trim();
    }

    return Text.rich(
      TextSpan(),

      /*HTML.toTextSpan(
        context,
        processedHtml,

        linksCallback: (url) {
          final decoded = Uri.decodeFull(url);
          launchUrlString(decoded, mode: LaunchMode.externalApplication);
        },

        defaultTextStyle: style,
      )*/
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}
