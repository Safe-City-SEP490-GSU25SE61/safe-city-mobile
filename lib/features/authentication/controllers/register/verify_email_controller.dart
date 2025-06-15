// import 'dart:async';
//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:get/get.dart';
//
// import '../../../../common/widgets/success_screen/success_screen.dart';
// import '../../../../data/repositories/authentication/authentication_repository.dart';
// import '../../../../utils/constants/image_strings.dart';
// import '../../../../utils/constants/text_strings.dart';
// import '../../../../utils/popups/loaders.dart';
//
// class VerifyEmailController extends GetxController {
//   static VerifyEmailController get instance => Get.find();
//
//   @override
//   void onInit() {
//     sendEmailVerification();
//     super.onInit();
//   }
//
//   sendEmailVerification() async {
//     try {
//       await AuthenticationRepository.instance.sendEmailVerification();
//       TLoaders.successSnackBar(
//         title: "Đã gửi email xác thực",
//         message: "Vui lòng kiểm tra hộp thư của bạn và xác thực tài khoản.",
//       );
//     } catch (e) {
//       TLoaders.errorSnackBar(title: "Đã có lỗi xảy ra", message: e.toString());
//     }
//   }
//
//   /// Timer to automatically redirect on Email Verification
//   setTimerForAutoRedirect() {
//     Timer.periodic(const Duration(seconds: 1), (timer) async {
//       await FirebaseAuth.instance.currentUser?.reload();
//       final user = FirebaseAuth.instance.currentUser;
//       if (user?.emailVerified ?? false) {
//         timer.cancel();
//         Get.off(
//           () => SuccessScreen(
//             image: TImages.emailAccountSuccess,
//             title: TTexts.yourAccountCreatedTitle,
//             subTitle: TTexts.yourAccountCreatedSubTitle,
//             onPressed: () => AuthenticationRepository.instance.screenRedirect(),
//           ), // SuccessScreen
//         );
//       }
//     }); // Timer.periodic
//   }
//
//   /// Manually Check if Email Verified
//   checkEmailVerificationStatus() async {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser != null && currentUser.emailVerified) {
//       Get.off(
//         () => SuccessScreen(
//           image: TImages.emailAccountSuccess,
//           title: TTexts.yourAccountCreatedTitle,
//           subTitle: TTexts.yourAccountCreatedSubTitle,
//           onPressed: () => AuthenticationRepository.instance.screenRedirect(),
//         ),
//       );
//     }
//   }
// }
