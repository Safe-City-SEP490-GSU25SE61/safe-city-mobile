// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../../../../common/widgets/success_screen/success_screen.dart';
// import '../../../../utils/constants/image_strings.dart';
// import '../../../../utils/constants/sizes.dart';
// import '../../../../utils/constants/text_strings.dart';
// import '../../../../utils/helpers/helper_functions.dart';
// import '../../controllers/register/verify_email_controller.dart';
// import '../login/login.dart';
//
// class VerifyEmailScreen extends StatelessWidget {
//   const VerifyEmailScreen({super.key, this.email});
//
//   final String? email;
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(VerifyEmailController());
//     return Scaffold(
//       appBar: AppBar(
//         actions: [
//           IconButton(
//             onPressed: () => Get.offAll(() => const LoginScreen()),
//             icon: const Icon(CupertinoIcons.clear),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(TSizes.defaultSpace),
//           child: Column(
//             children: [
//               ///Image
//               Image(
//                 image: const AssetImage(TImages.emailSendImage),
//                 width: THelperFunctions.screenWidth() * 0.6,
//               ),
//               const SizedBox(height: TSizes.spaceBtwSections),
//
//               ///Title & Subtitle
//               Text(
//                 TTexts.confirmEmail,
//                 style: Theme.of(context).textTheme.headlineMedium,
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: TSizes.spaceBtwSections),
//               Text(
//                 email ?? '',
//                 style: Theme.of(context).textTheme.labelLarge,
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: TSizes.spaceBtwSections),
//               Text(
//                 TTexts.confirmEmailSubTitle,
//                 style: Theme.of(context).textTheme.labelMedium,
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: TSizes.spaceBtwSections),
//
//               ///Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: () => Get.to(
//                     () => SuccessScreen(
//                       image: TImages.emailAccountSuccess,
//                       title: TTexts.yourAccountCreatedTitle,
//                       subTitle: TTexts.yourAccountCreatedSubTitle,
//                       onPressed: () => Get.to(() => const LoginScreen()),
//                     ),
//                   ),
//                   child: const Text(TTexts.tContinue),
//                 ),
//               ),
//               const SizedBox(height: TSizes.spaceBtwItems),
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: TextButton(
//                   onPressed: () => controller.sendEmailVerification(),
//                   child: const Text(TTexts.resendEmail),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
