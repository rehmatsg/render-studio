import 'dart:ui';
import 'package:align_positioned/align_positioned.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../rehmat.dart';
import '../helpers/text_span_helper.dart';

class CreatorText extends CreatorWidget {

  CreatorText({required CreatorPage page, Map? data, BuildInfo buildInfo = BuildInfo.unknown}) : super(page, data: data, buildInfo: buildInfo);

  static Future<void> create(BuildContext context, {
    required CreatorPage page
  }) async {
    CreatorText widget = CreatorText(page: page);
    widget.fontSize = 40;
    widget.buildTextSpan(calculateSize: true, forceWidgetResize: true);
    page.widgets.add(widget);
  }

  static Future<void> createDefaultWidget({
    required CreatorPage page,
  }) async {
    String text = 'Double tap to edit text';
    TextStyle style = GoogleFonts.inter(
      fontSize: 40,
    );
    CreatorText widget = CreatorText(page: page);
    widget.text = text;
    widget.fontSize = 40;
    widget.primaryStyle = CreativeTextStyle.fromTextStyle(style, widget: widget);
    widget.align = TextAlign.center;
    widget.buildTextSpan(calculateSize: true, forceWidgetResize: true);
    page.widgets.add(widget, soft: true);
  }
  
  @override
  void onInitialize() {
    // buildTextSpan();
    primaryStyle = CreativeTextStyle(widget: this);
    primaryStyle.color = page.palette.onBackground;
    containerProvider = CreativeContainerProvider.create(this);
    fitSize = size;
    super.onInitialize();
  }

