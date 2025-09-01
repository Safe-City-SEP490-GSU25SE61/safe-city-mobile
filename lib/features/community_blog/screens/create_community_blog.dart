import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:safe_city_mobile/common/widgets/appbar/appbar.dart';
import '../../../common/widgets/popup/popup_modal.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/constants/text_strings.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../../utils/popups/loaders.dart';
import '../../../utils/validators/validation.dart';
import '../controllers/blog_controller.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class CreateBlogScreen extends StatefulWidget {
  const CreateBlogScreen({super.key});

  @override
  State<CreateBlogScreen> createState() => _CreateBlogScreenState();
}
class _CreateBlogScreenState extends State<CreateBlogScreen> {
  late quill.QuillController _quillController;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _quillController = quill.QuillController.basic();
  }

  @override
  void dispose() {
    _quillController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    // 🔥 TODO: Add your API call here to refresh membership data
  }

  @override
  Widget build(BuildContext context) {
    final popUpModal = PopUpModal.instance;
    final dark = THelperFunctions.isDarkMode(context);
    final blogController = Get.put(BlogController());
    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text(
          'Tạo bài blog mới',
        ),
      ),

      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: TColors.primary,
        child: ListView(
          padding: const EdgeInsets.all(TSizes.mediumSpace),
          children: [
            Form(
              key: blogController.createBlogFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Nhóm loại blog
                  Obx(
                        () => DropdownButtonFormField<BlogType>(
                      decoration: InputDecoration(
                        label: RichText(
                          text: TextSpan(
                            text: 'Nhóm loại blog ',
                            style: TextStyle(
                              color: dark ? Colors.white : TColors.darkerGrey,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            children: const [
                              TextSpan(
                                text: '*',
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        prefixIcon: const Icon(Iconsax.category),
                      ),
                      value: blogController.selectedCategory.value,
                      items: blogController.blogTypeCategories,
                      onChanged: (value) {
                        blogController.selectedCategory.value = value;
                      },
                      validator: (value) => TValidator.validateDropdown(
                        "nhóm loại blog",
                        value?.viLabel,
                      ),
                    ),
                  ),


                  const SizedBox(height: TSizes.spaceBtwInputFields),

                  /// Tiêu đề
                  TextFormField(
                    controller: blogController.title,
                    decoration: InputDecoration(
                      label: RichText(
                        text: TextSpan(
                          text: 'Tiêu đề ',
                          style: TextStyle(
                            color: dark ? Colors.white : TColors.darkerGrey,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: '*',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      prefixIcon: const Icon(Iconsax.edit),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                    validator: TValidator.validateBlogTitle,
                  ),
                  const SizedBox(height: TSizes.spaceBtwInputFields),

                  /// Nội dung
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: RichText(
                          text: TextSpan(
                            text: 'Nội dung chi tiết ',
                            style: TextStyle(
                              color: dark ? Colors.white : Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            children: const [
                              TextSpan(
                                text: '*',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      quill.QuillSimpleToolbar(
                        controller: _quillController,
                        config: quill.QuillSimpleToolbarConfig(
                          showUndo: true,
                          showRedo: true,
                          multiRowsDisplay: false,
                          color: dark? TColors.dark:Colors.white,
                          showHeaderStyle: false,
                          showFontSize: false,
                          showColorButton: false,
                          showBackgroundColorButton: false,
                          showAlignmentButtons: true,
                          showSuperscript: false,
                          showSubscript: false,
                          showListCheck: false,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        height: 400,
                        padding: const EdgeInsets.all(8),
                        child: quill.QuillEditor(
                          controller: _quillController,
                          focusNode: _focusNode,
                          scrollController: _scrollController,
                          config: const quill.QuillEditorConfig(
                            expands: false,
                            padding: EdgeInsets.zero,
                            placeholder: 'Nhập nội dung blog...',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TSizes.spaceBtwInputFields),

                  /// Bằng chứng
                  RichText(
                    text: TextSpan(
                      text: 'Phương tiện ',
                      style: TextStyle(
                        color: dark ? Colors.white : Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: TSizes.sm),
                  GestureDetector(
                    onTap: blogController.pickMedia,
                    child: Obx(() {
                      final hasMedia =
                          blogController.images.isNotEmpty ||
                              blogController.video.value != null;

                      return Container(
                        width: double.infinity,
                        height: 140,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: hasMedia
                            ? ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            ...blogController.images
                                .asMap()
                                .entries
                                .map((entry) {
                              final index = entry.key;
                              final file = entry.value;

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius:
                                      BorderRadius.circular(8),
                                      child: Image.file(
                                        File(file.path!),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () => blogController
                                            .images
                                            .removeAt(index),
                                        child: const Icon(
                                          Iconsax.close_circle,
                                          color: Colors.redAccent,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            if (blogController.video.value != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.black12,
                                        borderRadius:
                                        BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Iconsax.video,
                                        size: 40,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () =>
                                        blogController.video.value =
                                        null,
                                        child: const Icon(
                                          Iconsax.close_circle,
                                          color: Colors.redAccent,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        )
                            : Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Iconsax.document_upload,
                              size: 36,
                              color: dark
                                  ? TColors.lightDarkGrey
                                  : TColors.darkerGrey,
                            ),
                            const SizedBox(height: 12),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                    "Nhấn để tải lên hình ảnh hoặc video cho blog.",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: dark
                                          ? TColors.lightDarkGrey
                                          : TColors.darkerGrey,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Tối đa ",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: dark
                                          ? TColors.white
                                          : TColors.darkGrey,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "10 bức ảnh",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: dark
                                          ? TColors.lightDarkGrey
                                          : TColors.darkerGrey,
                                    ),
                                  ),
                                  TextSpan(
                                    text: " hoặc ",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: dark
                                          ? TColors.white
                                          : TColors.darkGrey,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "1 video không quá 400MB",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: dark
                                          ? TColors.lightDarkGrey
                                          : TColors.darkerGrey,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: TSizes.spaceBtwItems),

                  /// Gửi báo cáo
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                      ),
                      onPressed: () {
                        popUpModal.showConfirmCancelDialog(
                          title: 'Lưu ý khi gửi blog',
                          message: TTexts.createBlogNotice,
                          onConfirm: () {
                            final content = _quillController.document.toPlainText().trim();
                            if (content.isEmpty) {
                              TLoaders.warningSnackBar(
                                title: 'Vui lòng nhập nội dung chi tiết cho blog',
                                message: 'Nội dung chi tiết không được để trống',
                              );
                              return;
                            }
                            final deltaJson = jsonEncode(_quillController.document.toDelta().toJson());
                            blogController.createNewBlogPost(deltaJson);
                          },
                          storageKey: 'hide_create_blog_notice',
                        );
                      },
                      child: const Text("Tạo blog mới"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
