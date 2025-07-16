import 'package:align_positioned/align_positioned.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:render_studio/creator/helpers/image_provider.dart';
import 'package:universal_io/io.dart';
import '../../rehmat.dart';

Future<void> showAddWidgetModal(BuildContext context, CreatorPage page) async {
  final Map<String, dynamic> widgets = {
    'text': {
      'title': 'Text',
      'icon': RenderIcons.text,
    },
    'image': {
      'title': 'Image',
      'icon': RenderIcons.image,
      'onTap': () async {
        await ImageWidget.create(context, page: page);
      }
    },
    'design_asset': {
      'title': 'Design Asset',
      'icon': RenderIcons.design_asset,
      'onTap': () async {
        await CreatorDesignAsset.create(context, page: page);
      }
    },
    'pie-chart': {
      'title': 'Pie Chart',
      'icon': RenderIcons.pieChart
    },
    'shape': {
      'title': 'Shapes',
      'icon': RenderIcons.shapes,
      'onTap': () async {
        await ShapeWidget.create(context, page: page);
      }
    },
    'qr_code': {
      'title': 'QR Code',
      'icon': RenderIcons.qr,
      'onTap': () async {
        await QRWidget.create(context, page: page);
      }
    },
    'progress': {
      'title': 'Progress',
      'icon': RenderIcons.progress,
    },
    'box': {
      'title': 'Box',
      'icon': RenderIcons.box
    },
    'blob': {
      'title': 'Blob',
      'widget': Blob.random(
        size: 25,
        styles: BlobStyles(
          color: Palette.of(context).onSecondaryContainer,
        ),
      ),
    },
  };
  Widget buttonBuilder(BuildContext context, {
    required data
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 6
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Palette.of(context).secondaryContainer,
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.all(12),
            child: data['icon'] != null ? Icon(
              data['icon'],
              color: Palette.of(context).onSecondaryContainer,
            ) : data['widget'],
          ),
          const SizedBox(width: 15),
          Text(
            data['title'],
            style: Theme.of(context).textTheme.titleLarge,
          )
        ],
      ),
    );
  }
  await Alerts.showModal(
    context,
    opacity: 0.7,
    child: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledIconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(RenderIcons.close),
            ),
          ),
          Spacer(flex: 3),
          ... widgets.entries.map((entry) {
            return FadeIn(
              blur: false,
              scale: false,
              child: GestureDetector(
                onTap: () async {
                  TapFeedback.light();
                  if (entry.value['onTap'] != null) await entry.value['onTap']();
                  else CreatorWidget.create(context, page: page, id: entry.key);
                  Navigator.of(context).pop();
                },
                child: buttonBuilder(
                  context,
                  data: entry.value
                ),
              ),
            );
          }).toList(),
          Spacer(flex: 1,)
        ],
      ),
    )
  );
}

class BackgroundWidget extends CreatorWidget {

  BackgroundWidget({required CreatorPage page, Map? data, BuildInfo buildInfo = BuildInfo.unknown}) : super(page, data: data, buildInfo: buildInfo);

  @override
  final String name = 'Background';

  @override
  final String id = 'background';

  bool isResizable = false;
  bool isBackgroundWidget = true;
  bool isDraggable = false;

  @override
  bool allowClipboard = false;

  Color color = Colors.white;

  CreativeGradient? gradient;

  BackgroundType type = BackgroundType.color;

  CreativeImageProvider? imageProvider;

  @override
  Size get size => page.project.size.size;

  EdgeInsets padding = EdgeInsets.symmetric(horizontal: 20, vertical: 20);
  
