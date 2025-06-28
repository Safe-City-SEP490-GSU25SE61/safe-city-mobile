import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/custom_shapes/containers/primary_header_container.dart';
import '../../../../common/widgets/list_titles/settings_menu_title.dart';
import '../../../../common/widgets/list_titles/t_user_profile_title_card.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/user_rank_helper.dart';
import '../../../authentication/controllers/logout/logout_controller.dart';
import '../../controllers/user_profile_controller.dart';
import '../membership/membership.dart';
import '../profile/profile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final userController = Get.put(UserProfileController());

  @override
  void initState() {
    super.initState();
    userController.fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            ///Header
            TPrimaryHeaderContainer(
              child: Column(
                children: [
                  TAppBar(
                    title: Text(
                      'Thiết lập tài khoản',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium!.apply(color: TColors.white),
                    ),
                    showBackArrow: false,
                  ),

                  ///User Profile Card
                  Obx(() {
                    final isLoading = userController.profileLoading.value;
                    final user = userController.user.value;
                    final String imageUrl = user.imageUrl;
                    final bool isImageValid =
                        imageUrl.isNotEmpty && imageUrl != "null";
                    final bool isMale = user.gender == true;
                    final String fallbackAvatar = isMale
                        ? TImages.userImageMale
                        : TImages.userImageWoman;
                    return TUserProfileCard(
                      onPressed: () {},
                      fullName: user.fullName,
                      phone: user.phone,
                      profilePicture: isLoading
                          ? null
                          : isImageValid
                          ? imageUrl
                          : fallbackAvatar,
                      isNetworkImage: isImageValid,
                      rank: getUserRankFromString(user.achievementName),
                      isBiometricVerified: user.isBiometricEnabled,
                      remainingTime:
                          user.currentSubscription.localizedRemainingTime,
                    );
                  }),

                  const SizedBox(height: TSizes.defaultSpace),
                ],
              ),
            ),

            ///Body
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  ///Account Settings
                  const TSectionHeading(
                    title: 'Tài khoản',
                    showActionButton: false,
                    buttonTitle: 'Xem tất cả',
                  ),
                  const SizedBox(height: TSizes.mediumSpace),

                  TSettingsMenuTile(
                    icon: Iconsax.user_edit,
                    title: 'Thông tin cá nhân',
                    subtitle: 'Chỉnh sửa thông tin cá nhân của bạn',
                    onTap: () => Get.to(() => const ProfileScreen()),
                  ),
                  TSettingsMenuTile(
                    icon: Iconsax.security_safe,
                    title: 'Đăng nhập và bảo mật',
                    subtitle: 'Kiểm tra trạng thái và cài đặt bảo mật',
                    onTap: () {},
                  ),
                  TSettingsMenuTile(
                    icon: Iconsax.notification,
                    title: 'Cài đặt thông báo',
                    subtitle: 'Điều chỉnh các thông báo đến với bạn',
                    onTap: () {},
                  ),
                  TSettingsMenuTile(
                    icon: Iconsax.medal_star,
                    title: 'Thành tựu và cấp bậc',
                    subtitle:
                        'Các thành tựu khi tham gia vào các hoạt động trên app',
                    onTap: () => {},
                  ),
                  TSettingsMenuTile(
                    icon: Iconsax.calendar_2,
                    title: 'Các gói đăng ký và ưu đãi',
                    subtitle:
                        'Gói đăng ký để  mở khóa các tính năng độc quyền ',
                    onTap: () => (Get.to(MembershipScreen())),
                  ),
                  const SizedBox(height: TSizes.mediumSpace),
                  const TSectionHeading(
                    title: 'Cài đặt ứng dụng',
                    showActionButton: false,
                    buttonTitle: 'Xem tất cả',
                  ),
                  const SizedBox(height: TSizes.mediumSpace),
                  TSettingsMenuTile(
                    icon: Iconsax.message_question,
                    title: 'Trung tâm trợ giúp',
                    subtitle: 'Liên hệ  với trung tâm CSKH',
                    onTap: () {},
                  ),
                  TSettingsMenuTile(
                    icon: Iconsax.mobile,
                    title: 'Thông tin chung ',
                    subtitle: 'Điều khoản, chính sách và thông tin hệ thống',
                    onTap: () {},
                  ),

                  ///Logout
                  const SizedBox(height: TSizes.spaceBtwSections),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => logoutAccountWarningPopup(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: TColors.error),
                        foregroundColor: TColors.error,
                      ),
                      child: const Text('Đăng xuất'),
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void logoutAccountWarningPopup() {
    final logoutController = Get.put(LogoutController());
    Get.defaultDialog(
      contentPadding: const EdgeInsets.all(TSizes.md),
      title: 'Đăng xuất',
      middleText: 'Điều này sẽ đưa bạn trở về trang đăng nhập',
      confirm: ElevatedButton(
        onPressed: () async => logoutController.logout(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: TSizes.lg),
          child: Text('Đồng ý'),
        ),
      ),
      // ElevatedButton
      cancel: OutlinedButton(
        child: const Text('Hủy bỏ'),
        onPressed: () => Navigator.of(Get.overlayContext!).pop(),
      ), // OutlinedButton
    );
  }
}
