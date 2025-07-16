import 'package:smooth_corner/smooth_corner.dart';
import 'package:universal_io/io.dart';
import 'dart:ui';

import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../rehmat.dart';

class Spinner extends StatefulWidget {

  final Color? valueColor;
  final Color? backgroundColor;
  final double strokeWidth;
  final double? value;
  final bool adaptive;
  final double radius;

  const Spinner({Key? key, this.valueColor, this.backgroundColor, this.strokeWidth = 4.0, this.value, this.adaptive = true, this.radius = 10}) : super(key: key);

  static Future<void> fullscreen(
    BuildContext context, {
      /// Provide a function that will be executed
      required Future<void> Function() task,
      Function? onComplete
    }
  ) async {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) => PopScope(
        canPop: false,
        child: Container(
          height: double.infinity,
          width: double.infinity,
          color: Palette.of(context).surface.withValues(alpha: 0.25),
          child: Center(
            child: SmoothContainer(
              color: Palette.of(context).surface,
              borderRadius: BorderRadius.circular(10),
              smoothness: 0.6,
              padding: const EdgeInsets.all(20),
              child: Spinner()
            ),
          ),
        ),
      ),
      transitionBuilder: (context, animation, animation2, child) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20 * animation.value, sigmaY: 20 * animation.value),
        child: FadeTransition(
          child: child,
          opacity: animation,
        ),
      ),
    );
    try {
      await task();
    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'task failed', stacktrace: stacktrace);
    }
    Navigator.of(context).pop();
    if (onComplete != null) onComplete();
  }

  static Future<void> linearFullscreen(BuildContext context, {
    /// Provide a function that will be executed
    required Future<void> Function() task,
    Function? onComplete,
    required String message
  }) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Palette.blurBackground(context),
      barrierColor: Palette.blurBackground(context),
      isDismissible: false,
      enableDrag: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Container(
          height: double.infinity,
          width: double.infinity,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Center(
              child: SizedBox(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    SizedBox(height: 6,),
                    SizedBox(
                      width: MediaQuery.of(context).size.width/3,
                      child: LinearProgressIndicator(
                        minHeight: 3,
                      )
                    ),
                  ],
                ),
              )
            ),
          ),
        ),
      ),
    );
    try {
      await task();
    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'task failed', stacktrace: stacktrace);
    }
    Navigator.of(context).pop();
    if (onComplete != null) onComplete();
  }

  @override
  _SpinnerState createState() => _SpinnerState();
}

class _SpinnerState extends State<Spinner> {

  @override
  Widget build(BuildContext context) {
    Color color;
    color = widget.valueColor ?? Theme.of(context).progressIndicatorTheme.color ?? Palette.of(context).primary;
    if (!widget.adaptive || (widget.adaptive && Platform.isAndroid)) return SizedBox.square(
      dimension: widget.radius,
      child: CircularProgressIndicator(
        backgroundColor: widget.backgroundColor,
        strokeWidth: widget.strokeWidth,
        value: widget.value,
        valueColor: AlwaysStoppedAnimation(color),
      ),
    ); else return CupertinoActivityIndicator(
      radius: widget.radius,
      color: widget.valueColor,
    );
  }
  
}

class TitleSpinner extends StatelessWidget {
  
  const TitleSpinner({
    Key? key,
    required this.controller,
    required this.title
  }) : super(key: key);

  final LoadingController controller;

  final Widget title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FlipCard(
          front: title,
          controller: controller.flipCardController,
          back: TitleSpinnerWidget(),
          flipOnTouch: false,
          direction: FlipDirection.VERTICAL,
        )
      ],
    );
  }

}

class TitleSpinnerWidget extends StatefulWidget {

  const TitleSpinnerWidget({Key? key}) : super(key: key);

  @override
  State<TitleSpinnerWidget> createState() => _TitleSpinnerWidgetState();
}

class _TitleSpinnerWidgetState extends State<TitleSpinnerWidget> {
  @override
  Widget build(BuildContext context) {
    return Platform.isIOS ? CupertinoActivityIndicator() : SpinKitThreeBounce(
      color: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.grey[800] : Colors.grey[200],
      size: 20,
    );
  }
}

class LoadingController {

  FlipCardController flipCardController = FlipCardController();

  bool isLoading = false;

  void start() {
    isLoading = true;
    flipCardController.toggleCard();
  }

  void end() {
    isLoading = false;
    flipCardController.toggleCard();
  }

  void toggle() {
    isLoading = !isLoading;
    flipCardController.toggleCard();
  }

}