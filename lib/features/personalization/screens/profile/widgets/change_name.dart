// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:iconsax/iconsax.dart';
//
// import '../../../../../common/widgets/appbar/appbar.dart';
// import '../../../../../utils/constants/sizes.dart';
// import '../../../../../utils/constants/text_strings.dart';
// import '../../../../../utils/validators/validation.dart';
// import '../../../controller/user_profile_controller.dart';
//
// class ChangeUserName extends StatelessWidget {
//   const ChangeUserName({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(UserProfileController());
//     return Scaffold(
//       appBar: TAppBar(
//         showBackArrow: true,
//         title:
//             Text('Họ và tên', style: Theme.of(context).textTheme.headlineSmall),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(TSizes.defaultSpace),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Headings
//             Text(
//               'Vui lòng cup cấp tên thật để chúng tôi có thể dễ dàng tạo đơn nha~~',
//               style: Theme.of(context).textTheme.labelMedium,
//             ),
//             // Text
//             const SizedBox(height: TSizes.spaceBtwSections),
//
//             // Text field and Button
//             Form(
//               key: controller.profileFormKey,
//               child: Column(
//                 children: [
//                   TextFormField(
//                     controller: controller.fullName,
//                     validator: (value) =>
//                         TValidator.validateEmptyText('Họ và Tên', value),
//                     expands: false,
//                     decoration: const InputDecoration(
//                         labelText: TTexts.fullName,
//                         prefixIcon: Icon(Iconsax.user)),
//                   ),
//                   // TextFormField
//                 ],
//               ),
//             ),
//             const SizedBox(height: TSizes.spaceBtwSections),
//
//             // Save Button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                   onPressed: () => controller.updateUserProfile(),
//                   child: const Text('Lưu')),
//             ),
//             // SizedBox
//           ],
//         ),
//       ),
//     );
//   }
// }
