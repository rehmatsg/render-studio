import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:align_positioned/align_positioned.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:render_studio/creator/state.dart';
import 'package:supercharged/supercharged.dart';
import '../../rehmat.dart';
import 'dart:math' as math;

abstract class CreatorWidget extends PropertyChangeNotifier<WidgetChange> {

  @override
  bool operator == (Object other) {
    if (other is CreatorWidget && other.uid == uid) return true;
    return false;
  }

  @override
  int get hashCode => super.hashCode;

  CreatorWidget(this.page, {
    Map? data,
    BuildInfo buildInfo = BuildInfo.unknown,
  }) {
    uid = generateUID(prefix: id);
    stateCtrl = RenderWidgetStateController(this);
    onInitialize();
    onPaletteUpdate();
    if (data != null) try {
      uid = data['uid'];
      buildFromJSON(Map.from(data), buildInfo: buildInfo);
      updateGrids();
      stateCtrl.update();
    } on WidgetCreationException catch (e, stacktrace) {
      analytics.logError(e, cause: 'could not build widget from JSON', stacktrace: stacktrace);
      throw WidgetCreationException(
        'The widget could not be rebuilt due to some issues',
        details: 'Failed to build widget from JSON: $e',
      );
    }
  }

  static String generateUID({
    String prefix = 'widget#'
  }) => '$prefix${Constants.generateID(6)}';

  late RenderWidgetStateController stateCtrl;

  late String uid;

  final CreatorPage page;

  TabController? editorTabCtrl;

  AssetX? asset;

  String? variableComments;

  /// Tabs with editing options
  List<EditorTab> get tabs => [ ];

  List<Option> get defaultOptions => [
    if (isVariableWidget && page.project.isTemplateKit) Option.button(
      title: 'Comment',
      tooltip: 'Add a comment to the text variable',
      onTap: (context) async {
        String? comment = await Alerts.requestText(
          context,
          confirmButtonText: variableComments != null ? 'Update' : 'Add',
          hintText: 'Add a comment to briefly specify the role of this widget',
          initialValue: variableComments,
          title: 'Variable Comment',
        );
        if (comment != null && comment.isEmpty) comment = null;
        if (variableComments != comment) {
          variableComments = comment;
          updateListeners(WidgetChange.update, historyMessage: 'Add Variable Comment');
        }
      },
      icon: RenderIcons.comment
    ),
    if (group != null) Option.button(
      icon: RenderIcons.ungroup,
      title: 'Ungroup',
      tooltip: 'Remove this widget from the group',
      onTap: (context) {
        group!.ungroup(this);
      },
    ),
    if (group != null) Option.button(
      icon: RenderIcons.deleteGroup,
      title: 'Ungroup All',
      tooltip: 'Tap to ungroup all the widgets',
      onTap: (context) {
        group!.delete(this);
      },
    ),
    if (allowClipboard) Option.button(
      icon: RenderIcons.duplicate,
      title: group != null ? 'Duplicate Group' : 'Duplicate',
      tooltip: group != null ? 'Duplicate the group' : 'Duplicate the widget',
      onTap: (context) {
        Spinner.fullscreen(
          context,
          task: () async {
            CreatorWidget? duplicateW = await duplicate();
            if (duplicateW != null) page.widgets.add(duplicateW);
          },
        );
      },
    ),
    Option.toggle(
      disabledIcon: RenderIcons.unlock,
      enabledIcon: RenderIcons.lock,
      title: isLocked ? 'Unlock' : 'Lock',
      enabledTooltip: 'Unlock Widget',
      disabledTooltip: 'Lock Widget',
      value: isLocked,
      onChange: (value) {
        group != null ? group!.lock(this) : lock();
      },
    ),
    Option.button(
      icon: RenderIcons.delete,
      title: 'Delete',
      tooltip: 'Delete Text Widget',
      onTap: (context) async {
        delete();
      },
    ),
  ];

  /// Name of the widget
  final String name = 'Widget';

  /// ID of the widget
  /// Must be in lowercase letters
  final String id = 'widget';

  // ignore: unused_field
  late final Color _identificationColor;

  final bool allowClipboard = true;

  bool _locked = false;

  bool get isLocked => _locked;

  void lock() {
    _locked = true;
    if (group != null) {
      group!.findGroup(this).lock();
    } else {
      updateListeners(WidgetChange.lock);
    }
  }

  void unlock() {
    _locked = false;
    if (group != null) {
      group!.findGroup(this).unlock();
    } else {
      updateListeners(WidgetChange.lock);
    }
  }

  bool _firstBuildDone = false;
  void doFirstBuild() {
    // First build function is run once the rendering is over
    // Only once for the widget lifecycle
    _firstBuildDone = true;
    onFirstBuild();
  }

  void onFirstBuild() {}

  void onInitialize() {
    _identificationColor = [
      Colors.pink,
      Colors.amber,
      Colors.cyan,
      Colors.green,
      Colors.teal
    ].getRandom();
  }

  /// ### Rotate


  /// Rotation angle of the widget
  double angle = 0;


  /// ### Resize
  
  List<ResizeHandler> resizeHandlers = [
    ResizeHandler.topLeft,
    ResizeHandler.topRight,
    ResizeHandler.bottomLeft,
    ResizeHandler.bottomRight,
  ];

  bool isResizing = false;
  ResizeHandler? _currentResizingHandler;

  Size size = const Size(0, 0);
  Size? minSize;

  bool showWidgetHandlers = true;

  void setHandlersVisibility(bool value) {
    showWidgetHandlers = value;
    updateListeners(WidgetChange.misc);
  }

