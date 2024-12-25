import 'dart:ui';

import 'package:flutter/material.dart';

class MaterialDragScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices =>
      {...super.dragDevices, PointerDeviceKind.mouse};

  @override
  Widget buildScrollbar(
      BuildContext context, Widget child, ScrollableDetails details) {
    return switch (axisDirectionToAxis(details.direction)) {
      Axis.horizontal => Scrollbar(
          controller: details.controller,
          child: child,
        ),
      Axis.vertical => super.buildScrollbar(context, child, details)
    };
  }
}
