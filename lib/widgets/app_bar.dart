import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

import '../rehmat.dart';

class RenderAppBar extends StatefulWidget {

  const RenderAppBar({
    Key? key,
    required this.title,
    this.isLoading = false,
    this.isExpandable = true,
    this.pinned = true,
    this.floating = false,
    this.centerTitle = false,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.flexibleSpace,
    this.bottom,
    this.elevation,
    this.scrolledUnderElevation,
    this.shadowColor,
    this.surfaceTintColor,
    this.forceElevated = false,
    this.backgroundColor,
    this.foregroundColor,
    this.brightness,
    this.iconTheme,
    this.actionsIconTheme,
    this.textTheme,
    this.primary = true,
    this.excludeHeaderSemantics = false,
    this.titleSpacing,
    this.shape,
    this.snap = false,
    this.stretch = false,
    this.stretchTriggerOffset = 100.0,
    this.onStretchTrigger,
    this.leadingWidth,
    this.backwardsCompatibility,
    this.toolbarTextStyle,
    this.titleTextStyle,
    this.systemOverlayStyle,
  }) : super(key: key);

  /// {@macro flutter.material.appbar.isExpandable}
  /// 
  /// Set this property to false to disable the expandable behavior of the app bar.
  final bool isExpandable;

  /// Use this property to toggle between loading and non-loading states of the app bar
  final bool isLoading;

  /// {@macro flutter.material.appbar.leading}
  ///
  /// This property is used to configure an [AppBar].
  final Widget? leading;

  /// {@macro flutter.material.appbar.automaticallyImplyLeading}
  ///
  /// This property is used to configure an [AppBar].
  final bool automaticallyImplyLeading;

  /// {@macro flutter.material.appbar.title}
  ///
  /// This property is used to configure an [AppBar].
  final Widget title;

  /// {@macro flutter.material.appbar.actions}
  ///
  /// This property is used to configure an [AppBar].
  final List<Widget>? actions;

  /// {@macro flutter.material.appbar.flexibleSpace}
  ///
  /// This property is used to configure an [AppBar].
  final Widget? flexibleSpace;

  /// {@macro flutter.material.appbar.bottom}
  ///
  /// This property is used to configure an [AppBar].
  final PreferredSizeWidget? bottom;

  /// {@macro flutter.material.appbar.elevation}
  ///
  /// This property is used to configure an [AppBar].
  final double? elevation;

  /// {@macro flutter.material.appbar.scrolledUnderElevation}
  ///
  /// This property is used to configure an [AppBar].
  final double? scrolledUnderElevation;

  /// {@macro flutter.material.appbar.shadowColor}
  ///
  /// This property is used to configure an [AppBar].
  final Color? shadowColor;

  /// {@macro flutter.material.appbar.surfaceTintColor}
  ///
  /// This property is used to configure an [AppBar].
  final Color? surfaceTintColor;

  /// Whether to show the shadow appropriate for the [elevation] even if the
  /// content is not scrolled under the [AppBar].
  ///
  /// Defaults to false, meaning that the [elevation] is only applied when the
  /// [AppBar] is being displayed over content that is scrolled under it.
  ///
  /// When set to true, the [elevation] is applied regardless.
  ///
  /// Ignored when [elevation] is zero.
  final bool forceElevated;

  /// {@macro flutter.material.appbar.backgroundColor}
  ///
  /// This property is used to configure an [AppBar].
  final Color? backgroundColor;

  /// {@macro flutter.material.appbar.foregroundColor}
  ///
  /// This property is used to configure an [AppBar].
  final Color? foregroundColor;

  /// {@macro flutter.material.appbar.brightness}
  ///
  /// This property is used to configure an [AppBar].
  @Deprecated(
    'This property is no longer used, please use systemOverlayStyle instead. '
    'This feature was deprecated after v2.4.0-0.0.pre.',
  )
  final Brightness? brightness;

  /// {@macro flutter.material.appbar.iconTheme}
  ///
  /// This property is used to configure an [AppBar].
  final IconThemeData? iconTheme;

