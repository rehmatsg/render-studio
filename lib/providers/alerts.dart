import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'package:universal_io/io.dart';
import 'package:pro_animated_blur/pro_animated_blur.dart';
import '../rehmat.dart';

class Alerts {

  static void snackbar(BuildContext context, {
    required String text,
    Animation<double>? animation,
    SnackBarAction? action,
    bool floating = false,
    Color? backgroundColor,
    EdgeInsets? margin,
    EdgeInsets? padding,
    Duration? duration,
    Function()? onVisible,
  }) {
    ScaffoldMessengerState().removeCurrentSnackBar(reason: SnackBarClosedReason.remove);
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(text),
          animation: animation,
          action: action,
          behavior: floating ? SnackBarBehavior.floating : SnackBarBehavior.fixed,
          backgroundColor: backgroundColor,
          shape: floating ? RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7)
          ) : RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0)
          ),
          margin: floating ? (margin ?? const EdgeInsets.symmetric(horizontal: 5, vertical: 8)) : null,
          padding: padding ?? EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          duration: duration ?? const Duration(seconds: 4),
          elevation: 1,
          onVisible: onVisible,
        )
      );
    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'snackbar failed', stacktrace: stacktrace);
      return;
    }
  }

  static Future<bool> showConfirmationDialog(BuildContext context, {
    required String title,
    required String message,
    String confirmButtonText = 'Confirm',
    String cancelButtonText = 'Cancel',
    bool isDestructive = false,
  }) async {
    bool? confirm;
    confirm = await modal(
      context,
      icon: RenderIcons.warning,
      title: title,
      message: message,
      primaryButtonText: confirmButtonText,
      secondaryButtonText: cancelButtonText,
      isDestructive: true,
      onPrimaryTap: () {
        Navigator.of(context).pop(true);
      },
      onSecondaryTap: () {
        Navigator.of(context).pop(false);
      },
    );
    return confirm ?? false;
  }

  static Future<dynamic> dialog(BuildContext context, {
    required String title,
    String? content,
    String okButtonText = 'OK',
  }) async {
    if (Platform.isIOS) return await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'SF Pro'
          ),
        ),
        content: content != null ? Text(content) : null,
        actions: [
          CupertinoDialogAction(
            child: Text(okButtonText),
            textStyle: TextStyle(
              fontFamily: 'SF Pro',
              color: Palette.of(context).onSurface
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      )
    );
    else return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: content != null ? Text(content) : null,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(okButtonText)
          ),
        ],
      )
    );
  }

  static Future<void> toast({
    BuildContext? context
  }) async { }

  static Future<String?> optionsBuilder(BuildContext context, {
    String? title,
    required List<AlertOption> options
  }) async {
    return await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      // barrierColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Palette.of(context).surfaceContainerLow,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height * 0.2,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Palette.isDark(context) ? Colors.grey[800] : Colors.grey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 12),
              if (title != null) ... [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Label(
                    label: title
                  ),
                ),
                SizedBox(height: 12,),
              ],
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: options.length,
                itemBuilder: (context, index) => ListTile(
                  leading: options[index].icon != null ? Icon(options[index].icon) : null,
                  title: Text(options[index].title),
                  onTap: () {
                    Navigator.of(context).pop(options[index].id);
                  },
                ),
                separatorBuilder: (context, index) => Divider(
                  height: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> picker(BuildContext context, {
    required List<Widget> children,
    int initialIndex = 0,
    double itemExtent = 30,
    required ValueChanged<int> onSelectedItemChanged,
  }) => showModalBottomSheet(
    context: context,
    backgroundColor: Palette.of(context).surface,
    elevation: 0,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: _SlideDownBar(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 17),
              child: FilledTonalIconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(RenderIcons.done)
              ),
            )
          ],
        ),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height / 5,
            minHeight: MediaQuery.of(context).size.height * 0.2,
          ),
          child: CupertinoPicker(
            itemExtent: itemExtent,
            onSelectedItemChanged: onSelectedItemChanged,
            children: children,
            scrollController: FixedExtentScrollController(initialItem: initialIndex),
            magnification: 1.1,
            diameterRatio: 1.3,
            squeeze: 1,
          ),
        ),
      ],
    ),
  );

  static Future<String?> modalInfoBuilder(BuildContext context, {
    required String title,
    required String message,
  }) async {
    return await modal(
      context,
      title: title,
      childBuilder: (context, setState) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  static Future<T?> modal<T>(BuildContext context, {
    String? title,
    IconData? icon,
    String? message,
    Widget Function(BuildContext context, void Function(void Function()) setState)? childBuilder,
    String? primaryButtonText = 'Done',
    String? secondaryButtonText,
    bool isDestructive = false,
    void Function()? onPrimaryTap,
    void Function()? onSecondaryTap,
  }) async {
    assert(message != null || childBuilder != null);
    return await showModalBottomSheet<T>(
      context: context,
      showDragHandle: false,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      isScrollControlled: true,
      builder: (context) => ProAnimatedBlur(
        blur: 20,
        duration: kAnimationDuration,
        child: StatefulBuilder(
          builder: (context, setState) {
            return SmoothContainer(
              margin: EdgeInsets.only(
                bottom: Constants.of(context).bottomPadding + MediaQuery.of(context).viewInsets.bottom,
                left: 12,
                right: 12,
              ),
              color: Palette.of(context).surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(
                Constants.deviceCornerRadius - 12
              ),
              smoothness: 0.6,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) SmoothContainer(
                    margin: EdgeInsets.only(
                      top: 30,
                    ),
                    height: 70,
                    width: 70,
                    color: Palette.of(context).surfaceContainerLow,
                    borderRadius: BorderRadius.circular(
                      Constants.deviceCornerRadius - 12
                    ),
                    side: BorderSide(
                      color: Palette.isDark(context) ? Colors.grey.shade800 : Colors.grey.shade300,
                      width: 1,
                    ),
                    smoothness: 0.6,
                    child: Center(
                      child: Icon(
                        icon,
                      ),
                    ),
                  ) else SizedBox(height: 12),
                  if (title != null) Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (message != null) Padding(
                    padding: const EdgeInsets.only(
                      left: 18,
                      right: 18,
                      bottom: 12,
                    ),
                    child: Text(
                      message,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (childBuilder != null) ... [
                    childBuilder(context, setState),
                    SizedBox(height: 12),
                  ],
                  if (primaryButtonText != null || secondaryButtonText != null) Padding(
                    padding: const EdgeInsets.only(
                      left: 12,
                      right: 12,
                      bottom: 12,
                    ),
                    child: Row(
                      children: [
                        if (secondaryButtonText != null) Expanded(
                          child: SecondaryButton(
                            child: Text(secondaryButtonText),
                            onPressed: onSecondaryTap,
                            padding: EdgeInsets.symmetric(
                              vertical: 18,
                            ),
                            borderRadius: Constants.deviceCornerRadius - 12 - 6,
                          ),
                        ),
                        if (secondaryButtonText != null && primaryButtonText != null) SizedBox(width: 6),
                        if (primaryButtonText != null) Expanded(
                          child: Button(
                            child: Text(primaryButtonText),
                            backgroundColor: isDestructive ? Palette.of(context).error : Palette.of(context).onSurface,
                            textColor: isDestructive ? Palette.of(context).surface : Palette.of(context).onSurface,
                            onPressed: onPrimaryTap ?? () {
                              Navigator.of(context).pop();
                            },
                            padding: EdgeInsets.symmetric(
                              vertical: 18,
                            ),
                            borderRadius: Constants.deviceCornerRadius - 12 - 6,
                          ),
                        ),
                      ].maybeReverse(isDestructive),
                    ),
                  ) else SizedBox(height: 18),
                ],
              ),
            );
          }
        ),
      ),
    );
    // return await showModalBottomSheet(
    //   context: context,
    //   backgroundColor: Colors.transparent,
    //   // barrierColor: Colors.transparent,
    //   isScrollControlled: true,
    //   builder: (context) => SmoothClipRRect(
    //     borderRadius: BorderRadius.only(
    //       topLeft: Radius.circular(20),
    //       topRight: Radius.circular(20),
    //     ),
    //     smoothness: 0.6,
    //     child: StatefulBuilder(
    //       builder: (context, setState) {
    //         return Container(
    //           decoration: BoxDecoration(
    //             color: Palette.of(context).surface,
    //           ),
    //           constraints: BoxConstraints(
    //             minHeight: MediaQuery.of(context).size.height * 0.2,
    //           ),
    //           child: Column(
    //             mainAxisSize: MainAxisSize.min,
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               Padding(
    //                 padding: const EdgeInsets.symmetric(vertical: 12),
    //                 child: _SlideDownBar(),
    //               ),
    //               SizedBox(height: 12),
    //               if (title != null || actionButton != null) ... [
    //                 Padding(
    //                   padding: const EdgeInsets.symmetric(horizontal: 12),
    //                   child: Row(
    //                     children: [
    //                       if (title != null) Label(
    //                         label: title,
    //                       ),
    //                       if (actionButton != null) ... [
    //                         Spacer(),
    //                         ...actionButton
    //                       ]
    //                     ],
    //                   ),
    //                 ),
    //                 SizedBox(height: 12,),
    //               ],
    //               childBuilder(context, setState),
    //               SizedBox(
    //                 height: Constants.of(context).bottomPadding + MediaQuery.of(context).viewInsets.bottom,
    //               )
    //             ],
    //           ),
    //         );
    //       }
    //     ),
    //   ),
    // );
  }

  static Future<void> showModal(BuildContext context, {
    required Widget child,
    bool isDismissible = true,
    double opacity = 0.5,
  }) => showGeneralDialog(
    context: context,
    pageBuilder: (context, animation, secondaryAnimation) => Material(
      color: Colors.transparent,
      child: child
    ),
    barrierDismissible: isDismissible,
    barrierLabel: 'Dismiss',
    barrierColor: Palette.of(context).surface.withValues(alpha: opacity),
    transitionDuration: Duration(milliseconds: 250),
    transitionBuilder: (context, animation, animation2, child) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20 * animation.value, sigmaY: 20 * animation.value),
      child: FadeTransition(
        child: child,
        opacity: animation,
      ),
    ),
  );

  static Future<String?> requestText(BuildContext context, {
    String title = 'Enter text',
    String? initialValue,
    String? hintText,
    String confirmButtonText = 'Confirm',
    String cancelButtonText = 'Cancel',
  }) async {
    TextEditingController controller = TextEditingController(text: initialValue);
    if (Platform.isAndroid) await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextFormField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (value) => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(cancelButtonText)
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(confirmButtonText),
          )
        ],
      ),
    ); else await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'SF Pro'
          ),
        ),
        content: CupertinoTextField(
          controller: controller,
          placeholder: hintText,
          autofocus: true,
          minLines: 2,
          maxLines: 5,
          textInputAction: TextInputAction.done,
          onSubmitted: (value) => Navigator.of(context).pop(),
          style: TextStyle(
            fontFamily: 'SF Pro',
            color: context.isDarkMode ? Colors.white : Colors.black
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(cancelButtonText),
            textStyle: TextStyle(
              fontFamily: 'SF Pro',
              color: Palette.of(context).onSurface
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            child: Text(confirmButtonText),
            textStyle: TextStyle(
              fontFamily: 'SF Pro',
              color: Palette.of(context).onSurface
            ),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
    return controller.text;
  }

  static Future<void> showSuccess(BuildContext context, {
    Duration duration = const Duration(seconds: 3),
    String? message,
    String asset = 'assets/animations/success.json',
  }) async {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: ProAnimatedBlur(
          blur: 20,
          duration: kAnimationDuration,
          child: Container(
            height: double.infinity,
            width: double.infinity,
            color: Palette.of(context).surface.withValues(alpha: 0.5),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    asset,
                    frameRate: FrameRate.max,
                  ),
                  if (message != null) Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: FadeInUp(
                      child: Text(
                        message,
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold
                        )
                      ),
                    ),
                  )
                ],
              )
            ),
          ),
        ),
      ),
    );
    await Future.delayed(duration, () {
      Navigator.of(context).pop();
    });
  }

}

class _SlideDownBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 50,
          height: 5,
          decoration: BoxDecoration(
            color: Palette.of(context).outline,
            borderRadius: BorderRadius.circular(5),
          ),
        )
      ],
    );
  }
}

class AlertOption {

  final String title;
  final IconData? icon;
  final String id;

  AlertOption({
    required this.title,
    this.icon,
    required this.id,
  });

}

class RenderModalRoute extends PageRoute<void> {

  RenderModalRoute({
    required this.builder,
    RouteSettings? settings,
    this.color,
  }) : super(settings: settings);

  final WidgetBuilder builder;
  final Color? color;

  @override
  bool get opaque => false;

  @override
  Color? get barrierColor => color;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => kAnimationDuration;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    final result = builder(context);
    return Material(
      color: Colors.transparent,
      child: FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(animation),
        child: result,
      ),
    );
  }

}