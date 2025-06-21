// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:intl/intl.dart';
// import 'package:lumea_skin/features/personalization/screens/profile/widgets/change_date_of_birth.dart';
// import 'package:lumea_skin/features/personalization/screens/profile/widgets/change_gender.dart';
// import 'package:lumea_skin/features/personalization/screens/profile/widgets/change_name.dart';
// import 'package:lumea_skin/features/personalization/screens/profile/widgets/change_phone.dart';
// import 'package:lumea_skin/features/personalization/screens/profile/widgets/profile_menu.dart';
//
// import '../../../../common/widgets/appbar/appbar.dart';
// import '../../../../common/widgets/effects/shimmer_effect.dart';
// import '../../../../common/widgets/images/t_circular_image.dart';
// import '../../../../common/widgets/texts/section_heading.dart';
// import '../../../../utils/constants/image_strings.dart';
// import '../../../../utils/constants/sizes.dart';
// import 'package:get/get.dart';
//
// import '../../controller/user_profile_controller.dart';
//
// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final userController = UserProfileController.instance;
//     return Scaffold(
//       appBar: const TAppBar(
//         title: Text('Tài Khoản & Bảo Mật'),
//         showBackArrow: true,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(TSizes.spaceBtwItems),
//           child: Column(
//             children: [
//               ///Profile Picture
//               SizedBox(
//                 width: double.infinity,
//                 child: Column(
//                   children: [
//                     Obx(() {
//                       final String imageUrl =
//                           userController.user.value.imageUrl;
//                       final String genderAvatar =
//                           userController.user.value.gender == true
//                               ? TImages.maleAvatar
//                               : TImages.femaleAvatar;
//                       if (userController.imageUploading.value) {
//                         return const TShimmerEffect(width: 100, height: 100);
//                       } else {
//                         return TCircularImage(
//                             key: ValueKey(imageUrl),
//                             image:
//                                 imageUrl.isNotEmpty ? imageUrl : genderAvatar,
//                             width: 100,
//                             height: 100,
//                             padding: 0,
//                             isNetworkImage: imageUrl.isNotEmpty);
//                       }
//                     }),
//                     TextButton(
//                         onPressed: () =>
//                             userController.handleImageProfileUpload(),
//                         child: const Text('Thay ảnh đại diện'))
//                   ],
//                 ),
//               ),
//
//               ///Details
//               const SizedBox(height: TSizes.spaceBtwItems / 2),
//               const Divider(),
//               const SizedBox(height: TSizes.spaceBtwItems),
//               const TSectionHeading(
//                   title: 'Hồ sơ của tôi', showActionButton: false,buttonTitle: 'Xem tất cả'),
//               const SizedBox(height: TSizes.spaceBtwItems),
//
//               TProfileMenu(
//                 onPressed: () {},
//                 title: 'Email',
//                 value: userController.user.value.email,
//                 icon: Iconsax.copy,
//                 onIconPressed: () {
//                   Clipboard.setData(
//                     ClipboardData(text: userController.user.value.email),
//                   );
//                 },
//               ),
//
//               const Divider(),
//               const SizedBox(height: TSizes.spaceBtwItems),
//               const TSectionHeading(
//                   title: 'Thông tin cá nhân', showActionButton: false,buttonTitle: 'Xem tất cả',),
//               const SizedBox(height: TSizes.spaceBtwItems),
//               TProfileMenu(
//                   onPressed: () => Get.off(() => const ChangeUserName()),
//                   title: 'Tên đầy đủ',
//                   value: userController.user.value.fullName),
//               TProfileMenu(
//                   onPressed: () => Get.off(() => const ChangePhoneNumber()),
//                   title: 'Số điện thoại',
//                   value: userController.user.value.phone),
//               TProfileMenu(
//                   onPressed: () => Get.off(() => const ChangeUserGender()),
//                   title: 'Giới tính',
//                   value: userController.user.value.gender ? 'Nam' : 'Nữ'),
//               TProfileMenu(
//                   onPressed: () => Get.off(() => const ChangeUserDob()),
//                   title: 'Ngày sinh',
//                   value: DateFormat('dd/MM/yyyy')
//                       .format(userController.user.value.dateOfBirth)),
//               const Divider(),
//               const SizedBox(height: TSizes.spaceBtwSections),
//               Center(
//                 child: TextButton(
//                   onPressed: () {},
//                   child: const Text('Vô hiệu hóa tài khoản',
//                       style: TextStyle(color: Colors.red)),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