  /// {@macro flutter.material.appbar.actionsIconTheme}
  ///
  /// This property is used to configure an [AppBar].
  final IconThemeData? actionsIconTheme;

  /// {@macro flutter.material.appbar.textTheme}
  ///
  /// This property is used to configure an [AppBar].
  @Deprecated(
    'This property is no longer used, please use toolbarTextStyle and titleTextStyle instead. '
    'This feature was deprecated after v2.4.0-0.0.pre.',
  )
  final TextTheme? textTheme;

  /// {@macro flutter.material.appbar.primary}
  ///
  /// This property is used to configure an [AppBar].
  final bool primary;

  /// {@macro flutter.material.appbar.centerTitle}
  ///
  /// This property is used to configure an [AppBar].
  final bool? centerTitle;

  /// {@macro flutter.material.appbar.excludeHeaderSemantics}
  ///
  /// This property is used to configure an [AppBar].
  final bool excludeHeaderSemantics;

  /// {@macro flutter.material.appbar.titleSpacing}
  ///
  /// This property is used to configure an [AppBar].
  final double? titleSpacing;

  /// Whether the app bar should become visible as soon as the user scrolls
  /// towards the app bar.
  ///
  /// Otherwise, the user will need to scroll near the top of the scroll view to
  /// reveal the app bar.
  ///
  /// If [snap] is true then a scroll that exposes the app bar will trigger an
  /// animation that slides the entire app bar into view. Similarly if a scroll
  /// dismisses the app bar, the animation will slide it completely out of view.
  ///
  /// ## Animated Examples
  ///
  /// The following animations show how the app bar changes its scrolling
  /// behavior based on the value of this property.
  ///
  /// * App bar with [floating] set to false:
  ///   {@animation 476 400 https://flutter.github.io/assets-for-api-docs/assets/material/app_bar.mp4}
  /// * App bar with [floating] set to true:
  ///   {@animation 476 400 https://flutter.github.io/assets-for-api-docs/assets/material/app_bar_floating.mp4}
  ///
  /// See also:
  ///
  ///  * [SliverAppBar] for more animated examples of how this property changes the
  ///    behavior of the app bar in combination with [pinned] and [snap].
  final bool floating;

  /// Whether the app bar should remain visible at the start of the scroll view.
  ///
  /// The app bar can still expand and contract as the user scrolls, but it will
  /// remain visible rather than being scrolled out of view.
  ///
  /// ## Animated Examples
  ///
  /// The following animations show how the app bar changes its scrolling
  /// behavior based on the value of this property.
  ///
  /// * App bar with [pinned] set to false:
  ///   {@animation 476 400 https://flutter.github.io/assets-for-api-docs/assets/material/app_bar.mp4}
  /// * App bar with [pinned] set to true:
  ///   {@animation 476 400 https://flutter.github.io/assets-for-api-docs/assets/material/app_bar_pinned.mp4}
  ///
  /// See also:
  ///
  ///  * [SliverAppBar] for more animated examples of how this property changes the
  ///    behavior of the app bar in combination with [floating].
  final bool pinned;

  /// {@macro flutter.material.appbar.shape}
  ///
  /// This property is used to configure an [AppBar].
  final ShapeBorder? shape;

  /// If [snap] and [floating] are true then the floating app bar will "snap"
  /// into view.
  ///
  /// If [snap] is true then a scroll that exposes the floating app bar will
  /// trigger an animation that slides the entire app bar into view. Similarly
  /// if a scroll dismisses the app bar, the animation will slide the app bar
  /// completely out of view. Additionally, setting [snap] to true will fully
  /// expand the floating app bar when the framework tries to reveal the
  /// contents of the app bar by calling [RenderObject.showOnScreen]. For
  /// example, when a [TextField] in the floating app bar gains focus, if [snap]
  /// is true, the framework will always fully expand the floating app bar, in
  /// order to reveal the focused [TextField].
  ///
  /// Snapping only applies when the app bar is floating, not when the app bar
  /// appears at the top of its scroll view.
  ///
  /// ## Animated Examples
  ///
  /// The following animations show how the app bar changes its scrolling
  /// behavior based on the value of this property.
  ///
  /// * App bar with [snap] set to false:
  ///   {@animation 476 400 https://flutter.github.io/assets-for-api-docs/assets/material/app_bar_floating.mp4}
  /// * App bar with [snap] set to true:
  ///   {@animation 476 400 https://flutter.github.io/assets-for-api-docs/assets/material/app_bar_floating_snap.mp4}
  ///
  /// See also:
  ///
  ///  * [SliverAppBar] for more animated examples of how this property changes the
  ///    behavior of the app bar in combination with [pinned] and [floating].
  final bool snap;

