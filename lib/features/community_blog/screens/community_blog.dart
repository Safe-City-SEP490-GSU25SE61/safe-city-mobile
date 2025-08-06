import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:safe_city_mobile/features/community_blog/screens/widgets/community_blog_card.dart';
import 'package:safe_city_mobile/features/community_blog/screens/widgets/create_community_blog.dart';
import 'package:safe_city_mobile/features/community_blog/screens/widgets/location_filter_button.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../utils/constants/sizes.dart';
import '../controllers/blog_controller.dart';

class CommunityBlogScreen extends StatefulWidget {
  const CommunityBlogScreen({super.key});

  @override
  State<CommunityBlogScreen> createState() => _CommunityBlogScreenState();
}

class _CommunityBlogScreenState extends State<CommunityBlogScreen> {
  final blogController = Get.put(BlogController());
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initData() async {
    await blogController.fetchInitialDataOnce();
  }

  Future<void> _handleRefresh() async {
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? TColors.black : TColors.lightGrey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Blog cộng đồng',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [const SizedBox(width: TSizes.mediumSpace)],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: TColors.primary,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: blogController.searchController,
                      style: const TextStyle(color: Colors.black),
                      onFieldSubmitted: (value) async {
                        final selectedCommune = blogController.selectedCommune.value;
                        final selectedProvince = blogController.selectedProvince.value;

                        if (selectedProvince.isNotEmpty && selectedCommune.isNotEmpty) {
                          final communeId = blogController.blogService.getCommuneIdByName(
                            selectedProvince,
                            selectedCommune,
                          );

                          if (communeId != null) {
                            blogController.currentCommuneId = communeId;
                            await blogController.fetchInitialDataOnce();
                          }
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Tìm bài blog...',
                        hintStyle: const TextStyle(color: Colors.black),
                        prefixIcon: const Icon(Iconsax.search_normal),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  LocationFilterButton(onApply: _initData),
                ],
              ),
            ),

            // Blog List (Scrollable)
            Expanded(
              child: Obx(() {
                return ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  children: [
                    if (blogController.isLoading.value )
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 80),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: TColors.primary,
                          ),
                        ),
                      ),

                    if (blogController.blogs.isEmpty &&
                        !blogController.isLoading.value)
                      const Center(
                        child: Text(
                          'Không có bài viết',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),

                    ...blogController.blogs.map(
                          (blog) => CommunityBlogCard(blogId: blog.id),
                    ),

                    if (blogController.isFetchingMore)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),

      // 2 Floating Action Buttons
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'historyBtn',
            onPressed: () {
              // TODO: Navigate to HistoryBlogScreen
              // Example: Get.to(() => HistoryBlogScreen());
            },
            backgroundColor: TColors.white,
            child: const Icon(Iconsax.rotate_left,
                color: TColors.primary, size: 24),
          ),
          const SizedBox(height: TSizes.mediumLargeSpace),
          FloatingActionButton(
            heroTag: 'createBtn',
            onPressed: () => Get.to(() => CreateBlogScreen()),
            backgroundColor: TColors.white,
            child:
            const Icon(Iconsax.add, color: TColors.primary, size: 28),
          ),
        ],
      ),
    );
  }
}