  @override
  List<EditorTab> get tabs => [
    EditorTab(
      name: 'Text',
      options: [
        Option.button(
          title: 'Edit',
          tooltip: 'Edit text',
          onTap: (context) async {
            await editText(context: context);
          },
          icon: RenderIcons.keyboard
        ),
        if (page.project.isTemplateKit) Option.button(
          title: 'Test New Text',
          tooltip: 'Test alignment by randomizing text value',
          onTap: (context) async {
            editText(text: [
              'Hello World',
              'This is a test',
              'This is a long text to test the alignment of the text widget',
              'Single line text',
              'Multi line text\nThis is a new line',
            ].getRandom(avoid: text));
          },
          icon: RenderIcons.refresh
        ),
        if (page.project.isTemplateKit) Option.button(
          title: 'Variable',
          tooltip: 'Change text variable type',
          onTap: (context) async {
            if (variableTextType == null) variableTextType = _VariableTextType.values.first;
            page.editorManager.openModal(
              tab: (context, setState) => EditorTab.pickerBuilder(
                title: 'Variable',
                childCount: _VariableTextType.values.length,
                initialIndex: variableTextType != null ? _VariableTextType.values.indexOf(variableTextType!) : 0,
                itemBuilder: (context, index) {
                  return Text(
                    _VariableTextType.values[index].title,
                  );
                },
                onSelectedItemChanged: (index) {
                  variableTextType = _VariableTextType.values[index];
                  variableComments = _VariableTextType.values[index].prompt;
                },
              ),
              onDismiss: () {
                if (variableTextType == _VariableTextType.constant) {
                  isVariableWidget = false;
                  Alerts.snackbar(context, text: 'This widget has been updated to constant data, it will be excluded from project variables. Comment box disabled');
                } else isVariableWidget = true;
                updateListeners(WidgetChange.update, historyMessage: 'Change Variable Type');
                if (variableTextType == _VariableTextType.custom) Alerts.snackbar(context, text: 'Custom variable type declared. Remember to add a comment to the variable type.');
              }
            );
          },
          icon: RenderIcons.variable
        ),
        Option.font(
          this,
          fontFamily: fontFamily,
          onChange: (change, font) {
            if (font != null) fontFamily = font;
            updateListeners(change, forceSpanResize: true, historyMessage: 'Change Font');
          },
        ),
        if (group == null) Option.button(
          title: 'Size',
          tooltip: 'Text size',
          onTap: (context) async {
            autoSize = false;
            updateListeners(WidgetChange.misc);
            page.editorManager.openModal(
              tab: (context, setState) => EditorTab.size(
                current: fontSize,
                min: 10,
                max: 200,
                onChange: (value) {
                  fontSize = value;
                  size = calculateSizeForTextStyle(text, style: style, page: page);
                  updateListeners(WidgetChange.misc);
                }
              ),
              onDismiss: () {
                updateListeners(WidgetChange.misc);
              }
            );
          },
          icon: RenderIcons.text_size
        ),
        ... defaultOptions,
      ],
    ),
    EditorTab(
      name: 'Style',
      options: [
        ... primaryStyle.getOptions()
      ],
    ),
    EditorTab(
      name: 'Secondary Style',
      options: [
        Option.button(
          title: 'Info',
          onTap: (context) => Alerts.modalInfoBuilder(
            context,
            title: 'Secondary Style',
            message: 'Secondary style is used to apply a different style to a part of the text. For example, you can apply a different color to a part of the text. To apply a secondary style to a part of the text, enclose the text in asterisks (*). For example, "demo" in "Let\'s try with a *demo*" will be styled with the secondary style.',
          ),
          icon: RenderIcons.info
        ),
        if (secondaryStyle == null) Option.button(
          title: 'Add Secondary Style',
          onTap: (context) {
            secondaryStyle = CreativeTextStyle(widget: this);
            updateListeners(WidgetChange.update);
          },
          icon: RenderIcons.add
        ) else ... [
          Option.button(
            title: 'Swap Styles',
            onTap: (context) {
              CreativeTextStyle temp = primaryStyle;
              primaryStyle = secondaryStyle!;
              secondaryStyle = temp;
              updateListeners(WidgetChange.update);
            },
            icon: RenderIcons.swap
          ),
          ... secondaryStyle!.getOptions(),
          Option.button(
            title: 'Remove Secondary Style',
            tooltip: 'Remove secondary style',
            onTap: (context) {
              secondaryStyle = null;
              updateListeners(WidgetChange.update);
            },
            icon: RenderIcons.remove
          )
        ]
      ],
    ),
    containerProvider.editor(
      name: 'Shape',
      onChange: (change) {
        updateListeners(change);
      },
    ),
    EditorTab(
      name: 'Alignment',
      type: EditorTabType.single,
      options: [
        Option.custom(
          widget: (context) => Center(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: Constants.of(context).bottomPadding
              ),
              child: SegmentedButton<TextAlign>(
                emptySelectionAllowed: false,
                segments: [
                  ButtonSegment(
                    value: TextAlign.left,
                    icon: Icon(RenderIcons.text_align_left),
                    label: Text('Left'),
                  ),
                  ButtonSegment(
                    value: TextAlign.center,
                    icon: Icon(RenderIcons.text_align_right),
                    label: Text('Center'),
                  ),
                  ButtonSegment(
                    value: TextAlign.right,
                    icon: Icon(RenderIcons.text_align_center),
                    label: Text('Right'),
                  ),
                  ButtonSegment(
                    value: TextAlign.justify,
                    icon: Icon(RenderIcons.text_align_justify),
                    label: Text('Justify'),
                  ),
                ],
                showSelectedIcon: false,
                multiSelectionEnabled: false,
                onSelectionChanged: (align) {
                  this.align = align.first;
                  adjustHorizontalExpandDirection();
                  updateListeners(WidgetChange.update);
                },
                selected: {align}
              ),
            ),
          ),
        ),
      ],
    ),
    EditorTab(
      name: 'Effects',
      options: [
        Option.button(
          title: 'Shadow',
          onTap: (context) async {
            if (shadows == null) shadows = [Shadow()];
            page.editorManager.openModal(
              tab: (context, setState) => EditorTab.shadow<Shadow>(
                widget: this,
                shadow: shadows!.first,
                onChange: (value) {
                  if (value == null) shadows = null;
                  else shadows = [value];
                  updateListeners(WidgetChange.misc);
                },
              ),
              actions: (dismiss) => [
                IconButton(
                  onPressed: () {
                    dismiss();
                    shadows = null;
                    updateListeners(WidgetChange.update);
                  },
                  icon: Icon(RenderIcons.delete),
                  iconSize: 20,
                )
              ],
              onDismiss: () {
                updateListeners(WidgetChange.update);
              }
            );
          },
          icon: RenderIcons.shadow,
          tooltip: 'Customize shadow of text'
        ),
        // Option.button(
        //   title: 'Outline',
        //   tooltip: 'Add an outline to text',
        //   onTap: (context) async {
        //     primaryStyle.addStroke();
        //     secondaryStyle?.addStroke();
        //     updateListeners(WidgetChange.update);
        //   },
        //   icon: RenderIcons.outline
        // ),
        Option.button(
          title: 'Lifted',
          tooltip: 'Add a lifted effect to text',
          onTap: (context) async {
            if ((shadows?.length ?? 0) == 1 && shadows!.first.offset == Offset(0, 0) && shadows!.first.blurRadius == 30 && shadows!.first.color == Colors.black.withValues(alpha: 0.5)) {
              shadows = null;
            } else shadows = [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 30,
                spreadRadius: 30,
                offset: Offset(0, 0)
              )
            ];
            updateListeners(WidgetChange.update);
          },
          icon: RenderIcons.lifted
        ),
        Option.button(
          title: 'Drop Shadow',
          tooltip: 'Add a drop shadow to text',
          onTap: (context) async {
            if ((shadows?.length ?? 0) == 1 && shadows!.first.offset == Offset(0, 3) && shadows!.first.blurRadius == 1 && shadows!.first.color == Colors.black.withValues(alpha: 0.2)) {
              shadows = null;
            } else shadows = [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 1,
                offset: Offset(0, 3)
              )
            ];
            updateListeners(WidgetChange.update);
          },
          icon: RenderIcons.drop_shadow
        ),
        Option.button(
          title: 'Echo',
          tooltip: 'Add echo effect to text',
          onTap: (context) async {
            if ((shadows?.length ?? 0) == 2 && shadows!.first.offset == Offset(5, 5) && shadows!.first.blurRadius == 2 && shadows![1].blurRadius == 4 && shadows![1].offset == Offset(10, 10)) {
              shadows = null;
            } else {
              secondaryStyle = null;
              shadows = [
                BoxShadow(
                  color: primaryStyle.color.withValues(alpha: 0.4),
                  blurRadius: 2,
                  offset: Offset(5, 5)
                ),
                BoxShadow(
                  color: primaryStyle.color.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: Offset(10, 10)
                ),
              ];
            }
            updateListeners(WidgetChange.update);
          },
          icon: RenderIcons.echo
        ),
        // Option.button(
        //   title: 'Splice',
        //   tooltip: 'Add splice effect to text',
        //   onTap: (context) async {
        //     if (primaryStyle.stroke != null && (shadows?.length ?? 0) == 1 && shadows!.first.blurRadius == 2 && shadows!.first.offset == Offset(5, 5)) {
        //       if (primaryStyle.stroke != null) primaryStyle.addStroke();
        //       shadows = [];
        //     } else {
        //       secondaryStyle = null;
        //       if (primaryStyle.stroke == null) primaryStyle.addStroke();
        //       shadows = [
        //         BoxShadow(
        //           color: primaryStyle.color.withValues(alpha: 0.4),
        //           blurRadius: 2,
        //           offset: Offset(5, 5)
        //         ),
        //       ];
        //     }
        //     updateListeners(WidgetChange.update);
        //   },
        //   icon: RenderIcons.splice
        // ),
        Option.button(
          title: 'Glitch',
          tooltip: 'Add glitch effect to text',
          onTap: (context) async {
            if ((shadows?.length ?? 0) == 2 && shadows!.first.offset == Offset(-2, 0) && shadows![1].offset == Offset(2, 0)) {
              shadows = null;
            } else {
              shadows = [
                BoxShadow(
                  color: Colors.redAccent,
                  blurRadius: 3,
                  offset: Offset(-2, 0)
                ),
                BoxShadow(
                  color: Colors.blue,
                  blurRadius: 3,
                  offset: Offset(2, 0)
                ),
              ];
            }
            updateListeners(WidgetChange.update);
          },
          icon: RenderIcons.textGlitch
        ),
      ],
    ),
    EditorTab(
      name: 'Spacing',
      type: EditorTabType.row,
      options: [
        Option.showSlider(
          this,
          icon: RenderIcons.spacing,
          tooltip: 'Adjust Letter Spacing',
          title: 'Letter',
          max: 20,
          min: -10,
          value: letterSpacing,
          onChange: (value) {
            letterSpacing = value;
            alterHeightToFit();
          },
          onChangeEnd: () => updateListeners(WidgetChange.update),
        ),
        Option.showSlider(
          this,
          icon: RenderIcons.word_spacing,
          tooltip: 'Adjust Word Spacing',
          title: 'Word',
          max: 20,
          min: -10,
          value: wordSpacing,
          onChange: (value) {
            wordSpacing = value;
            alterHeightToFit();
          },
          onChangeEnd: () {
            alterHeightToFit();
            updateListeners(WidgetChange.update);
          },
        ),
        Option.showSlider(
          this,
          icon: RenderIcons.height,
          title: 'Height',
          tooltip: 'Change line height of the text',
          max: 2,
          min: 0.66,
          value: lineHeight ?? 1,
          onChange: (value) {
            lineHeight = value;
            alterHeightToFit();
          },
          onChangeEnd: () {
            alterHeightToFit();
            updateListeners(WidgetChange.update);
          },
        ),
      ],
    ),
    EditorTab.adjustTab(widget: this),
  ];

  // Inherited
  final String name = 'Text';
  final String id = 'text';

  bool isVariableWidget = true;

  late Size fitSize;

  @override
  List<ResizeHandler> get resizeHandlers => [
    ResizeHandler.topLeft,
    ResizeHandler.topRight,
    ResizeHandler.centerLeft,
    ResizeHandler.centerRight,
    ResizeHandler.bottomLeft,
    ResizeHandler.bottomRight,    
  ];

  bool isResizable = true;
  bool isDraggable = true;

  bool keepAspectRatio = true;

  @override
  final bool autoChangeHorizontalExpandDirection = false;
  
  /// BackgroundWidget Color
  Color textBackground = Colors.transparent;
  Color? decorationColor = Colors.black;

  String text = 'Double tap to edit text';

  bool autoSize = true;

  TextAlign align = TextAlign.left;

  double wordSpacing = 0;
  double letterSpacing = 1;

  Size size = const Size(200, 100);
  Size? minSize = const Size(10, 5);

  late Size _spanSize;

  double fontSize = 100;

  String fontFamily = 'Roboto';

  double radius = 10;

  double? lineHeight = 1; // 1 or 0.77

  EdgeInsets padding = EdgeInsets.zero;

  List<Shadow>? shadows;

  TextDecorationStyle decorationStyle = TextDecorationStyle.solid;

  Color? widgetColor;

  Color? borderColor;
  double? borderWidth;

  double borderRadius = 0;

  BoxShadow? boxShadow;

  _VariableTextType? variableTextType;

  late TextSpan textSpan;

  late CreativeContainerProvider containerProvider;

  Widget widget(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      AlignPositioned(
        childHeight: size.height + containerProvider.padding.vertical,
        childWidth: size.width + containerProvider.padding.horizontal,
        child: containerProvider.build(
          width: size.width,
          height: size.height
        ),
      ),
      SizedBox.expand(
        child: FittedBox(
          child: textWidget
        ),
      ),
    ],
  );

  Widget get textWidget => Container(
    decoration: BoxDecoration(
      border: preferences.debugMode ? Border.all(
        color: Colors.red,
        width: 0
      ) : null,
    ),
    child: SizedBox.fromSize(
      size: _spanSize,
      child: CreativeTextWidget(
        textSpan,
        textAlign: align,
        style: style,
        secondaryStyle: secondaryTextStyle,
      ),
    ),
  );

  late CreativeTextStyle primaryStyle;
  CreativeTextStyle? secondaryStyle;

  TextStyle get style => primaryStyle.style(
    font: fontFamily,
    lineHeight: lineHeight,
    decorationStyle: decorationStyle,
    shadows: shadows,
    wordSpacing: wordSpacing,
    letterSpacing: letterSpacing,
    fontSize: fontSize,
  );

  TextStyle? get secondaryTextStyle => secondaryStyle?.style(
    font: fontFamily,
    lineHeight: lineHeight,
    decorationStyle: decorationStyle,
    shadows: shadows,
    wordSpacing: wordSpacing,
    letterSpacing: letterSpacing,
    fontSize: fontSize
  );

  @override
  void onDoubleTap(BuildContext context) async {
    await editText(context: context);
  }

  void buildTextSpan({
    /// Calculate the size of the text
    bool calculateSize = false,
    /// Force the widget to resize to the size of the text
    /// Only works if calculateSize is `true`
    bool forceWidgetResize = false
  }) {
    textSpan = textSpanBuilder(
      text: text,
      patternList: [
        CustomRichTextPattern(
          targetString: r'\*(.+?)\*',
          style: secondaryTextStyle ?? style,
          matchBuilder: (match) => TextSpan(
            text: match![0]!.replaceAll('*', ''),
            style: secondaryTextStyle ?? style,
          ),
        ),
      ],
      defaultStyle: style
    );
    if (calculateSize) {
      _spanSize = getTextPainter().size;
      if (forceWidgetResize) size = _spanSize;
    }
  }

  TextPainter getTextPainter({
    double? maxWidth,
  }) {
    return TextPainter(
      text: textSpan,
      textAlign: align,
      textDirection: TextDirection.ltr
    )..layout(minWidth: 0, maxWidth: maxWidth ?? size.width);
  }

  double _widthScale = 1.0;

  /// Calculates new height of the widget when the width is changed using ResizeHandler (center)
  void alterHeightOnResize({
    ResizeHandler? handler,
    Alignment? alignment,
    required Size size
  }) {
    assert(handler != null || alignment != null);
    double _newSpanWidth = size.width / _widthScale;
    _spanSize = getTextPainter(maxWidth: _newSpanWidth).size;
    Size _newSize = Size(size.width, _spanSize.height * _widthScale);
    position = CreatorWidget.autoPosition(
      position: position,
      newSize: _newSize,
      prevSize: this.size,
      alignment: alignment != null ? alignment : (handler == ResizeHandler.centerRight ? Alignment.topLeft : Alignment.topRight)
    );
    this.size = _newSize;
  }

  /// Matches the height of the widget to fit the text
  void alterHeightToFit() {
    buildTextSpan();
    Size _newSpanSize = getTextPainter(maxWidth: _spanSize.width).size;
    double widthScale = size.width / _newSpanSize.width;
    Size _newSize = Size(size.width, _newSpanSize.height * widthScale);
    position = CreatorWidget.autoPosition(
      position: position,
      newSize: _newSize,
      prevSize: size,
      verticalExpandDirection: verticalExpandDirection,
      horizontalExpandDirection: horizontalExpandDirection
    );
    size = _newSize;
    _spanSize = _newSpanSize;
    updateListeners(WidgetChange.misc);
  }

  void removeExtraSpaceFromSize() {
    double wWidth = size.width;
    double wHeight = size.height;
    double sWidth = _spanSize.width;
    double sHeight = _spanSize.height;

    double scale;

    if (wWidth > wHeight) {
      if (sWidth > sHeight) {
        scale = wHeight / sHeight;
      } else {
        scale = wWidth / sWidth;
      }
    } else {
      if (sWidth > sHeight) {
        scale = wHeight / sHeight;
      } else {
        scale = wWidth / sWidth;
      }
    }

    Size _newSize = Size(sWidth * scale, sHeight * scale);
    size = _newSize;
    updateListeners(WidgetChange.misc);
  }

  /// Edits the text of the widget
  /// Provide `text` to edit the text directly, otherwise a modal will be shown to edit the text
  Future<void> editText({
    BuildContext? context,
    /// New text to be set, if null, a modal will be shown to ask user the new text
    String? text,
    bool logHistory = true
  }) async {
    assert(context != null || text != null);
    double scale = size.width / _spanSize.width;

    TextEditingController textCtrl = TextEditingController(text: this.text);
    textCtrl.selection = TextSelection.collapsed(offset: textCtrl.text.length);
    TextAlign align = this.align;
    var focusNode = FocusNode();

    Size _oldSize = size;

    if (text == null) {
      await showModalBottomSheet(
        context: context!,
        enableDrag: false,
        isScrollControlled: true,
        barrierColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(
                    left: 6,
                    right: 6,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 6,
                  ),
                  decoration: BoxDecoration(
                    color: Palette.of(context).surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        autofocus: true,
                        controller: textCtrl,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          hintText: 'Type something ...',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none
                          ),
                          filled: false,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9
                          ),
                        ),
                        minLines: 4,
                        maxLines: 8,
                        textAlign: align,
                        style: TextStyle(
                          fontFamily: fontFamily,
                          fontSize: 20
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(6),
                              onTap: () {
                                List<TextAlign> alignments = [
                                  TextAlign.left,
                                  TextAlign.center,
                                  TextAlign.right,
                                  TextAlign.justify,
                                ];
                                int index = alignments.indexOf(align);
                                setState(() {
                                  align = alignments[alignments.nextIndex(index)];
                                });
                                updateListeners(WidgetChange.misc);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Palette.of(context).outline,
                                    width: 1
                                  ),
                                  borderRadius: BorderRadius.circular(6)
                                ),
                                child: Text(
                                  'Align: ${align.toString().split('.').last.toTitleCase()}',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Divider(
                        height: 0,
                        endIndent: 0,
                        indent: 0,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Palette.of(context).surfaceContainerLow,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(
                                focusNode.hasFocus ? RenderIcons.close_keyboard : RenderIcons.keyboard,
                              ),
                              onPressed: () {
                                if (MediaQuery.of(context).viewInsets.bottom > 0) {
                                  focusNode.unfocus();
                                } else {
                                  focusNode.requestFocus();
                                }
                              },
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Done')
                            )
                          ],
                        ),
                      )
                    ],
                  )
                ),
              ),
            );
          },
        ),
      );
    }

    bool hasChanged = text == null ? (this.text != textCtrl.text || align != this.align) : (text != this.text);

    if (!hasChanged) return;
    
    this.align = align;
    adjustHorizontalExpandDirection();

    String new_text = text ?? textCtrl.text;
    if (new_text.trim() != '') this.text = new_text;

    double maxAllowedSpanWidth = (page.project.contentSize.width - page.widgets.background.padding.horizontal) / scale;

    buildTextSpan();
    Size nSpanSize = getTextPainter(maxWidth: maxAllowedSpanWidth).size;
    Size nWidgetSize = nSpanSize * scale;
    Size mWidgetSize = Size(
      page.project.contentSize.width - page.widgets.background.padding.horizontal,
      page.project.contentSize.height - page.widgets.background.padding.vertical,
    );

    if (nWidgetSize.aspectRatio > 1) {
      if (nWidgetSize.width > mWidgetSize.width) {
        double ratio = mWidgetSize.width / nWidgetSize.width;
        nWidgetSize = nWidgetSize * ratio;
      }
    } else {
      if (nWidgetSize.height > mWidgetSize.height) {
        double ratio = mWidgetSize.height / nWidgetSize.height;
        nWidgetSize = nWidgetSize * ratio;
      }
    }

    Offset _oldPosition = position;

    position = CreatorWidget.autoPosition(
      position: position, newSize: nWidgetSize, prevSize: size, verticalExpandDirection: verticalExpandDirection, horizontalExpandDirection: horizontalExpandDirection
    );

    size = nWidgetSize;
    _spanSize = nSpanSize;
    _widthScale = size.width / _spanSize.width;

    if (group != null) group!.findGroup(this).onElementResize(
      this,
      prevSize: _oldSize,
      prevPosition: _oldPosition,
    );
    if (hasChanged && logHistory) updateListeners(WidgetChange.update, historyMessage: 'Edit Text');
    else updateListeners(WidgetChange.misc);
    if (_containsSecondaryStyle(new_text) && secondaryStyle == null && context != null) Alerts.snackbar(
      context,
      text: 'Please add a secondary style to apply new style to the selected text'
    );
  }

  void adjustHorizontalExpandDirection() {
    // final numLines = getTextPainter(maxWidth: _spanSize.width).computeLineMetrics().length;
    // If there's only a single text line in the text, then the text can be expanded in both directions
    // A single line does not visibly show the alignment of the text, hence we can expand the text in both directions
    // if (numLines > 1) {
      switch (align) {
        case TextAlign.center:
          horizontalExpandDirection = HorizontalExpandDirection.both;
          break;
        case TextAlign.left:
          horizontalExpandDirection = HorizontalExpandDirection.right;
          break;
        case TextAlign.right:
          horizontalExpandDirection = HorizontalExpandDirection.left;
          break;
        case TextAlign.justify:
          horizontalExpandDirection = HorizontalExpandDirection.both;
          break;
        default:
          horizontalExpandDirection = HorizontalExpandDirection.both;
      }
    // } else {
    //   horizontalExpandDirection = HorizontalExpandDirection.both;
    // }
  }

  double _dPaddingVertical = 0;
  double _dPaddingHorizontal = 0;

  @override
  void onResizeStart({DragStartDetails? details, ResizeHandler? handler}) {
    _dPaddingHorizontal = containerProvider.padding.left + containerProvider.padding.right;
    _dPaddingVertical = containerProvider.padding.top + containerProvider.padding.bottom;
    _widthScale = size.width / _spanSize.width;
    super.onResizeStart(details: details, handler: handler);
  }

  @override
  void onResize(Size size, {ResizeHandler? type, bool isScaling = false}) {
    if (type?.type == ResizeHandlerType.corner || isScaling) {
      double scale = size.width / this.size.width;
      _dPaddingHorizontal *= scale;
      _dPaddingVertical *= scale;
      containerProvider.padding = EdgeInsets.only(
        top: _dPaddingVertical / 2,
        bottom: _dPaddingVertical / 2,
        left: _dPaddingHorizontal / 2,
        right: _dPaddingHorizontal / 2,
      );
    }
    if (type?.type == ResizeHandlerType.corner) position = CreatorWidget.autoPosition(position: position, newSize: size, prevSize: this.size, alignment: type?.autoPositionAlignment ?? Alignment.center);
    if (type?.type == ResizeHandlerType.center) alterHeightOnResize(handler: type!, size: size);
    else this.size = size;
    updateListeners(WidgetChange.drag);
  }

  @override
  void onResizeFinished({DragEndDetails? details, ResizeHandler? handler, bool updateNotify = true}) {
    removeExtraSpaceFromSize();
    super.onResizeFinished(details: details, handler: handler, updateNotify: updateNotify);
  }

  bool _containsSecondaryStyle(String text) {
    return text.contains(RegExp(r'\*.*\*'));
  }

  void onPaletteUpdate() {
    if (widgetColor != null) {
      widgetColor = page.palette.primary;
      primaryStyle.color = widgetColor!.computeTextColor();
    } else {
      primaryStyle.color = page.palette.onBackground;
    }
    buildTextSpan();
    updateListeners(WidgetChange.misc);
  }

  @override
  void updateListeners(WidgetChange change, {
    bool removeGrids = false,
    bool forceSpanResize = false,
    String? historyMessage
  }) {
    buildTextSpan();
    if (forceSpanResize) alterHeightToFit();
    super.updateListeners(change, removeGrids: removeGrids, historyMessage: historyMessage);
  }

  @override
  void loadVariables(Map<String, dynamic> variable) {
    print('Loading variable: $isVariableWidget');
    super.loadVariables(variable);
    print(variable);
    String? newValue = variable['value'];
    if (newValue == text || newValue == null) return;
    editText(text: newValue, logHistory: false);
  }

  @override
  Map<String, dynamic> getVariables() {
    if (variableTextType == null) throw 'Did not declare variable type';
    return {
      ... super.getVariables(),
      'type': 'string',
      // 'value': text,
      'text-type': variableTextType?.name
    };
  }

  @override
  List<String>? getFeatures() => variableTextType != null && variableTextType != _VariableTextType.constant && variableTextType != _VariableTextType.custom ? [variableTextType!.name] : null;

  @override
  Map<String, dynamic> toJSON({
    BuildInfo buildInfo = BuildInfo.unknown
  }) {
    bool isBuildingToUniversal = buildInfo.buildType == BuildType.save;
    double _fontSize = fontSize;
    Size __spanSize = _spanSize;
    double _radius = radius;
    EdgeInsets _padding = padding;
    double _wordSpacing = wordSpacing;
    double _letterSpacing = letterSpacing;
    if (isBuildingToUniversal) {
      _fontSize = page.project.sizeTranslator.getUniversalValue(value: fontSize);
      __spanSize = page.project.sizeTranslator.getUniversalSize(size: _spanSize);
      _radius = page.project.sizeTranslator.getUniversalValue(value: radius);
      _padding = page.project.sizeTranslator.getUniversalPadding(padding: padding);
      _wordSpacing = page.project.sizeTranslator.getUniversalValue(value: wordSpacing);
      _letterSpacing = page.project.sizeTranslator.getUniversalValue(value: letterSpacing);
    }
    return {
      ... super.toJSON(buildInfo: buildInfo),
      'text': {
        'text': text,
        'font': fontFamily,
        'auto-size': autoSize,
        'font-size': _fontSize,
        'line-height': lineHeight
      },
      '_span-size': {
        'width': __spanSize.width,
        'height': __spanSize.height
      },
      'color': {
        'background': textBackground.toHex()
      },
      'primary-style': primaryStyle.toJSON(),
      'secondary-style': secondaryStyle?.toJSON(),
      'widget': {
        'color': widgetColor?.toHex(),
        'radius': _radius,
      },
      'container-provider': containerProvider.toJSON(buildToUniversal: isBuildingToUniversal),
      'alignment': align.index,
      'shadows': shadows != null ? [
        for (Shadow shadow in shadows!) {
          'color': shadow.color.toHex(),
          'offset': {
            'dx': shadow.offset.dx,
            'dy': shadow.offset.dy
          },
          'blur': shadow.blurRadius
        }
      ] : null,
      'padding': _padding.toJSON(),
      'spacing': {
        'word': _wordSpacing,
        'letter': _letterSpacing,
      },
      'variable-type': variableTextType?.name,
    };
  }

  @override
  void buildFromJSON(Map<String, dynamic> json, {
    required BuildInfo buildInfo
  }) {
    super.buildFromJSON(json, buildInfo: buildInfo);
    bool isBuildingFromUniversalBuild = json['properties']['is-universal-build'] ?? false;

    try {
      text = json['text']['text'];
      fontFamily = json['text']['font'];
      lineHeight = json['text']['line-height'];
      autoSize = json['text']['auto-size'];

      fontSize = json['text']['font-size'];
      if (isBuildingFromUniversalBuild) fontSize = page.project.sizeTranslator.getLocalValue(value: fontSize);

      textBackground = HexColor.fromHex(json['color']['background']);

      primaryStyle = CreativeTextStyle.fromJSON(json['primary-style'], widget: this);
      if (json['secondary-style'] != null) secondaryStyle = CreativeTextStyle.fromJSON(json['secondary-style'], widget: this);

      if (json['widget']['color'] != null) widgetColor = HexColor.fromHex(json['widget']['color']);

      radius = json['widget']['radius'];
      if (isBuildingFromUniversalBuild) radius = page.project.sizeTranslator.getLocalValue(value: radius);

      align = TextAlign.values.where((element) => element.index == json['alignment']).first;

      for (final shadowData in json['shadows'] ?? []) {
        if (shadows == null) shadows = [];
        shadows!.add(
          Shadow(
            blurRadius: shadowData['blur'],
            color: HexColor.fromHex(shadowData['color']),
            offset: Offset(shadowData['offset']['dx'], shadowData['offset']['dy'])
          )
        );
      }

      padding = PaddingExtension.fromJSON(Map.from(json['padding']));
      if (isBuildingFromUniversalBuild) padding = page.project.sizeTranslator.getLocalPadding(padding: padding);

      letterSpacing = json['spacing']['letter'];
      if (isBuildingFromUniversalBuild) letterSpacing = page.project.sizeTranslator.getLocalValue(value: letterSpacing);

      wordSpacing = json['spacing']['word'];
      if (isBuildingFromUniversalBuild) wordSpacing = page.project.sizeTranslator.getLocalValue(value: wordSpacing);

      if (json['container-provider'] != null) {
        containerProvider = CreativeContainerProvider.fromJSON(json['container-provider'], widget: this, isBuildingFromUniversal: isBuildingFromUniversalBuild);
      }

      try {
        _spanSize = Size(json['_span-size']['width'], json['_span-size']['height']);
        if (isBuildingFromUniversalBuild) _spanSize = page.project.sizeTranslator.getLocalSize(size: _spanSize);
        buildTextSpan(calculateSize: false);
      } catch (e) {
        buildTextSpan(calculateSize: true);
      }

      if (json['variable-type'] != null) {
        variableTextType = VariableTextTypeExtension.fromName(json['variable-type']);
      }

    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'failed to render text', stacktrace: stacktrace);
      throw WidgetCreationException(
        'Failed to build text widget',
        details: 'Failed to build text widget from JSON: $e',
      );
    }
  }

}