  /// Setting this to `true` will allow
  /// resizing but only in the fixed aspect ratio
  bool keepAspectRatio = false;

  /// Set to `false` if you want the widget
  /// to not be resizable.
  /// Defaults to `true`
  final bool isResizable = true;

  /// Set to `true` for widgets like background
  /// to make sure that effects like border are not applied
  final bool isBackgroundWidget = false;

  /// Set to `true` for widgets like text and image that accept variables from AI generated content
  bool isVariableWidget = false;

  VerticalExpandDirection verticalExpandDirection = VerticalExpandDirection.both;
  HorizontalExpandDirection horizontalExpandDirection = HorizontalExpandDirection.both;

  final bool autoChangeVerticalExpandDirection = true;
  final bool autoChangeHorizontalExpandDirection = true;

  bool allowResize(Size _size) {
    if (isLocked) return false;
    if (_size.width < (minSize?.width ?? 10)) return false;
    if (_size.height < (minSize?.height ?? 10)) return false;
    if (_size.width > page.project.deviceSize.width * 2) return false;
    if (_size.height > page.project.deviceSize.height * 2) return false;
    return true;
  }

  void onResizeStart({
    DragStartDetails? details,
    ResizeHandler? handler
  }) {
    isResizing = true;
    _currentResizingHandler = handler;
    // _resizeHandlers = [handler];
  }

  void onResize(Size size, {ResizeHandler? type, bool isScaling = false}) {
    position = autoPosition(position: position, newSize: size, prevSize: this.size, alignment: type?.autoPositionAlignment ?? Alignment.center);
    this.size = size;
    updateListeners(WidgetChange.resize);
  }

  /// This method is called when the resizing of the widget is finished
  void onResizeFinished({
    DragEndDetails? details,
    ResizeHandler? handler,
    bool updateNotify = true
  }) {
    isResizing = false;
    _currentResizingHandler = null;
    updateListeners(WidgetChange.update, historyMessage: 'Resize');
  }

  /// Use this method to resize the widget using scale factor
  /// 
  /// For example, to resize the widget by 10%,
  /// use `scale(1.1)`
  bool scale(double scale) {
    Size _size = Size(size.width * scale, size.height * scale);
    if (allowResize(_size)) {
      size = _size;
      return true;
    } else return false;
  }

  List<ResizeHandler> _getResizeHandlersWRTSize() {
    List<ResizeHandler> __handlers = [];
    if (size.height.isBetween(0, 50)) {
      __handlers = [
        ResizeHandler.bottomRight,
        if (resizeHandlers.contains(ResizeHandler.centerLeft) && size.height > 20) ResizeHandler.centerLeft,
      ];
    } else {
      __handlers = List.from(resizeHandlers);
    }
    return __handlers;
  }


  /// ### Drag

  Offset position = const Offset(0, 0);
  Offset _previousPosition = const Offset(0, 0);

  Rect get area {
    if (group != null) {
      Offset center = group!.findGroup(this).position + position;
      return Rect.fromCenter(
        center: center,
        width: size.width,
        height: size.height,
      );
    } else {
      return Rect.fromCenter(
        center: position,
        width: size.width,
        height: size.height,
      );
    }
  }

  /// Set to `false` if you want the widget
  /// to not be draggable.
  /// 
  /// Defaults to `true`
  final bool isDraggable = true;

  bool isDragging = false;

  List<WidgetAlignment> get alignment => WidgetAlignmentExtension.fromPosition(this);

  void alignPositioned(WidgetAlignment alignment) {
    if (this.alignment.contains(alignment)) return;
    _previousPosition = position;
    position = alignment.getPosition(this);
    updateListeners(WidgetChange.update);
  }

  void updatePosition(DragUpdateDetails details) {
    if (!isDraggable) return;
    _previousPosition = position;
    position = position + details.delta;
    bool isDraggingFast = !details.delta.dx.isBetween(-preferences.snapSensitivity, preferences.snapSensitivity) || !details.delta.dy.isBetween(-preferences.snapSensitivity, preferences.snapSensitivity);
    if (angle == 0) updateGrids(realtime: true, showGridLines: true, snap: !isDraggingFast);
    updateListeners(WidgetChange.drag);
  }

  void updatePositionWithOffset(Offset offset) {
    if (!isDraggable) return;
    _previousPosition = position;
    position += offset;
    if (angle == 0) updateGrids(realtime: true, showGridLines: true, snap: true);
    updateListeners(WidgetChange.drag);
  }

  void onDragStart([DragStartDetails? details]) {
    isDragging = true;
    updateListeners(WidgetChange.misc);
  }

  void onDragFinish(BuildContext context) {
    // Update the listener to `update` changes. This will tell the parent to reload state and save the change in history
    double dx = position.dx;
    double dy = position.dy;
    double minDX = -(page.project.contentSize.width/2) - size.width/4;
    double minDY = -(page.project.contentSize.height/2) - size.height/4;
    double maxDX = page.project.contentSize.width/2 + size.width/4;
    double maxDY = page.project.contentSize.height/2 + size.height/4;
    if (dx < minDX) dx = minDX;
    if (dy < minDY) dy = minDY;
    if (dx > maxDX) dx = maxDX;
    if (dy > maxDY) dy = maxDY;
    // Prevent the widget from going out of the safe area
    position = Offset(dx, dy);
    isDragging = false;
    updateGrids(showGridLines: true, snap: true);
    updateListeners(WidgetChange.update, removeGrids: true, historyMessage: 'Move');
  }

  void onDoubleTap(BuildContext context) {}

  Group? group;

