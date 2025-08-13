import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../common/widgets/appbar/appbar.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../controllers/blog_controller.dart';
import 'community_blog_detail.dart';

class BlogHistoryScreen extends StatefulWidget {
  const BlogHistoryScreen({super.key});

  @override
  State<BlogHistoryScreen> createState() => _BlogHistoryScreenState();
}

class _BlogHistoryScreenState extends State<BlogHistoryScreen> {
  final blogController = Get.put(BlogController());

  @override
  void initState() {
    super.initState();
    blogController.fetchUserCreatedBlogs();
  }

  Future<void> _handleRefresh() async {
    await blogController.fetchUserCreatedBlogs();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: const TAppBar(
        title: Text('Lịch sử bài blog đã tạo'),
        showBackArrow: true,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: TColors.primary,
        child: Obx(() {
          if (blogController.isLoadingUserBlogs.value) {
            return const Center(
              child: CircularProgressIndicator(color: TColors.primary),
            );
          }

          if (blogController.userBlogs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(TImages.emptyBoxImage, width: 240, height: 240),
                  const SizedBox(height: 16),
                  const Text(
                    "Bạn chưa tạo bài blog nào",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(TSizes.md),
            itemCount: blogController.userBlogs.length,
            itemBuilder: (context, index) {
              final blog = blogController.userBlogs[index];

              return Card(
                color: isDark ? TColors.white : TColors.lightGrey,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  onTap: () {
                    Get.to(() => BlogDetailScreen(blogId: blog.id));
                  },
                  title: Text(
                    blog.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: TColors.primary,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Loại bài viết: ${blog.type}",
                        style: const TextStyle(color: Colors.black),
                      ),
                      Text(
                        "Phường/Xã: ${blog.communeName}",
                        style: const TextStyle(color: Colors.black),
                      ),
                      Text(
                        "Ngày tạo: ${DateFormat('yyyy-MM-dd HH:mm').format(blog.createdAt)}",
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                  trailing: const Icon(
                    Iconsax.arrow_right,
                    color: TColors.primary,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
