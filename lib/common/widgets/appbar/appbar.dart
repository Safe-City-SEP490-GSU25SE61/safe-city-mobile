import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/device/device_utility.dart';
import '../../../utils/helpers/helper_functions.dart';

class TAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TAppBar({
    super.key,
    this.title,
    this.actions,
    this.leadingIcon,
    this.leadingOnPressed,
    this.showBackArrow = false,
    this.showCloseButton = false,
    this.onClose,
    this.navigateOnClose,
  });

  final Widget? title;
  final bool showBackArrow;
  final bool showCloseButton;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? leadingOnPressed;
  final VoidCallback? onClose;
  final Widget? navigateOnClose;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    Widget? buildLeading() {
      if (showBackArrow) {
        return IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Iconsax.arrow_left,
            color: dark ? TColors.white : TColors.dark,
          ),
        );
      } else if (showCloseButton) {
        return IconButton(
          onPressed: () {
            if (onClose != null) {
              onClose!();
            } else if (navigateOnClose != null) {
              Get.offAll(() => navigateOnClose!);
            } else {
              Get.back();
            }
          },
          icon: Icon(Icons.close, color: dark ? TColors.white : TColors.dark),
        );
      } else if (leadingIcon != null) {
        return IconButton(onPressed: leadingOnPressed, icon: Icon(leadingIcon));
      } else {
        return null;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TSizes.md),
      child: AppBar(
        automaticallyImplyLeading: false,
        leading: buildLeading(),
        title: title,
        actions: actions,
        titleSpacing: 0,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(TDeviceUtils.getAppBarHeight());
}
