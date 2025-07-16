import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:smooth_corner/smooth_corner.dart';

import '../../rehmat.dart';

class CreativeContainerProvider {

  CreativeContainerProvider._(this.widget);
  final CreatorWidget widget;

  factory CreativeContainerProvider.create(CreatorWidget widget, {
    Color? color
  }) {
    return CreativeContainerProvider._(widget) .. color = color;
  }

  Color? color;

  BackgroundType type = BackgroundType.color;

  Color? borderColor;
  double? borderWidth;

  double borderRadius = 0;

  BoxShadow? shadow;

  double blur = 0;

  CreativeGradient? gradient;

  EdgeInsets padding = EdgeInsets.zero;

  EditorTab editor({
    required void Function(WidgetChange change) onChange,
    String name = 'Background',
    List<Option> options = const [],
    bool showBorder = true,
    bool showShadow = true,
    bool showPadding = true,
    bool showBlur = true,
    bool showColor = true,
  }) => EditorTab(
    name: name,
    options: [
      if (showColor) Option.color(
        widget,
        selected: color,
        palette: widget.page.palette,
        allowClear: true,
        onChange: (color) {
          this.color = color;
          onChange(WidgetChange.misc);
        },
        onChangeEnd: (color) {
          onChange(WidgetChange.update);
        },
      ),
      Option.button(
        title: 'Gradient',
        onTap: (context) async {
          gradient ??= CreativeGradient.fromPalette(palette: widget.page.palette);
          widget.page.editorManager.openModal(
            actions: (dismiss) => [
              IconButton(
                onPressed: () {
                  gradient = null;
                  dismiss();
                },
                icon: Icon(RenderIcons.delete)
              ),
            ],
            tab: (context, setState) => gradient!.getEditor(
              widget: widget,
              palette: widget.page.palette,
              onChange: (change) {
                setState(() {});
                onChange(change);
              },
            ),
            onDismiss: () {
              onChange(WidgetChange.update);
            }
          );
        },
        icon: RenderIcons.gradient
      ),
      if (showShadow) Option.button(
        title: 'Shadow',
        onTap: (context) async {
          if (shadow == null) {
            shadow = BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 5,
              offset: Offset(0, 5)
            );
          }
          widget.page.editorManager.openModal(
            actions: (dismiss) => [
              IconButton(
                onPressed: () {
                  shadow = null;
                  dismiss();
                  onChange(WidgetChange.update);
                },
                icon: Icon(RenderIcons.delete)
              )
            ],
            tab: (context, setState) => EditorTab.shadow<BoxShadow>(
              widget: widget,
              shadow: shadow!,
              onChange: (value) {
                shadow = value;
                onChange(WidgetChange.misc);
              },
            ),
            onDismiss: () {
              onChange(WidgetChange.update);
            }
          );
        },
        icon: Icons.text_fields,
        tooltip: 'Customize shadow of box'
      ),
      if (showBorder) Option.button(
        title: 'Border',
        onTap: (context) async {
          Size originalWidgetSize = widget.size;
          if (borderRadius > widget.size.height * 1.5) borderRadius = widget.size.height * 1.5;
          widget.page.editorManager.openModal(
            actions: (dismiss) => [
              IconButton(
                onPressed: () {
                  borderColor = borderWidth = null;
                  onChange(WidgetChange.update);
                  dismiss();
                },
                icon: Icon(RenderIcons.delete)
              )
            ],
            tab: (context, setState) => EditorTab(
              name: 'Border',
              type: EditorTabType.single,
              options: [
                Option.custom(
                  widget: (context) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomSlider(
                          value: borderWidth ?? 0,
                          min: 0,
                          max: 10,
                          label: 'Width',
                          onChange: (value) {
                            widget.size = Size(originalWidgetSize.width + value * 2, originalWidgetSize.height + value * 2);
                            if (borderColor == null) borderColor = color?.computeTextColor();
                            borderWidth = value;
                            onChange(WidgetChange.misc);
                          },
                          actions: [
                            ColorSelector(
                              widget: widget,
                              title: 'Color',
                              palette: widget.page.palette,
                              onColorSelect: (color) {
                                if (borderWidth == null) borderWidth = 2;
                                borderColor = color;
                                onChange(WidgetChange.update);
                              },
                              size: const Size(30, 30),
                              color: borderColor ?? color?.computeTextColor() ?? widget.page.palette.primary,
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        CustomSlider(
                          value: borderRadius,
                          min: 0,
                          max: widget.size.height * 1.5,
                          label: 'Radius',
                          onChange: (value) {
                            borderRadius = value;
                            onChange(WidgetChange.misc);
                          }
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            onDismiss: () {
              if ((borderWidth ?? 0) > 0 && borderColor == null) {
                borderColor = color?.computeTextColor() ?? widget.page.palette.primary;
              }
              onChange(WidgetChange.update);
            },
          );
        },
        icon: Icons.border_all,
        tooltip: 'Customize the border'
      ),
      if (showPadding) Option.button(
        title: 'Padding',
        icon: RenderIcons.padding,
        tooltip: 'Add padding to the widget',
        onTap: (context) async {
          double maxVerticalPadding = widget.size.height;
          double maxHorizontalPadding = widget.size.width;
          if (padding.vertical > maxVerticalPadding) padding = EdgeInsets.symmetric(vertical: maxVerticalPadding, horizontal: padding.horizontal);
          if (padding.horizontal > maxHorizontalPadding) padding = EdgeInsets.symmetric(horizontal: maxHorizontalPadding, vertical: padding.vertical);
          widget.page.editorManager.openModal(
            tab: (context, setState) => EditorTab.paddingEditor(
              padding: padding,
              onChange: (value) {
                padding = value;
                onChange(WidgetChange.misc);
              },
              minVertical: 0,
              maxVertical: maxVerticalPadding,
              minHorizontal: 0,
              maxHorizontal: maxHorizontalPadding,
            ),
            onDismiss: () {
              onChange(WidgetChange.update);
            }
          );
        },
      ),
      if (showBlur) Option.showSlider(
        widget,
        title: 'Blur',
        icon: RenderIcons.blur,
        value: blur,
        min: 0,
        max: 20,
        onChange: (value) {
          blur = value;
          onChange(WidgetChange.misc);
        },
        onChangeEnd: () => onChange(WidgetChange.update),
        showValueEditor: true
      ),
      ... options
    ]
  );

  Widget build({
    Widget? child,
    double? width,
    double? height,
  }) => Container(
    width: width != null ? width + (padding.horizontal * 2) : null,
    height: height != null ? height + (padding.vertical * 2) : null,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        if (shadow != null) shadow!
      ],
    ),
    child: ClipPath(
      clipBehavior: (shadow != null || blur > 0) ? Clip.hardEdge : Clip.none,
      clipper: ShapeBorderClipper(
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: SmoothClipRRect(
          side: (borderWidth != null) ? BorderSide(
            color: borderColor ?? color?.computeTextColor() ?? widget.page.palette.primary,
            width: borderWidth ?? 0
          ) : BorderSide.none,
          borderRadius: BorderRadius.circular(borderRadius),
          smoothness: 0.6,
          child: Container(
            decoration: BoxDecoration(
              color: type == BackgroundType.color ? color : Colors.white,
              gradient: gradient?.gradient,
            ),
            child: child,
          ),
        ),
      ),
    ),
  );

  Map<String, dynamic> toJSON({
    bool buildToUniversal = false,
  }) {
    double? _borderWidth = this.borderWidth;
    EdgeInsets _padding = this.padding;
    double _borderRadius = this.borderRadius;
    double? _spreadRadius = shadow?.spreadRadius;
    double? _blurRadius = shadow?.blurRadius;
    Offset? _offset = shadow?.offset;
    if (buildToUniversal) {
      if (_borderWidth != null) widget.page.project.sizeTranslator.getUniversalValue(value: _borderWidth);
      _padding = widget.page.project.sizeTranslator.getUniversalPadding(padding: _padding);
      // _borderRadius = widget.page.project.sizeTranslator.getUniversalValue(value: _borderRadius);
      if (_spreadRadius != null) _spreadRadius = widget.page.project.sizeTranslator.getUniversalValue(value: _spreadRadius);
      if (_blurRadius != null) _blurRadius = widget.page.project.sizeTranslator.getUniversalValue(value: _blurRadius);
      if (_offset != null) _offset = widget.page.project.sizeTranslator.getUniversalPosition(position: _offset);
    }
    return {
      'color': color?.toHex(),
      'gradient': gradient?.toJSON(),
      'border-color': borderColor?.toHex(),
      'border-width': _borderWidth,
      'border-radius': _borderRadius,
      'blur': blur,
      'padding': _padding.toJSON(),
      'shadow': shadow == null ? null : {
        'color': shadow?.color.toHex(),
        'blur-radius': _blurRadius,
        'spread-radius': _spreadRadius,
        'offset-x': _offset?.dx,
        'offset-y': _offset?.dy,
      },
    };
  }

  factory CreativeContainerProvider.fromJSON(Map data, {
    required CreatorWidget widget,
    bool isBuildingFromUniversal = false,
  }) {
    CreativeContainerProvider provider = CreativeContainerProvider._(widget);
    try {
      if (data['color'] != null) provider.color = HexColor.fromHex(data['color']);

      if (data['gradient'] != null) try {
        provider.gradient = CreativeGradient.fromJSON(data['gradient']);
      } catch (e) {}

      if (data['border-color'] != null) provider.borderColor = HexColor.fromHex(data['border-color']);

      provider.borderWidth = data['border-width'];
      if (isBuildingFromUniversal && provider.borderWidth != null) provider.borderWidth = widget.page.project.sizeTranslator.getLocalValue(value: provider.borderWidth!);

      if (data['border-radius'] != null) {
        provider.borderRadius = data['border-radius'];
        // if (isBuildingFromUniversal) provider.borderRadius = widget.page.project.sizeTranslator.getLocalValue(value: provider.borderRadius);
      }

      if (data['shadow'] != null) {
        double blurRadius = data['shadow']['blur-radius'];
        double spreadRadius = data['shadow']['spread-radius'];
        Offset offset = Offset(
          data['shadow']['offset-x'],
          data['shadow']['offset-y'],
        );
        if (isBuildingFromUniversal) {
          blurRadius = widget.page.project.sizeTranslator.getLocalValue(value: blurRadius);
          spreadRadius = widget.page.project.sizeTranslator.getLocalValue(value: spreadRadius);
          offset = widget.page.project.sizeTranslator.getLocalPosition(position: offset);
        }
        provider.shadow = BoxShadow(
          color: HexColor.fromHex(data['shadow']['color']),
          blurRadius: blurRadius,
          spreadRadius: spreadRadius,
          offset: offset,
        );
      }
      provider.blur = data['blur'] ?? 0;
      if (isBuildingFromUniversal) provider.blur = widget.page.project.sizeTranslator.getLocalValue(value: provider.blur);

      if (data['padding'] != null) {
        provider.padding = PaddingExtension.fromJSON(data['padding']);
        if (isBuildingFromUniversal) {
          provider.padding = widget.page.project.sizeTranslator.getLocalPadding(padding: provider.padding);
        }
      }
    } catch (e) { }
    return provider;
  }

}