  /// Whether the app bar should stretch to fill the over-scroll area.
  ///
  /// The app bar can still expand and contract as the user scrolls, but it will
  /// also stretch when the user over-scrolls.
  final bool stretch;

  /// The offset of overscroll required to activate [onStretchTrigger].
  ///
  /// This defaults to 100.0.
  final double stretchTriggerOffset;

  /// The callback function to be executed when a user over-scrolls to the
  /// offset specified by [stretchTriggerOffset].
  final AsyncCallback? onStretchTrigger;

  /// {@macro flutter.material.appbar.leadingWidth}
  ///
  /// This property is used to configure an [AppBar].
  final double? leadingWidth;

  /// {@macro flutter.material.appbar.backwardsCompatibility}
  ///
  /// This property is used to configure an [AppBar].
  @Deprecated(
    'This property is obsolete and is false by default. '
    'This feature was deprecated after v2.4.0-0.0.pre.',
  )
  final bool? backwardsCompatibility;

  /// {@macro flutter.material.appbar.toolbarTextStyle}
  ///
  /// This property is used to configure an [AppBar].
  final TextStyle? toolbarTextStyle;

  /// {@macro flutter.material.appbar.titleTextStyle}
  ///
  /// This property is used to configure an [AppBar].
  final TextStyle? titleTextStyle;

  /// {@macro flutter.material.appbar.systemOverlayStyle}
  ///
  /// This property is used to configure an [AppBar].
  final SystemUiOverlayStyle? systemOverlayStyle;

  @override
  State<RenderAppBar> createState() => _RenderAppBarState();
}

class _RenderAppBarState extends State<RenderAppBar> {

  @override
  Widget build(BuildContext context) {
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final ScaffoldState? scaffold = Scaffold.maybeOf(context);

    final bool hasDrawer = scaffold?.hasDrawer ?? false;
    final bool hasEndDrawer = scaffold?.hasEndDrawer ?? false;
    final bool canPop = parentRoute?.canPop ?? false;
    
    final bool willHaveLeading = (hasDrawer || ((!hasEndDrawer && canPop) || (parentRoute?.impliesAppBarDismissal ?? false)) || widget.leading != null);

    Widget? leading = widget.leading;
    /// Only add a leading button if it has to be a back button
    if (willHaveLeading && canPop && (parentRoute?.impliesAppBarDismissal ?? false)) leading = NewBackButton();

    return SliverAppBar(
      pinned: widget.pinned,
      floating: widget.floating,
      centerTitle: widget.centerTitle,
      expandedHeight: isExpandable ? kAppBarExpandedHeight : null,
      leading: leading,
      actions: widget.actions,
      actionsIconTheme: widget.actionsIconTheme,
      automaticallyImplyLeading: widget.automaticallyImplyLeading,
      backgroundColor: widget.backgroundColor,
      bottom: widget.bottom,
      elevation: widget.elevation,
      forceElevated: widget.forceElevated,
      foregroundColor: widget.foregroundColor,
      iconTheme: widget.iconTheme,
      leadingWidth: widget.leadingWidth,
      toolbarTextStyle: widget.toolbarTextStyle,
      systemOverlayStyle: widget.systemOverlayStyle,
      shape: widget.shape,
      snap: widget.snap,
      stretch: widget.stretch,
      stretchTriggerOffset: widget.stretchTriggerOffset,
      onStretchTrigger: widget.onStretchTrigger,
      primary: widget.primary,
      shadowColor: widget.shadowColor,
      titleSpacing: widget.titleSpacing,
      titleTextStyle: widget.titleTextStyle,
      title: isExpandable ? null : title,
      flexibleSpace: isExpandable ? RenderFlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        centerTitle: false,
        title: widget.title,
        titlePaddingTween: EdgeInsetsTween(
          begin: const EdgeInsets.only(
            left: 12,
            bottom: 16
          ),
          end: EdgeInsets.symmetric(
            horizontal: willHaveLeading ? 60 : 12,
            vertical: 15
          )
        ),
        stretchModes: const [StretchMode.fadeTitle],
      ) : null,
    );
  }

  bool get isExpandable => widget.isLoading ? false : (widget.isExpandable);

  Widget get title => widget.isLoading ? const TitleSpinnerWidget() : widget.title;
  
}

