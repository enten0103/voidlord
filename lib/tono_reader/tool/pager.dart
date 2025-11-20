import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:voidlord/tono_reader/config.dart';
import 'package:voidlord/tono_reader/model/widget/tono_container.dart';
import 'package:voidlord/tono_reader/model/widget/tono_text.dart';
import 'package:voidlord/tono_reader/model/widget/tono_widget.dart';
import 'package:voidlord/tono_reader/tool/css_tool.dart';

extension TonoPager on TonoWidget {
  int paging() {
    var config = Get.put(TonoReaderConfig());
    var currentIndex = 1;
    if (this is TonoContainer) {
      TonoContainer html = this as TonoContainer;
      var body = html.children[0];
      if (body is TonoContainer) {
        var containerSize = genContainerSize(html, body, config);
        var children = body.children;
        var renderHeight = containerSize.height;
        var preMarginBottom = 0.0;
        var currentHeight = 0.0;
        for (var child in children) {
          var marginTop = child.extra['margin-top'] as double;
          var marginBottom = child.extra['margin-bottom'] as double;
          double height = child.extra['height'];
          var margin = 0.0;
          if (preMarginBottom * marginTop < 0) {
            margin = preMarginBottom + marginTop;
          } else {
            margin = preMarginBottom > marginTop ? preMarginBottom : marginTop;
          }
          var totalHeight = margin + height;
          currentHeight += totalHeight;
          if (child.extra['pageIndex'] == null) {
            child.extra['pageIndex'] = [];
          }
          if (currentHeight + marginBottom > renderHeight) {
            if (child.extra['cn'] == "p") {
              var nextHeight = currentHeight + marginBottom - renderHeight;
              var lineHeight = child.extra['line-height'];
              var lineCount = child.extra['line'];
              var nextLineCount = (nextHeight / lineHeight).ceil();
              var preLineCount = lineCount - nextLineCount;
              preLineCount = preLineCount < 0 ? 0 : preLineCount;
              child.extra['nextP'] = nextLineCount;
              child.extra['preP'] = preLineCount;
              if (preLineCount != 0) {
                (child.extra['pageIndex'] as List).add(currentIndex);
              }
              if (nextLineCount != 0) {
                currentIndex++;
                (child.extra['pageIndex'] as List).add(currentIndex);
                currentHeight = totalHeight - lineHeight * preLineCount;
              }
            } else {
              currentIndex++;
              (child.extra['pageIndex'] as List).add(currentIndex);
              currentHeight = totalHeight;
            }
          } else {
            (child.extra['pageIndex'] as List).add(currentIndex);
          }

          preMarginBottom = marginBottom;
          child.extra['currentHeight'] = currentHeight;
          child.extra['totalHeight'] = totalHeight;
          child.extra['margin'] = margin;
        }
      }
    }

    return currentIndex;
  }

  int prepaging() {
    var config = Get.put(TonoReaderConfig());
    if (this is TonoContainer) {
      TonoContainer html = this as TonoContainer;
      var body = html.children[0];
      if (body is TonoContainer) {
        var children = body.children;
        var containerSize = genContainerSize(html, body, config);
        var width = containerSize.width;
        var count = children.length;
        for (var child in children) {
          if (child is TonoContainer) {
            var em = child.css.getFontSize();
            var margin =
                parseMarginAll(child.css.toMap(), em) ?? EdgeInsets.zero;
            if ((child.className == "p" || child.className.startsWith("h")) &&
                child.children.length == 1 &&
                child.children[0] is TonoText) {
              var ttext = child.children[0] as TonoText;
              var css = ttext.css.toMap();
              var cssIndent = css["text-indent"];
              var paddingSize = genPaddingSize(containerSize, child);
              int indent = 0;
              if (cssIndent != null) {
                indent = (parseUnit(cssIndent, 0, em) / em).toInt();
              }
              var containerWidth =
                  width - paddingSize.width - margin.left - margin.right;
              var line = predictTextLines(
                  text: ttext.text,
                  indented: indent,
                  fontSize: em,
                  containerWidth: containerWidth);
              var lineHeight = parseLineHeight(css['line-height'], em) * em;
              child.extra['cn'] = "p";
              child.extra['line-height'] = lineHeight;
              child.extra['line'] = line;
              child.extra['height'] = lineHeight * line + paddingSize.height;
              count--;
            }
            child.extra['margin-top'] = margin.top;
            child.extra['margin-bottom'] = margin.bottom;
          }
        }
        return count;
      }
    }
    return 0;
  }