  /// Finds the group of the widget if it is a part of a group, else returns the widget itself
  /// 
  /// Use cases:
  /// - When building adjust editor tabs for the widget.
  /// You would not want to nudge the widget within the group, so returns the parent group to nudge
  CreatorWidget get widgetOrGroup {
    try {
      if (group != null) return group!.findGroup(this);
    } catch (e, stacktrace) {
      analytics.logError(e, stacktrace: stacktrace, cause: 'error finding group of widget');
    }
    return this;
  }

  bool isSelected() => page.widgets.isSelected(widget: this);

  bool isOnlySelected() => page.widgets.isSelected(widget: this) && page.widgets.selections.length == 1 && group == null;

  /// ###

  double opacity = 1.0;

  /// ###

  /// Build function of the widget
  /// All of the resizing, drag, tap and double tap related code is written here
  /// @override this method to disable drag, resizing, tapping and others
  Widget build(BuildContext context) {
    if (!_firstBuildDone) doFirstBuild();
    return AlignPositioned(
      key: ValueKey<String>(uid),
      dx: position.dx,
      dy: position.dy,
      childHeight: size.height,
      childWidth: size.width,
      child: rotatedWidget(
        child: _CustomGestureDetector(
          uid: uid,
          onDoubleTap: (this is WidgetGroup || isLocked) ? null : () => onDoubleTap(context),
          onTap: (this is WidgetGroup) ? null : () {
            if (!isSelected() || (isSelected() && page.widgets.multiselect)) page.widgets.select(this);
          },
          child: SizedBox.fromSize(
            size: size,
            child: widget(context)
          )
        ),
      ),
    );
  }

  Widget rotatedWidget({required Widget child}) => Transform.rotate(
    angle: angle * math.pi / 180,
    child: child
  );

  /// This is the main widget of the widget
  Widget widget(BuildContext context) {
    return Container();
  }

  void updateListeners(
    /// Type of change when notifying listeners
    /// Affects the history of the widget
    WidgetChange change, {
    /// Pass `true` to remove all grids
    bool removeGrids = false,
    String? historyMessage,
  }) {
    if (change == WidgetChange.update) updateGrids();
    if (removeGrids) page.gridState.hideAll();
    notifyListeners(change);
    stateCtrl.update(change);
    if (change == WidgetChange.update && asset != null) {
      asset!.logVersion(version: page.history.nextVersion ?? '', file: asset!.file);
    }
    if (change == WidgetChange.update) {
      page.history.log(historyMessage);
    }
  }

