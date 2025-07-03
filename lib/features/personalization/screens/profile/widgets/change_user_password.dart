import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/text_strings.dart';
import '../../../../../utils/validators/validation.dart';
import '../../../controllers/profile/user_profile_controller.dart';

class ChangeUserPassword extends StatelessWidget {
  const ChangeUserPassword({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserProfileController());
    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text(
          'Thay đổi mật khẩu',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Headings
            Text(
              'Hãy nhật mật khẩu cũ và mật khẩu mới để thay đổi',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            // Text
            const SizedBox(height: TSizes.spaceBtwSections),

            // Text field and Button
            Form(
              key: controller.profileFormKey,
              child: Column(
                children: [
                  Obx(
                    () => TextFormField(
                      controller: controller.oldPassword,
                      validator: (value) => TValidator.validatePassword(value),
                      expands: false,
                      obscureText: controller.hideOldPassword.value,
                      decoration: InputDecoration(
                        labelText: TTexts.oldPassword,
                        prefixIcon: const Icon(Iconsax.password_check),
                        suffixIcon: IconButton(
                          onPressed: () => controller.hideOldPassword.value =
                              !controller.hideOldPassword.value,
                          icon: Icon(
                            controller.hideOldPassword.value
                                ? Iconsax.eye_slash
                                : Iconsax.eye,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  Obx(
                    () => TextFormField(
                      controller: controller.newPassword,
                      validator: (value) => TValidator.validatePassword(value),
                      expands: false,
                      obscureText: controller.hideNewPassword.value,
                      decoration: InputDecoration(
                        labelText: TTexts.newPassword,
                        prefixIcon: const Icon(Iconsax.password_check),
                        suffixIcon: IconButton(
                          onPressed: () => controller.hideNewPassword.value =
                              !controller.hideNewPassword.value,
                          icon: Icon(
                            controller.hideNewPassword.value
                                ? Iconsax.eye_slash
                                : Iconsax.eye,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.changePassword(),
                child: const Text('Lưu'),
              ),
            ),
            // SizedBox
          ],
        ),
      ),
    );
  }
}
