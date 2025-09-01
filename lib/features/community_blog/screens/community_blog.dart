import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:safe_city_mobile/features/community_blog/screens/widgets/community_blog_card.dart';
import 'package:safe_city_mobile/features/community_blog/screens/create_community_blog.dart';
import 'package:safe_city_mobile/features/community_blog/screens/widgets/location_filter_button.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../common/widgets/popup/popup_modal.dart';
import '../../../utils/constants/sizes.dart';
import '../controllers/blog_controller.dart';
import 'community_blog_history.dart';

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
    // _initData(isFirstRequest: true);
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    await blogController.fetchInitialDataOnce(isFirstRequest: true);
  }

  @override
  Widget build(BuildContext context) {
    final popUpModal = PopUpModal.instance;
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      backgroundColor: dark ? TColors.black : TColors.lightGrey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Blog cộng đồng', style: TextStyle(fontSize: 20)),
        actions: [
          InkWell(
            onTap: () => Get.to(() => BlogHistoryScreen()),
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: const [
                  Icon(Iconsax.refresh, color: Colors.black, size: 20),
                  SizedBox(width: 6),
                  Text(
                    'Lịch sử',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: TSizes.mediumSpace),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _handleRefresh,
            color: TColors.primary,
            child: Column(
              children: [
                Obx(() {
                  final loading = blogController.isLoading.value;
                  return IgnorePointer(
                    ignoring: loading,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 16, 10, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: blogController.searchController,
                              style: const TextStyle(color: Colors.black),
                              onFieldSubmitted: (value) async {
                                if (loading) return;
                                final searchText = value.trim();
                                final selectedCommune =
                                    blogController.selectedCommune.value;
                                final selectedProvince =
                                    blogController.selectedProvince.value;

                                if (selectedProvince.isNotEmpty &&
                                    selectedCommune.isNotEmpty) {
                                  final communeId = blogController.blogService
                                      .getCommuneIdByName(
                                        selectedProvince,
                                        selectedCommune,
                                      );

                                  if (communeId != null) {
                                    blogController.currentCommuneId = communeId;
                                    await blogController.fetchInitialDataOnce(
                                      provinceName: selectedProvince,
                                      communeName: selectedCommune,
                                      isFirstRequest: false,
                                      searchQuery: searchText,
                                    );
                                  }
                                } else {
                                  await blogController.fetchInitialDataOnce(
                                    isFirstRequest: false,
                                    searchQuery: searchText,
                                  );
                                }
                              },
                              decoration: InputDecoration(
                                hintText: 'Tìm bài blog...',
                                hintStyle: const TextStyle(color: Colors.black),
                                prefixIcon: const Icon(Iconsax.search_normal),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          LocationFilterButton(
                            onApply: () {
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                Expanded(
                  child: Obx(() {
                    if (!blogController.isLoading.value &&
                        blogController.blogs.isEmpty) {
                      return const Center(
                        child: Text(
                          'Không có bài viết',
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      itemCount: blogController.blogs.length,
                      itemBuilder: (context, index) {
                        final blog = blogController.blogs[index];
                        return CommunityBlogCard(blogId: blog.id);
                      },
                    );
                  }),
                ),
              ],
            ),
          ),

          Obx(() {
            if (!blogController.isLoading.value) return const SizedBox.shrink();
            return Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: const Center(
                  child: CircularProgressIndicator(color: TColors.primary),
                ),
              ),
            );
          }),
        ],
      ),
      floatingActionButton: Obx(() {
        if (blogController.isLoading.value) return const SizedBox.shrink();
        return FloatingActionButton(
          heroTag: 'createBtn',
          onPressed: () {
            if (!blogController.isPremium.value) {
              popUpModal.showContentEmptyDialog(
                title: 'Thông báo',
                message: 'Bạn phải đăng ký gói để sử dụng chức năng này',
              );
              return;
            }
            Get.to(() => CreateBlogScreen());
          },
          backgroundColor: TColors.white,
          child: const Icon(Iconsax.add, color: TColors.primary, size: 28),
        );
      }),
    );
  }
}
