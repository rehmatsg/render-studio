import 'package:flutter/material.dart';

import '../rehmat.dart';

enum ExportQuality {
  onex,
  twox,
  fourx
}

extension ExportQualityExtension on ExportQuality {

  double pixelRatio(BuildContext context, Project project) {
    double pixelRatio = project.size.size.width / project.contentSize.width;
    switch (this) {
      case ExportQuality.fourx:
        pixelRatio *= 4;
        break;
      case ExportQuality.twox:
        pixelRatio *= 2;
        break;
      default:
        break;
    }
    return pixelRatio;
  }

  static ExportQuality fromString(String? quality) {
    switch (quality) {
      case '4x':
        return ExportQuality.fourx;
      case '2x':
        return ExportQuality.twox;
      case '1x':
        return ExportQuality.onex;
      default:
        return ExportQuality.onex;
    }
  }

  String get name {
    switch (this) {
      case ExportQuality.onex:
        return '1x';
      case ExportQuality.twox:
        return '2x';
      case ExportQuality.fourx:
        return '4x';
    }
  }

  String getFinalSize(Size size) {
    switch (this) {
      case ExportQuality.onex:
        return '${size.width.toInt()}x${size.height.toInt()}';
      case ExportQuality.twox:
        return '${(size.width * 2).toInt()}x${(size.height * 2).toInt()}';
      case ExportQuality.fourx:
        return '${(size.width * 4).toInt()}x${(size.height * 4).toInt()}';
      default:
        return '${size.width.toInt()}x${size.height.toInt()}';
    }
  }

}