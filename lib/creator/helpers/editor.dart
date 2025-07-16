import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/utils.dart' hide ContextExtensionss;
import 'package:render_studio/creator/helpers/editor_manager.dart';
import 'package:sprung/sprung.dart';

import '../../rehmat.dart';

class Editor extends StatefulWidget {
  
  const Editor({
    Key? key,
    required this.widget,
  }) : super(key: key);

  final CreatorWidget widget;

  static Size calculateSize(BuildContext context) {
    double verticalPadding = Constants.of(context).bottomPadding;
    double height = getButtonWithIconHeight(context);
    return Size(double.infinity, height + verticalPadding);
  }

  @override
  _EditorState createState() => _EditorState();
}

class _EditorState extends State<Editor> with TickerProviderStateMixin {

  late CreatorWidget creatorWidget;

  void setNewTabCtrl() {
    creatorWidget.editorTabCtrl = TabController(length: creatorWidget.tabs.length, vsync: this);
  }

  @override
  void initState() {
    creatorWidget = widget.widget;
    creatorWidget.addListener(onPropertyChange, [WidgetChange.update, WidgetChange.lock]);
    if (creatorWidget.editorTabCtrl == null) setNewTabCtrl();
    super.initState();
  }

  @override
  void dispose() {
    creatorWidget.removeListener(onPropertyChange, [WidgetChange.update, WidgetChange.lock]);
    super.dispose();
  }

  @override
  void didUpdateWidget(Editor old) {
    super.didUpdateWidget(old);
  }

