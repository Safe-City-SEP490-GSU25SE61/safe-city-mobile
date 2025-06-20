// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
//
// import '../../../../utils/constants/image_strings.dart';
// import '../../../../utils/popups/full_screen_loader.dart';
// import '../../../../utils/popups/loaders.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//
// import '../../../data/services/personalization/user_profile_service.dart';
// import '../../../utils/helpers/network_manager.dart';
//
// import '../models/user_profile_model.dart';
// import '../screens/profile/profile.dart';
//
// class UserProfileController extends GetxController {
//   static UserProfileController get instance => Get.find();
//   Rx<UserProfileModel> user = UserProfileModel.empty().obs;
//   final userProfileService = Get.put(UserProfileService());
//   final fullName = TextEditingController();
//   final email = TextEditingController();
//   final phone = TextEditingController();
//   final dob = TextEditingController();
//   final gender = TextEditingController();
//   final secureStorage = const FlutterSecureStorage();
//   var userUpdateProfile = {}.obs;
//   final profileLoading = false.obs;
//   final imageUploading = false.obs;
//   GlobalKey<FormState> profileFormKey = GlobalKey<FormState>();
//
//   // ProfileScreenState? profileScreenState;
//
//   final day = Rx<int>(1);
//   final month = Rx<String>('Một');
//   final year = Rx<int>(DateTime.now().year);
//
//   final List<String> vietnameseMonths = [
//     'Một',
//     'Hai',
//     'Ba',
//     'Bốn',
//     'Năm',
//     'Sáu',
//     'Bảy',
//     'Tám',
//     'Chín',
//     'Mười',
//     'Mười một',
//     'Mười hai'
//   ];
//
//   /// Fetch user record
//   Future<void> initializeNames() async {
//     fullName.text = user.value.fullName;
//     phone.text = user.value.phone;
//   }
//
//   @override
//   void onInit() {
//     super.onInit();
//     initializeNames();
//     fetchUserProfile();
//   }
//
//   String convertMonthToVietnamese(int month) {
//     return vietnameseMonths[month - 1];
//   }
//
//   int convertVietnameseToMonth(String month) {
//     return vietnameseMonths.indexOf(month) + 1;
//   }
//
//   Future<void> fetchUserProfile() async {
//     try {
//       profileLoading.value = true;
//       final user = await userProfileService.getUserProfile();
//       this.user(user);
//       profileLoading.value = false;
//     } catch (e) {
//       user(UserProfileModel.empty());
//     } finally {
//       profileLoading.value = false;
//     }
//   }
//
//   Future<void> updateUserProfile() async {
//     final selectedDob = DateTime(
//       year.value,
//       convertVietnameseToMonth(month.value),
//       day.value,
//     ).toUtc();
//     final updatedFields = {
//       "fullName":
//           fullName.text.isNotEmpty ? fullName.text : user.value.fullName,
//       "email": email.text.isNotEmpty ? email.text : user.value.email,
//       "phone": phone.text.isNotEmpty ? phone.text : user.value.phone,
//       "dateOfBirth": selectedDob.toIso8601String(),
//       "gender": gender.text == 'Male' ? true : false,
//       "imageUrl": user.value.imageUrl,
//     };
//
//     try {
//       TFullScreenLoader.openLoadingDialog(
//           'Đang xử lí chờ xíu...', TImages.screenLoadingSparkle2);
//
//       final isConnected = await NetworkManager.instance.isConnected();
//       if (!isConnected) {
//         TFullScreenLoader.stopLoading();
//         return;
//       }
//
//       if (!profileFormKey.currentState!.validate()) {
//         TFullScreenLoader.stopLoading();
//         return;
//       }
//       final result = await userProfileService.updateUserProfile(updatedFields);
//       if (result['success'] == true) {
//         TLoaders.successSnackBar(
//             title: 'Thành công', message: 'Cập nhật thành công');
//         TFullScreenLoader.stopLoading();
//         await fetchUserProfile();
//         Get.off(() => const ProfileScreen());
//       } else {
//         TLoaders.errorSnackBar(
//             title: 'Xảy ra lỗi!', message: result['message']);
//       }
//     } catch (e) {
//       TLoaders.errorSnackBar(
//           title: 'Lỗi!', message: 'Không thể cập nhật hồ sơ');
//     } finally {
//       profileLoading.value = false;
//     }
//   }
//
//   Future<void> handleImageProfileUpload() async {
//     try {
//       final image = await ImagePicker().pickImage(
//           source: ImageSource.gallery,
//           imageQuality: 80,
//           maxHeight: 1200,
//           maxWidth: 1200);
//
//       if (image != null) {
//         imageUploading.value = true;
//
//         final result =
//             await UserProfileService().updateUserProfilePicture(image);
//
//         if (result['success'] == true) {
//           user.update((user) {
//             if (user != null) {
//               user.imageUrl = result['imageUrl'] as String;
//             }
//           });
//           TLoaders.successSnackBar(
//               title: 'Thành công', message: 'Cập nhật ảnh đại diện thành công');
//         } else {
//           TLoaders.errorSnackBar(
//               title: 'Xảy ra lỗi rồi!', message: result['message']);
//         }
//       }
//     } catch (e) {
//       TLoaders.errorSnackBar(
//           title: 'Xảy ra lỗi rồi!',
//           message: 'Đã xảy ra sự cố không xác định, vui lòng thử lại sau');
//     } finally {
//       imageUploading.value = false;
//     }
//   }
// }
