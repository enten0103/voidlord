import 'package:flutter/cupertino.dart';
import 'package:voidlord/tono_reader/model/widget/tono_container.dart';
import 'package:voidlord/tono_reader/render/widget/tono_container_widget.dart';
import 'package:voidlord/tono_reader/render/widget/tono_inline_container_widget.dart';

extension TonoContainerRender on TonoInlineContainerWidget {
  InlineSpan renderContainer(
    TonoContainer inlineWidget,
  ) {
    return WidgetSpan(
      baseline: TextBaseline.alphabetic,
      alignment: PlaceholderAlignment.baseline,
      child: TonoContainerWidget(tonoContainer: inlineWidget),
    );
  }
}