class CreativeTextStyle {

  bool bold = false;
  bool italics = false;
  bool underline = false;
  bool strikethrough = false;
  bool overline = false;

  Paint? stroke;

  late Color color;

  final CreatorWidget widget;
  CreativeTextStyle({required this.widget}) {
    color = widget.page.palette.onBackground;
  }

  factory CreativeTextStyle.fromTextStyle(TextStyle style, {
    required CreatorWidget widget,
  }) {
    CreativeTextStyle creativeTextStyle = CreativeTextStyle(
      widget: widget,
    );
    creativeTextStyle.bold = style.fontWeight == FontWeight.bold;
    creativeTextStyle.italics = style.fontStyle == FontStyle.italic;
    creativeTextStyle.underline = style.decoration?.contains(TextDecoration.underline) ?? false;
    creativeTextStyle.strikethrough = style.decoration?.contains(TextDecoration.lineThrough) ?? false;
    creativeTextStyle.overline = style.decoration?.contains(TextDecoration.overline) ?? false;
    creativeTextStyle.color = style.color ?? widget.page.palette.onBackground;
    return creativeTextStyle;
  }

  factory CreativeTextStyle.fromJSON(Map data, {
    required CreatorWidget widget
  }) {
    final style = CreativeTextStyle(widget: widget);
    style.bold = data['bold'];
    style.italics = data['italics'];
    style.underline = data['underline'];
    style.strikethrough = data['strikethrough'];
    style.overline = data['overline'];
    style.color = HexColor.fromHex(data['color']);
    return style;
  }

