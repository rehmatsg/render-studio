import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:render_studio/models/project/templatex.dart';

import '../../../rehmat.dart';

class GeneratedTemplatesView extends StatefulWidget {

  const GeneratedTemplatesView({
    super.key,
    required this.prompt
  });

  final String prompt;

  @override
  State<GeneratedTemplatesView> createState() => _GeneratedTemplatesViewState();
}

class _GeneratedTemplatesViewState extends State<GeneratedTemplatesView> {

  late final String prompt;

  bool isLoading = true;

  List<Project> projects = [];

  PageController controller = PageController();

  Future<void> generateTemplates() async {
    try {
      projects = await TemplateKit.generate(context, prompt: prompt);
      setState(() {
        isLoading = false;
      });
    } catch (e, stacktrace) {
      print(e);
      analytics.logError(e, cause: 'template generation error', stacktrace: stacktrace);
      await Alerts.dialog(
        context,
        title: 'Error',
        content: 'Failed to generate templates. Please try again later'
      );
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    prompt = widget.prompt;
    generateTemplates();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: NewBackButton(
          confirm: true,
          confirmTitle: isLoading ? 'Cancel' : 'Discard',
          confirmMessage: isLoading ? 'Are you sure you want to cancel generating templates?' : 'Are you sure you want to discard these templates?',
          icon: isLoading ? RenderIcons.close : RenderIcons.arrow_back,
        ),
        title: isLoading ? null : Text('Templates')
      ),
      extendBodyBehindAppBar: isLoading,
      body: AnimatedSwitcher(
        duration: kAnimationDuration,
        child: isLoading ? Center(
          child: Lottie.asset(
            'assets/animations/cube-loading-${context.isDarkMode ? 'dark' : 'light'}.json',
            frameRate: FrameRate.max,
          ),
        ) : FadeIn(
          child: PageView.builder(
            controller: controller,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => IgnorePointer(
              child: SizedBox(
                width: projects[index].contentSize.width,
                height: projects[index].contentSize.height,
                child: CreatorView(project: projects[index])
              ),
            ),
            itemCount: projects.length,
          ),
        ),
      ),
      bottomNavigationBar: isLoading ? null : Container(
        decoration: BoxDecoration(
          color: Palette.of(context).surfaceContainerLow,
          border: Border(
            top: BorderSide(
              color: Palette.of(context).onSurface.withValues(alpha: 0.1),
              width: 0.5
            )
          )
        ),
        padding: EdgeInsets.only(
          bottom: Constants.of(context).bottomPadding,
          top: 12,
          left: 12,
          right: 12
        ),
        child: Row(
          children: [
            PullDownButton(
              itemBuilder: (context) => [
                PullDownMenuItem(
                  title: 'Report',
                  icon: RenderIcons.flag,
                  onTap: () {
                    
                  },
                ),
                PullDownMenuItem(
                  title: 'Delete',
                  icon: RenderIcons.delete,
                  isDestructive: true,
                  onTap: () {
                    
                  },
                ),
              ],
              buttonBuilder: (context, showMenu) {
                return IconButton.filledTonal(
                  onPressed: showMenu,
                  tooltip: 'View more options',
                  icon: Icon(
                    RenderIcons.more,
                  ),
                );
              }
            ),
            IconButton.filledTonal(
              onPressed: () {},
              tooltip: 'Save to gallery',
              icon: Icon(
                RenderIcons.download,
              ),
            ),
            IconButton.filledTonal(
              onPressed: () {},
              tooltip: 'Mark the generation as helpful',
              icon: Icon(
                RenderIcons.thums_up,
              ),
            ),
            IconButton.filledTonal(
              onPressed: () {},
              tooltip: 'Mark the generation as unhelpful',
              icon: Icon(
                RenderIcons.thums_down,
              ),
            ),
            Spacer(),
            IntrinsicHeight(
              child: PrimaryButton(
                padding: EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12
                ),
                child: Row(
                  children: [
                    Text(
                      'Edit',
                    )
                  ],
                ),
                onPressed: () {
                  try {
                    Project project = projects[controller.page!.round()];
                    AppRouter.push(context, page: Studio(project: project));
                  } catch (e) {
                    print(e);
                    Alerts.dialog(
                      context,
                      title: 'Error',
                      content: 'Failed to edit template. Please try again later'
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

}