import 'package:align_positioned/align_positioned.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:sprung/sprung.dart';
import '../../rehmat.dart';
import '../state.dart';

/// A class to manage and handle the widgets in the page.
class WidgetManager extends ChangeNotifier {

  late Map<String, CreatorWidget> _widgets;
  late String _background;

  final CreatorPage page;

  WidgetManager._({required List<CreatorWidget> widgets, required this.page}) {
    this._widgets = Map<String, CreatorWidget>.fromIterable(
      widgets,
      key: (widget) => widget.uid,
      value: (widget) {
        if (widget is BackgroundWidget) _background = widget.uid;
        return widget;
      }
    );
    updateSortedUIDs();
  }

  /// Creates a new instance of [WidgetManager] when a new page is created.
  factory WidgetManager.create(CreatorPage page, {
    Map<String, dynamic>? data
  }) {
    List<CreatorWidget> widgets = [];
    if (data != null) {
      for (Map map in data['widgets']) {
        try {
          CreatorWidget widget = CreatorWidget.fromJSON(page: page, Map<String, dynamic>.from(map));
          widgets.add(widget);
        } catch (e, stacktrace) {
          analytics.logError(e, cause: 'could not build widget', stacktrace: stacktrace);
          page.project.issues.add(Exception('${map['name']} failed to rebuild'));
        }
      }
    } else {
      widgets.add(BackgroundWidget(page: page));
    }
    WidgetManager manager = WidgetManager._(
      widgets: widgets,
      page: page,
    );
    manager.addListeners();
    return manager;
  }

  BackgroundWidget get background => _widgets[_background] as BackgroundWidget;

  List<CreatorWidget> _selections = [];
  int get nSelections => _selections.length;

  int get nWidgets => _widgets.length;

  bool _multiselect = false;

  bool get multiselect => _multiselect;
  set multiselect(bool multiselect) {
    _multiselect = multiselect;
    if (multiselect) _selections.remove(background);
    selections.forEach((element) {
      element.updateListeners(WidgetChange.misc);
    });
    _selections = [
      if (_selections.isNotEmpty) _selections.first,
    ];
    notifyListeners();
    page.updateListeners(PageChange.selection);
  }

  bool isSelected({
    CreatorWidget? widget,
    String? uid
  }) {
    assert(widget != null || uid != null);
    if (widget != null) return _selections.contains(widget);
    else return _selections.indexWhere((widget) => widget.uid == uid) != -1;
  }

  List<CreatorWidget> get selections => _selections;

  /// Selects the provided widget.
  /// 
  /// If [multiselect] is true, then the widget will be added to the selection.
  /// If [multiselect] is false, then the widget will be the only selected widget.
  /// 
  /// Incase the widget is a [BackgroundWidget], then the selection will be cleared and the widget will be the only selected widget.
  void select([CreatorWidget? widget]) {
    if (widget == null) {
      _selections.clear();
      updateGrids();
      page.updateListeners(PageChange.selection);
      return;
    }
    if (widget is WidgetGroup) {
      multiselect = false;
      _selections.clear();
      _selections.add(background);
    } else if (widget.uid == background.uid || widget is BackgroundWidget) {
      if (!multiselect) {
        _selections.clear();
        _selections.add(background);
      }
    } else {
      if (multiselect) {
        if (isSelected(widget: widget)) {
          _selections.remove(widget);
        } else if (widget.group != null) {
          // multiselect = false;
          // select(widget.group!.findGroup(widget));
          _selections.add(widget);
        } else {
          _selections.add(widget);
        }
      } else {
        _selections = [widget];
      }
    }
    updateGrids();
    page.updateListeners(PageChange.selection);
  }

  /// Selects the widget with the given [uid].
  /// Note that nothing will happen if the widget is not found.
  void selectWithUID(String uid) {
    CreatorWidget? widget = find(uid);
    if (widget != null) select(widget);
  }

  CreatorWidget? find(String uid) {
    if (_widgets.containsKey(uid)) return _widgets[uid];
    else {
      for (CreatorWidget widget in _widgets.values) {
        if (widget is WidgetGroup) {
          CreatorWidget? found = widget.widgets.firstWhereOrNull((element) => element.uid == uid);
          if (found != null) return found;
        }
      }
      return null;
    }
  }

