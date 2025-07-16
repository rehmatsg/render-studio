import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'package:sprung/sprung.dart';
import 'package:universal_io/io.dart';
import '../rehmat.dart';

class TextIconButton extends StatefulWidget {

  const TextIconButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.color,
    this.padding
  }) : super(key: key);

  final String text;

  final IconData icon;

  final Color? color;
  final EdgeInsetsGeometry? padding;

  final Function() onPressed;

  @override
  _TextIconButtonState createState() => _TextIconButtonState();
}

class _TextIconButtonState extends State<TextIconButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: Constants.borderRadius,
      onTap: widget.onPressed,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: Constants.borderRadius,
          color: widget.color ?? Palette.of(context).surfaceContainerLow,
          border: Border.all(
            color: Palette.of(context).onSurfaceVariant.withValues(alpha: 0.2),
            width: 0
          )
        ),
        child: Padding(
          padding: widget.padding ?? EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: Palette.of(context).onSecondaryContainer
              ),
              Container(width: 5,),
              Text(
                widget.text,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Palette.of(context).onSurfaceVariant
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class BlurredIconButton extends StatelessWidget {

  const BlurredIconButton({
    super.key,
    required this.icon,
    this.onPressed
  });

  final IconData icon;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        TapFeedback.light();
        onPressed?.call();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Palette.blurBackground(context),
            padding: EdgeInsets.all(10),
            child: Icon(
              icon,
              color: Palette.onBlurBackground(context),
            ),
          ),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatefulWidget {

  PrimaryButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.feedback = true,
    this.disabled = false,
    /// If true, the button will show a loading indicator when pressed until the onPressed function finishes
    this.autoLoading = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
    this.borderRadius = 40
  }) : super(key: key);

  final Widget child;
  final Function()? onPressed;
  final Function()? onLongPress;
  final bool feedback;
  final bool disabled;
  final bool autoLoading;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {

  @override
  Widget build(BuildContext context) {
    return RawButton(
      child: widget.child,
      autoLoading: widget.autoLoading,
      disabled: widget.disabled,
      feedback: widget.feedback,
      onLongPress: widget.onLongPress,
      onPressed: widget.onPressed,
      backgroundColor: Palette.of(context).onSurface,
      textColor: Palette.of(context).surface,
      padding: widget.padding,
      borderRadius: widget.borderRadius,
    );
  }

}

class SecondaryButton extends StatefulWidget {

  SecondaryButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.feedback = true,
    this.disabled = false,
    /// If true, the button will show a loading indicator when pressed until the onPressed function finishes
    this.autoLoading = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
    this.borderRadius = 40
  }) : super(key: key);

  final Widget child;
  final Function()? onPressed;
  final Function()? onLongPress;
  final bool feedback;
  final bool disabled;
  final bool autoLoading;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();

}

class _SecondaryButtonState extends State<SecondaryButton> {

  @override
  Widget build(BuildContext context) {
    return RawButton(
      child: widget.child,
      autoLoading: widget.autoLoading,
      disabled: widget.disabled,
      feedback: widget.feedback,
      onLongPress: widget.onLongPress,
      onPressed: widget.onPressed,
      border: BorderSide(
        color: Palette.isDark(context) ? Colors.grey.shade800 : Colors.grey.shade400,
        width: 1
      ),
      backgroundColor: Palette.of(context).surfaceContainerLow,
      textColor: Palette.of(context).onSurfaceVariant,
      padding: widget.padding,
    );
  }

}

class Button extends StatefulWidget {

  Button({
    Key? key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.feedback = true,
    this.disabled = false,
    /// If true, the button will show a loading indicator when pressed until the onPressed function finishes
    this.autoLoading = false,
    this.backgroundColor,
    this.textColor,
    this.shadow,
    this.border,
    this.borderRadius = 40,
    this.padding
  }) : super(key: key);

  final Widget child;
  final Function()? onPressed;
  final Function()? onLongPress;
  final bool feedback;
  final bool disabled;
  final bool autoLoading;

