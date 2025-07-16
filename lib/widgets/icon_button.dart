import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../rehmat.dart';

// Use a standard IconButton with specific style to implement the
// 'Filled' toggle button.
class FilledIconButton extends StatefulWidget {

  const FilledIconButton({
    super.key,
    this.selected = false,
    required this.onPressed,
    required this.icon,
    this.selectedIcon,
    this.tooltip
  });

  final bool selected;
  final void Function() onPressed;
  final Icon icon;
  final Icon? selectedIcon;
  final String? tooltip;

  @override
  State<FilledIconButton> createState() => _FilledIconButtonState();
}

class _FilledIconButtonState extends State<FilledIconButton> {

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Palette.of(context);

    return IconButton(
      isSelected: widget.selected,
      icon: widget.icon,
      selectedIcon: widget.selectedIcon,
      onPressed: widget.onPressed,
      tooltip: widget.tooltip,
      style: IconButton.styleFrom(
        foregroundColor: widget.selected ? colors.onPrimary : colors.primary,
        backgroundColor: widget.selected ? colors.primary : colors.surfaceContainerLow,
        hoverColor: widget.selected ? colors.onPrimary.withValues(alpha: 0.08) : colors.primary.withValues(alpha: 0.08),
        focusColor: widget.selected ? colors.onPrimary.withValues(alpha: 0.12) : colors.primary.withValues(alpha: 0.12),
        highlightColor: widget.selected ? colors.onPrimary.withValues(alpha: 0.12) : colors.primary.withValues(alpha: 0.12),
      )
    );
  }
}

// Use a standard IconButton with specific style to implement the
// 'Filled Tonal' toggle button.
class FilledTonalIconButton extends StatefulWidget {

  const FilledTonalIconButton({
    super.key,
    this.selected = false,
    required this.onPressed,
    required this.icon,
    this.selectedIcon,
    this.tooltip,
    this.padding = const EdgeInsets.all(8.0),
    this.secondary = false
  });

  final bool selected;
  final void Function() onPressed;
  final Icon icon;
  final Icon? selectedIcon;
  final String? tooltip;
  final EdgeInsetsGeometry padding;
  final bool secondary;

  @override
  State<FilledTonalIconButton> createState() => _FilledTonalIconButtonState();
}

class _FilledTonalIconButtonState extends State<FilledTonalIconButton> {

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Palette.of(context);

    return IconButton(
      isSelected: widget.selected,
      icon: widget.icon,
      selectedIcon: widget.selectedIcon,
      onPressed: widget.onPressed,
      tooltip: widget.tooltip,
      padding: widget.padding,
      style: IconButton.styleFrom(
        foregroundColor: widget.selected ? colors.onPrimaryContainer : (widget.secondary ? colors.onSurface : colors.onSurfaceVariant),
        backgroundColor: widget.selected ? colors.primaryContainer : (widget.secondary ? colors.surface : colors.surfaceContainerLow),
        hoverColor: (widget.selected ? colors.onPrimaryContainer : (widget.secondary ? colors.onSurface : colors.onSurfaceVariant).withValues(alpha: 0.08)).withValues(alpha: 0.08),
        focusColor: (widget.selected ? colors.onPrimaryContainer : (widget.secondary ? colors.onSurface : colors.onSurfaceVariant).withValues(alpha: 0.08)).withValues(alpha: 0.08),
        highlightColor: (widget.selected ? colors.onPrimaryContainer : (widget.secondary ? colors.onSurface : colors.onSurfaceVariant).withValues(alpha: 0.08)).withValues(alpha: 0.08),
      ),
    );
  }
}

class OutlinedIconButtons extends StatefulWidget {

  const OutlinedIconButtons({
    super.key,
    this.selected = false,
    this.onPressed,
    required this.icon,
    this.selectedIcon,
    this.tooltip
  });

  final bool selected;
  final void Function()? onPressed;
  final Icon icon;
  final Icon? selectedIcon;
  final String? tooltip;

