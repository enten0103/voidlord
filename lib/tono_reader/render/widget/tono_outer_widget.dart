import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voidlord/tono_reader/config.dart';
import 'package:voidlord/tono_reader/controller.dart';
import 'package:voidlord/tono_reader/model/base/tono_location.dart';
import 'package:voidlord/tono_reader/model/widget/tono_container.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_converter.dart';
import 'package:voidlord/tono_reader/render/state/tono_container_provider.dart';
import 'package:voidlord/tono_reader/render/state/tono_inline_state_provider.dart';
import 'package:voidlord/tono_reader/render/state/tono_interaction_provider.dart';
import 'package:voidlord/tono_reader/render/state/tono_layout_provider.dart';
import 'package:voidlord/tono_reader/render/state/tono_location_provider.dart';
import 'package:voidlord/tono_reader/render/state/tono_parent_size_cache.dart';
import 'package:voidlord/tono_reader/render/widget/tono_container_widget.dart';
import 'package:voidlord/tono_reader/state/tono_data_provider.dart';
import 'package:voidlord/tono_reader/state/tono_progresser.dart';
import 'package:voidlord/tono_reader/state/tono_user_data_provider.dart';
import 'package:voidlord/tono_reader/tool/scroll/src/scrollable_positioned_list.dart';
import 'package:voidlord/tono_reader/tool/vertical_clipper.dart';
import 'package:voidlord/tono_reader/ui/default/comps/marker.dart';
import 'package:voidlord/tono_reader/ui/default/comps/title_divline.dart';
import 'package:voidlord/tono_reader/ui/default/comps/dialog/op_dialog_view.dart';

///
/// body+html元素渲染
/// 实现滚动逻辑
/// 根容器渲染
/// bg相关暂不实现
///
/// 根元素不进行transform,无 [TonoCssTransform] 渲染
class TonoOuterWidget extends StatelessWidget {
  /// 根元素
  final TonoContainer root;

  TonoOuterWidget({
    super.key,
    required this.root,
  }) : assert(
          root.className == "html" &&
              root.children.length == 1 &&
              root.children[0].className == "body",
          "根元素dom结构应为 html-> body->...",
        );

  @override
  Widget build(BuildContext context) {
    var provider = Get.find<TonoProvider>()..initSliderProgressor();
    var progressor = Get.find<TonoProgresser>();
    var controller = Get.find<TonoReaderController>();
    var config = Get.find<TonoReaderConfig>();
    var userData = Get.find<TonoUserDataProvider>();
    controller.itemPositionsListener.itemPositions.addListener(() {
      var positions = controller.itemPositionsListener.itemPositions.value;
      progressor.currentElementIndex.value = positions.first.index;
    });
    return TonoInlineStateProvider(
        state: InlineState(),
        child: TonoLayoutProvider(
            type: TonoLayoutType.fix,
            child: TonoSingleElementWidget(
                element: root,
                child: TonoSingleElementWidget(
                    element: root.children[0] as TonoContainer,
                    child: ClipRect(
                        clipper: VerticalClipper(),
                        child: ScrollablePositionedList.separated(
                            padding: EdgeInsets.only(
                              left: config.viewPortConfig.left,
                              right: config.viewPortConfig.right,
                            ),
                            itemScrollController:
                                controller.itemScrollController,
                            itemPositionsListener:
                                controller.itemPositionsListener,
                            minCacheExtent: 100,
                            itemCount: progressor.totalElementCount,
                            separatorBuilder: (context, index) {
                              var histroyIndex = userData.histroy.toIndex();
                              if (provider.isLast(index)) {
                                if (histroyIndex != 0 &&
                                    histroyIndex == index) {
                                  return SizedBox(
                                      height: Get.mediaQuery.size.height / 3,
                                      child: TitleDivline(title: "上次看到"));
                                }
                                return SizedBox(
                                  height: Get.mediaQuery.size.height / 3,
                                );
                              } else {
                                if (histroyIndex != 0 &&
                                    histroyIndex == index) {
                                  return TitleDivline(title: "上次看到");
                                }
                                return Container();
                              }
                            },
                            itemBuilder: (ctx, index) {
                              var location = index.toLocation();
                              var isMarked = userData.isMarked(location).obs;
                              return TonoInteractionProvider(
                                  markded: isMarked,
                                  child: TonoLocationProvider(
                                      location: location,
                                      child: GestureDetector(
                                          onLongPress: () {
                                            Get.dialog(OpDialogView(
                                              index: index,
                                              location: location,
                                              isMarked: isMarked,
                                            ));
                                          },
                                          child: Stack(
                                              clipBehavior: Clip.none,
                                              children: [
                                                TonoContainerWidget(
                                                    key: ValueKey(index),
                                                    tonoContainer: provider
                                                            .getWidgetByElementCount(
                                                                index)
                                                        as TonoContainer),
                                                Obx(() => Marker(
                                                    isMarked: isMarked.value))
                                              ]))));
                            }))))));
  }

  Size genContainerSize() {
    var config = Get.find<TonoReaderConfig>();
    var padding = Get.mediaQuery.padding;
    var screenSize = Get.mediaQuery.size;
    return Size(
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
  }
}

class TonoSingleElementWidget extends StatelessWidget {
  const TonoSingleElementWidget({
    super.key,
    required this.element,
    required this.child,
  });

  final TonoContainer element;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    var cache = Get.find<TonoParentSizeCache>();

    var fcm = FlutterStyleFromCss(
      element.css,
      pdisplay: element.parent?.display,
      tdisplay: element.display,
      parentSize: element.className == "html" || element.className == "body"
          ? genContainerSize().toPredictSize()
          : cache.getSize(element.hashCode) ?? context.psize.value,
    ).flutterStyleMap;
    return TonoContainerProvider(
      fcm: fcm,
      psize: Rx(genContainerSize().toPredictSize()),
      data: element,
      child: child,
    );
  }
}

Size genContainerSize() {
  var config = Get.find<TonoReaderConfig>();
  var padding = Get.mediaQuery.padding;
  var screenSize = Get.mediaQuery.size;
  return Size(
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
}
