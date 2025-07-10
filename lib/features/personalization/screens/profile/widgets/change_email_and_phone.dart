import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/text_strings.dart';
import '../../../../../utils/validators/validation.dart';
import '../../../controllers/profile/user_profile_controller.dart';

class ChangeEmailAndPhoneScreen extends StatelessWidget {
  const ChangeEmailAndPhoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserProfileController());
    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text(
          'Cập nhật thông tin cá nhân',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      // AppBar
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Headings
            Text(
              'Điều chỉnh thông tin cá nhân của bạn tại đây',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            // Text
            const SizedBox(height: TSizes.spaceBtwSections),

            // Text field and Button
            Form(
              key: controller.profileFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: controller.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => TValidator.validateEmail(value),
                    expands: false,
                    decoration: const InputDecoration(
                      labelText: TTexts.email,
                      prefixIcon: Icon(Iconsax.direct),
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  TextFormField(
                    controller: controller.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) => TValidator.validatePhoneNumber(value),
                    expands: false,
                    decoration: const InputDecoration(
                      labelText: TTexts.phoneNo,
                      prefixIcon: Icon(Iconsax.call),
                    ),
                  ),
                  // TextFormField
                ],
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.updateEmailAndPhoneOnly(),
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
