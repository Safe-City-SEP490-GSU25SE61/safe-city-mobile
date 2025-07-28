import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../data/services/community_blog/blog_service.dart';
import '../models/blog_comment_model.dart';
import '../models/blog_models.dart';

class BlogController extends GetxController {
  static BlogController get instance => Get.find();

  final blogService = BlogService();

  RxList<BlogModel> blogs = <BlogModel>[].obs;
  RxList<CommentModel> comments = <CommentModel>[].obs;
  RxBool isLoading = false.obs;
  RxBool isCommentsLoading = false.obs;
  final comment = TextEditingController();
  final commentKey = GlobalKey<FormState>();

  Future<void> fetchBlogsByCommuneId(int communeId) async {
    try {
      isLoading.value = true;
      blogs.value = await blogService.getBlogsByCommuneId(communeId);
    } catch (e) {
      blogs.clear();
      if (kDebugMode) print('Error fetching blogs: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleBlogLike(BlogModel blog) async {
    final index = blogs.indexWhere((b) => b.id == blog.id);
    if (index == -1) return;

    try {
      await blogService.toggleLike(blog.id);

      final updatedBlog = blog.copyWith(
        isLike: !blog.isLike,
        totalLike: blog.isLike ? blog.totalLike - 1 : blog.totalLike + 1,
      );

      blogs[index] = updatedBlog;
      blogs.refresh();
    } catch (e) {
      if (kDebugMode) print('Error toggling like: $e');
    }
  }

  Future<void> fetchCommentsByBlogId(int blogId) async {
    try {
      isCommentsLoading.value = true;
      comments.value = await blogService.getCommentsByBlogId(blogId);
    } catch (e) {
      comments.clear();
      if (kDebugMode) print('Error fetching comments: $e');
    } finally {
      isCommentsLoading.value = false;
    }
  }

  Future<void> postComment(int blogId, String content) async {
    try {
      await blogService.postComment(blogId: blogId, content: content);
      await fetchCommentsByBlogId(blogId);

      final index = blogs.indexWhere((b) => b.id == blogId);
      if (index != -1) {
        final updatedBlog = blogs[index].copyWith(
          totalComment: blogs[index].totalComment + 1,
        );
        blogs[index] = updatedBlog;
        blogs.refresh();
      }
    } catch (e) {
      if (kDebugMode) print('Error posting comment: $e');
      rethrow;
    }
  }
}
