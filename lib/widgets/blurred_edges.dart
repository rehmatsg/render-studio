import 'package:flutter/material.dart';

import '../rehmat.dart';

class BlurredEdgesController {

  late final ScrollController scrollCtrl;

  BlurredEdgesController() {
    scrollCtrl = ScrollController();
  }

}

class BlurredEdgesView extends StatefulWidget {

  const BlurredEdgesView({
    super.key,
    required this.controller,
    required this.child,
    this.blurLength = 40
  });

  final BlurredEdgesController controller;
  
  final Widget child;

  final double blurLength;

  @override
  State<BlurredEdgesView> createState() => _BlurredEdgesViewState();
}

class _BlurredEdgesViewState extends State<BlurredEdgesView> {

  late final ScrollController controller;

  void onScroll() => setState(() { });

  @override
  void initState() {
    super.initState();
    controller = widget.controller.scrollCtrl;
    controller.addListener(onScroll);
  }

  @override
  void dispose() {
    controller.removeListener(onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[
            initialColor,
            color,
            color,
            color,
            finalColor
          ],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: widget.child,
    );
  }

  Color get color => Palette.of(context).surface;

  Color get initialColor {
    double scrolled = controller.position.extentBefore;
    if (scrolled < widget.blurLength) {
      return color.withValues(alpha: 1 - scrolled / widget.blurLength);
    } else {
      return color.withValues(alpha: 0);
    }
  }

  Color get finalColor {
    double scrolled = controller.position.extentAfter;
    if (scrolled < widget.blurLength) {
      return color.withValues(alpha: 1 - scrolled / widget.blurLength);
    } else {
      return color.withValues(alpha: 0);
    }
  }

}