  Map<String, dynamic> toJSON() => {
    'bold': bold,
    'italics': italics,
    'underline': underline,
    'strikethrough': strikethrough,
    'overline': overline,
    'color': color.toHex(),
  };

  void _updateStroke([bool isToggling = false]) {
    if ((isToggling && stroke == null) || (!isToggling && stroke != null)) {
      stroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = bold ? 2 : 1
        ..color = color;
    } else if (isToggling && stroke != null) {
      stroke = null;
    }
  }

  void addStroke() {
    _updateStroke(true);
  }

  void refresh() {
    _updateStroke();
    color = widget.page.palette.onBackground;
  }

  TextStyle style({
    required String font,
    TextDecorationStyle? decorationStyle,
    List<Shadow>? shadows,
    double? lineHeight,
    double? wordSpacing,
    double? letterSpacing,
    double? fontSize,
  }) => GoogleFonts.getFont(font).copyWith(
    fontWeight: bold ? (stroke != null ? FontWeight.normal : FontWeight.bold) : FontWeight.normal,
    decoration: TextDecoration.combine([
      if (underline) TextDecoration.underline,
      if (strikethrough) TextDecoration.lineThrough,
      if (overline) TextDecoration.overline,
    ]),
    fontStyle: italics ? FontStyle.italic : FontStyle.normal,
    color: stroke == null ? color : null,
    fontSize: fontSize,
    letterSpacing: letterSpacing,
    wordSpacing: wordSpacing,
    fontFeatures: [ ],
    shadows: [
      if (shadows != null) ... shadows
    ],
    foreground: stroke,
    decorationStyle: decorationStyle,
    decorationColor: stroke == null ? color : null,
    height: lineHeight,
  );

