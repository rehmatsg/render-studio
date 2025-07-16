import 'dart:ui';

import 'package:flutter/material.dart';

import '../../rehmat.dart';

class QRCodeDataEditor extends StatefulWidget {

  QRCodeDataEditor({Key? key}) : super(key: key);

  @override
  State<QRCodeDataEditor> createState() => _QRCodeDataEditorState();
}

class _QRCodeDataEditorState extends State<QRCodeDataEditor> {

  _QRCodeType type = _QRCodeType.text;

  TextEditingController textCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'QR Code',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      // color: Theme.of(context).colorScheme.surface
                    )
                  ),
                  PopupMenuButton<_QRCodeType>(
                    child: Chip(
                      label: Text(type.name),
                      deleteIcon: Icon(RenderIcons.arrow_down),
                    ),
                    itemBuilder: (context) => List<PopupMenuEntry<_QRCodeType>>.generate(
                      _QRCodeType.values.length,
                      (index) => PopupMenuItem(
                        value: _QRCodeType.values[index],
                        child: Text(
                          _QRCodeType.values[index].name,
                          style: TextStyle(
                            color: _QRCodeType.values[index] == type
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).textTheme.bodyLarge!.color
                          ),
                        ),
                      )
                    ),
                    onSelected: (value) => setState(() => type = value),
                  )
                ],
              ),
              SizedBox(height: 24),
              TextFormField(
                controller: textCtrl,
                decoration: InputDecoration(
                  // fillColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
                  label: Text(type.name),
                  prefix: prefix != null ? Text(prefix!) : null
                ),
              ),
              Spacer(),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      child: Text('Save'),
                      onPressed: () => Navigator.of(context).pop('$prefix${textCtrl.text}'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  String? get prefix {
    switch (type) {
      case _QRCodeType.url:
        return 'https://';
      case _QRCodeType.phone:
        return 'tel://';
      case _QRCodeType.email:
        return 'mailto:';
      case _QRCodeType.sms:
        return 'sms:';
      case _QRCodeType.facetime:
        return 'https://';
      default:
        return null;
    }
  }

}

enum _QRCodeType {
  text,
  url,
  email,
  phone,
  sms,
  facetime,
}

extension _QRCodeTypeExtension on _QRCodeType {

  String get name {
    switch (this) {
      case _QRCodeType.text:
        return 'Text';
      case _QRCodeType.url:
        return 'URL';
      case _QRCodeType.email:
        return 'Email';
      case _QRCodeType.phone:
        return 'Phone';
      case _QRCodeType.sms:
        return 'SMS';
      case _QRCodeType.facetime:
        return 'Facetime';
    }
  }

}