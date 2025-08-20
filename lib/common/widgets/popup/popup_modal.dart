import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:safe_city_mobile/utils/constants/sizes.dart';
import 'package:slide_to_act/slide_to_act.dart';

import '../../../features/virtual_escort/controllers/virtual_escort_pause_controller.dart';
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

  /// Slide to confirm + cancel button popup
  void showSlideConfirmPauseDialog({
    required String title,
    required String message,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    final controller = Get.put(PauseController());

    Get.defaultDialog(
      backgroundColor: Colors.white,
      title: title,
      titleStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      contentPadding: const EdgeInsets.all(16),
      barrierDismissible: false,
      content: Obx(() {
        return SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Message
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$message ',
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    TextSpan(
                      text: 'Số lần dừng: ${controller.pauseChances.value}',
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),


              /// Show countdown if active
              if (controller.remainingSeconds.value > 0) ...[
                CircularPercentIndicator(
                  radius: 60.0,
                  lineWidth: 6.0,
                  percent: controller.remainingSeconds.value / 300,
                  center: Text(
                    "${(controller.remainingSeconds.value ~/ 60).toString().padLeft(2, '0')}:${(controller.remainingSeconds.value % 60).toString().padLeft(2, '0')}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  progressColor: TColors.error,
                  backgroundColor: Colors.grey.shade300,
                  circularStrokeCap: CircularStrokeCap.round,
                  animation: true,
                  animateFromLastPercent: true,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    controller.stopPause();
                    if (onConfirm != null) onConfirm();
                    Get.back();
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: TSizes.lg),
                    child: Text('Tiếp tục hành trình'),
                  ),
                ),
              ] else ...[
                /// Slide to confirm
                Builder(
                  builder: (context) {
                    final GlobalKey<SlideActionState> key = GlobalKey();
                    return SlideAction(
                      key: key,
                      outerColor: TColors.primary,
                      innerColor: Colors.white,
                      text: "Trượt để tạm dừng",
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      onSubmit: () {
                        controller.startPause();
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 14),

                /// Show cancel button ONLY when not pausing
                OutlinedButton(
                  onPressed: () {
                    if (onCancel != null) onCancel();
                    Get.back();
                  },
                  child: const Text('Hủy bỏ', style: TextStyle(color: Colors.black)),
                ),
              ],
            ],
          ),
        );
      }),
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
            style: const TextStyle(fontSize: 14, height: 1.4),
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
                  Get.to(());
                  return null;
                },
              );
            },
          ),
        ],
      ),
    );
  }
}


