library flex_list;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class FlexList extends MultiChildRenderObjectWidget {
  /// What you would expect if you could use Expanded within a Wrap.
  ///
  /// Each child is placed next to the previous in the same row, if it has enough space.
  /// If there isn't enough space, it will get placed in the next row.
  /// The space in the previous row is now divided between the elements of the row.
  ///
  /// Note, all elements used have to implement .getDryLayout() since this method is used
  /// to determine the sizes of the children in advance.
  FlexList({
    super.key,
    required List<Widget> children,
    this.horizontalSpacing = 10.0,
    this.verticalSpacing = 10.0,
  }) : super(children: children);

  /// Spacing between items in same row
  final double horizontalSpacing;

  /// Spacing between rows
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
  Size computeDryLayout(BoxConstraints constraints) {
    // TODO: Implement
    return super.computeDryLayout(constraints);
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
    while (child != null) {
      final horizSpacing = first ? 0 : horizontalSpacing;
      final size = child.getDryLayout(childConstraint);
      final parentData = child.parentData! as _FlexListParentData
        .._initSize = size;

      final neededWidth = size.width + horizSpacing;

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
        final finalChildWidth = childParentData._initSize.width +
            eachChildAvailableWidth +
            lastItemPadding;

        var consts = BoxConstraints.expand(
            width: finalChildWidth, height: childParentData._initSize.height);
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
