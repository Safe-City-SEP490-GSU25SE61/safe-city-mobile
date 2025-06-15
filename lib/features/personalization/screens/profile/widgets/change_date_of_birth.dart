// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../../../../../common/widgets/appbar/appbar.dart';
// import '../../../../../utils/constants/sizes.dart';
// import '../../../controller/user_profile_controller.dart';
//
// class ChangeUserDob extends StatelessWidget {
//   const ChangeUserDob({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<UserProfileController>();
//
//     DateTime userDob = controller.user.value.dateOfBirth;
//     controller.day.value = userDob.day;
//     controller.month.value = controller.convertMonthToVietnamese(userDob.month);
//     controller.year.value = userDob.year;
//
//     final List<int> days = List.generate(31, (index) => index + 1);
//     final List<String> months = controller.vietnameseMonths;
//     final List<int> years =
//         List.generate(100, (index) => DateTime.now().year - index);
//
//     return Scaffold(
//       appBar: TAppBar(
//         showBackArrow: true,
//         title:
//             Text('Ngày sinh', style: Theme.of(context).textTheme.headlineSmall),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(TSizes.defaultSpace),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Bạn có biết ngày sinh bật mí rất nhiều về bạn',
//               style: Theme.of(context).textTheme.labelMedium,
//             ),
//             const SizedBox(height: TSizes.spaceBtwSections),
//             Form(
//               key: controller.profileFormKey,
//               child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       Flexible(
//                         flex: 2,
//                         child: DropdownButtonFormField<int>(
//                           value: controller.day.value,
//                           items: days.map((int value) {
//                             return DropdownMenuItem<int>(
//                               value: value,
//                               child: Text(value.toString(),
//                                   style: const TextStyle(fontSize: 14)),
//                             );
//                           }).toList(),
//                           onChanged: (newValue) =>
//                               controller.day.value = newValue ?? 1,
//                           decoration: const InputDecoration(labelText: 'Ngày'),
//                         ),
//                       ),
//                       const SizedBox(width: TSizes.smallSpace),
//                       Flexible(
//                         flex: 3,
//                         child: DropdownButtonFormField<String>(
//                           value: controller.month.value,
//                           items: months.map((String value) {
//                             return DropdownMenuItem<String>(
//                               value: value,
//                               child: Text(value,
//                                   style: const TextStyle(fontSize: 14)),
//                             );
//                           }).toList(),
//                           onChanged: (newValue) =>
//                               controller.month.value = newValue ?? months[0],
//                           decoration: const InputDecoration(labelText: 'Tháng'),
//                         ),
//                       ),
//                       const SizedBox(width: TSizes.smallSpace),
//                       Flexible(
//                         flex: 2,
//                         child: DropdownButtonFormField<int>(
//                           value: controller.year.value,
//                           items: years.map((int value) {
//                             return DropdownMenuItem<int>(
//                               value: value,
//                               child: Text(value.toString(),
//                                   style: const TextStyle(fontSize: 14)),
//                             );
//                           }).toList(),
//                           onChanged: (newValue) => controller.year.value =
//                               newValue ?? DateTime.now().year,
//                           decoration: const InputDecoration(labelText: 'Năm'),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: TSizes.spaceBtwSections),
//
//                   // Save Button
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: () => controller.updateUserProfile(),
//                       child: const Text('Lưu'),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
