import 'package:flutter/material.dart';

import '../../rehmat.dart';

enum WidgetAlignment {
  // Widget is aligned to the top of the parent
  top,
  // Widget is horizontally centered in the parent
  center,
  // Widget is aligned to the bottom of the parent
  bottom,
  // Widget is aligned to the left of the parent
  left,
  // Widget is vertically centered in the parent
  middle,
  // Widget is aligned to the right of the parent
  right,
}

extension WidgetAlignmentExtension on WidgetAlignment {

  Offset getPosition(CreatorWidget widget) {
    double dx = widget.position.dx;
    double dy = widget.position.dy;
    Size size = widget.size;
    Size pageSize = widget.page.project.contentSize;
    switch (this) {
      case WidgetAlignment.top:
        dy = size.height/2 - pageSize.height/2;
        break;
      case WidgetAlignment.bottom:
        dy = pageSize.height/2 - size.height/2;
        break;
      case WidgetAlignment.left:
        dx = size.width/2 - pageSize.width/2;
        break;
      case WidgetAlignment.right:
        dx = pageSize.width/2 - size.width/2;
        break;
      case WidgetAlignment.center:
        dx = 0;
        break;
      case WidgetAlignment.middle:
        dy = 0;
        break;
    }
    return Offset(dx, dy);
  }

  static List<WidgetAlignment> fromPosition(CreatorWidget widget) {
    double dx = widget.position.dx;
    double dy = widget.position.dy;
    Size size = widget.size;
    Size pageSize = widget.page.project.contentSize;
    List<WidgetAlignment> alignments = [];
    if (dx == size.width/2 - pageSize.width/2) {
      alignments.add(WidgetAlignment.left);
    }
    if (dx == pageSize.width/2 - size.width/2) {
      alignments.add(WidgetAlignment.right);
    }
    if (dx == 0) {
      alignments.add(WidgetAlignment.center);
    }
    if (dy == size.height/2 - pageSize.height/2) {
      alignments.add(WidgetAlignment.top);
    }
    if (dy == pageSize.height/2 - size.height/2) {
      alignments.add(WidgetAlignment.bottom);
    }
    if (dy == 0) {
      alignments.add(WidgetAlignment.middle);
    }
    return alignments;
  }

}