  final Color? backgroundColor;
  final Color? textColor;
  final BoxShadow? shadow;
  final BorderSide? border;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  @override
  State<Button> createState() => _ButtonState();
  
}

class _ButtonState extends State<Button> {

  @override
  Widget build(BuildContext context) {
    return RawButton(
      child: widget.child,
      autoLoading: widget.autoLoading,
      disabled: widget.disabled,
      feedback: widget.feedback,
      onLongPress: widget.onLongPress,
      onPressed: widget.onPressed,
      backgroundColor: widget.backgroundColor ?? Palette.of(context).surfaceContainerLow,
      textColor: widget.textColor ?? Palette.of(context).onSurfaceVariant,
      shadow: widget.shadow,
      border: widget.border,
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
    );
  }

}

class RawButton extends StatefulWidget {

  const RawButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.feedback = true,
    this.disabled = false,
    required this.backgroundColor,
    required this.textColor,
    this.border,
    this.autoLoading = false,
    this.shadow,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
    this.borderRadius = 40
  }) : super(key: key);

  final Widget child;
  final Function()? onPressed;
  final Function()? onLongPress;
  final bool feedback;
  final bool disabled;
  final Color backgroundColor;
  final Color textColor;
  final BorderSide? border;
  final bool autoLoading;
  final BoxShadow? shadow;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  State<RawButton> createState() => RawButtonState();
}

class RawButtonState extends State<RawButton> {

  bool isLoading = false;

  double scale = 1;
  
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
    TextStyle? textStyle = Theme.of(context).textTheme.titleLarge;
    return GestureDetector(
      onPanDown: (details) => reduceRadius(),
      onTapDown: (details) => reduceRadius(),
      onPanCancel: () => resetRadius(),
      onTapUp: (details) => resetRadius(),
      onTapCancel: () => resetRadius(),
      onTap: widget.onPressed != null ? () {
        TapFeedback.tap();
        onPressed();
      } : null,
      child: AnimatedScale(
        duration: kAnimationDuration,
        scale: scale,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 500),
          curve: Sprung.criticallyDamped,
          // decoration: BoxDecoration(
          //   color: widget.backgroundColor,
          //   borderRadius: BorderRadius.circular(radius),
          //   border: Border.fromBorderSide(widget.border ?? BorderSide.none),
          // ),
          decoration: ShapeDecoration(
            shape: SmoothRectangleBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              smoothness: 0.6,
              side: widget.border?.copyWith(
                color: widget.border?.color.withValues(alpha: widget.disabled ? 0.5 : 1)
              ) ?? BorderSide.none
            ),
            color: widget.backgroundColor.a == 0 ? widget.backgroundColor : widget.backgroundColor.withValues(alpha: widget.disabled ? 0.5 : 1),
          ),
          padding: widget.padding,
          child: DefaultTextStyle(
            style: textStyle!.copyWith(
              color: widget.textColor,
              fontSize: 19,
              fontFamily: 'SF Pro Rounded',
              fontWeight: FontWeight.w500,
              height: 1,
            ),
            textAlign: TextAlign.center,
            child: isLoading ? SizedBox(
              height: 19,
              width: 19,
              child: Spinner(
                valueColor: widget.textColor,
                strokeWidth: 2,
              )
            ) : widget.child,
          ),
        ),
      ),
    );
  }

  void reduceRadius() => setState(() => scale = 0.95);

  void resetRadius() => setState(() => scale = 1);

  Future<void> onPressed() async {
    if (widget.onPressed == null || isLoading) return;
    if (widget.autoLoading) setState(() => isLoading = true);
    await widget.onPressed!();
    if (widget.autoLoading) setState(() => isLoading = false);
  }

}

class InkWellButton extends StatelessWidget {

  const InkWellButton({
    super.key,
    required this.child,
    this.radius,
    this.backgroundColor,
    this.onTap
  });

  final Widget child;
  final BorderRadius? radius;
  final Color? backgroundColor;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.transparent
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: child
        ),
      ),
    );
  }

}

class RenderDropdownButton<T> extends StatefulWidget {

