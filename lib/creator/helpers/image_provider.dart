import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:colorfilter_generator/addons.dart';
import 'package:colorfilter_generator/colorfilter_generator.dart';
import 'package:colorfilter_generator/presets.dart';
import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';
import 'package:sprung/sprung.dart';
import 'dart:math' as math;
import '../../rehmat.dart';

class CreativeImageProvider {

  CreativeImageProvider._(this.widget);
  final CreatorWidget widget;

  factory CreativeImageProvider.create(CreatorWidget widget) {
    return CreativeImageProvider._(widget);
  }

  double brightness = 0;
  double contrast = 0;
  double exposure = 0;
  double saturation = 0;
  double visibility = 0;
  double? sepia;
  double hue = 0;

  bool flipHorizontal = false;
  bool flipVertical = false;

  ColorFilterGenerator? filter;

  Color fadeColor = Colors.black;
  bool blurFade = false;
  ImageFade? fade;

  List<double> get matrix {
    ColorFilterGenerator myFilter = ColorFilterGenerator(
      name: "Custom Filter",
      filters: [
        ColorFilterAddons.brightness(brightness),
        ColorFilterAddons.contrast(contrast),
        ColorFilterAddons.saturation(saturation),
        ColorFilterAddons.hue(hue),
        if (sepia != null) ColorFilterAddons.sepia(sepia!),
        if (filter != null) filter!.matrix,
        // PresetFilters.ludwig.opacity(0.20),
      ]
    );
    return myFilter.matrix;
  }