  @override
  Widget build(BuildContext context) {
    Size editorSize = Editor.calculateSize(context);
    TabController tabController = creatorWidget.editorTabCtrl!;
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Palette.of(context).surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 2,
          )
        ],
      ),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TabBar(
                      controller: creatorWidget.editorTabCtrl,
                      enableFeedback: true,
                      tabAlignment: TabAlignment.start,
                      padding: EdgeInsets.only(
                        right: 50
                      ),
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorColor: Constants.getThemedBlackAndWhite(context),
                      labelColor: Constants.getThemedBlackAndWhite(context),
                      indicator: creatorWidget.tabs.length > 1 ? null : const BoxDecoration(),
                      unselectedLabelColor: Constants.getThemedBlackAndWhite(context).withValues(alpha: 0.5),
                      isScrollable: true,
                      labelStyle: Theme.of(context).textTheme.titleSmall,
                      tabs: List.generate(
                        creatorWidget.tabs.length,
                        (index) => Tab(
                          text: creatorWidget.tabs[index].name,
                        )
                      ),
                      onTap: (value) {
                        if (!tabController.indexIsChanging) {
                          setState(() {
                            widget.widget.page.editorManager.toggleHidden();
                          });
                        } else {
                          if (widget.widget.page.editorManager.isHidden) setState(() {
                            widget.widget.page.editorManager.toggleHidden();
                          });
                        }
                      },
                    ),
                  ),
                  if (widget.widget.page.editorManager.isHidden) Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Palette.of(context).surface.withValues(alpha: 1),
                            blurRadius: 10,
                            spreadRadius: 10,
                          )
                        ],
                      ),
                      child: IconButton(
                        onPressed: () {
                          TapFeedback.light();
                          setState(() {
                            widget.widget.page.editorManager.toggleHidden();
                          });
                        },
                        icon: Icon(RenderIcons.arrow_up),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  )
                ],
              ),
              Divider(
                indent: 0,
                endIndent: 0,
                height: 0,
                color: context.isDarkMode ? HexColor.fromHex('#374049') : HexColor.fromHex('#fafafa'),
              ),
              AnimatedSize(
                duration: kAnimationDuration * 2,
                curve: Sprung(),
                child: widget.widget.page.editorManager.isHidden ? SizedBox.fromSize(
                  size: Size.fromHeight(Constants.of(context).bottomPadding),
                ) : SizedBox.fromSize(
                  size: editorSize,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 12,
                      // bottom: Constants.of(context).bottomPadding,
                    ),
                    child: Center(
                      child: TabBarView(
                        controller: tabController,
                        physics: const NeverScrollableScrollPhysics(),
                        clipBehavior: Clip.none,
                        children: List.generate(
                          creatorWidget.tabs.length,
                          (index) {
                            return creatorWidget.tabs[index].build(context);
                          }
                        )
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          if (creatorWidget.isLocked) Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () {
                TapFeedback.light();
                creatorWidget.unlock();
              },
              child: Container(
                color: Palette.blurBackground(context),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9
                      ),
                      decoration: BoxDecoration(
                        color: Palette.of(context).onSurface,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.lock_fill,
                            size: Theme.of(context).textTheme.titleLarge?.fontSize,
                            color: Palette.of(context).surface,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Locked',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Palette.of(context).surface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      )
    );
  }

  void onPropertyChange() {
    if (creatorWidget.tabs.length != creatorWidget.editorTabCtrl!.length) setNewTabCtrl();
    setState(() { });
  }

}

class EditorTab {

  EditorTab({
    required this.name,
    required this.options,
    this.type = EditorTabType.row,
  });

  final List<Option> options;
  final String name;
  final EditorTabType type;

  Widget build(BuildContext context) {
    switch (type) {
      case EditorTabType.row:
        return SizedBox(
          height: EditorManager.standardSize(context).height,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: options.length,
            padding: EdgeInsets.symmetric(horizontal: 12),
            itemBuilder: (context, index) => options[index].build(context),
            separatorBuilder: (context, index) => const SizedBox(width: 6),
            physics: const RangeMaintainingScrollPhysics(),
            scrollDirection: Axis.horizontal,
          ),
        );
      case EditorTabType.single:
        return options[0].build(context);
    }
  }

  static EditorTab opacity({
    required double opacity,
    required Function(double value) onChange,
    Function(double value)? onChangeEnd,
    Function(double value)? onChangeStart,
  }) => EditorTab(
    name: 'Opacity',
    type: EditorTabType.single,
    options: [
      Option.slider(
        value: opacity,
        min: 0.05,
        max: 1,
        onChangeStart: onChangeStart,
        onChange: onChange,
        onChangeEnd: onChangeEnd,
      )
    ],
  );

  static EditorTab rotate({
    required double angle,
    required Function(double value) onChange,
    Function(double value)? onChangeEnd,
    Function(double value)? onChangeStart,
  }) => EditorTab(
    name: 'Rotate',
    type: EditorTabType.single,
    options: [
      Option.slider(
        value: angle,
        min: -90,
        max: 90,
        onChangeStart: onChangeStart,
        onChange: onChange,
        onChangeEnd: onChangeEnd,
        snapPoints: [
          -90,
          -45,
          0,
          45,
          90,
        ],
      )
    ],
  );

  static EditorTab scale({
    required Size size,
    required Size minSize,
    required Size maxSize,
    required Function(Size value) onChange,
    Function(Size value)? onChangeEnd,
  }) {

    double ratio = size.width / size.height;
    
    double min = (ratio < 1) ? minSize.height : minSize.width;
    double max = (ratio < 1) ? maxSize.height : maxSize.width;

    Size _calculateSize({required double value}) {
      if (ratio < 1) {
        return Size(value * ratio, value);
      } else {
        return Size(value, value / ratio);
      }
    }

    double value = ratio < 1 ? size.height : size.width;
    if (value <= min) value = min;

    return EditorTab(
      name: 'Scale',
      type: EditorTabType.single,
      options: [
        Option.slider(
          value: value,
          min: min,
          max: max,
          label: 'Scale',
          onChange: (value) {
            onChange(_calculateSize(value: value));
          },
          onChangeEnd: (value) {
            if (onChangeEnd != null) onChangeEnd(_calculateSize(value: value));
          }
        )
      ],
    );
    
  }

  static EditorTab size({
    required double current,
    required double min,
    required double max,
    required Function(double value) onChange,
    Function(double value)? onChangeEnd,
    Function(double value)? onChangeStart,
  }) => EditorTab(
    name: 'Size',
    type: EditorTabType.single,
    options: [
      Option.slider(
        value: current,
        min: min,
        max: max,
        onChangeStart: onChangeStart,
        onChange: onChange,
        onChangeEnd: onChangeEnd,
        showValueEditor: true
      )
    ],
  );

  static EditorTab picker({
    required String title,
    required List<Widget> children,
    required void Function(int index)? onSelectedItemChanged,
    double itemExtent = 30,
    int initialIndex = 0
  }) => EditorTab(
    name: title,
    type: EditorTabType.single,
    options: [
      Option.picker(
        children: children,
        onSelectedItemChanged: onSelectedItemChanged,
        itemExtent: itemExtent,
        initialIndex: initialIndex
      )
    ],
  );

  static EditorTab pickerBuilder({
    required String title,
    required Widget? Function(BuildContext context, int index) itemBuilder,
    required void Function(int index)? onSelectedItemChanged,
    int? childCount,
    double itemExtent = 30,
    int initialIndex = 0
  }) => EditorTab(
    name: title,
    type: EditorTabType.single,
    options: [
      Option.pickerBuilder(
        itemBuilder: itemBuilder,
        onSelectedItemChanged: onSelectedItemChanged,
        childCount: childCount,
        initialIndex: initialIndex,
        itemExtent: itemExtent
      )
    ],
  );

  static EditorTab adjustTab({
    required CreatorWidget widget,
    bool rotate = true,
    bool scale = true,
    bool opacity = true,
    bool nudge = true,
    bool position = true,
    bool order = true,
  }) => EditorTab(
    name: 'Adjust',
    options: [
      if (rotate) Option.rotate(
        widget: widget.widgetOrGroup,
      ),
      if (scale && widget.group == null) Option.scale(
        widget: widget,
      ),
      if (opacity) Option.opacity(
        widget: widget,
      ),
      if (nudge) Option.nudge(
        widget: widget.widgetOrGroup,
      ),
      if (position) Option.position(
        widget: widget.widgetOrGroup
      ),
      if (order && widget.page.widgets.nWidgets >= 3) Option.openReorderTab(
        widget: widget.widgetOrGroup,
      )
    ]
  );

  static EditorTab nudge({
    required CreatorWidget widget,
    required Function(double dx) onDXchange,
    required Function(double dy) onDYchange,
  }) {
    double sensitivity = Constants.nudgeSensitivity / widget.page.scale;
    return EditorTab(
      name: 'Nudge',
      type: EditorTabType.single,
      options: [
        Option.custom(
          widget: (context) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ButtonWithIcon(
                onTap: (context) {
                  onDYchange(-sensitivity);
                  TapFeedback.light();
                },
                tooltip: 'Move Up',
                icon: RenderIcons.arrow_up,
              ),
              SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ButtonWithIcon(
                    onTap: (context) {
                      onDXchange(-sensitivity);
                    },
                    tooltip: 'Move Left',
                    icon: RenderIcons.arrow_left,
                  ),
                  SizedBox(width: 6),
                  ButtonWithIcon(
                    onTap: (context) {
                      onDYchange(sensitivity);
                    },
                    tooltip: 'Move Down',
                    icon: RenderIcons.arrow_down,
                  ),
                  SizedBox(width: 6),
                  ButtonWithIcon(
                    onTap: (context) {
                      onDXchange(sensitivity);
                    },
                    tooltip: 'Move Right',
                    icon: RenderIcons.arrow_right,
                  ),
                ]
              )
            ],
          ),
        )
      ],
    );
  }

  static EditorTab position({
    required CreatorWidget widget
  }) {
    List<Map> options = [
      {
        'title': 'Top',
        'icon': RenderIcons.align_top,
        'alignment': WidgetAlignment.top
      },
      {
        'title': 'Left',
        'icon': RenderIcons.align_left,
        'alignment': WidgetAlignment.left
      },
      {
        'title': 'Middle',
        'icon': RenderIcons.align_middle,
        'alignment': WidgetAlignment.middle
      },
      {
        'title': 'Center',
        'icon': RenderIcons.align_center,
        'alignment': WidgetAlignment.center
      },
      {
        'title': 'Bottom',
        'icon': RenderIcons.align_bottom,
        'alignment': WidgetAlignment.bottom
      },
      {
        'title': 'Right',
        'icon': RenderIcons.align_right,
        'alignment': WidgetAlignment.right
      },
    ];
    return EditorTab(
      name: 'Position',
      type: EditorTabType.single,
      options: [
        Option.custom(
          widget: (context) => StaggeredGrid.count(
            crossAxisCount: 2,
            axisDirection: AxisDirection.down,
            children: List.generate(
              options.length,
              (index) {
                Map data = options[index];
                return ListTile(
                  title: Text(data['title']),
                  leading: Icon(data['icon']),
                  onTap: () {
                    widget.alignPositioned(data['alignment']);
                  },
                );
              }
            ),
          ),
        )
      ],
    );
  }

  static EditorTab paddingEditor({
    required EdgeInsets padding,
    required Function(EdgeInsets value) onChange,
    double? minVertical,
    double? maxVertical,
    double? minHorizontal,
    double? maxHorizontal,
  }) => EditorTab(
    name: 'Padding',
    type: EditorTabType.single,
    options: [
      Option.custom(
        widget: (context) => _PaddingEditor(
          padding: padding,
          onChange: onChange,
          maxVertical: maxVertical,
          minVertical: minVertical,
          maxHorizontal: maxHorizontal,
          minHorizontal: minHorizontal,
        ),
      )
    ],
  );

  static EditorTab containerSizeEditor({
    required double widthRatio,
    required double heightRatio,
    required Function(double newWidthRatio, double newHeightRatio) onChange,
  }) => EditorTab(
    name: 'Size',
    type: EditorTabType.single,
    options: [
      Option.custom(
        widget: (context) => _ContainerSizeEditor(
          widthRatio: widthRatio,
          heightRatio: heightRatio,
          onChange: onChange,
        ),
      )
    ],
  );

  static EditorTab shadow<T>({
    required CreatorWidget widget,
    required Shadow shadow,
    required void Function(T? value) onChange,
  }) {
    return EditorTab(
      name: 'Shadow Editor',
      type: EditorTabType.single,
      options: [
        Option.custom(
          widget: (context) => _ShadowEditor<T>(
            widget: widget,
            shadow: shadow,
            onChange: onChange,
          ),
        )
      ],
    );
  }

  static EditorTab palette({
    required CreatorPage page,
    required void Function(ColorPalette palette) onSelected
  }) => EditorTab(
    name: 'Palette',
    type: EditorTabType.single,
    options: [
      Option.custom(
        widget: (context) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _PaletteListView(
                title: 'Current',
                palettes: [
                  page.palette
                ],
                onSelected: onSelected,
                page: page,
              ),
              if (paletteManager.palettes.isNotEmpty) ... [
                SizedBox(
                  height: 150,
                  child: VerticalDivider(
                    endIndent: 10,
                  ),
                ),
                _PaletteListView(
                  title: 'Saved',
                  palettes: [
                    ... paletteManager.palettes
                  ],
                  onSelected: onSelected,
                  page: page,
                ),
              ],
              for (String collectionName in ColorPalette.collections.keys) ... [
                SizedBox(
                  height: 150,
                  child: VerticalDivider(
                    endIndent: 10,
                  ),
                ),
                _PaletteListView(
                  title: collectionName,
                  palettes: ColorPalette.collections[collectionName]!,
                  onSelected: onSelected,
                  page: page,
                )
              ]
            ],
          ),
        ),
      )
    ]
  );

  static EditorTab color(BuildContext context, {
    ColorPalette? palette,
    required void Function(Color color) onChange,
    bool allowOpacity = true,
    Color? selected
  }) => EditorTab(
    name: 'Color',
    type: EditorTabType.single,
    options: [
      Option.custom(
        widget: (context) => ColorEditorTab(
          onChange: onChange,
          palette: palette,
          color: selected,
          allowOpacity: allowOpacity,
        ),
      )
    ]
  );

  static EditorTab reorder({
    required CreatorWidget widget,
    required void Function() onReorder,
    required void Function() onReorderEnd,
  }) => EditorTab(
    name: 'Reorder',
    type: EditorTabType.single,
    options: [
      Option.custom(
        widget: (context) => _ReorderEditorTab(
          widget: widget,
          onReorder: onReorder,
          onReorderEnd: onReorderEnd,
        )
      )
    ]
  );

  static EditorTab projectResize({
    required Project project,
  }) => EditorTab(
    name: 'Resize',
    type: EditorTabType.single,
    options: [
      Option.custom(
        widget: (context) => _ProjectResizeTab(
          project: project,
        )
      )
    ]
  );

}

