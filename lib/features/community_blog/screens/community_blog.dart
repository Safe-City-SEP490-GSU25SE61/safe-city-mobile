import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:safe_city_mobile/features/community_blog/screens/widgets/community_blog_card.dart';
import 'package:safe_city_mobile/features/community_blog/screens/widgets/location_filter_button.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../utils/constants/sizes.dart';
import '../controllers/blog_controller.dart';
import '../controllers/blog_filter_controller.dart';

class CommunityBlogScreen extends StatefulWidget {
  const CommunityBlogScreen({super.key});

  @override
  State<CommunityBlogScreen> createState() => _CommunityBlogScreenState();
}

class _CommunityBlogScreenState extends State<CommunityBlogScreen> {
  final filterController = Get.put(BlogFilterController());
  final blogController = Get.put(BlogController());

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await filterController.fetchProvinces();

    final selectedCommune = filterController.selectedCommune.value;
    final selectedProvince = filterController.selectedProvince.value;
    final provinceIndex = filterController.provinces.indexOf(selectedProvince);

    if (provinceIndex != -1 && selectedCommune.isNotEmpty) {
      final communeId = await filterController.service.getCommuneIdByName(
        selectedCommune,
        provinceIndex + 1,
      );

      if (communeId != null) {
        await blogController.fetchBlogsByCommuneId(communeId);
      }
    }
  }

  Future<void> _handleRefresh() async {
    await _initData();
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
        child: Obx(() {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
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
                    const SizedBox(width: 12),
                    LocationFilterButton(onApply: _initData),
                  ],
                ),
              ),

              // Blog Cards
              if (blogController.blogs.isEmpty)
                const Center(
                  child: Text(
                    'Không có bài viết',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              else
                ...blogController.blogs.map(
                  (blog) => CommunityBlogCard(blogId: blog.id),
                ),
            ],
          );
        }),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Handle button press
        },
        backgroundColor: TColors.white,
        child: const Icon(Icons.add,color: TColors.primary,),
      ),
    );
  }
}
