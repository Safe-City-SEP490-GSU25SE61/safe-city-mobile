import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/community_blog/blog_service.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/helpers/debouncer_helper.dart';
import '../../../utils/helpers/media_helper.dart';
import '../../../utils/helpers/network_manager.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loaders.dart';
import '../models/blog_comment_model.dart';
import '../models/blog_models.dart';
import '../models/commune_model.dart';
import '../models/province_with_commune_model.dart';

class BlogController extends GetxController {
  static BlogController get instance => Get.find();

  final blogService = BlogService();
  final likeDebouncer = Debouncer(delay: Duration(milliseconds: 500));

  // Blog state
  RxList<BlogModel> blogs = <BlogModel>[].obs;
  RxBool isLoading = false.obs;
  bool isFetchingMore = false;
  bool hasMore = true;
  int? currentCommuneId;
  int currentPage = 1;

  // Search & filter
  final searchController = TextEditingController();
  final selectedCategory = Rxn<BlogType>();
  final blogTypeCategories = <DropdownMenuItem<BlogType>>[].obs;
  final selectedBlogType = Rxn<BlogType>();
  final RxString selectedProvince = ''.obs;
  final RxString selectedCommune = ''.obs;

  // Blog creation form
  final title = TextEditingController();
  final content = TextEditingController();
  final images = <PlatformFile>[].obs;
  final video = Rxn<PlatformFile>();
  final createBlogFormKey = GlobalKey<FormState>();

  // Comments
  RxList<CommentModel> comments = <CommentModel>[].obs;
  RxBool isCommentsLoading = false.obs;
  final comment = TextEditingController();
  final commentKey = GlobalKey<FormState>();

  final RxList<ProvinceWithCommunesModel> provinces = <ProvinceWithCommunesModel>[].obs;
  final RxList<CommuneModel> communes = <CommuneModel>[].obs;
  final Rx<FilterStatus> status = FilterStatus.initial.obs;



  @override
  void onInit() {
    super.onInit();
    loadBlogTypeCategories();
    fetchInitialDataOnce(isFirstRequest: true);
  }


  void loadBlogTypeCategories() {
    blogTypeCategories.value = BlogType.values
        .map(
          (type) => DropdownMenuItem<BlogType>(
            value: type,
            child: Text(type.viLabel),
          ),
        )
        .toList();
  }

  Future<void> fetchInitialDataOnce({
    String? provinceName,
    String? communeName,
    BlogType? type,
    bool isFirstRequest = false,
  }) async {
    try {
      isLoading.value = true;
      status.value = FilterStatus.loadingFilters;
      blogs.clear();

      if (isFirstRequest) {
        final result = await blogService.getBlogsByCommuneId(
          0,
          blogType: type?.name,
          title: searchController.text,
          isFirstRequest: true,
        );

        blogs.addAll(result);

        final cachedProvinces = blogService.cachedProvinces;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          provinces.value = cachedProvinces;
          status.value = FilterStatus.success;
        });

        return;
      }

      if (provinceName != null && communeName != null) {
        currentCommuneId = blogService.getCommuneIdByName(provinceName, communeName);
        if (kDebugMode) {
          print('[DEBUG] Resolved communeId = $currentCommuneId for $provinceName → $communeName');
        }

        if (currentCommuneId == null) {
          blogs.clear();
          status.value = FilterStatus.success;
          return;
        }

        final result = await blogService.getBlogsByCommuneId(
          currentCommuneId!,
          blogType: type?.name,
          title: searchController.text,
          isFirstRequest: false,
        );

        blogs.addAll(result);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          final selectedProv = provinces.firstWhere(
                (p) => p.name == provinceName,
            orElse: () => provinces.first,
          );
          communes.value = selectedProv.communes;
          selectedProvince.value = selectedProv.name;
          selectedCommune.value = communeName;
          status.value = FilterStatus.success;
        });
      }
    } catch (e) {
      if (kDebugMode) print('Failed to fetch filters/blogs: $e');
      status.value = FilterStatus.error;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCommunesByProvince(String provinceName) async {
    try {
      status.value = FilterStatus.loadingCommunes;

      final province = provinces.firstWhere(
            (p) => p.name == provinceName,
        orElse: () => throw Exception('Province not found'),
      );

      communes.value = province.communes;
      selectedProvince.value = province.name;
      status.value = FilterStatus.success;
    } catch (e) {
      status.value = FilterStatus.error;
      if (kDebugMode) print('Failed to fetch communes: $e');
    }
  }


  void toggleBlogLike(BlogModel blog) {
    final index = blogs.indexWhere((b) => b.id == blog.id);
    if (index == -1) return;

    final isNowLiked = !blog.isLike;
    final updatedBlog = blog.copyWith(
      isLike: isNowLiked,
      totalLike: isNowLiked ? blog.totalLike + 1 : blog.totalLike - 1,
    );

    blogs[index] = updatedBlog;
    blogs.refresh();

    likeDebouncer.run(() async {
      try {
        await blogService.toggleLike(blog.id);
      } catch (e) {
        if (kDebugMode) print('Error toggling like: $e');
        final revertedBlog = blog.copyWith(
          isLike: blog.isLike,
          totalLike: blog.totalLike,
        );
        blogs[index] = revertedBlog;
        blogs.refresh();
      }
    });
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

  void pickMedia() async {
    final result = await MediaHelper.pickMedia(
      maxImages: 10,
      maxImageSizeMB: 8,
      maxVideoSizeMB: 400,
      maxVideoDurationMinutes: 30,
    );
    if (result != null) {
      images.value = result['images'] ?? [];
      video.value = result['video'];
    }
  }

  Future<void> submitReport(String content) async {
    try {
      TFullScreenLoader.openLoadingDialog(
        "Đang tạo blog, vui lòng không đóng trang này...",
        TImages.loadingCircle,
      );

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      if (!createBlogFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }
      final blogType = selectedCategory.value?.name;
      final result = await blogService.submitBlog(
        title: title.text.trim(),
        content: content,
        type: blogType!,
        communeId: currentCommuneId!,
        images: images,
        video: video.value,
      );

      TFullScreenLoader.stopLoading();
      FocusScope.of(Get.context!).unfocus();

      if (result['success']) {
        Get.back();
        TLoaders.successSnackBar(title: "Thành công", message: "Đã tạo blog");
        title.clear();
        images.clear();
        video.value = null;
        // fetchBlogsByCommuneId(currentCommuneId!, forceRefresh: true);
      } else {
        TLoaders.errorSnackBar(
          title: 'Xảy ra lỗi rồi!',
          message:
              result['message'] ?? 'Tạo blog thất bại, vui lòng thử lại sau',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred: $e');
      }
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(
        title: 'Xảy ra lỗi rồi!',
        message: 'Đã xảy ra sự cố không xác định, vui lòng thử lại sau',
      );
    }
  }
}