class _ReorderEditorTab extends StatefulWidget {

  const _ReorderEditorTab({
    required this.widget,
    required this.onReorder,
    required this.onReorderEnd,
  });

  final CreatorWidget widget;
  final void Function() onReorder;
  final void Function() onReorderEnd;
  

  @override
  State<_ReorderEditorTab> createState() => __ReorderEditorTabState();
}

class __ReorderEditorTabState extends State<_ReorderEditorTab> {

  late final CreatorWidget creatorWidget;

  @override
  void initState() {
    creatorWidget = widget.widget;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        OutlinedIconButtons(
          onPressed: (index > 1) ? () {
            reorderByChange(-1);
          } : null,
          icon: Icon(RenderIcons.arrow_down)
        ),
        Expanded(
          child: SizedBox(
            height: 20,
            child: Slider(
              value: creatorWidget.page.widgets.sortedUIDs.indexOf(creatorWidget.uid).toDouble(),
              min: 1,
              max: creatorWidget.page.widgets.sortedUIDs.length.toDouble() - 1,
              divisions: creatorWidget.page.widgets.sortedUIDs.length - 2,
              onChanged: (value) {
                reorder(value.toInt());
                widget.onReorder();
              },
              onChangeEnd: (value) {
                reorder(value.toInt(), notify: true);
                widget.onReorderEnd();
              },
            ),
          ),
        ),
        OutlinedIconButtons(
          onPressed: (index < creatorWidget.page.widgets.nWidgets - 1) ? () {
            reorderByChange(1);
          } : null,
          icon: Icon(RenderIcons.arrow_up)
        ),
      ],
    );
  }

  void reorder(int value, {bool notify = true}) {
    creatorWidget.page.widgets.reorder(creatorWidget.uid, value.toInt(), log: notify);
    setState(() { });
    creatorWidget.page.updateListeners(PageChange.misc);
  }

  void reorderByChange(int change) {
    reorder(index + change, notify: true);
    widget.onReorderEnd();
    creatorWidget.page.updateListeners(PageChange.misc);
  }

  int get index => creatorWidget.page.widgets.sortedUIDs.indexOf(creatorWidget.uid);

}

