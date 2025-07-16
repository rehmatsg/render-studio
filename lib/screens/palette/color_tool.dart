import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

import '../../rehmat.dart';

class ColorTool extends StatefulWidget {

  ColorTool({
    Key? key,
    this.palette,
    this.selection,
    this.allowOpacity = true,
  }) : super(key: key);

  /// Provide a palette to allow few pre-defined colors to be selected.
  final ColorPalette? palette;
  /// If there is an already selected color, provide it here.
  final Color? selection;

  /// Set this to true to allow the user to select opacity.
  final bool allowOpacity;

  static Future<Color?> openTool(BuildContext context, {
    ColorPalette? palette,
    Color? selection,
    bool allowOpacity = true,
  }) => AppRouter.push(context, page: ColorTool(palette: palette, selection: selection, allowOpacity: allowOpacity,));

  @override
  State<ColorTool> createState() => _ColorToolState();
}

class _ColorToolState extends State<ColorTool> {

  late Color _color;

  @override
  void initState() {
    super.initState();
    _color = widget.selection ?? Colors.blueAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(6.0),
          child: NewBackButton(),
        ),
        title: Text('Color Tool'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(_color),
            child: Text(
              'Done'
            ),
          ),
          // PopupMenuButton<PaletteType>(
          //   // child: Text('Palette'),
          //   itemBuilder: (context) => [
          //     PopupMenuItem(
          //       child: Text('Color Wheel'),
          //       value: PaletteType.hueWheel,
          //     ),
          //     PopupMenuItem(
          //       child: Text('HSL'),
          //       value: PaletteType.hsl,
          //     ),
          //     PopupMenuItem(
          //       child: Text('HSV'),
          //       value: PaletteType.hsv,
          //     ),
          //     PopupMenuItem(
          //       child: Text('HSV with Value'),
          //       value: PaletteType.hsvWithValue,
          //     ),
          //   ],
          //   onSelected: (value) => setState(() {
          //     paletteType = value;
          //   }),
          // ),
          // // IconButton(
          // //   onPressed: () async {
          // //     File? image = await FilePicker.pick(
          // //       context: context,
          // //       type: FileType.image,
          // //       crop: false
          // //     );
          // //     print(image);
          // //     if (image != null) AppRouter.replace(context, page: ImageColorPicker(image: image));
          // //   },
          // //   icon: Icon(RenderIcons.color_picker)
          // // ),
          // IconButton(
          //   onPressed: () => Navigator.of(context).pop(_color),
          //   icon: Icon(RenderIcons.done)
          // )
        ],
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        children: [
          ColorPicker(
            onColorChanged: changeColor,
            padding: EdgeInsets.all(6),
            color: _color,
            enableOpacity: widget.allowOpacity,
            copyPasteBehavior: ColorPickerCopyPasteBehavior(
              copyIcon: RenderIcons.copy,
              copyFormat: ColorPickerCopyFormat.numHexRRGGBB,
              longPressMenu: true,
              pasteIcon: RenderIcons.paste,
              copyTooltip: 'Copy color',
            ),
            pickersEnabled: {
              ColorPickerType.wheel: true,
              ColorPickerType.custom: true,
            },
            customColorSwatchesAndNames: widget.palette != null ? {
              ColorTools.createPrimarySwatch(widget.palette!.primary) : 'Primary',
              ColorTools.createPrimarySwatch(widget.palette!.secondary) : 'Secondary',
              ColorTools.createPrimarySwatch(widget.palette!.tertiary) : 'Tertiary',
              ColorTools.createPrimarySwatch(widget.palette!.background) : 'Background',
              ColorTools.createPrimarySwatch(widget.palette!.onBackground) : 'On Background',
              ColorTools.createPrimarySwatch(widget.palette!.surface) : 'Surface',
            } : {},
            enableTonalPalette: true,
            showColorName: true,
            colorNameTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            colorCodeReadOnly: false,
            colorCodeHasColor: true,
            showColorCode: true,
            mainAxisSize: MainAxisSize.max,
          )
        ],
      ),
    );
  }

  void changeColor(Color color, [bool updateText = true]) {
    setState(() => _color = color);
  }