  @override
  State<OutlinedIconButtons> createState() => _OutlinedIconButtonsState();
}

// Use a standard IconButton with specific style to implement the
// 'Outlined' toggle button.
class _OutlinedIconButtonsState extends State<OutlinedIconButtons> {

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Palette.of(context);

    return IconButton(
      isSelected: widget.selected,
      icon: widget.icon,
      selectedIcon: widget.selectedIcon,
      onPressed: widget.onPressed,
      tooltip: widget.tooltip,
      style: IconButton.styleFrom(
        backgroundColor: widget.selected ? colors.inverseSurface : null,
        hoverColor: widget.selected ? colors.onInverseSurface.withValues(alpha: 0.08) : colors.onSurfaceVariant.withValues(alpha: 0.08),
        focusColor: widget.selected ? colors.onInverseSurface.withValues(alpha: 0.12) : colors.onSurfaceVariant.withValues(alpha: 0.12),
        highlightColor: widget.selected ? colors.onInverseSurface.withValues(alpha: 0.12) : colors.onSurface.withValues(alpha: 0.12),
        side: BorderSide(
          color: colors.outline,
          width: 0
        ),
      ).copyWith(
        foregroundColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return colors.onInverseSurface;
          }
          if (states.contains(WidgetState.pressed)) {
            return colors.onSurface;
          }
          return null;
        }),
      ),
    );
  }
}

class NewBackButton extends StatefulWidget {

  NewBackButton({
    Key? key,
    this.confirm = false,
    this.confirmMessage,
    this.confirmTitle,
    this.size,
    this.data,
    this.icon,
    this.secondary = false
  }) : super(key: key);

  final bool confirm;
  final String? confirmTitle;
  final String? confirmMessage;
  final double? size;
  final dynamic data;
  final IconData? icon;
  final bool secondary;

  @override
  State<NewBackButton> createState() => _NewBackButtonState();
}

class _NewBackButtonState extends State<NewBackButton> {

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(widget.icon ?? CupertinoIcons.arrow_turn_up_left),
      onPressed: onBack,
      // secondary: widget.secondary,
    );
  }

  Future<void> onBack() async {
    if (widget.confirm) {
      if (await Alerts.showConfirmationDialog(context, title: widget.confirmTitle ?? 'Do you want to go back?', message: widget.confirmMessage ?? 'Any unsaved changes will be discarded. This cannot be undone.', cancelButtonText: 'Cancel', confirmButtonText: 'Discard', isDestructive: true)) Navigator.of(context).pop(widget.data);
    }
    else Navigator.of(context).pop(widget.data);
  }

}

class ColorSelector extends StatefulWidget {

  const ColorSelector({
    Key? key,
    this.title,
    required this.widget,
    required this.onColorSelect,
    required this.color,
    this.onColorSelectEnd,
    this.size,
    this.borderWidth = 5,
    this.reverseOrder = false,
    this.palette,
    this.allowOpacity = true
  }) : super(key: key);

  final CreatorWidget widget;
  final String? title;
  final Function(Color color) onColorSelect;
  final Function(Color? color)? onColorSelectEnd;
  final Color color;
  final bool reverseOrder;
  final ColorPalette? palette;
  final bool allowOpacity;

  final Size? size;
  final double borderWidth;

  @override
  _ColorSelectorState createState() => _ColorSelectorState();
}

class _ColorSelectorState extends State<ColorSelector> {

  late Color color;

  @override
  void initState() {
    color = widget.color;
    super.initState();
  }
  
  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    } else {
      fn();
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = widget.size ?? Size(60, 60);
    return GestureDetector(
      onTap: () async {
        TapFeedback.light();
        widget.widget.page.editorManager.openModal(
          tab: (context, setState) => EditorTab.color(
            context,
            palette: widget.palette,
            allowOpacity: widget.allowOpacity,
            selected: color,
            onChange: (_color) {
              color = _color;
              widget.onColorSelect(_color);
            },
          ),
          onDismiss: () {
            setState(() { });
          }
        );
      },
      child: SizedBox.fromSize(
        size: size,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: color,
              width: 2
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 5,
                spreadRadius: 1,
                offset: Offset(0, 2)
              )
            ]
          ),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ),
      ),
    );
  }

}

