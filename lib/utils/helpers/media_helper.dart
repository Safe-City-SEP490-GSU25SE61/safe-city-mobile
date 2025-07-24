import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

import '../popups/loaders.dart';

class MediaHelper {
  static Future<Map<String, dynamic>?> pickMedia() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4'],
    );

    if (result == null) return null;

    List<PlatformFile> images = [];
    PlatformFile? video;

    for (var file in result.files) {
      final ext = file.extension;
      final isImage = ['jpg', 'jpeg', 'png'].contains(ext);
      final isVideo = ext == 'mp4';

      if (isImage) {
        if (images.length >= 3) {
          TLoaders.warningSnackBar(
            title: "Giới hạn ảnh",
            message: "Chỉ được chọn tối đa 3 ảnh.",
          );
          return null;
        }
        if (file.size > 8 * 1024 * 1024) {
          TLoaders.warningSnackBar(
            title: "Ảnh quá lớn",
            message: "${file.name} vượt quá 8MB.",
          );
          return null;
        }
        images.add(file);
      } else if (isVideo) {
        if (video != null) {
          TLoaders.warningSnackBar(
            title: "Chỉ 1 video",
            message: "Chỉ được chọn tối đa 1 video.",
          );
          return null;
        }
        if (file.size > 200 * 1024 * 1024) {
          TLoaders.warningSnackBar(
            title: "Video quá lớn",
            message: "${file.name} vượt quá 200MB.",
          );
          return null;
        }

        final videoFile = File(file.path!);
        final controller = VideoPlayerController.file(videoFile);
        await controller.initialize();
        final duration = controller.value.duration;
        controller.dispose();

        if (duration.inMinutes > 5) {
          TLoaders.warningSnackBar(
            title: "Video quá dài",
            message: "Video dài hơn 5 phút.",
          );
          return null;
        }

        video = file;
      } else {
        TLoaders.warningSnackBar(
          title: "Định dạng không hợp lệ",
          message: "${file.name} không được hỗ trợ.",
        );
        return null;
      }
    }

    return {'images': images, 'video': video};
  }
}
