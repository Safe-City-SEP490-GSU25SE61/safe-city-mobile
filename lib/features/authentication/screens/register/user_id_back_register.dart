import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_decorated_container/flutter_decorated_container.dart';
import 'package:get/get.dart';
import 'package:safe_city_mobile/features/authentication/screens/login/login.dart';
import 'package:safe_city_mobile/features/authentication/screens/register/register.dart';
import 'package:safe_city_mobile/utils/constants/colors.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/text_strings.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../controllers/camera/camera_controller.dart';

class UserIdBackRegister extends StatelessWidget {
  const UserIdBackRegister({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserIdCameraController(), permanent: false);
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: const TAppBar(
        title: Text('Tạo Tài Khoản'),
        showCloseButton: true,
        navigateOnClose: LoginScreen(),
      ),
      body: FutureBuilder(
        future: controller.initializeCamera(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          return Obx(
            () => Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(TSizes.spaceBtwItems),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Bước 2: Vui lòng cung cấp mặt sau CCCD',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),

                        Obx(() {
                          return SizedBox(
                            width: double.infinity,
                            height: 220,
                            child: DecoratedContainer(
                              strokeWidth: 3,
                              dashSpace: 4,
                              dashWidth: 14,
                              cornerRadius: 12,
                              strokeColor: dark
                                  ? TColors.white
                                  : TColors.darkerGrey,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: controller.capturedImage.value != null
                                    ? Image.file(
                                        File(
                                          controller.capturedImage.value!.path,
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : FittedBox(
                                        fit: BoxFit.cover,
                                        child: SizedBox(
                                          width: controller
                                              .cameraController!
                                              .value
                                              .previewSize!
                                              .height,
                                          height: controller
                                              .cameraController!
                                              .value
                                              .previewSize!
                                              .width,
                                          child: CameraPreview(
                                            controller.cameraController!,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: TSizes.spaceBtwItems),
                        Text(
                          TTexts.identityDataConfirmation,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            color: dark ? Colors.white70 : Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () async {
                              await controller.uploadIdentityCard(
                                isFront: false,
                              );
                              if (controller.backImageInfo.value != null) {
                                await controller.disposeCamera();
                                Get.to(() => const RegisterScreen());
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TColors.primary,
                            ),
                            child: const Text('Tiếp tục'),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Obx(() {
                          final isTaken =
                              controller.capturedImage.value != null;
                          return SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: OutlinedButton(
                              onPressed: () {
                                if (isTaken) {
                                  controller.retakePicture();
                                } else {
                                  controller.takePicture();
                                }
                              },
                              child: Text(isTaken ? 'Chụp lại' : 'Chụp'),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                if (controller.isLoading.value)
                  Container(
                    color: Colors.black.withValues(alpha: 0.4),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