class ButtonWithIcon extends StatefulWidget {

  const ButtonWithIcon({
    Key? key,
    this.title,
    required this.onTap,
    this.onLongPress,
    this.child,
    this.icon,
    this.tooltip,
    this.borderRadius = 70,
    this.feedbackBorderRadius = 5,
    this.size,
    this.greyOut = false,
    this.backgroundColor,
    this.foregroundColor,
    this.showBorder = true,
    this.animateBorderRadius = true
  }) : super(key: key);

  final String? title;
  final Function(BuildContext context) onTap;
  final Function(BuildContext context)? onLongPress;
  final IconData? icon;
  final Widget? child;
  final String? tooltip;

  final Size? size;
  final double borderRadius;
  final double feedbackBorderRadius;

  final Color? backgroundColor;
  final Color? foregroundColor;

  final bool showBorder;

  final bool animateBorderRadius;

  /// Setting this to `true` will make the icon look grey, showing the button is disabled or the value is turned off
  final bool greyOut;

  // static double calculateHeight(BuildContext context) 

  @override
  _ButtonWithIconState createState() => _ButtonWithIconState();
}

class _ButtonWithIconState extends State<ButtonWithIcon> {

  double scale = 1;

  @override
  void initState() {
    super.initState();
  }
  
  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    } else {
      fn();
    }
  }

  @override
  Widget build(BuildContext context) {
    return tooltip(
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onPanDown: (details) => reduceScale(),
              onTapDown: (details) => reduceScale(),
              onPanCancel: () => resetScale(),
              onTapUp: (details) => resetScale(),
              onTapCancel: () => resetScale(),
              onLongPress: () {
                if (widget.onLongPress != null) widget.onLongPress!(context);
              },
              onTap: () {
                reduceScale();
                TapFeedback.tap();
                widget.onTap(context);
                Future.delayed(const Duration(milliseconds: 300), () => resetScale());
              },
              child: AnimatedScale(
                duration: Duration(milliseconds: 100),
                scale: scale,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  height: widget.size?.height ?? 70,
                  width: widget.size?.width ?? 70,
                  decoration: BoxDecoration(
                    color: widget.backgroundColor ?? Palette.of(context).surfaceContainerLow,
                    // color: widget.backgroundColor ?? Constants.getThemedObject(context, light: Color.lerp(HexColor.fromHex('#fafafa'), Palette.of(context).primaryContainer, 0.2), dark: Colors.grey[900]),
                    // color: context.isDarkMode ? Colors.grey[900] : null,
                    // gradient: context.isDarkMode ? null : LinearGradient(
                    //   begin: Alignment.topLeft,
                    //   end: Alignment.bottomRight,
                    //   colors: [
                    //     Color.lerp(HexColor.fromHex('#fafafa'), Palette.of(context).primaryContainer, 0.1) ?? Colors.white,
                    //     Color.lerp(HexColor.fromHex('#fafafa'), Palette.of(context).primaryContainer, 0.3) ?? Colors.white
                    //   ]
                    // ),
                    border: widget.showBorder ? Border.all(
                      color: Constants.getThemedObject(context, light: Palette.of(context).outline, dark: Colors.grey[800]!),
                      width: 1,
                    ) : null,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.black.withValues(alpha: 0.1),
                    //     blurRadius: 2,
                    //     offset: Offset(0, 1)
                    //   )
                    // ]
                  ),
                  child: Center(
                    child: widget.child ?? Icon(
                      widget.icon,
                      color: widget.greyOut ? Colors.grey[700] : (widget.foregroundColor ?? Palette.of(context).onSurface)
                    ),
                  ),
                ),
              ),
            ),
            if (widget.title != null) ... [
              Container(height: 6,),
              SizedBox(
                height: calculateTextHeight(),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    widget.title!,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      fontFamily: 'Geist',
                      height: 1.2,
                    ),
                    overflow: TextOverflow.visible,
                    maxLines: 2,
                    softWrap: true,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget tooltip({required Widget child}) {
    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip!,
        child: child,
      );
    } else {
      return child;
    }
  }

  void reduceScale() {
    if (widget.animateBorderRadius) setState(() => scale = 0.95);
  }

  void resetScale() {
    if (widget.animateBorderRadius) setState(() => scale = 1);
  }

  double calculateTextHeight() {
    if (widget.title != null) {
      return (Theme.of(context).textTheme.bodySmall!.fontSize! * 1.2 * 2);
    } else {
      return 0;
    }
  }

}

