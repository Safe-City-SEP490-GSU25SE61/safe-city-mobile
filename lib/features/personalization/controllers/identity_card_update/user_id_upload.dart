import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_decorated_container/flutter_decorated_container.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/device_id_helper.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../login_and_security/user_login_and_security_controller.dart';
import '../profile/user_profile_controller.dart';

class UserIdUploadScreen extends StatelessWidget {
  const UserIdUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserLoginAndSecurityController());
    final userController = Get.find<UserProfileController>();
    final Rx<File?> frontImage = Rx<File?>(null);
    final Rx<File?> backImage = Rx<File?>(null);
    final dark = THelperFunctions.isDarkMode(context);

    Future<void> pickImage(bool isFront) async {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null) {
        final file = File(picked.path);
        if (isFront) {
          frontImage.value = file;
        } else {
          backImage.value = file;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Cập nhật CCCD')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Obx(
              () => GestureDetector(
                onTap: () => pickImage(true),
                child: SizedBox(
                  width: double.infinity,
                  height: 220,
                  child: DecoratedContainer(
                    strokeWidth: 3,
                    dashSpace: 4,
                    dashWidth: 14,
                    cornerRadius: 12,
                    strokeColor: dark ? TColors.white : TColors.darkerGrey,
                    child: frontImage.value == null
                        ? const Center(
                            child: Text('Tải lên ảnh CCCD mặt trước'),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              frontImage.value!,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Obx(
              () => GestureDetector(
                onTap: () => pickImage(false),
                child: SizedBox(
                  width: double.infinity,
                  height: 220,
                  child: DecoratedContainer(
                    strokeWidth: 3,
                    dashSpace: 4,
                    dashWidth: 14,
                    cornerRadius: 12,
                    strokeColor: dark ? TColors.white : TColors.darkerGrey,
                    child: backImage.value == null
                        ? const Center(child: Text('Tải lên ảnh CCCD mặt sau'))
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              backImage.value!,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