  /// Update all the grids present in the page for the current widget
  void updateGrids({
    /// Set the `realtime` to `true` if this method is being called in realtime.
    /// Example use: When the widget is being dragged
    bool realtime = false,
    /// Settings this to `false` will not snap the widgets and not show the grid lines
    bool showGridLines = false,
    /// Settings this to false will only match the widget to the grid, but not create new ones
    bool createGrids = true,
    /// Snap the widget to the grid
    /// 
    /// Both `this.snap` and `preferences.snap` are required to be true for the widget to snap
    bool snap = true,
    double? snapSensitivity,
    Offset? position
  }) {

    position ??= this.position;
    snapSensitivity ??= preferences.snapSensitivity;
    snap = snap && preferences.snap;

    double dx = position.dx;
    double dy = position.dy;

    double x0 = position.dx - size.width/2;
    double x = position.dx;
    double x1 = position.dx + size.width/2;

    double px0 = _previousPosition.dx - size.width/2;
    double px = _previousPosition.dx;
    double px1 = _previousPosition.dx + size.width/2;

    double y0 = position.dy - size.height/2;
    double y = position.dy;
    double y1 = position.dy + size.height/2;

    double py0 = _previousPosition.dy - size.height/2;
    double py = _previousPosition.dy;
    double py1 = _previousPosition.dy + size.height/2;

    bool isInSnapSensitiveArea(double x, double px, Grid grid) {
      double target = grid.position.dx;
      if (grid.layout == GridLayout.horizontal) target = grid.position.dy;
      double sensitivity = snapSensitivity!;

      double d = (x - target).abs();
      double pd = (px - target).abs();
      bool isMovingAway = d > pd;

      if (isMovingAway && realtime) sensitivity = sensitivity / 3;

      return x >= target - sensitivity && x <= target + sensitivity;
    }

    bool isWithinReachableDistance(Grid grid) {
      if (grid.widget == null || grid.length == null) return true;
      if (grid.layout == GridLayout.horizontal) return true;
      double md = grid.length! / 2;
      double d = (grid.position.dy - dy).abs();
      return d <= md;
    }

    if (showGridLines) {
      int nSnapGrids = 0;
      GridLayout? snappedGridLayout;
      for (Grid grid in page.gridState.grids) {
        bool hasSnapped = false;
        List<Grid> snappedGrids = [];
        
        if (grid.widget == this) continue;
        else if (snappedGridLayout == grid.layout) continue;
        else if (nSnapGrids >= 2) continue;
        else if (this is WidgetGroup && (this as WidgetGroup).widgets.contains(grid.widget)) continue;

        if (grid.layout.isVertical) {
          if (isInSnapSensitiveArea(x0, px0, grid) && isWithinReachableDistance(grid) && grid.gridWidgetPlacement != GridWidgetPlacement.centerVertical) {
            dx = grid.position.dx + size.width/2;
            hasSnapped = true;
            snappedGrids.add(grid);
          } else if (isInSnapSensitiveArea(x, px, grid) && isWithinReachableDistance(grid) && grid.gridWidgetPlacement == GridWidgetPlacement.centerVertical) {
            dx = grid.position.dx;
            hasSnapped = true;
            snappedGrids.add(grid);
          } else if (isInSnapSensitiveArea(x1, px1, grid) && isWithinReachableDistance(grid) && grid.gridWidgetPlacement != GridWidgetPlacement.centerVertical) {
            dx = grid.position.dx - size.width/2;
            hasSnapped = true;
            snappedGrids.add(grid);
          }
        } else if (grid.layout.isHorizontal) {
          if (isInSnapSensitiveArea(y0, py0, grid) && grid.gridWidgetPlacement != GridWidgetPlacement.centerHorizontal) {
            dy = grid.position.dy + size.height/2;
            hasSnapped = true;
            snappedGrids.add(grid);
          } else if (isInSnapSensitiveArea(y, py, grid) && grid.gridWidgetPlacement == GridWidgetPlacement.centerHorizontal) {
            dy = grid.position.dy;
            hasSnapped = true;
            snappedGrids.add(grid);
          } else if (isInSnapSensitiveArea(y1, py1, grid) && grid.gridWidgetPlacement != GridWidgetPlacement.centerHorizontal) {
            dy = grid.position.dy - size.height/2;
            hasSnapped = true;
            snappedGrids.add(grid);
          }
        }
        
        // Create a haptic feedback when the widget snaps to the grid
        // Other conditions in the if statement prevent the feedback from being created multiple times
        if (hasSnapped && !grid.isVisible && preferences.vibrateOnSnap && snap) TapFeedback.light();

        if (hasSnapped) {
          grid.isVisible = true;
          snappedGridLayout = grid.layout;

          for (Grid grid in snappedGrids) {
            if (grid.layout.isHorizontal && autoChangeVerticalExpandDirection) {
              if (grid.gridWidgetPlacement == GridWidgetPlacement.top) verticalExpandDirection = VerticalExpandDirection.down;
              else if (grid.gridWidgetPlacement == GridWidgetPlacement.bottom) verticalExpandDirection = VerticalExpandDirection.up;
              else verticalExpandDirection = VerticalExpandDirection.both;
            } else if (grid.layout.isVertical && autoChangeHorizontalExpandDirection) {
              if (grid.gridWidgetPlacement == GridWidgetPlacement.left) horizontalExpandDirection = HorizontalExpandDirection.right;
              else if (grid.gridWidgetPlacement == GridWidgetPlacement.right) horizontalExpandDirection = HorizontalExpandDirection.left;
              else horizontalExpandDirection = HorizontalExpandDirection.both;
            }
          }
        } else {
          grid.isVisible = false;
          if (autoChangeVerticalExpandDirection) verticalExpandDirection = VerticalExpandDirection.both;
          else if (autoChangeHorizontalExpandDirection) horizontalExpandDirection = HorizontalExpandDirection.both;
        }

        if (hasSnapped) nSnapGrids++;
      }
      if (snap) {
        _previousPosition = this.position;
        this.position = Offset(dx, dy);
      }
      page.gridState.notifyListeners();
    }

    List<Grid> newGrids = [];

    Grid _createGrid({
      required Offset position,
      required GridLayout layout,
      required GridWidgetPlacement gridWidgetPlacement,
    }) => Grid(
      position: position,
      color: page.palette.onBackground,
      // color: _identificationColor,
      layout: layout,
      gridWidgetPlacement: gridWidgetPlacement,
      page: page,
      widget: this,
      dotted: true,
      length: layout == GridLayout.horizontal ? null : (size.height < page.project.contentSize.height/3 ? size.height * 3 : page.project.contentSize.height/2),
    );

    bool hasSmallHeight = size.height < 20;
    bool hasSmallWidth = size.width < 40;

    if (createGrids && !realtime) {
      newGrids.addAll([
        if (page.gridState.grids.indexWhere((grid) => grid.position.dx.isBetween(x0 - snapSensitivity!, x0 + snapSensitivity)) < 0 && !hasSmallWidth) _createGrid(
          position: Offset(x0, y),
          layout: GridLayout.vertical,
          gridWidgetPlacement: GridWidgetPlacement.left
        ),
        if (page.gridState.grids.indexWhere((grid) => grid.position.dx.isBetween(x - snapSensitivity!, x + snapSensitivity)) < 0) _createGrid(
          position: Offset(x, y),
          layout: GridLayout.vertical,
          gridWidgetPlacement: GridWidgetPlacement.centerVertical
        ),
        if (page.gridState.grids.indexWhere((grid) => grid.position.dx.isBetween(x1 - snapSensitivity!, x1 + snapSensitivity)) < 0 && !hasSmallWidth) _createGrid(
          position: Offset(x1, y),
          layout: GridLayout.vertical,
          gridWidgetPlacement: GridWidgetPlacement.right
        ),
        if (page.gridState.grids.indexWhere((grid) => grid.position.dy.isBetween(y0 - snapSensitivity!, y0 + snapSensitivity)) < 0 && !hasSmallHeight) _createGrid(
          position: Offset(0, y0),
          layout: GridLayout.horizontal,
          gridWidgetPlacement: GridWidgetPlacement.top
        ),
        if (page.gridState.grids.indexWhere((grid) => grid.position.dy.isBetween(y - snapSensitivity!, y + snapSensitivity)) < 0) _createGrid(
          position: Offset(0, y),
          layout: GridLayout.horizontal,
          gridWidgetPlacement: GridWidgetPlacement.centerHorizontal
        ),
        if (page.gridState.grids.indexWhere((grid) => grid.position.dy.isBetween(y1 - snapSensitivity!, y1 + snapSensitivity)) < 0 && !hasSmallHeight) _createGrid(
          position: Offset(0, y1),
          layout: GridLayout.horizontal,
          gridWidgetPlacement: GridWidgetPlacement.bottom
        ),
      ]);
      page.gridState.grids.removeWhere((element) => element.widget == this);
      page.gridState.grids.addAll(newGrids);
    }

    page.gridState.notifyListeners();

  }

