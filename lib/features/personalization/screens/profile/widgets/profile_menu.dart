import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/sizes.dart';

class TProfileMenu extends StatelessWidget {
  const TProfileMenu({
    super.key,
    required this.onPressed,
    required this.title,
    this.value,
    this.icon = Iconsax.arrow_right_34,
    this.onIconPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final VoidCallback? onIconPressed;
  final String title;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(vertical: TSizes.spaceBtwItems / 1.5),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(title,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis),
            ),
            Expanded(
              flex: 4,
              child: Text((value != null && value!.isNotEmpty) ? value! : 'Thiết lập ngay',
                  style: (value != null && value!.isNotEmpty)
                      ? Theme.of(context).textTheme.bodyMedium
                      : Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis),
            ),
            Expanded(
              child: GestureDetector(
                onTap: onIconPressed,
                child: Icon(icon, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
