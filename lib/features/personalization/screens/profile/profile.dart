import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:safe_city_mobile/features/personalization/screens/profile/widgets/change_user_password.dart';
import 'package:safe_city_mobile/features/personalization/screens/profile/widgets/point_profile_menu.dart';
import 'package:safe_city_mobile/features/personalization/screens/profile/widgets/profile_menu.dart';
import 'package:safe_city_mobile/features/personalization/screens/profile/widgets/rank_profile_menu.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/effects/shimmer_effect.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import 'package:get/get.dart';

import '../../../../utils/helpers/user_rank_helper.dart';
import '../../controllers/profile/user_profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    UserProfileController.instance.fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    final userController = Get.put(UserProfileController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!userController.profileLoading.value) {
        userController.fetchUserProfile();
      }
    });
    return Scaffold(
      appBar: const TAppBar(
        title: Text('Tài Khoản & Bảo Mật'),
        showBackArrow: true,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: TColors.primary,
        child: Obx(() {
          final user = userController.user.value;
          final userRank = getUserRankFromString(user.achievementName);
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(TSizes.spaceBtwItems),
              child: Column(
                children: [
                  ///Profile Picture
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        Obx(() {
                          final String imageUrl =
                              userController.user.value.imageUrl;
                          final String genderAvatar =
                              userController.user.value.gender == true
                              ? TImages.userImageMale
                              : TImages.userImageWoman;

                          if (userController.imageUploading.value) {
                            return const TShimmerEffect(
                              width: 100,
                              height: 100,
                              radius: 100,
                            );
                          } else {
                            final bool isNetworkImage = imageUrl.isNotEmpty;

                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.pink.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: isNetworkImage
                                        ? Image.network(
                                            imageUrl,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.asset(
                                            genderAvatar,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),

                                if (userController
                                    .user
                                    .value
                                    .isBiometricEnabled)
                                  Positioned(
                                    bottom: 0,
                                    right: 3,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: TColors.success,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Icon(
                                        Icons.verified,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          }
                        }),
                        TextButton(
                          onPressed: () =>
                              userController.handleImageProfileUpload(),
                          child: const Text('Thay ảnh đại diện'),
                        ),
                      ],
                    ),
                  ),

                  ///Details
                  const SizedBox(height: TSizes.spaceBtwItems / 2),
                  const Divider(),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  TSectionHeading(
                    title: 'Hồ sơ của tôi',
                    showActionButton: true,
                    buttonTitle: 'Cập nhật thông tin',
                    onPressed: () => Get.to(() => {}),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  TProfileMenu(
                    onPressed: () {},
                    title: 'Email',
                    value: userController.user.value.email,
                    icon: Iconsax.copy,
                    onIconPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: userController.user.value.email),
                      );
                    },
                  ),
                  TProfileMenu(
                    onPressed: () => {},
                    title: 'Số điện thoại',
                    value: userController.user.value.phone,
                    icon: Iconsax.copy,
                    onIconPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: userController.user.value.phone),
                      );
                    },
                  ),
                  TProfileMenu(
                    onPressed: () => Get.to(ChangeUserPassword()),
                    title: 'Mật khẩu',
                    value: 'Thay đổi mật khẩu',
                    showIcon: true,
                  ),
                  TRankProfileMenu(title: 'Xếp hạng', rank: userRank),
                  TPointDisplay(
                    totalPoint: user.totalPoint,
                    title: 'Tổng điểm',
                  ),

                  const Divider(),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  const TSectionHeading(
                    title: 'Thông tin cá nhân',
                    showActionButton: true,
                    buttonTitle: 'Cập nhật CCCD',
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  TProfileMenu(
                    // onPressed: () => Get.off(() => const ChangeUserName()),
                    onPressed: () => {},
                    title: 'Số định danh',
                    value: userController.user.value.idNumber,
                    showIcon: false,
                  ),
                  TProfileMenu(
                    // onPressed: () => Get.off(() => const ChangeUserName()),
                    onPressed: () => {},
                    title: 'Tên đầy đủ',
                    value: userController.user.value.fullName,
                    showIcon: false,
                  ),
                  TProfileMenu(
                    // onPressed: () => Get.off(() => const ChangeUserDob()),
                    onPressed: () => {},
                    title: 'Ngày sinh',
                    value: DateFormat(
                      'dd/MM/yyyy',
                    ).format(userController.user.value.dateOfBirth),
                    showIcon: false,
                  ),
                  TProfileMenu(
                    // onPressed: () => Get.off(() => const ChangeUserGender()),
                    onPressed: () => {},
                    title: 'Giới tính',
                    value: userController.user.value.gender ? 'Nam' : 'Nữ',
                    showIcon: false,
                  ),
                  TProfileMenu(
                    // onPressed: () => Get.off(() => const ChangeUserGender()),
                    onPressed: () => {},
                    title: 'Nơi cư trú',
                    value: userController.user.value.address,
                    showIcon: false,
                  ),
                  TProfileMenu(
                    // onPressed: () => Get.off(() => const ChangeUserGender()),
                    onPressed: () => {},
                    title: 'Nơi khai sinh',
                    value: userController.user.value.placeOfBirth,
                    showIcon: false,
                  ),
                  TProfileMenu(
                    // onPressed: () => Get.off(() => const ChangeUserGender()),
                    onPressed: () => {},
                    title: 'Thời gian cấp',
                    value: DateFormat(
                      'dd/MM/yyyy',
                    ).format(userController.user.value.issueDate),
                    showIcon: false,
                  ),
                  TProfileMenu(
                    // onPressed: () => Get.off(() => const ChangeUserGender()),
                    onPressed: () => {},
                    title: 'Hết hạn vào',
                    value: DateFormat(
                      'dd/MM/yyyy',
                    ).format(userController.user.value.expiryDate),
                    showIcon: false,
                  ),
                  TProfileMenu(
                    // onPressed: () => Get.off(() => const ChangeUserGender()),
                    onPressed: () => {},
                    title: 'Nơi cấp CCD',
                    value: userController.user.value.placeOfIssue,
                    showIcon: false,
                  ),

                  const Divider(),
                  const SizedBox(height: TSizes.spaceBtwSections),
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Vô hiệu hóa tài khoản',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