  EditorTab editor(AssetX asset, {
    required void Function(WidgetChange change, {String? historyMessage}) onChange,
    String name = 'Image',
    List<Option> options = const [],
  }) => EditorTab(
    name: name,
    type: EditorTabType.row,
    options: [
      Option.showSlider(
        widget,
        icon: RenderIcons.brightness,
        title: 'Brightness',
        max: 0.25,
        min: -0.25,
        value: brightness,
        onChange: (value) {
          brightness = value;
          onChange(WidgetChange.misc);
        },
        onChangeEnd: () => onChange(WidgetChange.update),
        showValueEditor: true
      ),
      Option.showSlider(
        widget,
        icon: RenderIcons.contrast,
        title: 'Contrast',
        max: 0.25,
        min: -0.25,
        value: contrast,
        onChange: (value) {
          contrast = value;
          onChange(WidgetChange.misc);
        },
        onChangeEnd: () => onChange(WidgetChange.update),
        showValueEditor: true
      ),
      // Option.showSlider(
      //   widget,
      //   icon: RenderIcons.exposure,
      //   title: 'Exposure',
      //   max: 1,
      //   min: -1,
      //   value: exposure,
      //   onChange: (value) {
      //     exposure = value;
      //     onChange(WidgetChange.misc);
      //   },
      //   onChangeEnd: () => onChange(WidgetChange.update),
      //   showValueEditor: true
      // ),
      Option.showSlider(
        widget,
        icon: RenderIcons.saturation,
        title: 'Saturation',
        max: 1,
        min: -1,
        value: saturation,
        onChange: (value) {
          saturation = value;
          onChange(WidgetChange.misc);
        },
        onChangeEnd: () => onChange(WidgetChange.update),
        showValueEditor: true
      ),
      // Option.showSlider(
      //   icon: RenderIcons.visibility,
      //   title: 'Visibility',
      //   max: 1,
      //   min: -1,
      //   value: visibility,
      //   onChange: (value) {
      //     visibility = value;
      //     updateListeners(WidgetChange.misc);
      //   },
      //   onChangeEnd: (value) {
      //     visibility = value;
      //     updateListeners(WidgetChange.update);
      //   },
      // ),
      Option.showSlider(
        widget,
        icon: RenderIcons.hue,
        title: 'Hue',
        max: 1,
        min: 0,
        value: hue,
        onChange: (value) {
          hue = value;
          onChange(WidgetChange.misc);
        },
        onChangeEnd: () => onChange(WidgetChange.update),
        showValueEditor: true
      ),
      Option.button(
        title: 'Fade',
        onTap: (context) {
          widget.page.editorManager.openModal(
            tab: (context, setState) => EditorTab(
              name: 'Fade',
              type: EditorTabType.single,
              options: [
                Option.custom(
                  widget: (context) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: Text('Direction'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ColorSelector(
                              widget: widget,
                              allowOpacity: false,
                              size: Size.square(
                                Theme.of(context).textTheme.labelLarge!.fontSize! + 20
                              ),
                              onColorSelect: (color) {
                                setState(() {
                                  fadeColor = color;
                                });
                                onChange(WidgetChange.misc);
                              },
                              color: fadeColor
                            ),
                            SizedBox(width: 12),
                            RenderDropdownButton<ImageFade>(
                              value: fade,
                              onChanged: (value) {
                                setState(() {
                                  fade = value;
                                });
                                onChange(WidgetChange.misc);
                              },
                              items: [
                                RenderDropdownMenuItem(
                                  title: 'Inwards',
                                  value: ImageFade.inwards,
                                ),
                                RenderDropdownMenuItem(
                                  title: 'Outwards',
                                  value: ImageFade.out,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SwitchListTile.adaptive(
                        title: Text('Smooth Blur'),
                        value: blurFade,
                        onChanged: (value) {
                          setState(() {
                            blurFade = value;
                          });
                          onChange(WidgetChange.misc);
                        },
                      ),
                    ],
                  ),
                ),
              ]
            ),
            actions: (dismiss) => [
              IconButton(
                icon: Icon(RenderIcons.delete),
                onPressed: () {
                  fade = null;
                  blurFade = false;
                  dismiss();
                  onChange(WidgetChange.update);
                },
              )
            ],
            onDismiss: () {
              onChange(WidgetChange.update, historyMessage: 'Fade Image');
            },
          );
        },
        icon: RenderIcons.gradient
      ),
      Option.button(
        title: 'Filters',
        onTap: (context) {
          widget.page.editorManager.openModal(
            padding: EdgeInsets.zero,
            tab: (context, setState) => EditorTab(
              name: 'Filters',
              type: EditorTabType.single,
              options: [
                Option.custom(
                  widget: (context) {
                    List<ColorFilterGenerator> filters = [
                      PresetFilters.none,
                      PresetFilters.aden,
                      PresetFilters.amaro,
                      PresetFilters.ashby,
                      PresetFilters.brannan,
                      PresetFilters.brooklyn,
                      PresetFilters.charmes,
                      PresetFilters.clarendon,
                      PresetFilters.crema,
                      PresetFilters.dogpatch,
                      PresetFilters.earlybird,
                      PresetFilters.f1977,
                      PresetFilters.gingham,
                      PresetFilters.ginza,
                      PresetFilters.hefe,
                      PresetFilters.helena,
                      PresetFilters.hudson,
                      PresetFilters.inkwell,
                      PresetFilters.juno,
                      PresetFilters.kelvin,
                      PresetFilters.lark,
                      PresetFilters.loFi,
                      PresetFilters.ludwig,
                      PresetFilters.maven,
                      PresetFilters.mayfair,
                      PresetFilters.moon,
                      PresetFilters.nashville,
                      PresetFilters.perpetua,
                      PresetFilters.reyes,
                      PresetFilters.rise,
                      PresetFilters.sierra,
                      PresetFilters.skyline,
                      PresetFilters.slumber,
                      PresetFilters.stinson,
                      PresetFilters.sutro,
                      PresetFilters.toaster,
                      PresetFilters.toaster,
                      PresetFilters.valencia,
                      PresetFilters.vesper,
                      PresetFilters.walden,
                      PresetFilters.willow,
                      PresetFilters.xProII,
                      PresetFilters.addictiveBlue,
                      PresetFilters.addictiveRed,
                    ];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: Constants.of(context).bottomPadding
                      ),
                      child: SizedBox(
                        height: 150,
                        child: ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          scrollDirection: Axis.horizontal,
                          separatorBuilder: (context, index) => SizedBox(width: 4),
                          itemBuilder: (context, index) => GestureDetector(
                            onTap: () {
                              TapFeedback.light();
                              filter = filters[index];
                              onChange(WidgetChange.update);
                            },
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: 150,
                                maxHeight: 150,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: _imageBuilder(
                                  asset,
                                  colorFilter: ColorFilter.matrix(filters[index].matrix),
                                ),
                              ),
                            ),
                          ),
                          itemCount: filters.length,
                        ),
                      ),
                    );
                  },
                )
              ]
            )
          );
        },
        icon: RenderIcons.filter
      ),
      Option.divider(),
      Option.toggle(
        title: 'Flip Vertical',
        value: flipVertical,
        onChange: (value) {
          flipVertical = !flipVertical;
          onChange(WidgetChange.update);
        },
        enabledIcon: RenderIcons.flip_vertical,
        disabledIcon: RenderIcons.flip_vertical,
        enabledTooltip: 'Flip Vertically',
        disabledTooltip: 'Flip Vertically',
      ),
      Option.toggle(
        title: 'Flip Horizontal',
        value: flipHorizontal,
        onChange: (value) {
          flipHorizontal = !flipHorizontal;
          onChange(WidgetChange.update);
        },
        enabledIcon: RenderIcons.flip_horizontal,
        disabledIcon: RenderIcons.flip_horizontal,
        enabledTooltip: 'Flip Horizontally',
        disabledTooltip: 'Flip Horizontally',
      ),
      if (options.isNotEmpty) Option.divider(),
      ... options
    ]
  );

  Widget _imageBuilder(AssetX asset, {
    required ColorFilter colorFilter,
    BoxFit fit = BoxFit.cover,
    Size? size
  }) => Transform(
    alignment: Alignment.center,
    transform: Matrix4.rotationY(flipHorizontal ? math.pi : 0)..rotateX(flipVertical ? math.pi : 0),
    child: ColorFiltered(
      colorFilter: colorFilter,
      child: OctoImage(
        fadeInCurve: Sprung.overDamped,
        fadeInDuration: Constants.animationDuration,
        image: asset.assetType == AssetType.file ? FileImage(asset.file!) : CachedNetworkImageProvider(asset.url!) as ImageProvider,
        width: size?.width,
        height: size?.height,
        imageBuilder: (context, child) {
          return Stack(
            children: [
              child,
              if (blurFade) ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: ShaderMask(
                  shaderCallback: (rect) {
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black, Colors.black.withValues(alpha: 0)],
                      stops: [0.4, 0.75]
                    ).createShader(rect);
                  },
                  blendMode: fade == ImageFade.inwards ? BlendMode.dstIn : BlendMode.dstOut,
                  child: child
                )
              ),
              if (fade != null) Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      if (fade == ImageFade.inwards) fadeColor,
                      Colors.transparent,
                      if (fade == ImageFade.out) fadeColor
                    ],
                    stops: [
                      if (fade == ImageFade.inwards) 0,
                      0.5,
                      if (fade == ImageFade.out) 1
                    ]
                  )
                ),
              )
            ],
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(5)
            ),
            child: Center(
              child: Icon(
                RenderIcons.error,
                color: Colors.black
              ),
            ),
          );
        },
        placeholderBuilder: (context) => ClipRRect(
          child: Stack(
            children: [
              Container(
                // color: page.background.color.withValues(alpha: 0.5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.page.palette.background.withAlpha(180).withValues(alpha: 0.5),
                      widget.page.palette.background.withValues(alpha: 0.5),
                    ]
                  )
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: SizedBox.fromSize(
                    size: size,
                    child: Container(),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  height: 50,
                  width: 50,
                  child: Spinner(
                    adaptive: true,
                  )
                ),
              )
            ],
          ),
        ),
        fit: fit,
      )
    ),
  );

  Widget build(AssetX asset, {
    required Size size,
  }) => _imageBuilder(
    asset,
    colorFilter: ColorFilter.matrix(matrix),
    size: size
  );

  static CreativeImageProvider fromJSON(Map data, {
    required CreatorWidget widget
  }) {
    CreativeImageProvider provider = CreativeImageProvider._(widget);
    provider.brightness = data['brightness'] ?? 0;
    provider.contrast = data['contrast'] ?? 0;
    provider.exposure = data['exposure'] ?? 0;
    provider.saturation = data['saturation'] ?? 0;
    provider.visibility = data['visibility'] ?? 0;
    provider.sepia = data['sepia'];
    provider.hue = data['hue'] ?? 0;
    provider.flipHorizontal = data['flipHorizontal'] ?? false;
    provider.flipVertical = data['flipVertical'] ?? false;
    provider.filter = data['filter'] != null ? ColorFilterGenerator(
      name: "Custom Filter",
      filters: [
        if (data['filter'] != null) (data['filter'] as List).toDataType<double>(),
      ]
    ) : null;
    provider.fadeColor = HexColor.fromHex(data['fade-color'], defaultColor: Colors.black);
    provider.blurFade = data['blur-fade'] ?? false;
    provider.fade = ImageFadeExtension.fromString(data['fade']);
    return provider;
  }

  Map<String, dynamic> toJSON() => {
    'brightness': brightness,
    'contrast': contrast,
    'exposure': exposure,
    'saturation': saturation,
    'visibility': visibility,
    'sepia': sepia,
    'hue': hue,
    'flipHorizontal': flipHorizontal,
    'flipVertical': flipVertical,
    'filter': filter?.matrix,
    'fade-color': fadeColor.toHex(),
    'fade': fade?.name,
    'blur-fade': blurFade
  };

}

enum ImageFade {
  inwards,
  out
}

extension ImageFadeExtension on ImageFade {

  String get name {
    switch (this) {
      case ImageFade.inwards:
        return 'Inwards';
      case ImageFade.out:
        return 'Outwards';
    }
  }

  static ImageFade? fromString(String? value) {
    switch (value) {
      case 'Inwards':
        return ImageFade.inwards;
      case 'Outwards':
        return ImageFade.out;
      default:
        return null;
    }
  }

}