import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class UserIdCameraController extends GetxController {
  CameraController? cameraController;
  Rx<File?> capturedImage = Rx<File?>(null);
  RxBool isCameraInitialized = false.obs;
  RxBool isBusyTakingPicture = false.obs;

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.first;
    cameraController = CameraController(frontCamera, ResolutionPreset.high);
    await cameraController!.initialize();
    isCameraInitialized.value = true;
  }

  Future<void> takePicture() async {
    if (!cameraController!.value.isInitialized) return;
    if (cameraController!.value.isTakingPicture) return;
    if (isBusyTakingPicture.value) return;

    try {
      isBusyTakingPicture.value = true;
      final image = await cameraController!.takePicture();
      capturedImage.value = File(image.path);
    } catch (e) {
      if (kDebugMode) {
        print("Error taking picture: $e");
      }
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


  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }
}
