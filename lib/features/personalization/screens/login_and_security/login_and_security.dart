import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../authentication/controllers/camera/camera_controller.dart';
import '../../controllers/login_and_security/user_login_and_security_controller.dart';
import '../profile/profile.dart';

class LoginAndSecurityScreen extends StatelessWidget {
  const LoginAndSecurityScreen({super.key});

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    // 🔥 TODO: Add your API call here to refresh membership data
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final controller = Get.put(UserLoginAndSecurityController());
    final cameraController = Get.put(UserIdCameraController());
    return Scaffold(
      appBar: TAppBar(title: Text('Tùy chỉnh tài khoản'), showBackArrow: true),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: TColors.primary,
        child: ListView(
          padding: const EdgeInsets.all(14.0),
          children: [
            const SizedBox(height: TSizes.smallSpace),
            Text(
              'Cài đặt bảo mật',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            Card(
              color: dark ? TColors.darkerBlack : TColors.lightGrey,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.fingerprint),
                        SizedBox(width: 12),
                        Text(
                          'Sinh trắc học',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: TSizes.smallSpace),
                    const Text(
                      'Tất cả sinh trắc học trên thiết bị này đều có thể:',
                      style: TextStyle(fontSize: 14),
                    ),

                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Dùng để thay cho mật khẩu',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Obx(
                          () => Switch(
                            value: controller.isBiometricEnabled.value,
                            onChanged: (val) {
                              controller.toggleBiometricLogin(val);
                            },
                            activeColor: TColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: TSizes.defaultSpace),

            Text(
              'Cài đặt ứng dụng',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: dark ? TColors.lightPrimary : TColors.veryLightPrimary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.verified_user_rounded, color: TColors.primary),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Thông tin định danh',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Thông tin định danh giúp xác định danh tính và tuân thủ quy định của pháp luật.',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          backgroundColor: TColors.lightGrey,
                          builder: (context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Text(
                                    'Thông tin định danh',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ListTile(
                                  leading: const Icon(
                                    Icons.document_scanner,
                                    color: Colors.black,
                                  ),
                                  title: Text(
                                    'Cập nhật CCCD gắn chip',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  subtitle: const Text(
                                    'Để tài khoản được bảo mật tốt nhất',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  onTap: () {},
                                ),
                                const Divider(),
                                ListTile(
                                  leading: const Icon(
                                    Icons.face,
                                    color: Colors.black,
                                  ),
                                  title: const Text(
                                    'Kiểm tra thông tin định danh',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  subtitle: const Text(
                                    'Xác thực khuôn mặt để xem thông tin',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Get.to(() => ProfileScreen());
                                  },
                                ),
                                const SizedBox(height: 10),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text('Kiểm tra'),
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