  T? get<T extends CreatorWidget>(String uid) => _widgets[uid] as T?;

  /// Adds the given widget to the page
  void add(CreatorWidget widget, {
    /// If true, then the widget will be added without calling `init()` on it.
    bool soft = false
  }) {
    // Add a listener for that widget here
    multiselect = false;
    _widgets[widget.uid] = widget;
    sortedUIDs.add(widget.uid);
    if (!soft) select(widget);
    rebuildListeners();
    if (!soft) page.history.log('Add widget');
    page.updateListeners(PageChange.misc);
  }

  void delete(String uid, {
    /// If true, then the widget will be deleted without calling `dispose()` on it.
    bool soft = false
  }) {
    if (!_widgets.containsKey(uid)) return;
    multiselect = false;
    CreatorWidget widget = _widgets[uid]!;
    if (!soft) widget.onDelete();
    _widgets.remove(widget.uid);
    sortedUIDs.remove(widget.uid);
    if (!soft) page.history.log('Delete widget');
    select();
    rebuildListeners();
    page.updateListeners(PageChange.misc);
  }

  CreatorWidget? findWidget(String uid) {
    if (_widgets.containsKey(uid)) return _widgets[uid];
    return null;
  }

  void updateGrids() {
    page.gridState.clear();
    for (CreatorWidget widget in _widgets.values) {
      widget.updateGrids();
      widget.stateCtrl.update();
    }
  }

  void rebuildListeners() {
    removeListeners();
    addListeners();
  }

  /// Adds listener for every widget
  void addListeners() {
    for (CreatorWidget widget in _widgets.values) {
      widget.addListener(onWidgetUpdate, [WidgetChange.update]);
      widget.addListener(onWidgetNotReallyUpdate, [WidgetChange.resize, WidgetChange.drag, WidgetChange.rotate, WidgetChange.misc]);
    }
  }

  /// Removes listener for every single widget
  void removeListeners() {
    for (CreatorWidget widget in _widgets.values) {
      widget.removeListener(onWidgetUpdate, [WidgetChange.update]);
      widget.removeListener(onWidgetNotReallyUpdate, [WidgetChange.resize, WidgetChange.drag, WidgetChange.rotate, WidgetChange.misc]);
    }
  }

  /// Set the state of the page when a widget is updated.
  void onWidgetUpdate() { }

  /// This method is different from `onWidgetUpdate`.
  /// This is called when the widget is dragged, resized or rotated.
  /// This has to be separated because it does not record history.
  void onWidgetNotReallyUpdate() { }

  void dispose() {
    removeListeners();
    super.dispose();
  }

  /// Generates a map with all the widgets in JSON format
  /// 
  /// See the example below for the use case of this method. (To be used in `CreatorPage.toJSON`)
  /// ```
  /// {
  ///   ..
  ///   ... widgetManager.toJSON()
  /// }
  /// ```
  Map<String, dynamic> toJSON([BuildInfo buildInfo = BuildInfo.unknown]) {
    List<Map<String, dynamic>> widgetData = [];
    for (String uid in sortedUIDs) {
      CreatorWidget widget = _widgets[uid]!;
      widgetData.add(widget.toJSON(buildInfo: buildInfo));
    }
    return {
      'widgets': widgetData
    };
  }

  List<CreatorWidget> get widgets {
    return sortedUIDs.map((uid) {
      return _widgets[uid]!;
    }).toList();
  }

  List<String> sortedUIDs = [];
  void updateSortedUIDs() {
    sortedUIDs = List<String>.from(_widgets.values.map((widget) => widget.uid));
  }

  void reorder(String uid, int index, {
    /// Enables history logging of the reorder
    /// Use it when the slider of reorder calls `onChangeEnd` method
    bool log = false,
  }) {
    int oldIndex = sortedUIDs.indexOf(uid);
    if (oldIndex == index) return;
    sortedUIDs.removeAt(oldIndex);
    sortedUIDs.insert(index, uid);
    if (log) page.history.log('Reorder');
    page.updateListeners(PageChange.misc);
  }

