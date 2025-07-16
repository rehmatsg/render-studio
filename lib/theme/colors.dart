import 'package:flutter/material.dart';
import '../rehmat.dart';

abstract class Palette {

  static ColorScheme of(BuildContext context) => Theme.of(context).colorScheme;

  static bool isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  /// Material color for use in BackdropFilter elements
  static Color blurBackground(BuildContext context) => of(context).surfaceContainerLow.withValues(alpha: 0.4);

  static Color onBlurBackground(BuildContext context) => isDark(context) ? Colors.white : Colors.black;

  static Future<Color?> showColorPicker(BuildContext context, {
    required Color selected,
    ColorPalette? palette
  }) => ColorTool.openTool(context, palette: palette, selection: selected);
  
}