  const RenderDropdownButton({super.key, required this.items, this.value, this.onChanged});

  final List<RenderDropdownMenuItem<T>> items;

  final T? value;

  final Function(T?)? onChanged;

  @override
  State<RenderDropdownButton<T>> createState() => _RenderDropdownButtonState<T>();
}

class _RenderDropdownButtonState<T> extends State<RenderDropdownButton<T>> {

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      List<DropdownMenuItem<T>> items = widget.items.map<DropdownMenuItem<T>>((e) => e.toDropdownMenuItem()).toList();
      return DropdownButton<T>(
        items: items,
        value: widget.value,
        onChanged: widget.onChanged,
        elevation: 2,
        borderRadius: BorderRadius.circular(8),
        icon: Icon(
          RenderIcons.arrow_down,
          size: 18,
        ),
        enableFeedback: true,
        underline: Container(),
        dropdownColor: Palette.of(context).surfaceContainerLow,
      );
    } else {
      return _IOSRenderDropdownButton<T>(
        items: widget.items,
        value: widget.value,
        onChanged: widget.onChanged,
      );
    }
  }

}

class _IOSRenderDropdownButton<T> extends StatefulWidget {

  const _IOSRenderDropdownButton({super.key, required this.items, this.value, this.onChanged});

  final List<RenderDropdownMenuItem<T>> items;

  final T? value;

  final Function(T?)? onChanged;

  @override
  State<_IOSRenderDropdownButton<T>> createState() => _IOSRenderDropdownButtonState<T>();
}

class _IOSRenderDropdownButtonState<T> extends State<_IOSRenderDropdownButton<T>> {

  late T? value;

  late List<RenderDropdownMenuItem<T>> items;

  @override
  void initState() {
    super.initState();
    value = widget.value;
    items = widget.items;
  }

  @override
  void didUpdateWidget(covariant _IOSRenderDropdownButton<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      setState(() {
        value = widget.value;
      });
    }
    if (oldWidget.items != widget.items) {
      setState(() {
        items = widget.items;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    RenderDropdownMenuItem? selected;
    if (value != null) selected = items.firstWhereOrNull((e) => e.value == value);

    return Container(
      child: PullDownButton(
        itemBuilder: (context) => items.map((e) => PullDownMenuItem.selectable(
          title: e.title,
          enabled: e.enabled,
          selected: e.value == value,
          onTap: () {
            if (e.onTap != null) e.onTap!();
            if (widget.onChanged != null) widget.onChanged!(e.value);
            setState(() {
              value = e.value;
            });
          },
        )).toList(),
        buttonBuilder: (context, showMenu) => AnimatedSize(
          duration: kAnimationDuration,
          child: RawButton(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: Text(
                    selected?.title ?? 'Select',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Palette.of(context).onSurfaceVariant
                    ),
                  ),
                ),
                Icon(
                  RenderIcons.arrow_down,
                  color: Palette.of(context).onSurfaceVariant,
                  size: Theme.of(context).textTheme.labelLarge?.fontSize,
                )
              ],
            ),
            backgroundColor: Palette.of(context).surfaceContainerLow,
            textColor: Palette.of(context).onSurfaceVariant,
            onPressed: showMenu,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        )
      )
    );
  }

}

class RenderDropdownMenuItem<T> {
  /// Creates an item for a dropdown menu.
  ///
  /// The [child] argument is required.
  const RenderDropdownMenuItem({
    this.key,
    required this.title,
    this.onTap,
    this.value,
    this.enabled = true,
  });

  final Key? key;

  final String title;

  /// Called when the dropdown menu item is tapped.
  final VoidCallback? onTap;

  /// The value to return if the user selects this menu item.
  ///
  /// Eventually returned in a call to [DropdownButton.onChanged].
  final T? value;

  /// Whether or not a user can select this menu item.
  ///
  /// Defaults to `true`.
  final bool enabled;

  DropdownMenuItem<T> toDropdownMenuItem() => DropdownMenuItem<T>(
    key: key,
    child: Text(title),
    onTap: onTap,
    value: value,
    enabled: enabled,
  );
}