import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../common/widgets/appbar/appbar.dart';
import '../../../common/widgets/media/image_fullscreen_widget.dart';
import '../../../common/widgets/media/video_player_widget.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/formatters/formatter.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../controllers/blog_controller.dart';
import '../models/blog_models.dart';
import '../models/commune_model.dart';
import '../models/province_with_commune_model.dart';
import 'widgets/blog_comment_card.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class BlogDetailScreen extends StatelessWidget {
  final int blogId;

  const BlogDetailScreen({super.key, required this.blogId});

  @override
  Widget build(BuildContext context) {
    final blogController = Get.find<BlogController>();
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? TColors.black : TColors.white,
      appBar: TAppBar(
        showBackArrow: true,
        title: Text(
          'Chi tiết bài viết',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Obx(() {
        final blog = blogController.blogs.firstWhere(
              (b) => b.id == blogId,
          orElse: () => BlogModel(
            id: blogId,
            title: "Bài viết đang chờ xác minh",
            content: jsonEncode([
              {"insert": "Bài viết này chưa được cán bộ xã xác minh.\n"}
            ]),
            type: "pending",
            authorName: "Hệ thống",
            avatarUrl: "",
            createdAt: DateTime.now(),
            pinned: false,
            commune: CommuneModel(
              id: 0,
              name: "Chưa xác định",
            ),
            province: ProvinceWithCommunesModel(
              id: 0,
              name: "Chưa xác định",
              communes: [],
            ),
            mediaUrls: [],
            totalLike: 0,
            totalComment: 0,
            isLike: false,
            isPremium: false,
          ),
        );
        print('DEBUG: Blog mediaUrls = ${blog.mediaUrls}');

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Title
              Text(
                blog.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: dark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),

              /// Author & Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    blog.authorName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: dark ? Colors.white : Colors.black,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Iconsax.clock, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        TFormatter.formatTime(blog.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              /// Blog content
              SizedBox(
                child: quill.QuillEditor(
                  controller: quill.QuillController(
                    document: quill.Document.fromJson(jsonDecode(blog.content)),
                    selection: const TextSelection.collapsed(offset: 0),
                  ),
                  focusNode: FocusNode(),
                  scrollController: ScrollController(),
                  config: quill.QuillEditorConfig(
                    scrollable: true,
                    expands: false,
                    scrollPhysics: const NeverScrollableScrollPhysics(),
                    showCursor: false,
                    enableInteractiveSelection: false,
                    padding: EdgeInsets.zero,
                    customStyles: quill.DefaultStyles(
                      paragraph: quill.DefaultTextBlockStyle(
                        TextStyle(
                          fontSize: 14,
                          color: dark ? Colors.white : Colors.black,
                        ),
                        const quill.HorizontalSpacing(0, 0),
                        const quill.VerticalSpacing(0, 0),
                        const quill.VerticalSpacing(0, 0),
                        null,
                      ),
                    ),
                  ),
                ),
              ),

              /// Media: Hình ảnh và Video
              if (blog.mediaUrls.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Hình ảnh',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: blog.mediaUrls
                        .where((url) => !url.endsWith('.mp4'))
                        .length,
                    itemBuilder: (context, index) {
                      final imageUrls = blog.mediaUrls
                          .where((url) => !url.endsWith('.mp4'))
                          .toList();
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => FullScreenImageViewer(
                                images: imageUrls,
                                initialIndex: index,
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(imageUrls[index]),
                        ),
                      );
                    },
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                  ),
                ),
              ],

              if (blog.mediaUrls.any((url) => url.endsWith('.mp4'))) ...[
                const SizedBox(height: TSizes.md),
                const Text(
                  'Video',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AdvancedVideoPlayer(
                      videoUrl: blog.mediaUrls.firstWhere(
                        (url) => url.endsWith('.mp4'),
                      ),
                    ),
                  ),
                ),
              ],

              const Divider(height: TSizes.spaceBtwSections),

              /// Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton.icon(
                    onPressed: () => blogController.toggleBlogLike(blog),
                    icon: Icon(
                      blog.isLike ? Iconsax.like_15 : Iconsax.like_1,
                      size: 22,
                      color: blog.isLike
                          ? TColors.buttonLike
                          : TColors.darkGrey,
                    ),
                    label: Text(
                      "${blog.totalLike} Thích",
                      style: TextStyle(
                        color: blog.isLike
                            ? TColors.buttonLike
                            : TColors.darkGrey,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlogCommentCard(blogId: blog.id),
                        ),
                      );
                    },
                    icon: const Icon(
                      Iconsax.message,
                      size: 22,
                      color: TColors.darkGrey,
                    ),
                    label: Text(
                      "${blog.totalComment} Bình luận",
                      style: const TextStyle(color: TColors.darkGrey),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // TODO: Implement share functionality
                    },
                    icon: const Icon(
                      Iconsax.share,
                      size: 22,
                      color: TColors.darkGrey,
                    ),
                    label: const Text(
                      "Chia sẻ",
                      style: TextStyle(color: TColors.darkGrey),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
