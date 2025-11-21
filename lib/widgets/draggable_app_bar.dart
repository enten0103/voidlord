import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class DraggableAppBar extends AppBar {
  DraggableAppBar({
    super.key,
    Widget? title,
    super.actions,
    super.leading,
    super.automaticallyImplyLeading = true,
    super.centerTitle,
    super.backgroundColor,
    super.elevation,
    super.scrolledUnderElevation,
    super.notificationPredicate,
    super.shadowColor,
    super.surfaceTintColor,
    super.shape,
    super.foregroundColor,
    super.iconTheme,
    super.actionsIconTheme,
    super.primary = true,
    super.excludeHeaderSemantics = false,
    super.titleSpacing,
    super.toolbarOpacity = 1.0,
    super.bottomOpacity = 1.0,
    super.toolbarHeight,
    super.leadingWidth,
    super.toolbarTextStyle,
    super.titleTextStyle,
    super.systemOverlayStyle,
    super.forceMaterialTransparency = false,
    super.clipBehavior,
    super.bottom,
  }) : super(
         title: title != null ? DragToMoveArea(child: title) : null,
         flexibleSpace: const DragToMoveArea(child: SizedBox.expand()),
       );
}
