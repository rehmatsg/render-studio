import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_io/io.dart';
import 'package:file_picker/file_picker.dart' as filepicker;
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../rehmat.dart';

enum FileType {
  dynamic,
  image,
  video,
  svg
}

extension FileTypeExtension on FileType {

  String get type {
    switch (this) {
      case FileType.image:
        return 'image';
      case FileType.video:
        return 'video';
      case FileType.svg:
        return 'svg';
      default:
        return 'image';
    }
  }

  static FileType fromString(String type) {
    switch (type) {
      case 'image':
        return FileType.image;
      case 'video':
        return FileType.video;
      case 'svg':
        return FileType.svg;
      default:
        return FileType.image;
    }
  }

}

class FilePicker {

  static Future<File?> pick({
    /// Type of file to select
    /// • image
    /// • video
    /// • svg
    FileType? type,
    bool crop = false,
    /// If `crop` is `true` and `forceCrop` is `true`, the user will be forced to crop the image.
    /// If `false`, the provided `cropRatio` will be used the initial crop ratio.
    bool forceCrop = true,
    CropAspectRatio? cropRatio,
    BuildContext? context,
  }) async {
    final ImagePicker _picker = ImagePicker();
    XFile? xFile;
    File file;
    switch (type) {
      case FileType.image:
        xFile = await _picker.pickImage(
          source: ImageSource.gallery,
        );
        break;
      case FileType.video:
        xFile = await _picker.pickVideo(
          source: ImageSource.gallery,
        );
        break;
      case FileType.svg:
        filepicker.FilePickerResult? result = await filepicker.FilePicker.platform.pickFiles(
          type: filepicker.FileType.custom,
          allowedExtensions: ['svg'],
        );
        if (result != null && result.files.isNotEmpty) {
          file = File(result.files.single.path!);
          return file;
        } else {
          return null;
        }
      default:
        return null;
    }
    if (xFile == null) return null;
    file = File(xFile.path);
    if (context != null && crop && type == FileType.image) {
      try {
        return await FilePicker.crop(context, file: file, ratio: cropRatio, forceCrop: forceCrop);
      } catch (e, stacktrace) {
        analytics.logError(e, cause: 'FilePicker.crop failed', stacktrace: stacktrace);
        return null;
      }
    } else {
      return file;
    }
    // filepicker.FileType fileType;
    // List<String>? allowedExtensions;
    // switch (type) {
    //   case FileType.image:
    //     fileType = filepicker.FileType.image;
    //     break;
    //   case FileType.video:
    //     fileType = filepicker.FileType.video;
    //     break;
    //   case FileType.svg:
    //     fileType = filepicker.FileType.custom;
    //     allowedExtensions = ['svg'];
    //     break;
    //   default:
    //     fileType = filepicker.FileType.custom;
    // }
    // filepicker.FilePickerResult? result = await filepicker.FilePicker.platform.pickFiles(
    //   allowCompression: false,
    //   type: fileType,
    //   allowedExtensions: allowedExtensions
    // );
  }

  /// Shows a bottom sheet for options to select image from unsplash or pick from gallery
  static Future<File?> imagePicker(BuildContext context, {
    bool crop = false,
    CropAspectRatio? cropRatio,
    /// If `crop` is `true` and `forceCrop` is `true`, the user will be forced to crop the image.
    /// If `false`, the provided `cropRatio` will be used the initial crop ratio.
    bool forceCrop = true,
  }) async {
    String? option = await Alerts.optionsBuilder(
      context,
      title: 'Image',
      options: [
        if (app.remoteConfig.enableUnsplash) AlertOption(
          title: 'Unsplash',
          id: 'unsplash'
        ),
        AlertOption(
          title: 'Gallery',
          id: 'gallery'
        ),
      ]
    );
    if (option == null) return null;
    switch (option) {
      case 'unsplash':
        return await UnsplashImagePicker.getImage(context, crop: crop, cropRatio: cropRatio, forceCrop: forceCrop);
      case 'gallery':
        return await FilePicker.pick(
          context: context,
          crop: crop,
          cropRatio: cropRatio,
          type: FileType.image,
          forceCrop: forceCrop
        );
      default:
        return null;
    }
  }