enum EditorTabType {
  /// Arrange the options in a list
  row,
  /// Center align the single widget
  single
}

class _PaddingEditor extends StatefulWidget {

  _PaddingEditor({
    Key? key,
    required this.padding,
    required this.onChange,
    this.maxVertical,
    this.minVertical,
    this.maxHorizontal,
    this.minHorizontal,
  }) : super(key: key);

  final EdgeInsets padding;
  final Function(EdgeInsets value) onChange;
  final double? maxVertical;
  final double? minVertical;
  final double? maxHorizontal;
  final double? minHorizontal;

  @override
  State<_PaddingEditor> createState() => __PaddingEditorState();
}

class __PaddingEditorState extends State<_PaddingEditor> {

  late EdgeInsets padding;

  double horizontal = 0;
  double vertical = 0;

  bool locked = false;

  @override
  void initState() {
    padding = widget.padding;
    horizontal = padding.left;
    vertical = padding.top;
    if (horizontal == vertical) locked = true;
    else locked = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      RenderIcons.arrow_left_right
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Slider(
                        value: locked ? vertical : horizontal,
                        label: 'Horizontal',
                        min: widget.minHorizontal ?? 0,
                        max: widget.maxHorizontal ?? 24,
                        onChanged: (value) {
                          double change = value - horizontal;
                          horizontal = value;
                          if (locked && vertical + change <= widget.maxVertical! && vertical + change >= widget.minVertical!) {
                            vertical += change;
                          }
                          padding = EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
                          setState(() { });
                          widget.onChange(padding);
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12,),
                Row(
                  children: [
                    Icon(
                      RenderIcons.arrow_up_down
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Slider(
                        value: vertical,
                        label: 'Vertical',
                        min: widget.minVertical ?? 0,
                        max: widget.maxVertical ?? 24,
                        onChanged: (value) {
                          double change = value - vertical;
                          vertical = value;
                          if (locked && horizontal + change <= widget.maxHorizontal! && horizontal + change >= widget.minHorizontal!) {
                            horizontal += change;
                          }
                          padding = EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
                          setState(() { });
                          widget.onChange(padding);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 6),
          OutlinedIconButtons(
            onPressed: () {
              TapFeedback.light();
              setState(() => locked = !locked);
            },
            icon: Icon(
              locked ? RenderIcons.lock : RenderIcons.unlock,
            ),
          )
        ],
      ),
    );
  }
  
}

class _ContainerSizeEditor extends StatefulWidget {

  _ContainerSizeEditor({
    Key? key,
    required this.widthRatio,
    required this.heightRatio,
    required this.onChange,
  }) : super(key: key);

  final double widthRatio;
  final double heightRatio;
  final Function(double widthRatio, double heightRatio) onChange;

  @override
  State<_ContainerSizeEditor> createState() => __ContainerSizeEditorState();
}

class __ContainerSizeEditorState extends State<_ContainerSizeEditor> {

  late double widthRatio;
  late double heightRatio;

  bool locked = true;

  @override
  void initState() {
    widthRatio = widget.widthRatio;
    heightRatio = widget.heightRatio;
    if (widthRatio == heightRatio) locked = true;
    else locked = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      RenderIcons.arrow_left_right
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Slider(
                        value: widthRatio,
                        label: 'Width',
                        min: 1,
                        max: 2,
                        onChanged: (value) {
                          print(value);
                          double change = value - widthRatio;
                          widthRatio = value;
                          if (locked && heightRatio + change <= 2 && heightRatio + change >= 1) {
                            heightRatio += change;
                          }
                          setState(() { });
                          widget.onChange(widthRatio, heightRatio);
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12,),
                Row(
                  children: [
                    Icon(
                      RenderIcons.arrow_up_down
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Slider(
                        value: heightRatio,
                        label: 'Height',
                        min: 1,
                        max: 2,
                        onChanged: (value) {
                          double change = value - heightRatio;
                          heightRatio = value;
                          if (locked && widthRatio + change <= 2 && widthRatio + change >= 1) {
                            widthRatio += change;
                          }
                          setState(() { });
                          widget.onChange(widthRatio, heightRatio);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 6),
          OutlinedIconButtons(
            onPressed: () {
              TapFeedback.light();
              setState(() => locked = !locked);
            },
            icon: Icon(
              locked ? RenderIcons.lock : RenderIcons.unlock,
            ),
          )
        ],
      ),
    );
  }

  Widget iconButton() {
    if (locked) return FilledTonalIconButton(
      onPressed: () => setState(() => locked = !locked),
      icon: Icon(RenderIcons.lock)
    );
    else return OutlinedIconButtons(
      onPressed: () => setState(() => locked = !locked),
      icon: Icon(RenderIcons.unlock)
    );
  }
  
}

class _ShadowEditor<T> extends StatefulWidget {

  _ShadowEditor({
    Key? key,
    required this.widget,
    required this.shadow,
    required this.onChange,
  });

  final CreatorWidget widget;
  final Shadow shadow;
  final void Function(T value) onChange;

  @override
  State<_ShadowEditor<T>> createState() => __ShadowEditorState<T>();
}

class __ShadowEditorState<T> extends State<_ShadowEditor<T>> {

  late T shadow;

  Shadow get _shadow => shadow as Shadow;

  late final TextEditingController xController;
  late final TextEditingController yController;
  late final TextEditingController opacityController;
  late final TextEditingController blurController;
  final TextEditingController spreadController = TextEditingController(text: '0');

  Color color = Colors.black;
  double opacity = 0.3;
  double distance = 0;
  double direction = 0;
  double blur = 0;
  double spread = 0;

  @override
  void initState() {
    shadow = (widget.shadow as T);
    color = _shadow.color;
    getDirectionAndDistance();
    blur = _shadow.blurRadius;
    opacity = _shadow.color.opacity.trimToDecimal(1);
    blurController = TextEditingController.fromValue(TextEditingValue(text: blur.toString()));
    opacityController = TextEditingController.fromValue(TextEditingValue(text: opacity.toString()));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12,),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomSlider(
            value: distance,
            min: 0,
            max: 20,
            label: 'Distance',
            actions: [
              Text(
                'Color',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)
                ),
              ),
              SizedBox(width: 12),
              ColorSelector(
                widget: widget.widget,
                onColorSelect: (color) {
                  this.opacity = color.opacity;
                  this.color = color.withValues(alpha: 1);
                  onChange();
                },
                reverseOrder: true,
                size: const Size(30, 30),
                color: color,
              ),
            ],
            onChange: (value) {
              distance = value;
              onChange();
            },
            onChangeStart: (value) {
              widget.widget.setHandlersVisibility(false);
            },
            onChangeEnd: (value) {
              widget.widget.setHandlersVisibility(true);
            },
          ),
          CustomSlider(
            value: direction,
            min: 0.0174533,
            max: 6.28319,
            label: 'Direction',
            onChange: (value) {
              direction = value;
              onChange();
            },
            onChangeStart: (value) {
              widget.widget.setHandlersVisibility(false);
            },
            onChangeEnd: (value) {
              widget.widget.setHandlersVisibility(true);
            },
          ),
          SizedBox(height: 12),
          CustomSlider(
            value: blur,
            min: 0,
            max: 20,
            label: 'Blur',
            onChange: (value) {
              blur = value;
              onChange();
            },
            onChangeStart: (value) {
              widget.widget.setHandlersVisibility(false);
            },
            onChangeEnd: (value) {
              widget.widget.setHandlersVisibility(true);
            },
          ),
        ],
      ),
    );
  }

  void onChange() {
    if (shadow.runtimeType == BoxShadow) {
      shadow = BoxShadow(
        color: color.withValues(alpha: opacity),
        offset: getOffset(),
        blurRadius: blur,
        spreadRadius: spread,
      ) as T;
    } else if (shadow.runtimeType == Shadow) {
      shadow = Shadow(
        color: color.withValues(alpha: opacity),
        offset: getOffset(),
        blurRadius: blur,
      ) as T;
    }
    widget.onChange(shadow);
  }

  Offset getOffset() {
    final double x = distance * cos(direction);
    final double y = distance * sin(direction);
    return Offset(x, y);
  }

  void getDirectionAndDistance() {
    final Offset offset = _shadow.offset;
    distance = sqrt(pow(offset.dx, 2) + pow(offset.dy, 2));
    direction = atan2(offset.dy, offset.dx);
  }

}