  List<Option> getOptions({
    bool showColor = true,
    bool allowColorOpacity = true,
    bool showBold = true,
    bool showItalics = true,
    bool showUnderline = true,
    bool showStrikethrough = true,
    bool showOverline = true,
  }) => [
    if (showColor) Option.color(
      widget,
      tooltip: 'Tap to select text color',
      palette: widget.page.palette,
      selected: color,
      allowOpacity: allowColorOpacity,
      allowClear: false,
      onChange: (_color) {
        if (_color == null) return;
        this.color = _color;
        if (stroke != null) _updateStroke();
        widget.updateListeners(WidgetChange.misc);
      },
      onChangeEnd: (color) {
        widget.updateListeners(WidgetChange.update);
      },
    ),
    if (showBold) Option.toggle(
      title: 'Bold',
      value: bold,
      onChange: (value) {
        bold = value;
        _updateStroke();
        widget.updateListeners(WidgetChange.update);
      },
      enabledIcon: RenderIcons.bold,
      disabledIcon: RenderIcons.bold,
      disabledTooltip: 'Add bold formatting',
      enabledTooltip: 'Remove bold formatting',
    ),
    if (showItalics) Option.toggle(
      title: 'Italics',
      value: italics,
      onChange: (value) {
        italics = value;
        widget.updateListeners(WidgetChange.update);
      },
      disabledIcon: RenderIcons.italic,
      enabledIcon: RenderIcons.italic,
      disabledTooltip: 'Add italics formatting',
      enabledTooltip: 'Remove italics formatting',
    ),
    if (showUnderline) Option.toggle(
      title: 'Underline',
      value: underline,
      onChange: (value) {
        underline = value;
        widget.updateListeners(WidgetChange.update);
      },
      disabledIcon: RenderIcons.underline,
      enabledIcon: RenderIcons.underline,
      disabledTooltip: 'Add underline formatting',
      enabledTooltip: 'Remove underline formatting',
    ),
    if (showStrikethrough) Option.toggle(
      title: 'Strikethrough',
      value: strikethrough,
      onChange: (value) {
        strikethrough = value;
        widget.updateListeners(WidgetChange.update);
      },
      disabledIcon: RenderIcons.strike,
      enabledIcon: RenderIcons.strike,
      disabledTooltip: 'Add strikethrough formatting',
      enabledTooltip: 'Remove strikethrough formatting',
    ),
    if (showOverline) Option.toggle(
      title: 'Overline',
      value: overline,
      onChange: (value) {
        overline = value;
        widget.updateListeners(WidgetChange.update);
      },
      disabledIcon: RenderIcons.overline,
      enabledIcon: RenderIcons.overline,
      disabledTooltip: 'Add overline formatting',
      enabledTooltip: 'Remove overline formatting',
    ),
  ];

}

