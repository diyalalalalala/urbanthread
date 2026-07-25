import 'package:flutter/widgets.dart';

/// Height of [lines] lines of [style], at the reader's text scale.
///
/// Measured with a [TextPainter] rather than multiplying `fontSize` by
/// `height`: a style that leaves `height` null falls back to the font's own
/// ascent and descent, which differ per family and cannot be guessed. Both
/// spellings appear in [AppTypography] — `bodySmall` sets a height, `price`
/// does not.
///
/// This exists because a horizontal strip and a grid cell both have to state
/// their height before their contents are laid out, so the space a caption
/// needs has to be worked out in advance. Doing it from the resolved style
/// means the tile follows the theme and the system font size instead of a
/// constant that was right on one device with one font.
double textBlockHeight(BuildContext context, TextStyle? style, {int lines = 1}) {
  // Merged the way `Text` itself merges: a style that sets no `height` — the
  // price does not — inherits one from the enclosing `DefaultTextStyle`, and
  // measuring the bare style would come out a line-and-a-half short.
  final effective = DefaultTextStyle.of(context).style.merge(style);

  final painter = TextPainter(
    // An ascender and a descender, so this is a full line however short the
    // real string turns out to be.
    text: TextSpan(text: 'Mg', style: effective),
    textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
    textScaler: MediaQuery.textScalerOf(context),
  )..layout();

  final height = painter.height * lines;
  painter.dispose();

  return height;
}
