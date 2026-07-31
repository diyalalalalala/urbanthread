import 'package:flutter/widgets.dart';

double textBlockHeight(BuildContext context, TextStyle? style, {int lines = 1}) {
  final effective = DefaultTextStyle.of(context).style.merge(style);

  final painter = TextPainter(
    text: TextSpan(text: 'Mg', style: effective),
    textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
    textScaler: MediaQuery.textScalerOf(context),
  )..layout();

  final height = painter.height * lines;
  painter.dispose();

  return height;
}
