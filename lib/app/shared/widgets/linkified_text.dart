import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Renders [text] as plain text, except any URLs inside it become
/// tappable spans that open in an external browser.
class LinkifiedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextStyle? linkStyle;
  final int? maxLines;
  final TextOverflow? overflow;

  const LinkifiedText({
    super.key,
    required this.text,
    this.style,
    this.linkStyle,
    this.maxLines,
    this.overflow,
  });

  static final RegExp _urlPattern = RegExp(
    r'((https?:\/\/|www\.)[^\s]+)',
    caseSensitive: false,
  );

  Future<void> _open(String raw) async {
    final url = raw.startsWith('http') ? raw : 'https://$raw';
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final matches = _urlPattern.allMatches(text);
    if (matches.isEmpty) {
      return Text(text, style: style, maxLines: maxLines, overflow: overflow);
    }

    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final match in matches) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }
      final link = text.substring(match.start, match.end);
      spans.add(TextSpan(
        text: link,
        style: linkStyle ??
            style?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
        recognizer: TapGestureRecognizer()..onTap = () => _open(link),
      ));
      cursor = match.end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }

    return Text.rich(
      TextSpan(style: style, children: spans),
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