/// The part of a material design [AppBar] that expands, collapses, and
/// stretches.
///
/// Most commonly used in the [SliverAppBar.flexibleSpace] field, a flexible
/// space bar expands and contracts as the app scrolls so that the [AppBar]
/// reaches from the top of the app to the top of the scrolling contents of the
/// app. When using [SliverAppBar.flexibleSpace], the [SliverAppBar.expandedHeight]
/// must be large enough to accommodate the [SliverAppBar.flexibleSpace] widget.
///
/// Furthermore is included functionality for stretch behavior. When
/// [SliverAppBar.stretch] is true, and your [ScrollPhysics] allow for
/// overscroll, this space will stretch with the overscroll.
///
/// The widget that sizes the [AppBar] must wrap it in the widget returned by
/// [RenderFlexibleSpaceBar.createSettings], to convey sizing information down to the
/// [RenderFlexibleSpaceBar].
///
/// {@tool dartpad --template=freeform}
/// This sample application demonstrates the different features of the
/// [RenderFlexibleSpaceBar] when used in a [SliverAppBar]. This app bar is configured
/// to stretch into the overscroll space, and uses the
/// [RenderFlexibleSpaceBar.stretchModes] to apply `fadeTitle`, `blurBackground` and
/// `zoomBackground`. The app bar also makes use of [CollapseMode.parallax] by
/// default.
///
/// ```dart imports
/// import 'package:flutter/material.dart';
/// ```
/// ```dart
/// void main() => runApp(MaterialApp(home: MyApp()));
///
/// class MyApp extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: CustomScrollView(
///         physics: const BouncingScrollPhysics(),
///         slivers: <Widget>[
///           SliverAppBar(
///             stretch: true,
///             onStretchTrigger: () {
///               // Function callback for stretch
///               return;
///             },
///             expandedHeight: 300.0,
///             flexibleSpace: FlexibleSpaceBar(
///               stretchModes: <StretchMode>[
///                 StretchMode.zoomBackground,
///                 StretchMode.blurBackground,
///                 StretchMode.fadeTitle,
///               ],
///               centerTitle: true,
///               title: const Text('Flight Report'),
///               background: Stack(
///                 fit: StackFit.expand,
///                 children: [
///                   Image.network(
///                     'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg',
///                     fit: BoxFit.cover,
///                   ),
///                   const DecoratedBox(
///                     decoration: BoxDecoration(
///                       gradient: LinearGradient(
///                         begin: Alignment(0.0, 0.5),
///                         end: Alignment(0.0, 0.0),
///                         colors: <Color>[
///                           Color(0x60000000),
///                           Color(0x00000000),
///                         ],
///                       ),
///                     ),
///                   ),
///                 ],
///               ),
///             ),
///           ),
///           SliverList(
///             delegate: SliverChildListDelegate([
///               ListTile(
///                 leading: Icon(Icons.wb_sunny),
///                 title: Text('Sunday'),
///                 subtitle: Text('sunny, h: 80, l: 65'),
///               ),
///               ListTile(
///                 leading: Icon(Icons.wb_sunny),
///                 title: Text('Monday'),
///                 subtitle: Text('sunny, h: 80, l: 65'),
///               ),
///               // ListTiles++
///             ]),
///           ),
///         ],
///       ),
///     );
///   }
/// }
///
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [SliverAppBar], which implements the expanding and contracting.
///  * [AppBar], which is used by [SliverAppBar].
///  * <https://material.io/design/components/app-bars-top.html#behavior>
class RenderFlexibleSpaceBar extends StatefulWidget {
  /// Creates a flexible space bar.
  ///
  /// Most commonly used in the [AppBar.flexibleSpace] field.
  const RenderFlexibleSpaceBar({
    Key? key,
    this.title,
    this.foreground,
    this.background,
    this.centerTitle,
    this.titlePadding,
    this.titlePaddingTween,
    this.collapseMode = CollapseMode.parallax,
    this.stretchModes = const <StretchMode>[StretchMode.zoomBackground],
  }) : super(key: key);

