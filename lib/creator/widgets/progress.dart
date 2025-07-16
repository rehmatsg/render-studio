import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../rehmat.dart';

enum _ProgressType {
  linear,
  circular
}

class CreativeProgressWidget extends CreatorWidget {

  CreativeProgressWidget({required CreatorPage page, Map? data, BuildInfo buildInfo = BuildInfo.unknown}) : super(page, data: data, buildInfo: buildInfo);

  static Future<void> create(BuildContext context, {
    required CreatorPage page
  }) async {
    CreativeProgressWidget widget = CreativeProgressWidget(page: page);
    page.widgets.add(widget);
  }

  @override
  void onInitialize() {
    foregroundColor = page.palette.primary;
    backgroundColor = page.palette.primary.withValues(alpha: 0.2);
    super.onInitialize();
  }

  // Inherited
  final String name = 'Progress';
  @override
  final String id = 'progress';

  bool keepAspectRatio = true;
  bool isResizable = true;
  bool isDraggable = true;

  @override
  Size size = Size(100, 100);
  @override
  Size? minSize = Size(50, 10);

  late Color foregroundColor;
  late Color backgroundColor;

  double progress = 0.25;
  
  double strokeWidth = 10;

  StrokeCap corners = StrokeCap.round;

  double startAngle = 0;

  double backgroundDashSize = 0;
  double backgroundGapSize = 10;

  _ProgressType type = _ProgressType.circular;
  
  @override
  List<ResizeHandler> resizeHandlers = [
    ... ResizeHandler.values
  ];

  @override
  List<EditorTab> get tabs => [
    EditorTab(
      name: 'Progress',
      options: [
        Option.showSlider(
          this,
          title: 'Progress',
          icon: RenderIcons.progress,
          value: progress,
          min: 0.01,
          max: 1,
          snapPoints: [0.25, 0.5, 0.75, 1],
          snapSensitivity: 0.007,
          onChange: (value) {
            this.progress = value;
            updateListeners(WidgetChange.misc);
          },
          onChangeEnd: () => updateListeners(WidgetChange.update),
          showValueEditor: true
        ),
        Option.color(
          this,
          title: 'Ring Color',
          palette: page.palette,
          tooltip: 'Tap to change the color of progress ring',
          selected: foregroundColor,
          onChange: (color) {
            if (color != null) foregroundColor = color;
            updateListeners(WidgetChange.misc);
          },
          onChangeEnd: (color) {
            if (color != null) foregroundColor = color;
            updateListeners(WidgetChange.update);
          },
        ),
        Option.color(
          this,
          title: 'Inactive Color',
          palette: page.palette,
          tooltip: 'Tap to change the color of background',
          selected: backgroundColor,
          icon: RenderIcons.color2,
          onChange: (color) {
            if (color != null) backgroundColor = color;
            updateListeners(WidgetChange.misc);
          },
          onChangeEnd: (color) {
            if (color != null) backgroundColor = color;
            updateListeners(WidgetChange.update);
          },
        ),
        ... defaultOptions,
      ],
    ),
    EditorTab(
      name: 'Customize',
      options: [
        Option.button(
          title: type == _ProgressType.linear ? 'Linear' : 'Circular',
          onTap: (context) => page.editorManager.openModal(
            tab: (context, setState) => EditorTab.picker(
              title: 'Type',
              children: [
                Text('Linear'),
                Text('Circular'),
              ],
              initialIndex: type == _ProgressType.linear ? 0 : 1,
              onSelectedItemChanged: (index) {
                switch (index) {
                  case 0:
                    type = _ProgressType.linear;
                    keepAspectRatio = false;
                    resizeHandlers = [
                      ... ResizeHandler.values
                    ];
                    break;
                  case 1:
                    type = _ProgressType.circular;
                    keepAspectRatio = true;
                    if (size.width < size.height) {
                      size = Size(size.height, size.height);
                    } else {
                      size = Size(size.width, size.width);
                    }
                    resizeHandlers = [
                      ResizeHandler.topLeft,
                      ResizeHandler.topRight,
                      ResizeHandler.bottomLeft,
                      ResizeHandler.bottomRight,
                    ];
                    break;
                  default:
                }
                updateListeners(WidgetChange.update);
              },
            )
          ),
          icon: type == _ProgressType.linear ? RenderIcons.linear : RenderIcons.circular
        ),
        Option.showSlider(
          this,
          title: 'Stroke',
          icon: RenderIcons.align_bottom,
          value: strokeWidth,
          min: 5,
          max: 50,
          onChange: (value) {
            this.strokeWidth = value;
            updateListeners(WidgetChange.misc);
          },
          onChangeEnd: () => updateListeners(WidgetChange.update),
        ),
        Option.button(
          title: 'Corners',
          onTap: (context) => page.editorManager.openModal(
            tab: (context, setState) => EditorTab.picker(
              title: 'Corners',
              children: [
                Text('Round'),
                Text('Square'),
                Text('Butt')
              ],
              initialIndex: corners == StrokeCap.round ? 0 : corners == StrokeCap.square ? 1 : 2,
              onSelectedItemChanged: (index) {
                switch (index) {
                  case 0:
                    corners = StrokeCap.round;
                    break;
                  case 1:
                    corners = StrokeCap.square;
                    break;
                  case 2:
                    corners = StrokeCap.butt;
                    break;
                  default:
                }
                updateListeners(WidgetChange.update);
              },
            )
          ),
          icon: RenderIcons.border_radius
        ),
        if (type == _ProgressType.circular) ... [
          Option.showSlider(
            this,
            title: 'Start Angle',
            icon: RenderIcons.rotate,
            value: startAngle,
            min: -180,
            max: 180,
            snapPoints: [
              -180,
              -135,
              -90,
              -45,
              0,
              45,
              90,
              135,
              180
            ],
            onChange: (value) {
              this.startAngle = value;
              updateListeners(WidgetChange.misc);
            },
            onChangeEnd: () => updateListeners(WidgetChange.update),
            showValueEditor: true
          ),
          Option.showSlider(
            this,
            title: 'Dash',
            icon: RenderIcons.dash,
            value: backgroundDashSize,
            min: 0,
            max: 10,
            onChange: (value) {
              this.backgroundDashSize = value;
              updateListeners(WidgetChange.misc);
            },
            onChangeEnd: () => updateListeners(WidgetChange.update),
          ),
          Option.showSlider(
            this,
            title: 'Dash Gap',
            icon: RenderIcons.gap,
            value: backgroundGapSize,
            min: 0,
            max: 10,
            onChange: (value) {
              this.backgroundGapSize = value;
              updateListeners(WidgetChange.misc);
            },
            onChangeEnd: () => updateListeners(WidgetChange.update),
          ),
        ]
      ]
    ),
    EditorTab.adjustTab(
      widget: this,
      rotate: false
    )
  ];