class _PaletteViewModal extends StatefulWidget {

  _PaletteViewModal({
    Key? key,
    required this.palette,
    required this.onSelected,
    required this.page
  }) : super(key: key);

  final ColorPalette palette;
  final void Function(ColorPalette) onSelected;
  final CreatorPage page;

  @override
  State<_PaletteViewModal> createState() => __PaletteViewModalState();
}

class __PaletteViewModalState extends State<_PaletteViewModal> {

  @override
  void initState() {
    super.initState();
    widget.page.addListener(_onPageChange);
  }

  @override
  void dispose() {
    widget.page.removeListener(_onPageChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.palette.refresh();
        widget.onSelected(widget.palette);
        setState(() { });
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: SizedBox(
          width: 70,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (Color color in widget.palette.colors) Flexible(
                      child: AnimatedContainer(
                        duration: Constants.animationDuration,
                        width: 70,
                        decoration: BoxDecoration(
                          color: color,
                          border: Border.all(
                            color: color,
                            width: 0
                          )
                        ),
                      ),
                    ),
                  ]
                ),
              ),
              AnimatedSwitcher(
                duration: Constants.animationDuration,
                child: widget.page.palette == widget.palette ? Align(
                  alignment: Alignment.center,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Palette.blurBackground(context)
                        ),
                        child: Icon(
                          CupertinoIcons.shuffle,
                          size: 18,
                          color: Palette.onBlurBackground(context)
                        )
                      ),
                    ),
                  )
                ) : Container(),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _onPageChange() {
    setState(() { });
  }

}

