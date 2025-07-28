import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../common/widgets/login_signup/form_divider.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/text_strings.dart';
import '../../../../../utils/validators/validation.dart';
import '../../../controllers/login/login_controller.dart';
import '../../password_configuration/forget_password.dart';
import '../../register/user_id_front_register.dart';

class TLoginForm extends StatelessWidget {
  const TLoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    return Form(
      key: controller.loginFormKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: TSizes.spaceBtwSections),
        child: Column(
          children: [
            ///email
            TextFormField(
              controller: controller.email,
              validator: (value) => TValidator.validateEmail(value),
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.user_square),
                labelText: TTexts.email,
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwInputFields),

            ///password
            Obx(
              () => TextFormField(
                controller: controller.password,
                validator: (value) =>
                    TValidator.validateEmptyText('Mật khẩu', value),
                expands: false,
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

            const SizedBox(height: TSizes.spaceBtwInputFields / 2),

            ///Fingerprint verification and forgot password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ///Fingerprint verification
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        controller.handleFingerprintLogin();
                      },
                      child: Row(
                        children: [
                          Icon(Iconsax.finger_scan),
                          const SizedBox(width: 8),
                          Text(TTexts.quickLoginWithFingerPrint),
                        ],
                      ),
                    ),
                  ],
                ),

                ///forgot password
                TextButton(
                  onPressed: () => Get.to(ForgetPassword()),
                  child: const Text(TTexts.forgetPassword),
                ),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            ///Sign in button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () => controller.emailAndPasswordSignIn(),
                child: const Text(TTexts.signIn),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            ///Divider
            TFormDivider(dividerText: TTexts.orRegisterAccount),
            SizedBox(height: TSizes.spaceBtwItems),

            ///create account button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: OutlinedButton(
                onPressed: () => Get.to(
                  () => const UserIdFrontRegister(),
                  transition: Transition.cupertinoDialog,
                  duration: const Duration(milliseconds: 400),
                ),
                child: const Text(TTexts.createAccount),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