  double fontSize = 20;

  @override
  Widget widget(BuildContext context) {
    switch (type) {
      case _ProgressType.circular:
        return DashedCircularProgressBar(
          height: size.height,
          width: size.width,
          progress: progress,
          child: SizedBox.expand(
            child: ColoredBox(color: Colors.transparent),
          ),
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          foregroundStrokeWidth: strokeWidth,
          backgroundStrokeWidth: strokeWidth,
          corners: corners,
          maxProgress: 1,
          startAngle: startAngle,
          backgroundGapSize: backgroundGapSize,
          backgroundDashSize: backgroundDashSize,
        );
      case _ProgressType.linear:
        return LinearPercentIndicator(
          percent: progress,
          backgroundColor: backgroundColor,
          lineHeight: strokeWidth,
          progressColor: foregroundColor,
          barRadius: corners == StrokeCap.round ? Radius.circular(strokeWidth / 2) : Radius.zero,
          padding: EdgeInsets.zero,
        );
    }
  }

  @override
  void onPaletteUpdate() {
    foregroundColor = page.palette.primary;
    backgroundColor = page.palette.primary.withValues(alpha: 0.2);
    super.onPaletteUpdate();
  }

  @override
  Map<String, dynamic> toJSON({
    BuildInfo buildInfo = BuildInfo.unknown
  }) => {
    ... super.toJSON(buildInfo: buildInfo),
    'type': type == _ProgressType.circular ? 'circular' : 'linear',
    'progress': progress,
    'stroke-width': strokeWidth,
    'corners': corners == StrokeCap.round ? 'round' : corners == StrokeCap.square ? 'square' : 'butt',
    'start-angle': startAngle,
    'background-dash-size': backgroundDashSize,
    'background-gap-size': backgroundGapSize,
    'foreground-color': foregroundColor.toHex(),
    'background-color': backgroundColor.toHex(),
  };

  @override
  void buildFromJSON(Map<String, dynamic> json, {
    required BuildInfo buildInfo
  }) {
    super.buildFromJSON(json, buildInfo: buildInfo);
    try {
      type = json['type'] == 'circular' ? _ProgressType.circular : _ProgressType.linear;
      progress = json['progress'];
      strokeWidth = json['stroke-width'];
      corners = json['corners'] == 'round' ? StrokeCap.round : json['corners'] == 'square' ? StrokeCap.square : StrokeCap.butt;
      startAngle = json['start-angle'];
      backgroundDashSize = json['background-dash-size'];
      backgroundGapSize = json['background-gap-size'];
      foregroundColor = HexColor.fromHex(json['foreground-color']);
      backgroundColor = HexColor.fromHex(json['background-color']);
    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'Failed to build widget from JSON', stacktrace: stacktrace);
      throw WidgetCreationException(
        'Error building widget',
        details: 'Error building widget: $e'
      );
    }
  }

}