  int predictTextLines({
    required String text,
    required int indented,
    required double fontSize,
    required double containerWidth,
  }) {
    if (containerWidth <= 0 || fontSize <= 0 || text.isEmpty) {
      return 0;
    }
    for (var i = 0; i < indented; i++) {
      text = "文$text";
    }
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        fontSize: fontSize + 1,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr, // 必须明确设置文本方向
    );
    textPainter.layout(maxWidth: containerWidth);
    return textPainter.computeLineMetrics().length;
  }

  double parseLineHeight(String? cssLineHeight, double em) {
    if (cssLineHeight == null) return 1;
    cssLineHeight = cssLineHeight.replaceAll("!important", "");
    if (cssLineHeight.contains('em')) {
      double emValue = double.parse(cssLineHeight.replaceAll('em', '')) * em;
      return emValue / em;
    } else if (cssLineHeight.contains('px')) {
      double pxValue = double.parse(cssLineHeight.replaceAll('px', ''));
      return pxValue / em;
    } else if (cssLineHeight.contains('%')) {
      double percentage = double.parse(cssLineHeight.replaceAll('%', ''));
      return percentage / 100.0;
    } else {
      return double.parse(cssLineHeight);
    }
  }

  Size genPaddingSize(Size orginalSize, TonoContainer container) {
    var htmlCss = container.css.toMap();
    var htmlEm = container.css.getFontSize();
    var htmlCssPaddingLeft = htmlCss['padding-left'];
    var htmlCssPaddingRight = htmlCss['padding-right'];
    var htmlCssPaddingTop = htmlCss['padding-top'];
    var htmlCssPaddingBottom = htmlCss['padding-bottom'];
    var hpl = _parse(htmlCssPaddingLeft, orginalSize.width, htmlEm);
    var hpr = _parse(htmlCssPaddingRight, orginalSize.width, htmlEm);
    var hpt = _parse(htmlCssPaddingTop, orginalSize.height, htmlEm);
    var hpb = _parse(htmlCssPaddingBottom, orginalSize.height, htmlEm);
    return Size(hpl + hpr, hpt + hpb);
  }

  Size genContainerSize(TonoContainer htmlContainer,
      TonoContainer bodyContainer, TonoReaderConfig config) {
    var padding = Get.mediaQuery.padding;
    var screenSize = Get.mediaQuery.size;
    var safeSize = Size(
        screenSize.width -
            padding.left -
            padding.right -
            config.viewPortConfig.left -
            config.viewPortConfig.right,
        screenSize.height -
            padding.top -
            padding.bottom -
            config.viewPortConfig.top -
            config.viewPortConfig.bottom);
    var htmlCss = htmlContainer.css.toMap();
    var bodyCss = bodyContainer.css.toMap();
    var htmlEm = htmlContainer.css.getFontSize();
    var bodyEM = bodyContainer.css.getFontSize();
    var htmlCssPaddingLeft = htmlCss['padding-left'];
    var htmlCssPaddingRight = htmlCss['padding-right'];
    var htmlCssPaddingTop = htmlCss['padding-top'];
    var htmlCssPaddingBottom = htmlCss['padding-bottom'];

    var htmlCssMarginLeft = htmlCss['margin-left'];
    var htmlCssMarginRight = htmlCss['margin-right'];
    var htmlCssMarginTop = htmlCss['margin-top'];
    var htmlCssMarginBottom = htmlCss['margin-bottom'];

    var bodyCssMarginLeft = bodyCss['margin-left'];
    var bodyCssMarginRight = bodyCss['margin-right'];
    var bodyCssMarginTop = bodyCss['margin-top'];
    var bodyCssMarginBottom = bodyCss['margin-bottom'];

    var bodyCssPaddingLeft = bodyCss['padding-left'];
    var bodyCssPaddingRight = bodyCss['padding-right'];
    var bodyCssPaddingTop = bodyCss['padding-top'];
    var bodyCssPaddingBottom = bodyCss['padding-bottom'];
    var hpl = _parse(htmlCssPaddingLeft, safeSize.width, htmlEm);
    var hpr = _parse(htmlCssPaddingRight, safeSize.width, htmlEm);
    var hpt = _parse(htmlCssPaddingTop, safeSize.height, htmlEm);
    var hpb = _parse(htmlCssPaddingBottom, safeSize.height, htmlEm);
    var hml = _parse(htmlCssMarginLeft, safeSize.width, htmlEm);
    var hmr = _parse(htmlCssMarginRight, safeSize.width, htmlEm);
    var hmt = _parse(htmlCssMarginTop, safeSize.height, htmlEm);
    var hmb = _parse(htmlCssMarginBottom, safeSize.height, htmlEm);
    var bodySize = Size(
      safeSize.width - hpl - hpr - hml - hmr,
      safeSize.height - hpt - hpb - hmt - hmb,
    );
    var bpl = _parse(bodyCssPaddingLeft, bodySize.width, bodyEM);
    var bpr = _parse(bodyCssPaddingRight, bodySize.width, bodyEM);
    var bpt = _parse(bodyCssPaddingTop, bodySize.height, bodyEM);
    var bpb = _parse(bodyCssPaddingBottom, bodySize.height, bodyEM);
    var bml = _parse(bodyCssMarginLeft, bodySize.width, bodyEM);
    var bmr = _parse(bodyCssMarginRight, bodySize.width, bodyEM);
    var bmt = _parse(bodyCssMarginTop, bodySize.height, bodyEM);
    var bmb = _parse(bodyCssMarginBottom, bodySize.height, bodyEM);

    return Size(
      bodySize.width - bpl - bpr - bml - bmr,
      bodySize.height - bpt - bpb - bmt - bmb,
    );
  }

  double _parse(String? raw, double parent, double em) {
    if (raw == null) return 0;
    return parseUnit(raw, parent, em);
  }

  EdgeInsets? parseMarginAll(Map<String, String> css, double em) {
    List<EdgeInsets> margins = [];
    var width = Get.mediaQuery.size.width;
    var marginLeft = parseMarginLetf(css['margin-left'], width, em);
    if (marginLeft != null) margins.add(marginLeft);
    var marginRight = parseMarginRight(css['margin-right'], width, em);
    if (marginRight != null) margins.add(marginRight);
    var marginTop = parseMarginTop(css['margin-top'], width, em);
    if (marginTop != null) margins.add(marginTop);
    var marginBottom = parseMarginBottom(css['margin-bottom'], width, em);
    if (marginBottom != null) margins.add(marginBottom);
    if (margins.isEmpty) return null;
    double top = 0.0;
    double right = 0.0;
    double bottom = 0.0;
    double left = 0.0;
    for (EdgeInsets margin in margins) {
      top += margin.top;
      right += margin.right;
      bottom += margin.bottom;
      left += margin.left;
    }

    return EdgeInsets.fromLTRB(left, top, right, bottom);
  }

  EdgeInsets? parseMarginLetf(String? cssMarginLeft, double width, double em) {
    if (cssMarginLeft == null) return null;
    if (cssMarginLeft == "auto") {
      return null;
    }
    return EdgeInsets.only(left: parseUnit(cssMarginLeft, width, em));
  }

  EdgeInsets? parseMarginRight(
      String? cssMarginRight, double width, double em) {
    if (cssMarginRight == null) return null;
    if (cssMarginRight == "auto") {
      return null;
    }
    return EdgeInsets.only(right: parseUnit(cssMarginRight, width, em));
  }

  EdgeInsets? parseMarginTop(String? cssMarginTop, double width, double em) {
    if (cssMarginTop == null) return null;
    if (cssMarginTop == "auto") {
      return null;
    }
    return EdgeInsets.only(top: parseUnit(cssMarginTop, width, em));
  }

  EdgeInsets? parseMarginBottom(
      String? cssMarginBottom, double width, double em) {
    if (cssMarginBottom == null) return null;
    if (cssMarginBottom == "auto") {
      return null;
    }

    return EdgeInsets.only(bottom: parseUnit(cssMarginBottom, width, em));
  }
}
