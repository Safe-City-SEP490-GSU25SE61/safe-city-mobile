import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_decorated_container/flutter_decorated_container.dart';
import 'package:get/get.dart';
import 'package:safe_city_mobile/features/authentication/screens/login/login.dart';
import 'package:safe_city_mobile/features/authentication/screens/register/user_id_back_register.dart';
import 'package:safe_city_mobile/utils/constants/colors.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../controllers/camera/camera_controller.dart';

class UserIdFrontRegister extends StatelessWidget {
  const UserIdFrontRegister({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserIdCameraController(), permanent: false);
    final dark = THelperFunctions.isDarkMode(context);
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        if (didPop) {
          await controller.disposeCamera();
        }
      },
      child: Scaffold(
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

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(TSizes.spaceBtwItems),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Bước 1: Vui lòng cung cấp mặt trước CCCD',
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
                                    File(controller.capturedImage.value!.path),
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

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () =>
                            Get.to(() => const UserIdBackRegister()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColors.primary,
                        ),
                        child: const Text('Tiếp tục'),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Obx(() {
                      final isTaken = controller.capturedImage.value != null;
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
            );
          },
        ),
      ),
    );
  }
}
