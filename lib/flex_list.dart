library flex_list;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Provides a layout widget that takes multiple childs.
/// It behaves as you would expect Expand widgets to behave within a wrap.
///
/// Each child is placed next to the previous in the same row, if it has enough space.
/// If there isn't enough space, it will get placed in the next row.
/// The space in the previous row is now divided between the elements of the row.
///
/// Note, all elements used have to implement .getDryLayout() since this method is used
/// to determine the sizes of the children in advance.
class FlexList extends MultiChildRenderObjectWidget {
  /// Creates a flex list layout
  ///
  /// By default [horizontalSpacing] and [verticalSpacing] are set to 10.
  ///
  /// [children] are the items. All of them have to implement [computeDryLayout].
  /// [horizontalSpacing] defines the spacing between items in same row.
  /// [verticalSpacing] defines the spacing between row.
  FlexList({
    super.key,
    required List<Widget> children,
    this.horizontalSpacing = 10.0,
    this.verticalSpacing = 10.0,
  }) : super(children: children);

  /// Defines spacing between items in same row
  final double horizontalSpacing;

  /// Defines spacing between rows
  final double verticalSpacing;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderFlexList(
        horizontalSpacing: horizontalSpacing, verticalSpacing: verticalSpacing);
  }

  @override
  void updateRenderObject(BuildContext context, RenderFlexList renderObject) {
    renderObject
      ..horizontalSpacing = horizontalSpacing
      ..verticalSpacing = verticalSpacing;
  }
}

/// Displays its children in multiple rows and places as many children as possible
/// in one row.
///
/// A [RenderFlexList] determines the dry layout of each child and collects information
/// about how many rows are required. After obtaining all raw child sizes,
/// each child is layed out with additional space (depending on the remaining space left per row)
/// and is then positioned to it's correct location.
///
/// [horizontalSpacing] defines the spacing between items in same row.
/// [verticalSpacing] defines the spacing between row.
class RenderFlexList extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _FlexListParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _FlexListParentData> {
  RenderFlexList(
      {List<RenderBox>? children,
      double horizontalSpacing = 10.0,
      double verticalSpacing = 10.0})
      : _horizontalSpacing = horizontalSpacing,
        _verticalSpacing = verticalSpacing {
    addAll(children);
  }

  /// Spacing between items in same row
  double get horizontalSpacing => _horizontalSpacing;
  double _horizontalSpacing;

  /// Sets the horizontal spacing and marks that
  /// the [RenderBox] needs to get relayed out.
  set horizontalSpacing(double value) {
    if (_horizontalSpacing == value) {
      return;
    }
    _horizontalSpacing = value;
    markNeedsLayout();
  }

  /// Spacing between rows
  double get verticalSpacing => _verticalSpacing;
  double _verticalSpacing;

