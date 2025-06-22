import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../../../../data/services/authentication/authentication_service.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/popups/full_screen_loader.dart';
import '../../../../utils/popups/loaders.dart';
import '../../models/user_indentity_model.dart';
import '../../screens/register/verify_email.dart';
import '../camera/camera_controller.dart';

class SignupController extends GetxController {
  static SignupController get instance => Get.find();

  ///Variables
  final hidePassword = true.obs;
  final policy = true.obs;
  final email = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();
  final Rxn<UserIdentityModel> identityCardData = Rxn<UserIdentityModel>();
  GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();

  void signup() async {
    try {
      //start loading
      TFullScreenLoader.openLoadingDialog(
        'Đang xử lí chờ xíu...',
        TImages.loadingCircle,
      );

      //check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      //form validation
      if (!signupFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      //policy check
      if (!policy.value) {
        TFullScreenLoader.stopLoading();
        TLoaders.warningSnackBar(
          title: 'Vui lòng chấp nhận điều khoản',
          message:
              'Những điều khoản về chính sách và bảo mật là cần thiết để sử dụng dịch vụ của chúng tôi',
        );
        return;
      }
      final identity = identityCardData.value!;
      final userIdCamera = Get.put(UserIdCameraController());
      var result = await AuthenticationService().handleSignUp(
        fullName: identity.fullName!,
        email: email.text,
        phone: phone.text,
        password: password.text,
        dateOfBirth: identity.dateOfBirth!,
        gender: identity.gender ?? false,
        idNumber: identity.idNumber!,
        issueDate: _formatDate(identity.issueDate!),
        expiryDate: _formatDate(identity.expiryDate!),
        placeOfIssue: identity.placeOfIssue!,
        placeOfBirth: identity.placeOfBirth!,
        address: identity.address!,
        frontImage: userIdCamera.frontImageInfo.value != null
            ? userIdCamera.capturedImage.value!
            : File(''),
        backImage: userIdCamera.backImageInfo.value != null
            ? userIdCamera.capturedImage.value!
            : File(''),
      );

      TFullScreenLoader.stopLoading();

      if (result['success']) {
        TLoaders.successSnackBar(
          title: 'Đã gửi email với mã otp!',
          message: 'Vui lòng check email để lấy mã otp',
        );
        Get.to(() => VerifyEmailScreen(email: email.text.trim()));
        await storage.write(key: "user_email_verification", value: email.text);
      } else {
        TLoaders.warningSnackBar(
          title: 'Ối đã xảy ra sự cố',
          message: result['message'],
        );
      }
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(
        title: 'Xảy ra lỗi rồi!',
        message: 'Đã xảy ra sự cố không xác định, vui lòng thử lại sau',
      );
    }
  }

  String _formatDate(String rawDate) {
    try {
      final parsedDate = DateTime.parse(rawDate);
      return '${parsedDate.year.toString().padLeft(4, '0')}-'
          '${parsedDate.month.toString().padLeft(2, '0')}-'
          '${parsedDate.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return rawDate;
    }
  }
}
