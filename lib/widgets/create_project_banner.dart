import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';

import '../rehmat.dart';

class CreateProjectBanner extends StatefulWidget {

  const CreateProjectBanner({super.key});

  @override
  State<CreateProjectBanner> createState() => CreateProjectBannerState();
}

class CreateProjectBannerState extends State<CreateProjectBanner> {

  final BlurredEdgesController blurredEdgesCtrl = BlurredEdgesController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Palette.of(context).surfaceContainerLow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 12,
              right: 12,
              bottom: 0,
              top: 21
            ),
            child: Text(
              app.remoteConfig.createProjectBannerTitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1,
                color: Palette.of(context).onSurfaceVariant
              )
            )
          ),
          SizedBox(
            height: ((Theme.of(context).textTheme.labelMedium?.fontSize ?? 20) * 2 * 1.2) + 12 + 70 + 3 + 12,
            child: ListView.separated(
              controller: blurredEdgesCtrl.scrollCtrl,
              scrollDirection: Axis.horizontal,
              separatorBuilder: (context, index) => SizedBox(width: 6),
              padding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12
              ),
              itemBuilder: (context, index) {
                return _CreateButton(
                  onTap: () {
                    TapFeedback.light();
                    Project.createNewProject(context, PostSizePresets.values[index].toSize());
                  },
                  icon: PostSizePresets.values[index].icon,
                  title: PostSizePresets.values[index].title.toTitleCase(),
                );
              },
              itemCount: PostSizePresets.values.length,
            ),
          ),
        ],
      ),
    );
  }

}

class _CreateButton extends StatelessWidget {

  const _CreateButton({
    this.onTap,
    required this.icon,
    required this.title,
  });

  final void Function()? onTap;
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      child: Column(
        children: [
          SizedBox(
            height: 70,
            width: 70,
            child: Container(
              decoration: BoxDecoration(
                color: Palette.of(context).surface,
                borderRadius: SmoothBorderRadius(
                  cornerRadius: kBorderRadius - 8,
                  cornerSmoothing: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    offset: Offset(0, 1),
                    blurRadius: 2
                  )
                ]
              ),
              child: Material(
                color: Colors.transparent,
                child: Ink(
                  child: InkWell(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: kBorderRadius - 8,
                      cornerSmoothing: 0.5,
                    ),
                    onTap: onTap,
                    child: Center(child: Icon(icon)),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 3),
          Flexible(
            child: Text(
              title,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                height: 1.2,
                color: Palette.of(context).onSurfaceVariant,
              ),
            ),
          )
        ],
      ),
    );
  }
}