  static Future<File?> crop(BuildContext context, {
    required File file,
    CropAspectRatio? ratio,
    bool forceCrop = true
  }) async {
    Size? size = await AssetX.getDimensions(file);
    double? _ratio = (ratio != null) ? ratio.ratioX / ratio.ratioY : null;
    double? rectWidth;
    double? rectHeight;
    double? rectX;
    double? rectY;
    if (_ratio != null && size != null) {
      if (size.width > size.height) {
        rectWidth = size.height * _ratio;
        rectHeight = size.height;
        rectX = (size.width - rectWidth) / 2;
        rectY = 0;
      } else {
        rectWidth = size.width;
        rectHeight = size.width / _ratio;
        rectX = 0;
        rectY = (size.height - rectHeight) / 2;
      }
    }
    AndroidUiSettings uiSettings = AndroidUiSettings(
      backgroundColor: Palette.of(context).surface,
      cropFrameColor: Palette.of(context).primary,
      cropGridColor: Palette.of(context).onPrimaryContainer,
      dimmedLayerColor: Palette.of(context).surfaceContainerLow.withValues(alpha: 0.5),
      showCropGrid: true,
      activeControlsWidgetColor: Palette.of(context).primary,
      toolbarColor: Theme.of(context).appBarTheme.backgroundColor,
      toolbarWidgetColor: Theme.of(context).appBarTheme.foregroundColor,
      cropFrameStrokeWidth: 3,
      cropGridStrokeWidth: 2,
      toolbarTitle: 'Crop Image',
      lockAspectRatio: forceCrop,
    );
    IOSUiSettings iosUiSettings = IOSUiSettings(
      aspectRatioLockEnabled: forceCrop,
      // aspectRatioLockDimensionSwapEnabled: !forceCrop,
      resetAspectRatioEnabled: !forceCrop,
      rotateButtonsHidden: false,
      aspectRatioPickerButtonHidden: forceCrop,
      rectWidth: rectWidth,
      rectHeight: rectHeight,
      rectX: rectX,
      rectY: rectY,
    );
    CroppedFile? _croppedFile = await ImageCropper().cropImage(
      sourcePath: file.path,
      uiSettings: [
        uiSettings,
        iosUiSettings
      ],
      aspectRatio: forceCrop ? ratio : null,
      compressFormat: ImageCompressFormat.png
    );
    if (_croppedFile != null) return File(_croppedFile.path);
    else return null;
  }

  static Future<String> getRandomTempPath({
    String extension = '.temp'
  }) async {
    var tempFile = await getTemporaryDirectory();
    String savePath = '${tempFile.path}/${Constants.generateID()}.$extension';
    return savePath;
  }

  /// Downloads a file from the internet and returns the file path
  static Future<File> downloadFile(String url, {
    Map<String, dynamic>? headers,
    FileType type = FileType.image,
    /// If `true`, the file will be precached for use in Image widgets
    /// [context] is required if [precache] is `true`
    /// Only works for [FileType.image]
    bool precache = false,
    BuildContext? context,
    /// Returns the download progress
    void onProgress(double progress)?,
    String? savePath
  }) async {
    try {

      if (savePath == null) {
        var tempFile = await getTemporaryDirectory();
        savePath = '${tempFile.path}/${Constants.generateID()}.temp';
      }

      File file = File(savePath);

      await Dio().download(
        url,
        savePath,
        options: Options(
          headers: headers,
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) => status != null && status < 500,
        ),
        onReceiveProgress: (int received, int total) {
          double progress = received / total;
          onProgress?.call(progress);
        },
      );

      if (precache && type == FileType.image && context != null) {
        try {
          await precacheImage(FileImage(file), context);
        } catch (e, stacktrace) {
          analytics.logError(e, cause: 'Failed to precache image', stacktrace: stacktrace);
        }
      }

      return file;
    } catch (e, stacktrace) {
      print('Failed to download asset: $e');
      analytics.logError(e, cause: 'Failed to download asset', stacktrace: stacktrace);
      throw Exception('Failed to download asset');
    }
  }

}