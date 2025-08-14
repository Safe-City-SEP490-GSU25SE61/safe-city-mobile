import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:safe_city_mobile/utils/constants/sizes.dart';

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

  void showConfirmCancelDialog({
    required String title,
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
}