  @override
  List<EditorTab> get tabs => [
    EditorTab(
      name: 'Page',
      options: [
        Option.custom(
          widget: (context) => ButtonWithIcon(
            onTap: (context) async {
              await showAddWidgetModal(context, page);
            },
            icon: RenderIcons.add,
            title: 'Add Widget',
            tooltip: 'Add a widget to the canvas',
            backgroundColor: Palette.of(context).onSurfaceVariant,
            foregroundColor: Palette.of(context).surfaceContainerLow,
            showBorder: false,
            animateBorderRadius: false
          ),
        ),
        Option.button(
          icon: RenderIcons.palette,
          title: 'Palette',
          tooltip: 'Tap to shuffle palette',
          onTap: (context) async {
            bool hasChanged = false;
            page.editorManager.openModal(
              tab: (context, setState) => EditorTab.palette(
                page: page,
                onSelected: (palette) {
                  page.updatePalette(palette);
                  hasChanged = true;
                  updateListeners(WidgetChange.misc);
                },
              ),
              padding: EdgeInsets.only(
                left: 6,
                right: 6,
                top: 6,
                bottom: Constants.of(context).bottomPadding
              ),
              onDismiss: () {
                if (hasChanged) updateListeners(WidgetChange.update, historyMessage: 'Change Palette');
              }
            );
          },
        ),
        if (imageProvider == null && asset == null) Option.button(
          icon: RenderIcons.image,
          title: 'Add Image',
          tooltip: 'Tap to add an image to the background',
          onTap: (context) async {
            if (page.project.isTemplateKit) {
              isVariableWidget = true;
              Alerts.snackbar(context, text: 'You have added an image to the background. The asset will be treated as a variable. You can change this in the "Variable" button.');
            }
            File? file = await FilePicker.imagePicker(context, crop: true, cropRatio: page.project.size.cropRatio);
            if (file == null) return;
            if (asset == null) {
              asset = AssetX.create(file: file, project: page.project);
              imageProvider = CreativeImageProvider.create(this);
            } else {
              asset!.logVersion(version: page.history.nextVersion ?? '', file: file);
            }
            changeBackgroundType(BackgroundType.image);
            updateListeners(WidgetChange.update);
          },
        ),
        if (page.project.isTemplateKit && page.project.pages.length > 1) ... [
          Option.button(
            title: 'Type',
            tooltip: 'Label the page type',
            onTap: (context) async {
              page.editorManager.openModal(
                tab: (context, setState) => EditorTab.pickerBuilder(
                  title: 'Page Type',
                  childCount: PageType.values.length,
                  initialIndex: page.pageType != null ? PageType.values.indexOf(page.pageType!) : 0,
                  itemBuilder: (context, index) {
                    return Text(
                      PageType.values[index].title,
                    );
                  },
                  onSelectedItemChanged: (index) {
                    page.pageType = PageType.values[index];
                  },
                ),
                onDismiss: () {
                  updateListeners(WidgetChange.update, historyMessage: 'Change Page Type');
                }
              );
            },
            icon: RenderIcons.arrow_down
          ),
          Option.button(
            title: 'Comment',
            tooltip: 'Add a comment to specify page type',
            onTap: (context) async {
              String? comment = await Alerts.requestText(
                context,
                confirmButtonText: variableComments != null ? 'Update' : 'Add',
                hintText: 'Add a comment to briefly describe the role of this page',
                initialValue: variableComments,
                title: 'Page Type Comment',
              );
              if (comment != null && comment.isEmpty) comment = null;
              if (page.pageTypeComment != comment) {
                page.pageTypeComment = comment;
                updateListeners(WidgetChange.update, historyMessage: 'Add Variable Comment');
              }
            },
            icon: RenderIcons.comment
          ),
        ],
        Option.color(
          this,
          palette: page.palette,
          allowClear: false,
          allowOpacity: false,
          onChange: (color) {
            if (color == null) return;
            this.color = color;
            gradient = null;
            if (type != BackgroundType.color) {
              changeBackgroundType(BackgroundType.color);
            }
            updateListeners(WidgetChange.misc);
          },
          onChangeEnd: (color) {
            if (color != null) this.color = color;
            if (type != BackgroundType.color) {
              changeBackgroundType(BackgroundType.color);
            }
            updateListeners(WidgetChange.update);
          },
        ),
        Option.button(
          title: 'Gradient',
          onTap: (context) async {
            bool startedWithoutGradient = gradient == null;
            gradient ??= CreativeGradient.fromColors(from: color.harmonizeWith(Colors.white), to: color.harmonizeWith(Colors.black));
            updateListeners(WidgetChange.misc);
            page.editorManager.openModal(
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
                widget: this,
                palette: page.palette,
                allowOpacity: false,
                onChange: (change) {
                  setState(() {});
                  updateListeners(change);
                },
              ),
              onDismiss: () {
                if (startedWithoutGradient && gradient == null) {
                  changeBackgroundType(BackgroundType.color);
                  updateListeners(WidgetChange.misc);
                } else {
                  updateListeners(WidgetChange.update);
                }
              },
            );
          },
          icon: RenderIcons.gradient
        ),
        if (asset != null && imageProvider != null && page.project.isTemplateKit) Option.button(
          icon: RenderIcons.variable,
          title: 'Variable',
          onTap: (context) async {
            page.editorManager.openModal(
              tab: (context, setState) => EditorTab.picker(
                title: 'Image Variablilty',
                children: [
                  Text('Dynamic'),
                  Text('Constant'),
                ],
                initialIndex: isVariableWidget ? 0 : 1,
                onSelectedItemChanged: (index) {
                  isVariableWidget = index == 0;
                },
              ),
              onDismiss: () {
                updateListeners(WidgetChange.update, historyMessage: 'Change Variable');
              },
            );
          },
          tooltip: 'Toggle variablility of background image',
        ),
        Option.button(
          icon: RenderIcons.resize,
          title: 'Resize',
          tooltip: 'Tap to resize the project',
          onTap: (context) {
            page.editorManager.openModal(
              tab: (context, setState) => EditorTab.projectResize(project: page.project),
            );
          },
        ),
        Option.button(
          title: 'Padding',
          onTap: (context) async {
            updateGrids(showGridLines: true, hideCenterGrids: true);
            page.editorManager.openModal(
              tab: (context, setState) => EditorTab.paddingEditor(
                padding: padding,
                maxVertical: page.project.contentSize.height/8,
                minVertical: 0,
                maxHorizontal: page.project.contentSize.width/8,
                minHorizontal: 0,
                onChange: (value) {
                  padding = value;
                  updateGrids(showGridLines: true, hideCenterGrids: true);
                  updateListeners(WidgetChange.misc);
                },
              ),
              onDismiss: () {
                updateGrids(showGridLines: false);
                updateListeners(WidgetChange.update);
              },
            );
          },
          icon: RenderIcons.padding,
          tooltip: 'Adjust Padding'
        ),
        if (page.project.pages.length > 1) Option.button(
          icon: RenderIcons.delete,
          title: 'Delete Page',
          tooltip: 'Tap to delete this page',
          onTap: (context) async {
            bool delete = await Alerts.showConfirmationDialog(
              context,
              title: 'Delete Page?',
              message: 'Are you sure you want to delete this page and all of it\'s content? This cannot be reverted.',
              isDestructive: true,
              confirmButtonText: 'Delete'
            );
            if (delete) {
              page.project.pages.delete();
              Alerts.snackbar(context, text: 'Deleted page');
            }
          },
        ),
      ],
    ),
    if (imageProvider != null && asset != null) imageProvider!.editor(
      asset!,
      onChange: (change, {historyMessage}) {
        updateListeners(change, historyMessage: historyMessage);
      },
      name: 'Image',
      options: [
        Option.button(
          icon: RenderIcons.image,
          title: 'Replace',
          tooltip: 'Tap to replace image',
          onTap: (context) async {
            File? file = await FilePicker.imagePicker(context, crop: true, cropRatio: page.project.size.cropRatio);
            if (file == null) return;
            asset!.logVersion(version: page.history.nextVersion ?? '', file: file);
            updateListeners(WidgetChange.update);
          },
        ),
        Option.button(
          icon: RenderIcons.delete,
          title: 'Delete',
          tooltip: 'Remove background image',
          onTap: (context) async {
            asset = null;
            imageProvider = null;
            isVariableWidget = false;
            changeBackgroundType(BackgroundType.color);
            updateListeners(WidgetChange.update);
          },
        ),
      ],
    )
  ];

  @override
  Widget build(BuildContext context, {
    bool isInteractive = true,
  }) => AlignPositioned(
    dx: position.dx,
    dy: position.dy,
    touch: Touch.inside,
    child: widget(context),
  );

  @override
  Widget widget(BuildContext context) {
    if (asset == null) type = BackgroundType.color;
    return GestureDetector(
      onTap: () => page.widgets.select(this),
      child: (asset != null && imageProvider != null) ? imageProvider!.build(
        asset!,
        size: size,
      ) : Container(
        decoration: BoxDecoration(
          color: type == BackgroundType.color ? color : Colors.transparent,
          gradient: gradient?.gradient
        ),
      ),
    );
  }

  @override
  void updateListeners(
    /// Type of change when notifying listeners
    /// Affects the history of the widget
    WidgetChange change, {
    /// Pass `true` to remove all grids
    bool removeGrids = false,
    String? historyMessage,
  }) {
    if (removeGrids) page.gridState.hideAll();
    if (change == WidgetChange.update) {
      notifyListeners(change);
      if (asset != null) asset!.logVersion(version: page.history.nextVersion ?? '', file: asset!.file);
      page.history.log(historyMessage);
    }
    stateCtrl.update(change);
  }

  @override
  void updateGrids({
    bool realtime = false,
    bool showGridLines = false,
    bool createGrids = true,
    bool snap = true,
    double? snapSensitivity,
    Offset? position,
    bool hideCenterGrids = false
  }) {
    page.gridState.grids.removeWhere((grid) => grid.widget == this);
    Color gridColor = Colors.pinkAccent;
    // if (type == BackgroundType.color) {
    //   gridColor = page.palette.onBackground;
    // } else {
    //   gridColor = Colors.white;
    // }
    // Color gridColor = Colors.deepPurple;
    List<Grid> grids = [
      Grid(
        position: Offset(
          - page.project.contentSize.width/2 + padding.left,
          0
        ),
        color: gridColor,
        layout: GridLayout.vertical,
        gridWidgetPlacement: GridWidgetPlacement.left,
        widget: this,
        page: page,
        dotted: false
      ),
      Grid(
        position: Offset(
          page.project.contentSize.width/2 - padding.right,
          0
        ),
        color: gridColor,
        layout: GridLayout.vertical,
        gridWidgetPlacement: GridWidgetPlacement.right,
        widget: this,
        page: page,
        dotted: false
      ),
      Grid(
        position: Offset(
          0,
          page.project.contentSize.height/2 - padding.bottom,
        ),
        color: gridColor,
        layout: GridLayout.horizontal,
        gridWidgetPlacement: GridWidgetPlacement.bottom,
        widget: this,
        page: page,
        dotted: false
      ),
      Grid(
        position: Offset(
          0,
          - page.project.contentSize.height/2 + padding.top,
        ),
        color: gridColor,
        layout: GridLayout.horizontal,
        gridWidgetPlacement: GridWidgetPlacement.top,
        widget: this,
        page: page,
        dotted: false
      ),
      if (!hideCenterGrids) Grid(
        position: const Offset(0, 0),
        color: gridColor,
        layout: GridLayout.vertical,
        widget: this,
        page: page,
        gridWidgetPlacement: GridWidgetPlacement.centerVertical,
        dotted: false
      ),
      if (!hideCenterGrids) Grid(
        position: const Offset(0, 0),
        color: gridColor,
        layout: GridLayout.horizontal,
        widget: this,
        page: page,
        gridWidgetPlacement: GridWidgetPlacement.centerHorizontal,
        dotted: false
      )
    ];
    grids.forEach((element) {
      element.isVisible = showGridLines;
    });
    page.gridState.grids.addAll(grids);
    page.gridState.notifyListeners();
  }

  void changeBackgroundType(BackgroundType _type) {
    switch (_type) {
      case BackgroundType.color:
        asset = null;
        imageProvider = null;
        isVariableWidget = false;
        break;
      case BackgroundType.image:
        gradient = null;
        isVariableWidget = page.project.isTemplateKit;
        break;
    }
    type = _type;
    updateListeners(WidgetChange.misc);
  }

  void onPaletteUpdate() {
    color = page.palette.background;
    updateListeners(WidgetChange.misc);
  }

  @override
  List<String>? getFeatures() {
    if (isVariableWidget) return ['image'];
    return null;
  }

  @override
  void loadVariables(Map<String, dynamic> variable) {
    super.loadVariables(variable);
    String? url = variable['url'];
    if (url != null) {
      this.asset = AssetX.create(
        project: page.project,
        url: url,
        fileType: FileType.image
      );
      this.imageProvider ??= CreativeImageProvider.create(this);
      this.type = BackgroundType.image;
    }
  }

  @override
  Map<String, dynamic> getVariables() {
    List<String> availableSizes = ['1024x1024', '1024x1792', '1792x1024'];
    Size size = page.project.size.size;
    String sizeString = '${size.width.toInt()}x${size.height.toInt()}';
    if (!availableSizes.contains(sizeString)) {
      sizeString = '1024x1024';
    }
    return {
      ... super.getVariables(),
      'type': 'asset',
      'asset-type': 'image',
      'size': sizeString,
    };
  }

  @override
  Map<String, dynamic> toJSON({
    BuildInfo buildInfo = BuildInfo.unknown
  }) {
    if (asset != null && type != BackgroundType.image && buildInfo.buildType == BuildType.save) {
      asset = null;
      imageProvider = null;
      isVariableWidget = false;
    }
    EdgeInsets _padding = padding;
    if (buildInfo.buildType == BuildType.save) {
      _padding = page.project.sizeTranslator.getUniversalPadding(padding: _padding);
    }
    return {
      ... super.toJSON(buildInfo: buildInfo),
      'color': color.toHex(),
      'gradient': gradient?.toJSON(),
      'padding': _padding.toJSON(),
      'image-provider': imageProvider?.toJSON(),
    };
  }

  @override
  void buildFromJSON(Map<String, dynamic> json, {
    required BuildInfo buildInfo
  }) {
    super.buildFromJSON(json, buildInfo: buildInfo);
    bool isBuildingFromUniversalBuild = json['properties']['is-universal-build'] ?? false;
    try {
      color = HexColor.fromHex(json['color']);
      if (asset != null) {
        type = BackgroundType.image;
      }
      if (json['gradient'] != null) try {
        gradient = CreativeGradient.fromJSON(Map.from(json['gradient']));
      } catch (e) { }
      if (json['padding'] != null) {
        padding = PaddingExtension.fromJSON(Map.from(json['padding']));
        if (isBuildingFromUniversalBuild) {
          padding = page.project.sizeTranslator.getLocalPadding(padding: padding);
        }
      }
      if (json['image-provider'] != null) {
        imageProvider = CreativeImageProvider.fromJSON(Map.from(json['image-provider']), widget: this);
      }
    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'Error building background', stacktrace: stacktrace);
      throw WidgetCreationException(
        'Failed to create background widget',
        details: 'Error: $e'
      );
    }
  }

}

enum BackgroundType {
  color,
  image
}