  /// This method is called when the palette is updated for the parent page
  /// 
  /// Here, write the code to update colors used within the widget
  void onPaletteUpdate() { }

  void onProjectSizeChange(PostSize oldSize, PostSize newSize) {
    // Size oldActualSize = getActualSizeFromPostSize(oldSize, page.project.deviceSize);
    // Size newActualSize = getActualSizeFromPostSize(newSize, page.project.deviceSize);
    // 
    // double distanceFromPageLeft = oldActualSize.width/2 - (position.dx - size.width/2).abs();
    // double distanceFromPageRight = oldActualSize.width/2 - (position.dx + size.width/2).abs();
    // double distanceFromPageTop = oldActualSize.height/2 - (position.dy - size.height/2).abs();
    // double distanceFromPageBottom = oldActualSize.height/2 - (position.dy + size.height/2).abs();
    // double distanceFromPageCenter = position.distance.abs();
    // 
    // print('Widget: $name');
    // print('distanceFromPageLeft: $distanceFromPageLeft');
    // print('distanceFromPageRight: $distanceFromPageRight');
    // print('distanceFromPageTop: $distanceFromPageTop');
    // print('distanceFromPageBottom: $distanceFromPageBottom');
    // print('distanceFromPageCenter: $distanceFromPageCenter');
  }

  /// This method is called when the widget is deleted
  /// 
  /// It should be used to clean up any resources that the widget is using
  void onDelete() {
  }

  /// Called when the widget is disposed from the tree
  /// Use this function to dispose of any resources that the widget is using
  /// 
  /// Usage:
  /// 
  /// ```dart
  /// @override
  /// void dispose() {
  ///  super.dispose();
  ///   // Dispose of any resources here
  ///   controller.dispose();
  /// }
  /// ```
  void dispose() {
    super.dispose();
  }

  /// Duplicate Widget
  /// 
  /// Returns the widget with same properties but new uid and altered position
  Future<CreatorWidget?> duplicate() async {
    if (group != null) {
      return group!.findGroup(this).duplicate();
    }
    CreatorWidget widget = CreatorWidget.fromJSON(toJSON(), page: page, buildInfo: BuildInfo(buildType: BuildType.unknown));
    widget.uid = CreatorWidget.generateUID();
    widget.position = Offset(position.dx + 10, position.dy + 10);
    await widget.onDuplicate();
    widget._locked = false;
    return widget;
  }

  /// This method is called when a widget is duplicated from another
  /// Handle asset duplication here
  Future<void> onDuplicate() async {}

  void delete() {
    if (group != null) group!.deleteWidget(this);
    else page.widgets.delete(this.uid);
  }

  Map<String, dynamic> getVariables() => isVariableWidget ? {
    'uid': uid,
    'widget': id,
    'comments': variableComments
  } : {};

  void loadVariables(Map<String, dynamic> variable) {
    if (!isVariableWidget) return;
  }

  List<String>? getFeatures() => null;

  /// Convert the state and properties of the widget to JSON
  Map<String, dynamic> toJSON({
    BuildInfo buildInfo = BuildInfo.unknown
  }) {
    if (buildInfo.version != null && asset != null) {
      asset!.logVersion(version: buildInfo.version!, file: asset!.file);
    }
    Offset position = this.position;
    Size size = this.size;
    bool isUniversal = buildInfo.buildType == BuildType.save;
    if (buildInfo.buildType == BuildType.save) {
      position = page.project.sizeTranslator.getUniversalPosition(widget: this);
      size = page.project.sizeTranslator.getUniversalSize(widget: this);
    }
    return {
      'id': id,
      'uid': uid,
      'name': name,
      'asset': asset?.id,
      'group': group?.id,
      'properties': {
        'is-universal-build': isUniversal,
        'position': {
          'dx': position.dx,
          'dy': position.dy
        },
        'angle': angle,
        'opacity': opacity,
        'size': {
          'width': size.width,
          'height': size.height
        },
        'vertical-expand-direction': verticalExpandDirection.name,
        'horizontal-expand-direction': horizontalExpandDirection.name,
      },
      'variable-comment': variableComments,
      'is-variable-widget': isVariableWidget
    };
  }

  /// Create the widget from JSON
  /// 
  /// This method automatically detects the type of widget and returns the appropriate widget
  static CreatorWidget fromJSON(dynamic data, {
    required CreatorPage page,
    BuildInfo buildInfo = BuildInfo.unknown
  }) {
    data = Map.from(data);
    CreatorWidget? widget;
    switch (data['id']) {
      case 'background':
        widget = BackgroundWidget(page: page, data: data, buildInfo: buildInfo);
        break;
      case 'text':
        widget = CreatorText(page: page, data: data, buildInfo: buildInfo);
        break;
      case 'design_asset':
        widget = CreatorDesignAsset(page: page, data: data, buildInfo: buildInfo);
        break;
      case 'qr_code':
        widget = QRWidget(page: page, data: data, buildInfo: buildInfo);
        break;
      case 'image':
        widget = ImageWidget(page: page, data: data, buildInfo: buildInfo);
        break;
      case 'box':
        widget = CreatorBoxWidget(page: page, data: data, buildInfo: buildInfo);
        break;
      case 'shape':
        widget = ShapeWidget(page: page, data: data, buildInfo: buildInfo);
        break;
      case 'group':
        widget = WidgetGroup(page: page, data: data, buildInfo: buildInfo);
        break;
      case 'progress':
        widget = CreativeProgressWidget(page: page, data: data, buildInfo: buildInfo);
        break;
      case 'pie-chart':
        widget = CreativePieChart(page: page, data: data, buildInfo: buildInfo);
        break;
      case 'blob':
        widget = CreativeBlob(page: page, data: data, buildInfo: buildInfo);
        break;
      case 'watermark':
        widget = RenderStudioWatermark(page: page, data: data, buildInfo: buildInfo);
        break;
      default:
        throw WidgetCreationException('Failed to build widget ${data['name']}');
    }
    return widget;
  }

