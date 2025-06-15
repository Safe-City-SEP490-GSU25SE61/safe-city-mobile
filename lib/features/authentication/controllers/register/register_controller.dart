
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../../../../data/services/authentication/authentication_service.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/popups/full_screen_loader.dart';
import '../../../../utils/popups/loaders.dart';
import '../../screens/register/verify_email.dart';

class SignupController extends GetxController {
  static SignupController get instance => Get.find();

  ///Variables
  final hidePassword = true.obs;
  final policy = true.obs;
  final email = TextEditingController();
  final fullName = TextEditingController();
  final phone = TextEditingController();
  final day = TextEditingController();
  final month = TextEditingController();
  final year = TextEditingController();
  final password = TextEditingController();
  final gender = Rx<bool?>(null);
  GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();

  String formatDateOfBirth() {
    String d = day.text.padLeft(2, '0');
    String m = month.text.padLeft(2, '0');
    String y = year.text;

    if (y.isEmpty || m.isEmpty || d.isEmpty) return '';

    try {
      DateTime dob = DateTime.parse("$y-$m-$d");
      DateTime today = DateTime.now();
      int age = today.year - dob.year;

      if (today.month < dob.month ||
          (today.month == dob.month && today.day < dob.day)) {
        age--;
      }

      if (age < 18) {
        return '';
      }

      return "$y-$m-$d";
    } catch (e) {
      return '';
    }
  }

  void signup() async {
    try {
      //start loading
      TFullScreenLoader.openLoadingDialog(
          'Đang xử lí chờ xíu...', TImages.screenLoadingSparkle2);

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
        TLoaders.warningSnackBar(
            title: 'Vui lòng chấp nhận điều khoản',
            message:
            'Những điều khoản về chính sách và bảo mật là cần thiết để sử dụng dịch vụ của chúng tôi');
        return;
      }

      String formattedDob = formatDateOfBirth();
      if (formattedDob.isEmpty) {
        TFullScreenLoader.stopLoading();
        TLoaders.warningSnackBar(
            title: 'Ngày sinh không hợp lệ',
            message: 'Bạn phải từ 18 tuổi trở lên và nhập ngày hợp lệ.');
        return;
      }

      var result = await AuthenticationService().handleSignUp(
        email: email.text,
        fullName: fullName.text,
        phone: phone.text,
        password: password.text,
        dateOfBirth: formattedDob,
        gender: gender.value == true ? true : false,
      );

      TFullScreenLoader.stopLoading();

      if (result['success']) {
        TLoaders.successSnackBar(
            title: 'Đã gửi email với mã otp!',
            message: 'Vui lòng check email để lấy mã otp');
        // Get.to(() => VerifyEmailScreen(
        //   email: email.text.trim(),
        // ));
        await storage.write(key: "user_email_verification", value: email.text);
      } else {
        TLoaders.warningSnackBar(
            title: 'Ối đã xảy ra sự cố', message: result['message']);
      }
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(
          title: 'Xảy ra lỗi rồi!',
          message: 'Đã xảy ra sự cố không xác định, vui lòng thử lại sau');
    }
  }
}
