import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;

import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/popups/loaders.dart';
import '../../models/user_indentity_model.dart';
import '../register/register_controller.dart';

class UserIdCameraController extends GetxController {
  final String? apiConnection = dotenv.env['API_DEPLOYMENT_URL'];
  CameraController? cameraController;
  final controller = Get.put(SignupController());
  Rx<File?> capturedImage = Rx<File?>(null);
  RxBool isCameraInitialized = false.obs;
  RxBool isBusyTakingPicture = false.obs;
  RxBool isLoading = false.obs;

  final Rxn<UserIdentityModel> frontImageInfo = Rxn<UserIdentityModel>();
  final Rxn<UserIdentityModel> backImageInfo = Rxn<UserIdentityModel>();

  Future<void> initializeCamera() async {
    capturedImage.value = null;
    if (cameraController != null) {
      await cameraController!.dispose();
    }
    final cameras = await availableCameras();
    final frontCamera = cameras.first;
    cameraController = CameraController(frontCamera, ResolutionPreset.high);
    await cameraController!.initialize();
    isCameraInitialized.value = true;
  }

  Future<void> takePicture() async {
    if (!cameraController!.value.isInitialized || isBusyTakingPicture.value) {
      return;
    }

    try {
      isBusyTakingPicture.value = true;
      final image = await cameraController!.takePicture();
      capturedImage.value = File(image.path);
    } catch (e) {
      debugPrint("Error taking picture: $e");
    } finally {
      isBusyTakingPicture.value = false;
    }
  }

  void retakePicture() {
    capturedImage.value = null;
  }

  Future<void> disposeCamera() async {
    if (cameraController != null) {
      await cameraController?.dispose();
      cameraController = null;
      isCameraInitialized.value = false;
    }
  }

  void mergeFrontAndBackInfo() {
    final front = frontImageInfo.value;
    final back = backImageInfo.value;

    if (front == null || back == null) return;

    final merged = UserIdentityModel(
      fullName: front.fullName,
      idNumber: front.idNumber,
      dateOfBirth: front.dateOfBirth,
      gender: front.gender,
      issueDate: back.issueDate,
      placeOfIssue: back.placeOfIssue,
      expiryDate: back.expiryDate,
      address: back.address,
    );

    controller.identityCardData.value = merged;
  }

  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }

  /// Upload the captured image and store the result in front/back info
  Future<void> uploadIdentityCard({required bool isFront}) async {
    final file = capturedImage.value;
    if (file == null) return;

    final uri = Uri.parse('${apiConnection}auth/identity-card');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    try {
      isLoading.value = true;

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        isLoading.value = false;
        return;
      }

      final response = await request.send();
      final resString = await response.stream.bytesToString();
      isLoading.value = false;

      if (kDebugMode) {
        print('Status Code: ${response.statusCode}');
        print('Response Body: $resString');
      }

      final jsonData = json.decode(resString);

      if (response.statusCode == 202 &&
          jsonData['message'] == 'Successfully scanned identity card') {
        final data = UserIdentityModel.fromJson(jsonData['data']);

        // Check if scanned side matches expected side
        final expectedSide = isFront ? 'cc_front' : 'cc_back';
        if (data.cardSideType != expectedSide) {
          TLoaders.warningSnackBar(
            title: 'Sai mặt CCCD',
            message:
                'Vui lòng chụp đúng mặt ${isFront ? "TRƯỚC" : "SAU"} của CCCD.',
          );
          return;
        }

        if (isFront) {
          frontImageInfo.value = data;
          controller.identityCardData.value = data;
        } else {
          backImageInfo.value = data;
          controller.identityCardData.value = data;
        }

        if (frontImageInfo.value != null && backImageInfo.value != null) {
          mergeFrontAndBackInfo();
        }
      } else {
        TLoaders.warningSnackBar(
          title: 'Lỗi xác minh',
          message:
              'Không thể đọc được mặt ${isFront ? "trước" : "sau"} của CCCD. Vui lòng thử lại.',
        );
      }
    } catch (e) {
      isLoading.value = false;

      if (kDebugMode) {
        print('Error occurred: $e');
      }

      TLoaders.errorSnackBar(
        title: 'Xảy ra lỗi rồi!',
        message: 'Đã xảy ra sự cố không xác định, vui lòng thử lại sau',
      );
    }
  }
}