  /// Create new widget by ID
  static Future<void> create(BuildContext context, {
    required CreatorPage page,
    /// ID of the widget to create
    required String id
  }) async {
    switch (id) {
      case 'text':
        CreatorText.create(context, page: page);
        break;
      case 'design_asset':
        CreatorDesignAsset.create(context, page: page);
        break;
      case 'qr_code':
        QRWidget.create(context, page: page);
        break;
      case 'image':
        ImageWidget.create(context, page: page);
        break;
      case 'box':
        CreatorBoxWidget.create(context, page: page);
        break;
      case 'shape':
        ShapeWidget.create(context, page: page);
        break;
      case 'progress':
        CreativeProgressWidget.create(context, page: page);
        break;
      case 'pie-chart':
        CreativePieChart.create(context, page: page);
        break;
      case 'blob':
        CreativeBlob.create(context, page: page);
        break;
      case 'watermark':
        RenderStudioWatermark.create(page: page);
        break;
      default:
        break;
    }
  }

  void buildFromJSON(Map<String, dynamic> data, {
    required BuildInfo buildInfo
  }) {
    bool isBuildingFromUniversalBuild = data['properties']['is-universal-build'] ?? false;

    position = Offset(data['properties']['position']['dx'], data['properties']['position']['dy']);
    if (isBuildingFromUniversalBuild) position = page.project.sizeTranslator.getLocalPosition(widget: this);

    angle = data['properties']['angle'];

    opacity = data['properties']['opacity'];

    size = Size(data['properties']['size']['width'], data['properties']['size']['height']);
    if (isBuildingFromUniversalBuild) size = page.project.sizeTranslator.getLocalSize(widget: this);

    if (data['group'] != null) group = Group(data['group']);

    if (data['asset'] != null) asset = page.project.assetManager.get(data['asset']);

    if (asset?.history.isEmpty ?? false) {
      asset!.history[page.history.dates.first.version ?? ''] = AssetHistory(
        version: page.history.dates.first.version ?? '',
        type: asset!.assetType,
        file: asset!.file,
        url: asset!.url,
      );
    }

    verticalExpandDirection = VerticalExpandDirectionExtension.fromString(data['properties']['vertical-expand-direction']);
    horizontalExpandDirection = HorizontalExpandDirectionExtension.fromString(data['properties']['horizontal-expand-direction']);

    if (data['variable-comment'] != null) variableComments = data['variable-comment'];

    if (data['is-variable-widget'] != null) isVariableWidget = data['is-variable-widget'];

    if (buildInfo.version != null && asset != null) asset!.restoreVersion(version: buildInfo.version!);
    
    updateListeners(WidgetChange.misc);
  }

  /// Generates new offset for the widget to be positioned with alignment after resize
  static Offset autoPosition({
    required Offset position,
    required Size newSize,
    required Size prevSize,
    Alignment? alignment,
    VerticalExpandDirection? verticalExpandDirection,
    HorizontalExpandDirection? horizontalExpandDirection
  }) {
    assert(alignment != null || (verticalExpandDirection != null && horizontalExpandDirection != null), 'Alignment or expand direction must be provided');

    double changeInHeight = newSize.height - prevSize.height;
    double changeInWidth = newSize.width - prevSize.width;

    double dx = position.dx;
    double dy = position.dy;

    if (alignment != null) {
      if (alignment == Alignment.topLeft) {
        verticalExpandDirection = VerticalExpandDirection.down;
        horizontalExpandDirection = HorizontalExpandDirection.right;
      } else if (alignment == Alignment.topCenter) {
        verticalExpandDirection = VerticalExpandDirection.down;
        horizontalExpandDirection = HorizontalExpandDirection.both;
      } else if (alignment == Alignment.topRight) {
        verticalExpandDirection = VerticalExpandDirection.down;
        horizontalExpandDirection = HorizontalExpandDirection.left;
      } else if (alignment == Alignment.centerLeft) {
        verticalExpandDirection = VerticalExpandDirection.both;
        horizontalExpandDirection = HorizontalExpandDirection.right;
      } else if (alignment == Alignment.center) {
        verticalExpandDirection = VerticalExpandDirection.both;
        horizontalExpandDirection = HorizontalExpandDirection.both;
      } else if (alignment == Alignment.centerRight) {
        verticalExpandDirection = VerticalExpandDirection.both;
        horizontalExpandDirection = HorizontalExpandDirection.left;
      } else if (alignment == Alignment.bottomLeft) {
        verticalExpandDirection = VerticalExpandDirection.up;
        horizontalExpandDirection = HorizontalExpandDirection.right;
      } else if (alignment == Alignment.bottomCenter) {
        verticalExpandDirection = VerticalExpandDirection.up;
        horizontalExpandDirection = HorizontalExpandDirection.both;
      } else if (alignment == Alignment.bottomRight) {
        verticalExpandDirection = VerticalExpandDirection.up;
        horizontalExpandDirection = HorizontalExpandDirection.left;
      }
    }

    if (verticalExpandDirection == VerticalExpandDirection.down) {
      dy += changeInHeight/2;
    } else if (verticalExpandDirection == VerticalExpandDirection.up) {
      dy -= changeInHeight/2;
    }

    if (horizontalExpandDirection == HorizontalExpandDirection.right) {
      dx += changeInWidth/2;
    } else if (horizontalExpandDirection == HorizontalExpandDirection.left) {
      dx -= changeInWidth/2;
    }

    return Offset(dx, dy);
  }

}