class CreativeTextWidget extends StatelessWidget {

  const CreativeTextWidget(this.span, {
    super.key,
    this.style,
    this.secondaryStyle,
    this.textAlign = TextAlign.center,
    this.strutStyle,
    this.textDirection,
    this.locale,
    this.softWrap = true,
    this.maxLines,
    this.semanticsLabel,
    this.overflow = TextOverflow.visible,
    this.textHeightBehavior
  });

  final TextSpan span;
  final TextStyle? style;
  final TextStyle? secondaryStyle;
  final TextAlign? textAlign;
  final StrutStyle? strutStyle;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final int? maxLines;
  final String? semanticsLabel;
  final TextOverflow overflow;
  final TextHeightBehavior? textHeightBehavior;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      span,
      textAlign: textAlign ?? TextAlign.center,
      strutStyle: strutStyle,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap ?? true,
      overflow: overflow,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textHeightBehavior: textHeightBehavior,
    );
  }

}

Size calculateSizeForTextStyle(String text, {
  TextStyle? style,
  required CreatorPage page,
  double? maxWidth,
}) {
  final span = TextSpan(
    style: style,
    text: text,
  );
  final words = span.toPlainText().split(RegExp('\\s+'));
  final TextPainter textPainter = TextPainter(
    text: span,
    textAlign: TextAlign.left,
    maxLines: words.length,
    textDirection: TextDirection.ltr,
  ) ..layout(minWidth: 0, maxWidth: maxWidth ?? page.project.contentSize.width - 20);
  return textPainter.size;
}

