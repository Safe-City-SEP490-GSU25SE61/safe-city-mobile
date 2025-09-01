import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:safe_city_mobile/utils/constants/sizes.dart';
import 'package:slide_to_act/slide_to_act.dart';

import '../../../features/virtual_escort/screens/virtual_escort_sos.dart';
import '../../../utils/constants/colors.dart';

class PopUpModal {
  PopUpModal._internal();
  static final PopUpModal instance = PopUpModal._internal();

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  void showOkOnlyDialog({
    required String title,
    required String message,
    VoidCallback? onOk,
  }) {
    Get.defaultDialog(
      title: title,
      contentPadding: const EdgeInsets.all(TSizes.mediumLargeSpace),
      middleText: message,
      confirm: ElevatedButton(
        onPressed: () {
          Get.back();
          if (onOk != null) onOk();
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 18.0),
          child: Text('Đồng ý'),
        ),
      ),
    );
  }

  void showConfirmCancelDialog({required String title,
    required String message,
    required String storageKey,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) async {
    final saved = await secureStorage.read(key: storageKey);

    if (saved == 'true') {
      if (onConfirm != null) onConfirm();
      return;
    }

    RxBool doNotShowAgain = false.obs;

    Get.defaultDialog(
      title: title,
      contentPadding: const EdgeInsets.all(TSizes.mediumLargeSpace),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              textAlign: TextAlign.left,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            Obx(
                  () => Row(
                children: [
                  Checkbox(
                    value: doNotShowAgain.value,
                    onChanged: (val) {
                      doNotShowAgain.value = val ?? false;
                    },
                  ),
                  const Expanded(
                    child: Text(
                      "Không hiển thị lại nội dung này",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      confirm: SizedBox(
        width: 120,
        height: 50,
        child: ElevatedButton(
          onPressed: () async {
            Get.back();
            if (doNotShowAgain.value) {
              await secureStorage.write(key: storageKey, value: 'true');
            }
            if (onConfirm != null) onConfirm();
          },
          child: const Text('Đồng ý'),
        ),
      ),
      cancel: SizedBox(
        width: 120,
        height: 50,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red),
            foregroundColor: Colors.red,
          ),
          onPressed: () {
            Get.back();
            if (onCancel != null) onCancel();
          },
          child: const Text('Hủy bỏ'),
        ),
      ),
    );
  }

  void showContentEmptyDialog({
    required String title,
    required String message,
    VoidCallback? onOk,
  }) {
    Get.defaultDialog(
      title: title,
      contentPadding: const EdgeInsets.all(TSizes.mediumLargeSpace),
      middleText: message,
      confirm: ElevatedButton(
        onPressed: () {
          Get.back();
          if (onOk != null) onOk();
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 18.0),
          child: Text('Đồng ý'),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void showSlideToProceedDialog({
    required String title,
    required String message,
    VoidCallback? onCancel,
  }) {
    Get.defaultDialog(
      backgroundColor: Colors.white,
      title: title,
      titleStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black
      ),
      contentPadding: const EdgeInsets.all(16),
      barrierDismissible: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Message
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, height: 1.4,color: Colors.black),
          ),
          const SizedBox(height: 20),

          /// Slide to proceed
          Builder(
            builder: (context) {
              final GlobalKey<SlideActionState> key = GlobalKey();
              return SlideAction(
                key: key,
                outerColor: TColors.error,
                innerColor: Colors.white,
                text: "Trượt để tiếp tục",
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                onSubmit: () {
                  Get.back();
                  Get.to(() => VirtualEscortSosScreen());
                  return null;
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildSidebarAlert(IconData icon, String message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: TColors.error),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


