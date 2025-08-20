import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:safe_city_mobile/utils/constants/colors.dart';

import '../../../../utils/constants/sizes.dart';
import '../../../../utils/formatters/formatter.dart';
import '../../controllers/blog_controller.dart';
import 'blog_comment_card.dart';
import '../community_blog_detail.dart';

class CommunityBlogCard extends StatelessWidget {
  final int blogId;

  const CommunityBlogCard({super.key, required this.blogId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BlogController>();
    return Obx(() {
      final blog = controller.blogs.firstWhere((b) => b.id == blogId);
      final quillDoc = quill.Document.fromJson(jsonDecode(blog.content));
      final plainText = quillDoc.toPlainText().trim();
      return GestureDetector(
        onTap: () => Get.to(() => BlogDetailScreen(blogId: blog.id)),
        child: Card(
          color: TColors.white,
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Inside Column(children: [...])
                if (blog.pinned) ...[
                  Row(
                    children: [
                      Icon(Iconsax.star1, size: 16, color: TColors.primary),
                      SizedBox(width: 4),
                      Text(
                        'Bài viết được ghim',
                        style: TextStyle(
                          fontSize: 12,
                          color: TColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],

                /// Author & CreatedAt
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      blog.authorName,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
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
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: TSizes.smallSpace),

                /// Blog title
                Text(
                  blog.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: TSizes.smallSpace),

                /// Blog description
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: plainText.length > 160
                            ? '${plainText.substring(0, 160)}...'
                            : plainText,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      if (plainText.length > 160)
                        const TextSpan(
                          text: ' Đọc thêm',
                          style: TextStyle(
                            fontSize: 14,
                            color: TColors.primary,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: TSizes.smallSpace),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      blog.typeInVietnamese,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const Divider(height: 10),

                /// Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton.icon(
                      onPressed: () => controller.toggleBlogLike(blog),
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
                      onPressed: () {},
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
          ),
        ),
      );
    });
  }
}
