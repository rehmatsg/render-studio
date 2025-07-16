import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';

import '../rehmat.dart';

class PostSize {

  PostSize(this.size, this.type, this.icon);

  final Size size;
  final PostSizePresets type;
  final IconData icon;

  CropAspectRatio get cropRatio {
    return CropAspectRatio(ratioY: 1 / size.width, ratioX: 1 / size.height);
  }

  Map<String, dynamic> toJSON() => {
    'width': size.width,
    'height': size.height,
    'type': type.name
  };

  factory PostSize.fromJSON(Map data) {
    PostSizePresets preset = PostSizePresetsExtension.fromName(data['type']);
    return PostSize(Size(data['width'], data['height']), preset, preset.icon);
  }

}

enum PostSizePresets {
  square,
  landscape,
  instagram,
  instagramStory,
  instagramPortrait,
  instagramLandscape,
  facebook,
  pinterest,
  youtubeThumbnail,
  linkedInPost,
  linkedInPostMobile,
  snapchatStory,
}

extension PostSizePresetsExtension on PostSizePresets {

  Size get size {
    switch (this) {
      case PostSizePresets.square:
        return const Size(1080, 1080);
      case PostSizePresets.landscape:
        return const Size(1080, 566);
      case PostSizePresets.instagram:
        return const Size(1080, 1080);
      case PostSizePresets.instagramStory:
        return const Size(1080, 1920);
      case PostSizePresets.instagramPortrait:
        return const Size(1080, 1350);
      case PostSizePresets.instagramLandscape:
        return const Size(1350, 1080);
      case PostSizePresets.facebook:
        return const Size(1200, 628);
      case PostSizePresets.pinterest:
        return const Size(1000, 1500);
      case PostSizePresets.youtubeThumbnail:
        return const Size(1280, 720);
      case PostSizePresets.linkedInPost:
        return const Size(1200, 1200);
      case PostSizePresets.linkedInPostMobile:
        return const Size(1200, 628);
      case PostSizePresets.snapchatStory:
        return const Size(1080, 1920);
    }
  }

  String get title {
    switch (this) {
      case PostSizePresets.square:
        return 'Square';
      case PostSizePresets.landscape:
        return 'Landscape';
      case PostSizePresets.instagram:
        return 'Instagram';
      case PostSizePresets.instagramStory:
        return 'Instagram Story';
      case PostSizePresets.instagramPortrait:
        return 'Instagram Portrait';
      case PostSizePresets.instagramLandscape:
        return 'Instagram Landscape';
      case PostSizePresets.facebook:
        return 'Facebook';
      case PostSizePresets.pinterest:
        return 'Pinterest';
      case PostSizePresets.youtubeThumbnail:
        return 'YouTube Thumbnail';
      case PostSizePresets.linkedInPost:
        return 'LinkedIn Project';
      case PostSizePresets.linkedInPostMobile:
        return 'LinkedIn Mobile Project';
      case PostSizePresets.snapchatStory:
        return 'Snapchat Story';
    }
  }

  IconData get icon {
    switch (this) {
      case PostSizePresets.square:
        return FontAwesomeIcons.square;
      case PostSizePresets.landscape:
        return Icons.crop_16_9;
      case PostSizePresets.instagram:
        return FontAwesomeIcons.instagram;
      case PostSizePresets.instagramStory:
        return Icons.crop_portrait;
      case PostSizePresets.instagramPortrait:
        return Icons.crop_portrait_outlined;
      case PostSizePresets.instagramLandscape:
        return Icons.crop_16_9;
      case PostSizePresets.facebook:
        return FontAwesomeIcons.facebook;
      case PostSizePresets.pinterest:
        return FontAwesomeIcons.pinterest;
      case PostSizePresets.youtubeThumbnail:
        return FontAwesomeIcons.youtube;
      case PostSizePresets.linkedInPost:
        return FontAwesomeIcons.linkedin;
      case PostSizePresets.linkedInPostMobile:
        return FontAwesomeIcons.linkedinIn;
      case PostSizePresets.snapchatStory:
        return FontAwesomeIcons.snapchat;
    }
  }

  String get name {
    switch (this) {
      case PostSizePresets.square:
        return 'square';
      case PostSizePresets.landscape:
        return 'landscape';
      case PostSizePresets.instagram:
        return 'instagram';
      case PostSizePresets.instagramStory:
        return 'instagram-story';
      case PostSizePresets.instagramPortrait:
        return 'instagram-portrait';
      case PostSizePresets.instagramLandscape:
        return 'instagram-landscape';
      case PostSizePresets.facebook:
        return 'facebook';
      case PostSizePresets.pinterest:
        return 'pinterest';
      case PostSizePresets.youtubeThumbnail:
        return 'youtube-thumbnail';
      case PostSizePresets.linkedInPost:
        return 'linkedin-post';
      case PostSizePresets.linkedInPostMobile:
        return 'linkedin-post-mobile';
      case PostSizePresets.snapchatStory:
        return 'snapchat-story';
    }
  }

  static PostSizePresets fromName(String name) {
    switch (name) {
      case 'square':
        return PostSizePresets.square;
      case 'landscape':
        return PostSizePresets.landscape;
      case 'instagram':
        return PostSizePresets.instagram;
      case 'instagram-story':
        return PostSizePresets.instagramStory;
      case 'instagram-portrait':
        return PostSizePresets.instagramPortrait;
      case 'instagram-landscape':
        return PostSizePresets.instagramLandscape;
      case 'facebook':
        return PostSizePresets.facebook;
      case 'pinterest':
        return PostSizePresets.pinterest;
      case 'youtube-thumbnail':
        return PostSizePresets.youtubeThumbnail;
      case 'linkedin-post':
        return PostSizePresets.linkedInPost;
      case 'linkedin-post-mobile':
        return PostSizePresets.linkedInPostMobile;
      case 'snapchat-story':
        return PostSizePresets.snapchatStory;
      default:
        return PostSizePresets.landscape;
    }
  }

  PostSize toSize() {
    return PostSize(size, this, icon);
  }

}