  /// Sets the vertical spacing and marks that
  /// the [RenderBox] needs to get relayed out.
  set verticalSpacing(double value) {
    if (_verticalSpacing == value) {
      return;
    }
    _verticalSpacing = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! _FlexListParentData) {
      child.parentData = _FlexListParentData();
    }
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return computeDryLayout(BoxConstraints(maxHeight: height)).width;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return computeDryLayout(BoxConstraints(maxHeight: height)).width;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return computeDryLayout(BoxConstraints(maxWidth: width)).height;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return computeDryLayout(BoxConstraints(maxWidth: width)).height;
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToHighestActualBaseline(baseline);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _computeDryLayout(constraints);
  }

  Size _computeDryLayout(BoxConstraints constraints) {
    var height = 0.0;

    final childConstraint = BoxConstraints(
        minWidth: 0,
        maxWidth: constraints.maxWidth,
        minHeight: 0,
        maxHeight: constraints.maxHeight);

    var child = firstChild;
    var rowWidth = 0.0;
    var rowMaxHeight = 0.0;
    var firstRowChild = true;
    var firstRow = true;
    while (child != null) {
      final horizSpacing = firstRowChild ? 0 : horizontalSpacing;
      final size = child.getDryLayout(childConstraint);
      final parentData = child.parentData! as _FlexListParentData;

      final neededWidth = size.width + horizSpacing;

      if (constraints.maxWidth - rowWidth < neededWidth) {
        // if there is not enough space left in current row
        // add maxRowHeight + (potential) vericalSpacing to height
        height += rowMaxHeight + (firstRow ? 0 : verticalSpacing);
        // reset row with first new element
        rowWidth = 0;
        rowMaxHeight = 0.0;
        firstRow = false;
      }

      rowWidth += neededWidth;
      rowMaxHeight = rowMaxHeight > size.height ? rowMaxHeight : size.height;
      child = parentData.nextSibling;
      firstRowChild = false;
    }

    return Size(constraints.maxWidth, height);
  }

  @override
  void performLayout() {
    List<_RowMetrics> rows = [];
    // Determine Widths
    var child = firstChild;
    var rowWidth = 0.0;
    var rowMaxHeight = 0.0;
    var rowItemNumber = 0;

    final childConstraint = BoxConstraints(
        minWidth: 0,
        maxWidth: constraints.maxWidth,
        minHeight: 0,
        maxHeight: constraints.maxHeight);

    var first = true;
    var biggestWidth = 0.0;
    while (child != null) {
      final horizSpacing = first ? 0 : horizontalSpacing;
      final size = child.getDryLayout(childConstraint);
      final parentData = child.parentData! as _FlexListParentData
        .._initSize = size;

      final neededWidth = size.width + horizSpacing;
      if (neededWidth > biggestWidth ) {
        biggestWidth = neededWidth;
      }

      if (constraints.maxWidth - rowWidth < neededWidth) {
        // add to row to rows
        final rowSize = Size(rowWidth, rowMaxHeight);
        rows.add(_RowMetrics(rowItemNumber, rowSize));
        // reset row with first new element
        rowWidth = 0;
        rowMaxHeight = 0.0;
        rowItemNumber = 0;
      }

      parentData._rowIndex = rows.length;
      rowWidth += neededWidth;
      rowMaxHeight = rowMaxHeight > size.height ? rowMaxHeight : size.height;
      rowItemNumber++;
      child = parentData.nextSibling;
      first = false;
    }

    final rowSize = Size(rowWidth, rowMaxHeight);
    rows.add(_RowMetrics(rowItemNumber, rowSize));

    // position childs
    child = firstChild;

    var offsetX = 0.0;
    var offsetY = 0.0;
    for (int i = 0; i < rows.length; ++i) {
      final row = rows[i];
      final eachChildAvailableWidth =
          (constraints.maxWidth - row.contentRawSize.width) / row.childNumber;
      var itemNumber = 0;

      while (child != null) {
        final _FlexListParentData childParentData =
            child.parentData! as _FlexListParentData;

        if (childParentData._rowIndex != i) {
          break;
        }

        final lastItemPadding =
            itemNumber + 1 == row.childNumber && i != 0 ? horizontalSpacing : 0;

        final double finalChildWidth;
        final equalWidth = (constraints.maxWidth - (horizontalSpacing * (row.childNumber - 1)))/ row.childNumber;
        if (equalWidth >= biggestWidth) {
          finalChildWidth = equalWidth + lastItemPadding;
        } else {
          finalChildWidth = childParentData._initSize.width +
              eachChildAvailableWidth +
              lastItemPadding;
        }

        var consts = constraints.tighten(width: finalChildWidth);
        child.layout(consts);

        childParentData.offset = Offset(offsetX, offsetY);
        offsetX += finalChildWidth + horizontalSpacing;

        child = childParentData.nextSibling;
        itemNumber++;
      }

      offsetX = 0.0;
      // don't add space to last row
      final vertSpacing = i + 1 == rows.length ? 0 : verticalSpacing;
      offsetY += row.contentRawSize.height + vertSpacing;
      itemNumber = 0;
    }

    size = Size(constraints.maxWidth, offsetY);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

/// Holds the parent data of each child
///
/// _initSize is the raw size the item would take without expantion
/// _rowIndex is the row in which the child is gonna placed
class _FlexListParentData extends ContainerBoxParentData<RenderBox>
    with ContainerParentDataMixin<RenderBox> {
  int _rowIndex = 0;
  Size _initSize = Size.zero;
}

class _RowMetrics {
  final int childNumber;
  final Size
      contentRawSize; // where width is the some of all widths and height is the heighest element

  _RowMetrics(this.childNumber, this.contentRawSize);
}
