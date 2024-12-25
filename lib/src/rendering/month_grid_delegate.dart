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
