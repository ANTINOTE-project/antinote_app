import "package:antinote_app/main.dart";
import "package:flutter/material.dart";
import "package:simple_html_css/simple_html_css.dart";
import "package:url_launcher/url_launcher_string.dart";

class HtmlText extends StatelessWidget {
  final bool collapseLineBreaks;
  final String rawHtml;

  final TextOverflow overflow;
  final int? maxLines;
  final TextStyle? style;

  const HtmlText({
    super.key,
    required this.rawHtml,
    this.collapseLineBreaks = false,

    this.overflow = .clip,
    this.maxLines,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    var processedHtml = rawHtml;

    if (collapseLineBreaks) {
      processedHtml = processedHtml.replaceAll(
        RegExp(r"<br\s*/?>", caseSensitive: false),
        " ",
      );

      processedHtml = processedHtml.replaceAll("\n", "");
      processedHtml = processedHtml.replaceAll(RegExp(r" +"), " ").trim();
    }

    talker.log(processedHtml);

    return Text.rich(
      HTML.toTextSpan(
        context,
        processedHtml,

        linksCallback: (url) {
          launchUrlString(url);
        },

        defaultTextStyle: style ?? DefaultTextStyle.of(context).style,
      ),

      overflow: overflow,
      maxLines: maxLines,
    );
  }
}