class _PaletteListView extends StatefulWidget {

  _PaletteListView({
    Key? key,
    required this.title,
    required this.palettes,
    required this.onSelected,
    required this.page
  }) : super(key: key);

  final String title;
  final List<ColorPalette> palettes;
  final void Function(ColorPalette) onSelected;
  final CreatorPage page;

  @override
  State<_PaletteListView> createState() => __PaletteListViewState();
}

class __PaletteListViewState extends State<_PaletteListView> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
            child: Text(
              widget.title,
              style: Theme.of(context).textTheme.titleMedium
            ),
          ),
          SizedBox(
            height: 140,
            child: ListView.separated(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => SizedBox(
                height: 140,
                child: _PaletteViewModal(
                  palette: widget.palettes[index],
                  onSelected: widget.onSelected,
                  page: widget.page,
                ),
              ),
              itemCount: widget.palettes.length,
              separatorBuilder: (context, index) => SizedBox(width: 9),
            ),
          )
        ],
      ),
    );
  }

}

class _ProjectResizeTab extends StatefulWidget {

  const _ProjectResizeTab({required this.project});

  final Project project;

  @override
  State<_ProjectResizeTab> createState() => __ProjectResizeTabState();
}

class __ProjectResizeTabState extends State<_ProjectResizeTab> {

