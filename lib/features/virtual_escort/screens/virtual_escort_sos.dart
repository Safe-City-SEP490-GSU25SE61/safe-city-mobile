import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:safe_city_mobile/utils/constants/text_strings.dart';
import 'package:slide_to_act/slide_to_act.dart';

import '../../../common/widgets/popup/popup_modal.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../controllers/virtual_escort_journey_controller.dart';

class VirtualEscortSosScreen extends StatefulWidget {
  const VirtualEscortSosScreen({super.key});

  @override
  State<VirtualEscortSosScreen> createState() => _VirtualEscortSosScreenState();
}

class _VirtualEscortSosScreenState extends State<VirtualEscortSosScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // 🔑 control state of the second card
  bool membersNotified = true; // set to false to "grey out"

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: TColors.lightGrey,
      appBar: AppBar(
        backgroundColor: TColors.error,
        title: const Text(
          "Phát tín hiệu khẩn cấp",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              TTexts.sosInformation,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),

          // 🔹 SOS Ripple Button
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return SizedBox(
                      width: 310,
                      height: 310,
                      child: Center(
                        child: Container(
                          width: 250 + (_controller.value * 60),
                          height: 250 + (_controller.value * 60),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: TColors.error.withValues(
                              alpha: 0.2 * (1 - _controller.value),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                GestureDetector(
                  onTap: () {
                    final controller = VirtualEscortJourneyController.instance;
                    controller.sendSosSignal();

                    PopUpModal.instance.showOkOnlyDialog(
                      title: "SOS đã gửi",
                      message: "Tín hiệu khẩn cấp đã được gửi tới các thành viên trong nhóm.",
                    );
                  },
                  child: Container(
                    width: 230,
                    height: 230,
                    decoration: const BoxDecoration(
                      color: TColors.error,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "SOS",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SlideAction(
              outerColor: dark ? TColors.black : Colors.white,
              innerColor: TColors.error,
              text: "Trượt để hủy",
              textStyle: TextStyle(
                color: dark ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
              ),
              onSubmit: () {
                Get.back();
                return null;
              },
            ),
          ),
          const SizedBox(height: TSizes.mediumSpace),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                // First Card: Call Emergency
                Expanded(
                  child: InkWell(
                    onTap: () {
                      // TODO: Call emergency logic
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Iconsax.call, color: TColors.error, size: 24),
                          SizedBox(width: 4),
                          Text(
                            "Gọi khẩn cấp",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Second Card: Members notified
                Expanded(
                  child: InkWell(
                    onTap: membersNotified
                        ? () {
                            // TODO: Show members list
                          }
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: membersNotified
                              ? Colors.green
                              : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Iconsax.people,
                                color: membersNotified
                                    ? Colors.green
                                    : Colors.grey.shade400,
                                size: 24,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "12 Người nhận",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: membersNotified
                                      ? Colors.black
                                      : Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