  /// The primary contents of the flexible space bar when expanded.
  ///
  /// Typically a [Text] widget.
  final Widget? title;

  final Widget? foreground;

  /// Shown behind the [title] when expanded.
  ///
  /// Typically an [Image] widget with [Image.fit] set to [BoxFit.cover].
  final Widget? background;

  /// Whether the title should be centered.
  ///
  /// By default this property is true if the current target platform
  /// is [TargetPlatform.iOS] or [TargetPlatform.macOS], false otherwise.
  final bool? centerTitle;

  /// Collapse effect while scrolling.
  ///
  /// Defaults to [CollapseMode.parallax].
  final CollapseMode collapseMode;

  /// Stretch effect while over-scrolling.
  ///
  /// Defaults to include [StretchMode.zoomBackground].
  final List<StretchMode> stretchModes;

  /// Defines how far the [title] is inset from either the widget's
  /// bottom-left or its center.
  ///
  /// Typically this property is used to adjust how far the title is
  /// is inset from the bottom-left and it is specified along with
  /// [centerTitle] false.
  ///
  /// By default the value of this property is
  /// `EdgeInsetsDirectional.only(start: 72, bottom: 16)` if the title is
  /// not centered, `EdgeInsetsDirectional.only(start: 0, bottom: 16)` otherwise.
  final EdgeInsetsGeometry? titlePadding;
  final EdgeInsetsTween? titlePaddingTween;

  @override
  State<RenderFlexibleSpaceBar> createState() => _RenderFlexibleSpaceBarState();
}