double getButtonWithIconHeight(BuildContext context) {
  return (Theme.of(context).textTheme.bodySmall!.fontSize! * 1.2 * 2) + 6 + 70;
}

class ToggleIconButton extends StatefulWidget {

  ToggleIconButton({
    Key? key,
    required this.title,
    this.disabledTitle,
    required this.value,
    required this.enabledIcon,
    required this.disabledIcon,
    required this.onChange,
    this.enabledTooltip,
    this.disabledTooltip,
  }) : super(key: key);

  final bool value;
  final String title;
  final String? disabledTitle;
  final IconData enabledIcon;
  final IconData disabledIcon;
  final void Function(bool value) onChange;
  final String? enabledTooltip;
  final String? disabledTooltip;

  @override
  State<ToggleIconButton> createState() => _ToggleIconButton();
}

class _ToggleIconButton extends State<ToggleIconButton> {

  late IconData enabledIcon;
  late IconData disabledIcon;
  late void Function(bool value) onChange;

  @override
  void initState() {
    enabledIcon = widget.enabledIcon;
    disabledIcon = widget.disabledIcon;
    onChange = widget.onChange;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ButtonWithIcon(
      icon: widget.value ? enabledIcon : disabledIcon,
      onTap: (context) {
        onChange(!widget.value);
      },
      tooltip: (widget.value ? widget.enabledTooltip : widget.disabledTooltip) ?? 'Toggle',
      title: widget.value ? widget.title : widget.disabledTitle ?? widget.title,
    );
  }

}

class DragHandler extends StatefulWidget {

  DragHandler({
    Key? key,
    this.onPositionUpdate,
    this.onPositionUpdateEnd,
    this.backgroundColor,
    this.iconColor,
  }) : super(key: key);

  final void Function(DragUpdateDetails)? onPositionUpdate;
  final void Function(DragEndDetails)? onPositionUpdateEnd;
  final Color? backgroundColor;
  final Color? iconColor;

  @override
  State<DragHandler> createState() => _DragHandlerState();
}

class _DragHandlerState extends State<DragHandler> {

  bool isHovering = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onPanDown: (details) => setState(() => isHovering = true),
      // onPanCancel: () => setState(() => isHovering = false),
      onPanStart: (details) => setState(() => isHovering = true),
      onPanUpdate: (details) {
        if (widget.onPositionUpdate != null) widget.onPositionUpdate!(details);
      },
      onPanEnd: (details) {
        if (isHovering) setState(() => isHovering = false);
        if (widget.onPositionUpdateEnd != null) widget.onPositionUpdateEnd!(details);
      },
      child: AnimatedContainer(
        duration: Constants.animationDuration,
        height: isHovering ? 35 : 25,
        width: isHovering ? 35 : 25,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? Palette.of(context).surface,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: (widget.iconColor ?? Palette.of(context).onSurface).withValues(alpha: 0.1),
              blurRadius: 5,
              spreadRadius: 1,
            )
          ]
        ),
        child: Center(
          child: Icon(
            RenderIcons.drag,
            size: 18,
            color: widget.iconColor ?? Palette.of(context).onSurface,
          ),
        ),
      ),
    );
  }

}