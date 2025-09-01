import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:iconsax/iconsax.dart';
import 'package:safe_city_mobile/features/virtual_escort/screens/virtual_escort_sos.dart';
import 'package:safe_city_mobile/features/virtual_escort/screens/widgets/virtual_escort_group_create.dart';
import 'package:safe_city_mobile/features/virtual_escort/screens/widgets/virtual_escort_group_card.dart';
import 'package:safe_city_mobile/features/virtual_escort/screens/widgets/sugesstion_title.dart';
import 'package:safe_city_mobile/features/virtual_escort/screens/virtual_escort_group_detail.dart';
import 'package:safe_city_mobile/utils/constants/image_strings.dart';
import 'package:safe_city_mobile/utils/constants/sizes.dart';

import '../../../common/widgets/shimmers/virtual_escort_card_shimmer.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/formatters/formatter.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../../utils/popups/loaders.dart';
import '../controllers/virtual_escort_group_controller.dart';

class VirtualEscortScreen extends StatelessWidget {
  const VirtualEscortScreen({super.key});

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    final controller = Get.put(VirtualEscortGroupController());
    controller.fetchMyGroups();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VirtualEscortGroupController());
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  Lottie.asset(
                    TImages.virtualEscortBkg,
                    height: 280,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Giám sát an toàn',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              // TODO: Handle Lịch sử
                            },
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                children: const [
                                  Icon(
                                    Iconsax.refresh,
                                    color: Colors.black,
                                    size: 20,
                                  ),
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 100)),

            if (controller.groups.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'Giám sát an toàn của tôi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: dark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: TSizes.mediumSpace)),
            ],

            Obx(() {
              try {
                if (controller.isLoadingGroup.value) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const VirtualEscortGroupCardShimmer(),
                      childCount: 1,
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final group = controller.groups[index];
                    return VirtualEscortGroupCard(
                      group: group,
                      onTap: () => Get.to(
                        () => VirtualEscortGroupDetailPage(groupId: group.id),
                      ),
                    );
                  }, childCount: controller.groups.length),
                );
              } catch (e) {
                return SliverToBoxAdapter(
                  child: Text('Error: $e', style: TextStyle(color: Colors.red)),
                );
              }
            }),

            SliverToBoxAdapter(child: SizedBox(height: TSizes.mediumSpace)),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Các gợi ý tạo giám sát',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: dark ? Colors.white : Colors.black,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showJoinGroupDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Tham gia nhóm',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(10),
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed([
                  const SizedBox(height: 12),
                  buildSuggestionTile(
                    title: 'Cá nhân',
                    description:
                        'Tự tạo cho mình lộ trình di chuyển và kích hoạt SOS nếu gặp bất trắc',
                    icon: Iconsax.user,
                    onTap: () => Get.dialog(
                      CreateVirtualEscortGroupDialog(),
                      barrierDismissible: false,
                    ),
                    // onTap: () => Get.to(() =>VirtualEscortSosScreen()),
                    bkgColor: TColors.personalEscortBkg,
                    iconColor: TColors.personalEscortIcon,
                  ),
                  const SizedBox(height: 10),
                  buildSuggestionTile(
                    title: 'Gia đình',
                    description:
                        'Thành viên trong gia đình tạo các lộ trình di chuyển và giám sát lẫn nhau',
                    icon: Iconsax.home,
                    onTap: () => Get.dialog(
                      CreateVirtualEscortGroupDialog(),
                      barrierDismissible: false,
                    ),
                    bkgColor: TColors.familyEscortBkg,
                    iconColor: TColors.familyEscortIcon,
                  ),
                  const SizedBox(height: 10),
                  buildSuggestionTile(
                    title: 'Hội nhóm',
                    description:
                        'Các thành viên thân thiết lẫn nhau cùng giám sát sự an toàn của nhau',
                    icon: Iconsax.people,
                    onTap: () => Get.dialog(
                      CreateVirtualEscortGroupDialog(),
                      barrierDismissible: false,
                    ),
                    bkgColor: TColors.groupEscortBkg,
                    iconColor: TColors.groupEscortIcon,
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showJoinGroupDialog(BuildContext context) {
    final controller = VirtualEscortGroupController.instance;
    final codeController = TextEditingController();
    final dark = THelperFunctions.isDarkMode(context);
    Get.defaultDialog(
      backgroundColor: Colors.white,
      title: 'Tham gia nhóm',
      titleStyle: TextStyle(color: dark ? Colors.black : Colors.black),
      contentPadding: const EdgeInsets.all(TSizes.sm),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Nhập mã nhóm (6 ký tự) để tham gia',
            style: TextStyle(color: Colors.black),
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          SizedBox(
            width: 200,
            child: TextFormField(
              controller: codeController,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
                color: TColors.primary,
              ),
              inputFormatters: [
                LengthLimitingTextInputFormatter(6),
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                TFormatter.upperCaseFormatter(),
              ],
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                counterText: '',
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: TColors.grey, width: 1),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
      confirm: ElevatedButton(
        onPressed: () {
          final groupCode = codeController.text.toUpperCase();
          final codeRegExp = RegExp(r'^[A-Z0-9]{6}$');

          if (!codeRegExp.hasMatch(groupCode)) {
            TLoaders.warningSnackBar(
              title: 'Lỗi xác thực',
              message: 'Mã nhóm phải gồm 6 ký tự (chữ hoặc số).',
            );
            return;
          }
          controller.joinGroupByCode(groupCode);
        },
        style: ElevatedButton.styleFrom(backgroundColor: TColors.primary),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: TSizes.lg),
          child: Text('Tham gia'),
        ),
      ),
      cancel: OutlinedButton(
        onPressed: () => Navigator.of(Get.overlayContext!).pop(),
        child: const Text('Hủy bỏ', style: TextStyle(color: Colors.black)),
      ),
    );
  }
}
