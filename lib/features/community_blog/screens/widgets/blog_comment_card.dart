import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/formatters/formatter.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/popups/loaders.dart';
import '../../../../utils/validators/validation.dart';
import '../../controllers/blog_controller.dart';

class BlogCommentCard extends StatefulWidget {
  final int blogId;

  const BlogCommentCard({super.key, required this.blogId});

  @override
  State<BlogCommentCard> createState() => _BlogCommentCardState();
}

class _BlogCommentCardState extends State<BlogCommentCard> {
  final blogController = Get.find<BlogController>();

  @override
  void initState() {
    super.initState();
    blogController.fetchCommentsByBlogId(widget.blogId);
  }

  Future<void> _handleRefresh() async {
    await blogController.fetchCommentsByBlogId(widget.blogId);
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: TAppBar(title: const Text('Bình luận'), showBackArrow: true),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              color: TColors.primary,
              child: Obx(() {
                if (blogController.isCommentsLoading.value) {
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 80),
                    child: Center(
                      child: CircularProgressIndicator(color: TColors.primary),
                    ),
                  );
                }

                final comments = blogController.comments;

                if (comments.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 200),
                      Center(child: Text('Chưa có bình luận nào.')),
                    ],
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(TSizes.md),
                  itemCount: comments.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return ListTile(
                      title: Text(
                        comment.authorName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: dark ? Colors.white : Colors.black,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comment.content,
                            style: TextStyle(
                              color: dark ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            TFormatter.formatTime(comment.createdAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ),

          /// Comment input
          Form(
            key: blogController.commentKey,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: blogController.comment,
                      decoration: const InputDecoration(
                        hintText: 'Viết bình luận...',
                        border: InputBorder.none,
                      ),
                      validator: TValidator.validateComment,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      if (blogController.commentKey.currentState!.validate()) {
                        FocusScope.of(context).unfocus();
                        final content = blogController.comment.text.trim();
                        try {
                          await blogController.postComment(
                            widget.blogId,
                            content,
                          );
                          blogController.comment.clear();
                        } catch (e) {
                          TLoaders.warningSnackBar(
                            title: 'Tính năng chưa được bật',
                            message:
                                'Vui lòng đăng nhập bằng Email và Mật khẩu',
                          );
                        }
                      }
                    },
                    icon: Icon(Iconsax.send_1, color: TColors.buttonLike),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