  void readVariableValues(List<Map<String, dynamic>> values) {
    Map<String, Map<String, dynamic>> mappedValues = {};
    for (Map<String, dynamic> value in values) {
      mappedValues[value['uid']] = value;
    }
    for (CreatorWidget widget in _widgets.values) {
      if (widget is WidgetGroup) {
        for (CreatorWidget child in widget.widgets) {
          if (mappedValues.containsKey(child.uid)) {
            child.loadVariables(mappedValues[child.uid]!);
          }
        }
      } else {
        if (mappedValues.containsKey(widget.uid)) {
          widget.loadVariables(mappedValues[widget.uid]!);
        }
      }
    }
  }

  /// Use this method in `CreatorPage.build` to build material widgets.
  /// 
  /// See the example below for the use case of this method. (To be used in `CreatorPage.build`)
  /// ```dart
  /// Stack(
  ///  children: [
  ///   ... widgetManager.build(context),
  ///   ... other widgets
  /// ]
  /// ```
  List<Widget> buildHandlers(BuildContext context, {
    bool isInteractive = true,
  }) {
    return [
      _WidgetHandlerBuilder(
        manager: this
      ),
      _MultiselectDragOverlay(widgets: this)
    ];
  }

  Widget buildWidgets(BuildContext context, {
    Size? size
  }) {
    return ClipRRect(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 400),
        curve: Sprung(),
        child: SizedBox.fromSize(
          size: size,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              ... sortedUIDs.map((uid) => RenderWidgetState(
                key: UniqueKey(),
                controller: _widgets[uid]!.stateCtrl,
                widget: _widgets[uid]!,
                page: page,
              )).toList(),
            ]
          ),
        ),
      ),
    );
  }

  /// This method rebuild all the widgets in the page from a previous state in the history.
  void restoreHistory(List<Map> data, {
    required String? version
  }) {
    _selections.clear();
    page.gridState.clear();
    _widgets.clear();
    for (Map widgetData in data) try {
      CreatorWidget widget = CreatorWidget.fromJSON(
        widgetData,
        page: page,
        buildInfo: BuildInfo(buildType: BuildType.restore, version: version)
      );
      if (widget is BackgroundWidget) {
        _background = widget.uid;
      }
      this._widgets[widget.uid] = widget;
      updateSortedUIDs();
      widget.updateGrids();
      widget.updateListeners(WidgetChange.misc);
    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'could not restore history', stacktrace: stacktrace);
      page.project.issues.add(Exception('${widgetData['name']} failed to rebuild'));
    }
    rebuildListeners();
    page.updateListeners(PageChange.update);
  }

  /// Runs a function on every widget in the page.
  void forEach(void Function(CreatorWidget widget) callback) => _widgets.values.forEach(callback);
  
}

class _MultiselectDragOverlay extends StatefulWidget {

  const _MultiselectDragOverlay({
    required this.widgets
  });

  final WidgetManager widgets;

  @override
  State<_MultiselectDragOverlay> createState() => __MultiselectDragOverlayState();
}

class __MultiselectDragOverlayState extends State<_MultiselectDragOverlay> {

  late WidgetManager widgets;

  Offset? _selectorStart;
  Offset? _selectorEnd;

  void onMultiselectChange() => setState(() { });

  @override
  void initState() {
    widgets = widget.widgets;
    widgets.addListener(onMultiselectChange);
    super.initState();
  }

