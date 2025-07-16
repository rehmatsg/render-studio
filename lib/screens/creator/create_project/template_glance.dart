import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'package:universal_io/io.dart';
import '../../../rehmat.dart';

class TemplateGlance extends StatelessWidget {

  const TemplateGlance({
    Key? key,
    required this.glance,
    this.onTap,
    this.isSelected = false
  }) : super(key: key);

  final ProjectGlance glance;
  final void Function()? onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.width / 3;
    double width = height * glance.size.size.aspectRatio;
    return SizedBox(
      height: height,
      width: width,
      child: InkWell(
        onTap: () async {
          TapFeedback.light();
          if (onTap != null) onTap!();
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: kAnimationDuration,
          decoration: BoxDecoration(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 20
            ),
            border: Border.all(
              color: Palette.of(context).onSurface.withValues(alpha: isSelected ? 1 : 0),
              width: 2
            )
          ),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: SmoothClipRRect(
              smoothness: 0.6,
              borderRadius: BorderRadius.circular(15),
              child: OctoImage(
                image: FileImage(File(glance.thumbnail ?? '')),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Material(
                  color: Palette.of(context).surfaceContainerLow,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 20
                    ),
                    child: Center(
                      child: const Icon(RenderIcons.warning),
                    ),
                  ),
                ),
                placeholderBuilder: (context) => LayoutBuilder(
                  builder: (context, constraints) {
                    Size parentSize = constraints.biggest;
                    return SizedBox(
                      width: parentSize.width,
                      height: parentSize.width / glance.size.size.aspectRatio,
                      child: Center(),
                    );
                  }
                )
              )
            ),
          ),
        ),
      ),
    );
  }
}