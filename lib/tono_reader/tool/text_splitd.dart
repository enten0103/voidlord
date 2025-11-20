import 'package:flutter/material.dart';

class TextSplitd {
  static String split(String text, TextStyle style, double cw, int maxLines) {
    final span = TextSpan(text: text, style: style);
    final tp = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: cw);

    final lineMetrics = tp.computeLineMetrics();
    final numLines = lineMetrics.length;

    if (numLines <= maxLines) {
      return text;
    } else {
      var startOffset = tp
          .getLineBoundary(TextPosition(
              offset: tp
                  .getOffsetForCaret(
                      TextPosition(offset: numLines - maxLines), Rect.zero)
                  .dx
                  .toInt()))
          .end;
      if (startOffset < 0) {
        startOffset = 0;
      }
      final endOffset = text.length;
      final lastLinesText = text.substring(startOffset, endOffset);
      return lastLinesText;
    }
  }
}