/// The type of widget change when the listener is notified
enum WidgetChange {
  drag,
  resize,
  rotate,
  update,
  misc,
  lock
}

/// The types of scale/resize options available to widget
enum ScaleType {
  /// Adding this option to scale types will enable increasing width only
  dx,
  /// Adding this option to scale types will enable increasing height only
  dy,
  /// Adding this option to scale types will enable a shared button to increase width and height
  dxy
}

class WidgetCreationException implements Exception {

  final String? code;
  final String message;
  final String? details;

  WidgetCreationException(this.message, {this.details, this.code});

}

class WidgetHandlerBuilder extends StatefulWidget {

  const WidgetHandlerBuilder({
    super.key,
    required this.widget,
    this.isInteractive = true
  });

  final CreatorWidget widget;
  final bool isInteractive;

  @override
  State<WidgetHandlerBuilder> createState() => _WidgetHandlerBuilderState();
}

class _WidgetHandlerBuilderState extends State<WidgetHandlerBuilder> {

  late CreatorWidget creatorWidget;

  @override
  void initState() {
    super.initState();
    creatorWidget = widget.widget;
    creatorWidget.addListener(onWidgetChange);
  }

  @override
  void dispose() {
    creatorWidget.removeListener(onWidgetChange);
    super.dispose();
  }

  late Size _tempSize;

