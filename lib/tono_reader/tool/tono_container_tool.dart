import 'package:flutter/cupertino.dart';
import 'package:voidlord/tono_reader/model/widget/tono_container.dart';
import 'package:voidlord/tono_reader/model/widget/tono_widget.dart';
import 'package:voidlord/tono_reader/render/widget/tono_container_widget.dart';
import 'package:voidlord/tono_reader/render/widget/tono_inline_container_widget.dart';

extension TonoWidgetTool on TonoWidget {
  TonoWidget findBlockParent() {
    TonoWidget? parent = this.parent;
    while (parent != null) {
      if (parent.display == "block" || parent.display == null) {
        return parent;
      }
      parent = parent.parent;
    }
    return this;
  }

  List<TonoWidget> getScrollableWidgets(int deepth) {
    var widget = this;
    for (var i = 0; i < deepth; i++) {
      widget = (widget as TonoContainer).children[0];
    }
    return (widget as TonoContainer).children;
  }
}

extension TonoContainerTool on TonoContainer {
  List<Widget> genChildren() {
    List<Widget> children = [];
    List<TonoWidget> inlineChildren = [];
    for (var child in this.children) {
      if (child is TonoContainer) {
        if (child.display == "inline") {
          inlineChildren.add(child);
        } else {
          if (inlineChildren.isNotEmpty) {
            children.add(TonoInlineContainerWidget(
              inlineWidgets: [...inlineChildren],
            ));
            inlineChildren.clear();
          }
          children.add(TonoContainerWidget(
            tonoContainer: child,
          ));
        }
      } else {
        inlineChildren.add(child);
      }
    }

    if (inlineChildren.isNotEmpty) {
      children.add(TonoInlineContainerWidget(
        inlineWidgets: inlineChildren,
      ));
    }
    return children;
  }
}