enum _VariableTextType {
  heading,
  subtitle,
  body,
  caption,
  callout,
  callToAction,
  hashTag,
  date,
  pageNumber,
  footer,
  emoji,
  constant,
  custom,
}

extension VariableTextTypeExtension on _VariableTextType {

  String get name {
    switch (this) {
      case _VariableTextType.heading:
        return 'heading';
      case _VariableTextType.subtitle:
        return 'subtitle';
      case _VariableTextType.body:
        return 'body';
      case _VariableTextType.caption:
        return 'caption';
      case _VariableTextType.callout:
        return 'callout';
      case _VariableTextType.callToAction:
        return 'call-to-action';
      case _VariableTextType.hashTag:
        return 'hash-tag';
      case _VariableTextType.date:
        return 'date';
      case _VariableTextType.pageNumber:
        return 'page-number';
      case _VariableTextType.footer:
        return 'footer';
      case _VariableTextType.emoji:
        return 'emoji';
      case _VariableTextType.constant:
        return 'constant';
      case _VariableTextType.custom:
        return 'custom';
    }
  }

  String get title {
    switch (this) {
      case _VariableTextType.heading:
        return 'Heading';
      case _VariableTextType.subtitle:
        return 'Subtitle';
      case _VariableTextType.body:
        return 'Body';
      case _VariableTextType.caption:
        return 'Caption';
      case _VariableTextType.callout:
        return 'Callout';
      case _VariableTextType.callToAction:
        return 'Call to Action';
      case _VariableTextType.hashTag:
        return 'Hash Tag';
      case _VariableTextType.date:
        return 'Date';
      case _VariableTextType.pageNumber:
        return 'Page Number';
      case _VariableTextType.footer:
        return 'Footer';
      case _VariableTextType.emoji:
        return 'Emoji';
      case _VariableTextType.constant:
        return 'Constant';
      case _VariableTextType.custom:
        return 'Custom';
    }
  }