//   Widget get wheel => Center(
//     child: Container(
//       // duration: Duration(milliseconds: 100),
//       decoration: BoxDecoration(
//         boxShadow: [
//           BoxShadow(
//             color: _color.withValues(alpha: Palette.isDark(context) ? 0.1 : 0.2),
//             blurRadius: 200,
//             spreadRadius: 150,
//           ),
//         ],
//         borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 2/3)
//       ),
//       child: SizedBox(
//         height: MediaQuery.of(context).size.width * 2/3,
//         width: MediaQuery.of(context).size.width * 2/3,
//         child: ColorPickerArea(
//           HSVColor.fromColor(_color),
//           (value) => changeColor(value.toColor()),
//           paletteType
//         ),
//       ),
//     ),
//   );
// 
//   Widget get slider => SizedBox(
//     height: 100,
//     width: MediaQuery.of(context).size.width * 4/5,
//     child: ColorPickerSlider(
//       TrackType.lightness,
//       HSVColor.fromColor(_color),
//       (value) => changeColor(value.toColor()),
//       displayThumbColor: true,
//     ),
//   );
// 
//   Widget get paletteColors => (widget.palette != null) ? Padding(
//     padding: EdgeInsets.symmetric(vertical: 0),
//     child: Wrap(
//       spacing: 12,
//       runSpacing: 12,
//       alignment: WrapAlignment.center,
//       children: [
//         ... List.generate(
//           widget.palette!.colors.length,
//           (index) => InkWell(
//             onTap: () => changeColor(widget.palette!.colors[index]),
//             borderRadius: BorderRadius.circular(50),
//             child: AnimatedContainer(
//               duration: Constants.animationDuration,
//               height: 60,
//               width: 60,
//               padding: _color == widget.palette!.colors[index] ? EdgeInsets.all(2) : EdgeInsets.zero,
//               decoration: BoxDecoration(
//                 border: Border.all(
//                   color: widget.palette!.colors[index],
//                   width: 2,
//                 ),
//                 borderRadius: BorderRadius.circular(50),
//                 boxShadow: [
//                   BoxShadow(
//                     color: widget.palette!.colors[index].withValues(alpha: 0.2),
//                     blurRadius: 20,
//                     spreadRadius: 10,
//                   ),
//                 ],
//               ),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: widget.palette!.colors[index],
//                   borderRadius: BorderRadius.circular(50),
//                 ),
//               ),
//             ),
//           )
//         )
//       ],
//     ),
//   ) : Container();

}

class ColorEditorTab extends StatefulWidget {

  ColorEditorTab({
    Key? key,
    this.color,
    required this.onChange,
    this.palette,
    this.allowOpacity = true
  }) : super(key: key);

  final ColorPalette? palette;

  final void Function(Color color) onChange;

  final Color? color;

  final bool allowOpacity;

  @override
  State<ColorEditorTab> createState() => _ColorEditorTabState();
}

class _ColorEditorTabState extends State<ColorEditorTab> {

  ColorPalette? palette;

  late Color color;

  late List<Color> colors;

  @override
  void initState() {
    palette = widget.palette;
    color = widget.color ?? Colors.white;
    colors = [];
    if (palette != null) colors.addAll(palette!.colors);
    colors.addAll([
      Colors.black,
      Colors.white,
      Colors.grey.shade200,
      Colors.grey.shade300,
      Colors.grey.shade400,
      Colors.grey.shade600,
      Colors.grey.shade800,
      Colors.grey.shade900,
      Colors.brown,
      Colors.red,
      Colors.redAccent,
      Colors.blue,
      Colors.blueAccent,
      Colors.blueGrey,
      Colors.lightBlue,
      Colors.lightBlueAccent,
      Colors.green,
      Colors.greenAccent,
      Colors.lightGreen,
      Colors.lightGreenAccent,
      Colors.yellow,
      Colors.yellowAccent,
      Colors.orange,
      Colors.orangeAccent,
      Colors.pink,
      Colors.pinkAccent,
      Colors.purple,
      Colors.purpleAccent,
      Colors.indigo,
      Colors.indigoAccent,
      Colors.teal,
      Colors.tealAccent,
      Colors.cyan,
      Colors.cyanAccent,
      Colors.lime,
      Colors.limeAccent,
      Colors.amber,
      Colors.amberAccent,
      Colors.deepOrange,
      Colors.deepOrangeAccent,
      Colors.deepPurple,
      Colors.deepPurpleAccent,
    ]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 40,
          child: Row(
            children: [
              SizedBox(width: 12,),
              SizedBox(
                width: 40,
                height: 40,
                child: Center(
                  child: OutlinedIconButtons(
                    onPressed: () async {
                      Color? _color = await ColorTool.openTool(
                        context,
                        palette: palette,
                        selection: color,
                        allowOpacity: widget.allowOpacity
                      );
                      if (_color != null) onChange(_color);
                    },
                    icon: Icon(RenderIcons.color_picker),
                    tooltip: 'Open Advanced Color Tool',
                  ),
                ),
              ),
              SizedBox(width: 6),
              Expanded(
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: colors.length,
                  separatorBuilder: (context, index) {
                    if (palette != null && index == palette!.colors.length - 1) return SizedBox(
                      height: 40,
                      child: VerticalDivider(
                        width: 24,
                        endIndent: 3,
                        indent: 3,
                      )
                    );
                    else return SizedBox(width: 6,);
                  },
                  itemBuilder: (context, index) => SizedBox(
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors[index],
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                          width: 0
                        )
                      ),
                      child: InkWell(
                        onTap: () {
                          onChange(colors[index]);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.allowOpacity) Padding(
          padding: const EdgeInsets.only(
            left: 12,
            right: 12,
            top: 12
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Label(
                label: 'Opacity',
                subtitle: true,
              ),
              Expanded(
                child: Slider(
                  value: color.opacity,
                  min: 0,
                  max: 1,
                  onChanged: (opacity) {
                    onChange(color.withValues(alpha: opacity));
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: Constants.of(context).bottomPadding,
        )
      ],
    );
  }

  void onChange(Color color) {
    widget.onChange(color);
    setState(() {
      this.color = color;
    });
  }

}