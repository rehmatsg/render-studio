import 'package:flutter/material.dart';
import 'package:render_studio/creator/helpers/editor_manager.dart';
import 'package:sprung/sprung.dart';
import '../rehmat.dart';

class CreativeWidgetsShowcase extends StatefulWidget {

  const CreativeWidgetsShowcase({
    super.key,
    required this.page
  });

  final CreatorPage page;

  @override
  State<CreativeWidgetsShowcase> createState() => CreativeWidgetsShowcaseState();
}

class CreativeWidgetsShowcaseState extends State<CreativeWidgetsShowcase> {

  BlurredEdgesController _blurredEdgesController = BlurredEdgesController();

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> widgets = {
      'text': {
        'title': 'Text',
        'icon': RenderIcons.text,
      },
      'image': {
        'title': 'Image',
        'icon': RenderIcons.image,
        'onTap': () async {
          await ImageWidget.create(context, page: widget.page);
        }
      },
      'design_asset': {
        'title': 'Design Asset',
        'icon': RenderIcons.design_asset,
        'onTap': () async {
          await CreatorDesignAsset.create(context, page: widget.page);
        }
      },
      'pie-chart': {
        'title': 'Pie Chart',
        'icon': RenderIcons.pieChart
      },
      'shape': {
        'title': 'Shapes',
        'icon': RenderIcons.shapes
      },
      'qr_code': {
        'title': 'QR Code',
        'icon': RenderIcons.qr
      },
      'progress': {
        'title': 'Progress',
        'icon': RenderIcons.progress,
      },
      'box': {
        'title': 'Box',
        'icon': RenderIcons.box
      },
      'blob': {
        'title': 'Blob',
        'widget': Blob.random(
          size: 40,
          styles: BlobStyles(
            color: Palette.of(context).onSurfaceVariant,
          ),
        ),
      },
    };
    return AnimatedSize(
      duration: kAnimationDuration * 2,
      curve: Sprung.underDamped,
      child: SizedBox.fromSize(
        size: EditorManager.standardSize(context) + Offset(0, 48.0), // 48.0 (46.0 + 2) is the height calculated to match the size of editor (calculated from _kTabHeight in flutter/material/tabs.dart)
        child: Container(
          margin: EdgeInsets.only(
            // top: widget.ad != null ? 0 : 48.0
          ),
          decoration: BoxDecoration(
            color: Palette.of(context).surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 3,
                spreadRadius: 0,
              )
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: BlurredEdgesView(
                  controller: _blurredEdgesController,
                  child: ListView.separated(
                    controller: _blurredEdgesController.scrollCtrl,
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 12,
                      bottom: 12 + Constants.of(context).bottomPadding,
                    ),
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (context, index) => SizedBox(width: 1),
                    itemBuilder: (context, index) {
                      String key = widgets.keys.elementAt(index);
                      Map<String, dynamic> cWidget = widgets[key]!;
                      return Tooltip(
                        message: cWidget['title'],
                        child: SizedBox(
                          width: 80,
                          child: InkWellButton(
                            radius: BorderRadius.circular(10),
                            onTap: () {
                              TapFeedback.light();
                              if (cWidget['onTap'] != null) cWidget['onTap']!();
                              else CreatorWidget.create(context, page: widget.page, id: key,);
                            },
                            child: (cWidget['icon'] != null) ? Icon(
                              cWidget['icon'],
                              color: Palette.of(context).onSurfaceVariant,
                              size: 30,
                            ) : Center(
                              child: cWidget['widget']
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: widgets.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
}