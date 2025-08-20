import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:slide_to_act/slide_to_act.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/helpers/helper_functions.dart';

class VirtualEscortSosScreen extends StatefulWidget {
  final VoidCallback onCancel;

  const VirtualEscortSosScreen({super.key, required this.onCancel});

  @override
  State<VirtualEscortSosScreen> createState() => _VirtualEscortSosScreenState();
}

class _VirtualEscortSosScreenState extends State<VirtualEscortSosScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

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

  void _triggerSOS(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text("🚨 SOS Triggered"),
        content: Text("Emergency services have been notified."),
      ),
    );
  }

  void _cancelSOS(BuildContext context) {
    Get.snackbar(
      "Hủy tín hiệu",
      "Tín hiệu SOS đã được hủy.",
      backgroundColor: Colors.black.withValues(alpha: 0.7),
      colorText: Colors.white,
    );
    widget.onCancel();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: TColors.lightGrey,
      appBar: AppBar(
        backgroundColor: TColors.error,
        title: const Text("Phát tín hiệu khẩn cấp"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ripple SOS Button
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
                            color: TColors.error.withOpacity(
                              0.2 * (1 - _controller.value),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                GestureDetector(
                  onTap: () => _triggerSOS(context),
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
          const SizedBox(height: 80),

          // Slide to cancel
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SlideAction(
              outerColor: dark ? TColors.black : Colors.white,
              innerColor: TColors.error,
              text: "Trượt để hủy",
              textStyle: TextStyle(
                color: dark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
              onSubmit: () {
                _cancelSOS(context);
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}