  @override
  void dispose() {
    widgets.removeListener(onMultiselectChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        dragStartBehavior: DragStartBehavior.down,
        behavior: HitTestBehavior.translucent,
        onPanStart: widgets.multiselect ? (details) {
          _selectorStart = _selectorEnd = details.localPosition - Offset(widgets.page.project.contentSize.width/2, widgets.page.project.contentSize.height/2);
          setState(() { });
        } : null,
        onPanUpdate: widgets.multiselect ? (details) {
          _selectorEnd = Offset(_selectorEnd!.dx + details.delta.dx, _selectorEnd!.dy + details.delta.dy);
          setState(() { });
        } : null,
        onPanEnd: widgets.multiselect ? (details) {
          Size _selectorSize = Size((_selectorEnd!.dx - _selectorStart!.dx).abs(), (_selectorEnd!.dy - _selectorStart!.dy).abs());
          Offset _selectorMiddle = Offset((_selectorStart!.dx + _selectorEnd!.dx)/2, (_selectorStart!.dy + _selectorEnd!.dy)/2) - Offset(widgets.page.project.contentSize.width/2, widgets.page.project.contentSize.height/2);
          Rect rect = Rect.fromLTWH(
            _selectorMiddle.dx + widgets.page.project.contentSize.width/2 - _selectorSize.width/2,
            _selectorMiddle.dy + widgets.page.project.contentSize.height/2 - _selectorSize.height/2,
            _selectorSize.width,
            _selectorSize.height
          );
          _selectorStart = _selectorEnd = null;

          bool wereAllSelected = true;
          for (CreatorWidget widget in widgets.widgets) {
            if (widget is BackgroundWidget) continue;
            bool isOverlaping = widget.area.overlaps(rect) || rect.overlaps(widget.area);
            if (isOverlaping) {
              if (widget is WidgetGroup) {
                for (CreatorWidget child in widget.widgets) {
                  if (child.area.overlaps(rect) || rect.overlaps(child.area)) {
                    if (!widgets.isSelected(widget: child)) {
                      wereAllSelected = false;
                      widgets.select(child);
                    }
                  }
                }
              } else {
                if (!widgets.isSelected(widget: widget)) {
                  wereAllSelected = false;
                  widgets.select(widget);
                }
              }
            }
          }
          if (wereAllSelected) widgets.select();
          setState(() { });
        } : null,
        child: SizedBox.fromSize(
          size: widgets.page.project.contentSize,
          child: Stack(
            children: [
              if (_selectorStart != null && _selectorEnd != null) AlignPositioned(
                dx: (_selectorStart!.dx + _selectorEnd!.dx)/2,
                dy: (_selectorStart!.dy + _selectorEnd!.dy)/2,
                child: SizedBox(
                  width: (_selectorStart!.dx - _selectorEnd!.dx).abs(),
                  height: (_selectorStart!.dy - _selectorEnd!.dy).abs(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Palette.of(context).primary.harmonizeWith(widgets.page.palette.background).withValues(alpha: 0.2),
                      border: Border.all(
                        color: Palette.of(context).primary,
                        width: 1,
                      ),
                    ),
                  )
                ),
              ),

              // Uncomment to check if the area of each widget is calculated correctly
              // for (CreatorWidget widget in widgets.widgets) if (widget is! BackgroundWidget) AlignPositioned(
              //   dx: widget.area.center.dx,
              //   dy: widget.area.center.dy,
              //   child: SizedBox(
              //     width: widget.area.width,
              //     height: widget.area.height,
              //     child: Container(
              //       decoration: BoxDecoration(
              //         color: Palette.of(context).primary.harmonizeWith(widgets.page.palette.background).withValues(alpha: 0.2),
              //         border: Border.all(
              //           color: Palette.of(context).primary,
              //           width: 1,
              //         ),
              //       ),
              //     )
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

}

class _WidgetHandlerBuilder extends StatefulWidget {

  const _WidgetHandlerBuilder({
    required this.manager,
  });

  final WidgetManager manager;

  @override
  State<_WidgetHandlerBuilder> createState() => __WidgetHandlerBuilderState();
}

class __WidgetHandlerBuilderState extends State<_WidgetHandlerBuilder> {

  late final WidgetManager manager;

  @override
  void initState() {
    super.initState();
    manager = widget.manager;
    manager.addListener(onSelectionChange);
    manager.page.addListener(onSelectionChange);
  }

  @override
  void dispose() {
    manager.removeListener(onSelectionChange);
    manager.page.removeListener(onSelectionChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (manager.selections.firstOrNull is BackgroundWidget || manager.selections.firstOrNull == null || manager.selections.firstOrNull is RenderStudioWatermark) return Container();
    else {
      List<CreatorWidget> widgets = [];
      for (CreatorWidget widget in manager.selections) {
        if (widget.group == null || widget is WidgetGroup) widgets.add(widget);
        else if (widget.group != null) {
          WidgetGroup group = widget.group!.findGroup(manager.selections.first);
          if (!widgets.contains(group)) widgets.add(group);
        }
      }
      return Stack(
        children: [
          for (CreatorWidget widget in widgets) WidgetHandlerBuilder(
            widget: widget
          ),
        ],
      );
    }
  }

  void onSelectionChange() => setState(() { });

}