class _RenderFlexibleSpaceBarState extends State<RenderFlexibleSpaceBar> {
  bool _getEffectiveCenterTitle(ThemeData theme) {
    if (widget.centerTitle != null) {
      return widget.centerTitle!;
    }
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return false;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return true;
    }
  }

  Alignment _getTitleAlignment(bool effectiveCenterTitle) {
    if (effectiveCenterTitle) {
      return Alignment.bottomCenter;
    }
    final TextDirection textDirection = Directionality.of(context);
    switch (textDirection) {
      case TextDirection.rtl:
        return Alignment.bottomRight;
      case TextDirection.ltr:
        return Alignment.bottomLeft;
    }
  }

  double _getCollapsePadding(double t, FlexibleSpaceBarSettings settings) {
    switch (widget.collapseMode) {
      case CollapseMode.pin:
        return -(settings.maxExtent - settings.currentExtent);
      case CollapseMode.none:
        return 0.0;
      case CollapseMode.parallax:
        final double deltaExtent = settings.maxExtent - settings.minExtent;
        return -Tween<double>(begin: 0.0, end: deltaExtent / 4.0).transform(t);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final FlexibleSpaceBarSettings? settings = context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
        assert(
          settings != null,
          'A FlexibleSpaceBar must be wrapped in the widget returned by FlexibleSpaceBar.createSettings().',
        );

        final List<Widget> children = <Widget>[];

        final double deltaExtent = settings!.maxExtent - settings.minExtent;

        // 0.0 -> Expanded
        // 1.0 -> Collapsed to toolbar
        final double t = (1.0 - (settings.currentExtent - settings.minExtent) / deltaExtent).clamp(0.0, 1.0);

        // background
        if (widget.background != null) {
          final double fadeStart = math.max(0.0, 1.0 - kToolbarHeight / deltaExtent);
          const double fadeEnd = 1.0;
          assert(fadeStart <= fadeEnd);
          final double opacity = 1.0 - Interval(fadeStart, fadeEnd).transform(t);
          double height = settings.maxExtent;

          // StretchMode.zoomBackground
          if (widget.stretchModes.contains(StretchMode.zoomBackground) && constraints.maxHeight > height) {
            height = constraints.maxHeight;
          }
          children.add(Positioned(
            top: _getCollapsePadding(t, settings),
            left: 0.0,
            right: 0.0,
            height: height,
            child: Opacity(
              // IOS is relying on this semantics node to correctly traverse
              // through the app bar when it is collapsed.
              alwaysIncludeSemantics: true,
              opacity: opacity,
              child: widget.background,
            ),
          ));

          // StretchMode.blurBackground
          if (widget.stretchModes.contains(StretchMode.blurBackground) && constraints.maxHeight > settings.maxExtent) {
            final double blurAmount = (constraints.maxHeight - settings.maxExtent) / 10;
            children.add(
              Positioned.fill(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(
                    sigmaX: blurAmount,
                    sigmaY: blurAmount,
                  ),
                  child: Container(
                    color: Colors.transparent,
                  )
                )
              )
            );
          }
        }

        // title
        if (widget.title != null) {
          final ThemeData theme = Theme.of(context);

          Widget? title;
          switch (theme.platform) {
            case TargetPlatform.iOS:
            case TargetPlatform.macOS:
              title = widget.title;
              break;
            case TargetPlatform.android:
            case TargetPlatform.fuchsia:
            case TargetPlatform.linux:
            case TargetPlatform.windows:
              title = Semantics(
                namesRoute: true,
                child: widget.title,
              );
              break;
          }

          // StretchMode.fadeTitle
          if (widget.stretchModes.contains(StretchMode.fadeTitle) && constraints.maxHeight > settings.maxExtent) {
            final double stretchOpacity = 1 - (((constraints.maxHeight - settings.maxExtent) / 100).clamp(0.0, 1.0));
            title = Opacity(
              opacity: stretchOpacity,
              child: title,
            );
          }

          final double opacity = settings.toolbarOpacity;
          if (opacity > 0.0) {
            TextStyle titleStyle = theme.textTheme.titleLarge!;
            titleStyle = titleStyle.copyWith(
              fontWeight: FontWeight.w600,
              color: titleStyle.color!.withValues(alpha: opacity)
            );
            final bool effectiveCenterTitle = _getEffectiveCenterTitle(theme);
            final padding = widget.titlePadding ?? widget.titlePaddingTween?.transform(t) ?? EdgeInsetsDirectional.only(
              start: effectiveCenterTitle ? 0.0 : 72.0,
              bottom: 16.0,
            );
            final double scaleValue = Tween<double>(begin: 2.1, end: 1.0).transform(t);
            final Matrix4 scaleTransform = Matrix4.identity()
              ..scale(scaleValue, scaleValue, 1.0);
            final Alignment titleAlignment = _getTitleAlignment(effectiveCenterTitle);
            children.add(Container(
              padding: padding,
              child: Transform(
                alignment: titleAlignment,
                transform: scaleTransform,
                child: Align(
                  alignment: titleAlignment,
                  child: DefaultTextStyle(
                    style: titleStyle,
                    child: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) {
                        return Container(
                          width: constraints.maxWidth / scaleValue,
                          alignment: titleAlignment,
                          child: title,
                        );
                      }
                    ),
                  ),
                ),
              ),
            ));
          }
        }

        if (widget.foreground != null) children.add(widget.foreground!);

        return ClipRect(child: Stack(children: children));
      }
    );
  }
}