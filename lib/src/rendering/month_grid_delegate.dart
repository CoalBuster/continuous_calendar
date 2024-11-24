import 'dart:math' as math;

import 'package:flutter/rendering.dart';

class SliverGridDelegateWithFixedCounts extends SliverGridDelegate {
  final int columnCount;
  final int rowCount;

  const SliverGridDelegateWithFixedCounts({
    required this.columnCount,
    required this.rowCount,
  });

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final double tileWidth = constraints.crossAxisExtent / columnCount;
    final double tileHeight = constraints.viewportMainAxisExtent / rowCount;

    return SliverGridRegularTileLayout(
      childCrossAxisExtent: tileWidth,
      childMainAxisExtent: tileHeight,
      crossAxisCount: columnCount,
      crossAxisStride: tileWidth,
      mainAxisStride: tileHeight,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(SliverGridDelegateWithFixedCounts oldDelegate) => false;
}

// class MonthGridDelegate extends SliverGridDelegate {
//   final double dayPickerRowHeight;
//   final int maxDayPickerRowCount;

//   const MonthGridDelegate({
//     this.dayPickerRowHeight = 42.0,
//     this.maxDayPickerRowCount = 6,
//   });

//   @override
//   SliverGridLayout getLayout(SliverConstraints constraints) {
//     const int columnCount = DateTime.daysPerWeek;
//     final double tileWidth = constraints.crossAxisExtent / columnCount;
//     final double tileHeight = math.min(
//       dayPickerRowHeight,
//       constraints.viewportMainAxisExtent / (maxDayPickerRowCount + 1),
//     );
//     return SliverGridRegularTileLayout(
//       childCrossAxisExtent: tileWidth,
//       childMainAxisExtent: tileHeight,
//       crossAxisCount: columnCount,
//       crossAxisStride: tileWidth,
//       mainAxisStride: tileHeight,
//       reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
//     );
//   }

//   @override
//   bool shouldRelayout(MonthGridDelegate oldDelegate) => false;
// }