  late PostSizePresets current;

  @override
  void initState() {
    super.initState();
    PostSize currentSize = widget.project.size;
    current = PostSizePresets.values.firstWhereOrNull((preset) => preset.toSize().size == currentSize.size) ?? PostSizePresets.square;
  }

  @override
  Widget build(BuildContext context) {
    double maxHeight = EditorManager.standardOptionHeight(context);
    double maxPresetSize = PostSizePresets.values.map((e) => e.toSize().size.height).reduce(max);
    double scaleDown = maxHeight / maxPresetSize;
    return SizedBox(
      height: maxHeight + (2 * Theme.of(context).textTheme.bodySmall!.fontSize!) + 6,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: PostSizePresets.values.length,
        separatorBuilder: (context, index) => SizedBox(width: 9),
        padding: EdgeInsets.symmetric(horizontal: 12),
        itemBuilder: (context, index) {
          PostSizePresets preset = PostSizePresets.values[index];
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxHeight
            ),
            child: GestureDetector(
              onTap: () {
                TapFeedback.light();
                widget.project.resize(preset.toSize());
                setState(() {
                  current = preset;
                });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Spacer(),
                  AnimatedContainer(
                    height: preset.size.height * scaleDown,
                    width: preset.size.width * scaleDown,
                    duration: Duration(milliseconds: 100),
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Palette.of(context).surfaceContainerLow,
                      border: current == preset ? Border.all(
                        color: Palette.of(context).outline,
                        width: 2
                      ) : null,
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          preset.icon,
                          size: 20,
                          color: Constants.getThemedObject(context, light: Colors.grey, dark: Colors.grey[400])
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      preset.title,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

}