  static _VariableTextType? fromName(String name) {
    switch (name) {
      case 'heading':
        return _VariableTextType.heading;
      case 'subtitle':
        return _VariableTextType.subtitle;
      case 'body':
        return _VariableTextType.body;
      case 'caption':
        return _VariableTextType.caption;
      case 'callout':
        return _VariableTextType.callout;
      case 'call-to-action':
        return _VariableTextType.callToAction;
      case 'hash-tag':
        return _VariableTextType.hashTag;
      case 'date':
        return _VariableTextType.date;
      case 'page-number':
        return _VariableTextType.pageNumber;
      case 'footer':
        return _VariableTextType.footer;
      case 'emoji':
        return _VariableTextType.emoji;
      case 'constant':
        return _VariableTextType.constant;
      case 'custom':
        return _VariableTextType.custom;
      default:
        return null;
    }
  }

  String? get prompt {
    switch (this) {
      case _VariableTextType.heading:
        return 'Generate a catchy headline that will grab the attention of your audience. It should be short and straight to the point. Make sure the headline is relevant to the content and is between 5 to 10 words.';
      case _VariableTextType.subtitle:
        return 'Create a subtitle that will give more context to the headline. It should be a bit longer than the headline and should be between 10 to 20 words.';
      case _VariableTextType.body:
        return 'Write the main content of the page. It should be about 30 words and should be informative and engaging. Make sure the content is relevant to the subject of the post.';
      case _VariableTextType.caption:
        return 'Write a caption that will give context to the prompt. It should be short and straight to the point. Make sure the caption is relevant to the content and is between 5 to 10 words.';
      case _VariableTextType.callout:
        return 'Write a callout text for the post. It should be short and straight to the point. Make sure the callout is relevant to the content and is between 2 to 5 words.';
      case _VariableTextType.callToAction:
        return 'Write a call to action text for the post. It should be short and straight to the point. Make sure the call to action is relevant to the content and is between 1 to 5 words.';
      case _VariableTextType.hashTag:
        return 'Write a hashtag for the post. It should be short and straight to the point. Make sure the hashtag is relevant to the content. You can use multiple hashtags separated by a space.';
      case _VariableTextType.date:
        return 'Write the date for the post. It should be in the format of "Month Day, Year". For example, "January 1, 2022". If there\'s no specific date, you can use the current date.';
      case _VariableTextType.pageNumber:
        return 'Write the page number for the post. It should be a number and should be relevant to the content. Only provide a number without any other text.';
      case _VariableTextType.footer:
        return 'Write the footer text for the post. It should be short and straight to the point. Make sure the footer text is relevant to the content and is between 3 to 7 words.';
      case _VariableTextType.emoji:
        return 'Come up with an emoji that will give more context to the content. It should be relevant to the content and should be a single emoji.';
      case _VariableTextType.constant:
        return null;
      case _VariableTextType.custom:
        return null;
    }
  }
}