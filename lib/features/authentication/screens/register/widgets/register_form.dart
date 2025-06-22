import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:safe_city_mobile/features/authentication/screens/register/widgets/terms_and_conditions_checkbox.dart';

import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/text_strings.dart';
import '../../../../../utils/validators/validation.dart';
import '../../../controllers/register/register_controller.dart';

class TRegisterForm extends StatelessWidget {
  const TRegisterForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());

    return Obx(() {
      final identity = controller.identityCardData.value;

      return Form(
        key: controller.signupFormKey,
        child: Column(
          children: [
            /// Identity card number
            TextFormField(
              initialValue: identity?.idNumber ?? '',
              enabled: false,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: TTexts.identityCardNumber,
                prefixIcon: Icon(Iconsax.personalcard),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),

            /// Identity card full name
            TextFormField(
              initialValue: identity?.fullName ?? '',
              enabled: false,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: TTexts.fullName,
                prefixIcon: Icon(Iconsax.security_user),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),

            /// Date of Birth and Gender
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: identity?.dateOfBirth != null
                        ? identity!.dateOfBirth!.split('T').first
                        : '',
                    enabled: false,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: TTexts.dateOfBirth,
                      prefixIcon: Icon(Iconsax.cake),
                    ),
                  ),
                ),
                const SizedBox(width: TSizes.spaceBtwInputFields),
                Expanded(
                  child: TextFormField(
                    initialValue: (identity?.gender ?? false) ? 'Nam' : 'Nữ',
                    enabled: false,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: TTexts.gender,
                      prefixIcon: Icon(Iconsax.man),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),

            /// Place of residence
            TextFormField(
              initialValue: identity?.address ?? '',
              enabled: false,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: TTexts.placeOfResidence,
                prefixIcon: Icon(Iconsax.location),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),

            /// Place of birth
            TextFormField(
              initialValue: identity?.placeOfBirth ?? '',
              enabled: false,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: TTexts.placeOfBirth,
                prefixIcon: Icon(Iconsax.global),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),

            /// Email
            TextFormField(
              controller: controller.email,
              validator: (value) => TValidator.validateEmail(value),
              expands: false,
              decoration: const InputDecoration(
                labelText: TTexts.email,
                prefixIcon: Icon(Iconsax.direct),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),

            /// Phone Number
            TextFormField(
              controller: controller.phone,
              validator: (value) => TValidator.validatePhoneNumber(value),
              expands: false,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: TTexts.phoneNo,
                prefixIcon: Icon(Iconsax.call),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),

            /// Password
            Obx(
              () => TextFormField(
                controller: controller.password,
                validator: (value) => TValidator.validatePassword(value),
                obscureText: controller.hidePassword.value,
                decoration: InputDecoration(
                  labelText: TTexts.password,
                  prefixIcon: const Icon(Iconsax.password_check),
                  suffixIcon: IconButton(
                    onPressed: () => controller.hidePassword.value =
                        !controller.hidePassword.value,
                    icon: Icon(
                      controller.hidePassword.value
                          ? Iconsax.eye_slash
                          : Iconsax.eye,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Terms
            const TTermsAndConditionCheckbox(),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Signup button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => controller.signup(),
                child: const Text(TTexts.createAccount),
              ),
            ),
          ],
        ),
      );
    });
  }
}