  int _initPointerCount = 0;
  DateTime _lastGestureTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    if (creatorWidget != widget.widget) updateWidget();
    bool _isOnlySelected = widget.isInteractive && creatorWidget.isOnlySelected();
    bool _allowDrag = widget.isInteractive && creatorWidget.isDraggable && creatorWidget.group == null && _isOnlySelected && !creatorWidget.isLocked;
    return AnimatedOpacity(
      duration: kAnimationDuration,
      curve: Curves.easeInOut,
      opacity: creatorWidget.showWidgetHandlers ? 1 : 0,
      child: GestureDetector(
        behavior: _isOnlySelected ? HitTestBehavior.translucent : HitTestBehavior.deferToChild,
        // onPanStart: _allowDrag ? (details) => creatorWidget.onGestureStart() : null,
        // onPanUpdate: _allowDrag ? (details) => creatorWidget._onGestureUpdate(details, context) : null,
        // onPanEnd: _allowDrag ? (details) => creatorWidget._onDragEnd(context) : null,
        onScaleStart: (details) {
          _tempSize = creatorWidget.size;
          _initPointerCount = details.pointerCount;
          if (DateTime.now().difference(_lastGestureTime).inMilliseconds < 200) _initPointerCount = 0;
          if (_initPointerCount == 2) creatorWidget.onResizeStart();
          else if (_initPointerCount == 1) creatorWidget.onDragStart();
        },
        onScaleUpdate: (details) {
          if (_initPointerCount == 2) {
            Size _size = Size(_tempSize.width * details.scale, _tempSize.height * details.scale);
            if (creatorWidget.allowResize(_size)) creatorWidget.onResize(_size, isScaling: true);
          }
          if (_allowDrag && _initPointerCount == 1) creatorWidget.updatePositionWithOffset(details.focalPointDelta);
          creatorWidget.updateListeners(WidgetChange.misc);
        },
        onScaleEnd: (details) {
          if (_initPointerCount == 2) creatorWidget.onResizeFinished();
          else if (_initPointerCount == 1) creatorWidget.onDragFinish(context);
          _lastGestureTime = DateTime.now();
        },
        dragStartBehavior: DragStartBehavior.down,
        child: Stack(
          children: [
      
            _SelectedWidgetHighlighter(widget: creatorWidget),
      
            if (creatorWidget is WidgetGroup) ... [
              for (CreatorWidget child in (creatorWidget as WidgetGroup).widgets) if (child.isSelected()) creatorWidget.rotatedWidget(
                child: _SelectedWidgetHighlighter(
                  widget: child,
                  position: child.position + creatorWidget.position,
                  highlight: true,
                ),
              )
            ],
      
            if (_isOnlySelected) Visibility(
              visible: (creatorWidget.isResizable && !creatorWidget.isLocked),
              child: AlignPositioned(
                dx: creatorWidget.position.dx,
                dy: creatorWidget.position.dy,
                childHeight: creatorWidget.size.height + 40,
                childWidth: creatorWidget.size.width + 40,
                // rotateDegrees: angle,
                child: SizedBox(
                  width: creatorWidget.size.width + 40,
                  height: creatorWidget.size.height + 40,
                  child: creatorWidget.rotatedWidget(
                    child: Stack(
                      children: [
                        for (ResizeHandler handler in creatorWidget.resizeHandlers) ResizeHandlerBall(
                          type: handler,
                          widget: creatorWidget,
                          keepAspectRatio: creatorWidget.keepAspectRatio,
                          onSizeChange: creatorWidget.onResize,
                          onResizeEnd: creatorWidget.onResizeFinished,
                          isResizing: creatorWidget.isResizing,
                          onResizeStart: creatorWidget.onResizeStart,
                          isVisible: creatorWidget._getResizeHandlersWRTSize().contains(handler) || creatorWidget._currentResizingHandler == handler,
                          isMinimized: creatorWidget.isDragging,
                          // color: creatorWidget.page.palette.isLightBackground ? creatorWidget.page.palette.onBackground : creatorWidget.page.palette.onBackground.harmonizeWith(Colors.white),
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      
            if (_isOnlySelected) Visibility(
              visible: !creatorWidget.isDragging,
              child: Builder(
                builder: (_) {
                  double dy = creatorWidget.position.dy;
                  double dx = creatorWidget.position.dx;
                  double positionY = dy + creatorWidget.size.height/2 + 20 + 15;
                  double positionX = dx;
                  
                  if ((positionY + 15) > creatorWidget.page.project.contentSize.height/2) {
                    positionY = dy - creatorWidget.size.height/2 - 20 - 15;
                  }
                  
                  return AlignPositioned(
                    dy: positionY,
                    dx: positionX,
                    child: WidgetActionButton(
                      widget: creatorWidget,
                    ),
                  );
                }
              ),
            )
          ],
        ),
      ),
    );
  }

  void onWidgetChange() => setState(() {});

  void updateWidget() {
    creatorWidget.removeListener(onWidgetChange);
    creatorWidget = widget.widget;
    creatorWidget.addListener(onWidgetChange);
  }

}

class _SelectedWidgetHighlighter extends StatelessWidget {

  const _SelectedWidgetHighlighter({
    required this.widget,
    this.position,
    this.highlight = false,
  });

  final CreatorWidget widget;
  final Offset? position;
  final bool highlight;

  bool get isLightBackground => widget.page.palette.isLightBackground && widget.page.widgets.background.type != BackgroundType.image;

  Offset get _position => position ?? widget.position;

  @override
  Widget build(BuildContext context) {
    return AlignPositioned(
      dx: _position.dx,
      dy: _position.dy,
      childHeight: widget.size.height + (2 / widget.page.scale),
      childWidth: widget.size.width + (2 / widget.page.scale),
      child: IgnorePointer(
        child: widget.rotatedWidget(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: (highlight ? Colors.pinkAccent : Palette.of(context).primary).harmonizeWith(widget.page.palette.background),
                width: 1 / widget.page.scale,
              ),
              // boxShadow: [
              //   if (!isLightBackground) BoxShadow(
              //     blurStyle: BlurStyle.outer,
              //     color: Colors.black.withValues(alpha: 0.1),
              //     blurRadius: 5,
              //     spreadRadius: 0,
              //   )
              // ]
            ),
          ),
        ),
      ),
    );
  }
}

/// Customized GestureDetector that detects double tap events for selecting widgets
class _CustomGestureDetector extends StatefulWidget {

  const _CustomGestureDetector({
    this.onDoubleTap,
    this.onTap,
    required this.child,
    required this.uid,
  });

  final void Function()? onDoubleTap;
  final void Function()? onTap;
  final String uid;
  final Widget child;

  @override
  State<_CustomGestureDetector> createState() => _CustomGestureDetectorState();
}

class _CustomGestureDetectorState extends State<_CustomGestureDetector> {

  DateTime _lastTap = DateTime.now() - Duration(minutes: 1);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: ValueKey('gesture-${widget.uid}'),
      onTap: () {
        if (DateTime.now().difference(_lastTap).inMilliseconds < 200) {
          widget.onDoubleTap?.call();
        } else {
          widget.onTap?.call();
        }
        _lastTap = DateTime.now();
      },
      child: widget.child,
    );
  }
}

/// Determines the direction in which the widget should expand vertically when resized
enum VerticalExpandDirection {
  /// Expand the widget to the top, keeping the bottom position constant
  up,
  /// Expand the widget equally to the top and bottom, keeping the center position constant
  both,
  /// Expand the widget to the bottom, keeping the top position constant
  down
}

/// Determines the direction in which the widget should expand horizontally when resized
enum HorizontalExpandDirection {
  /// Expand the widget to the left, keeping the right position constant
  left,
  /// Expand the widget equally to the left and right, keeping the center position constant
  both,
  /// Expand the widget to the right, keeping the left position constant
  right
}

extension VerticalExpandDirectionExtension on VerticalExpandDirection {

  String get name {
    switch (this) {
      case VerticalExpandDirection.up:
        return 'up';
      case VerticalExpandDirection.both:
        return 'both';
      case VerticalExpandDirection.down:
        return 'down';
    }
  }

  static VerticalExpandDirection fromString(String? name) {
    switch (name) {
      case 'up':
        return VerticalExpandDirection.up;
      case 'both':
        return VerticalExpandDirection.both;
      case 'down':
        return VerticalExpandDirection.down;
      default:
        return VerticalExpandDirection.both;
    }
  }

}

extension HorizontalExpandDirectionExtension on HorizontalExpandDirection {

  String get name {
    switch (this) {
      case HorizontalExpandDirection.left:
        return 'left';
      case HorizontalExpandDirection.both:
        return 'both';
      case HorizontalExpandDirection.right:
        return 'right';
    }
  }

  static HorizontalExpandDirection fromString(String? name) {
    switch (name) {
      case 'left':
        return HorizontalExpandDirection.left;
      case 'both':
        return HorizontalExpandDirection.both;
      case 'right':
        return HorizontalExpandDirection.right;
      default:
        return HorizontalExpandDirection.both;
    }
  }

}