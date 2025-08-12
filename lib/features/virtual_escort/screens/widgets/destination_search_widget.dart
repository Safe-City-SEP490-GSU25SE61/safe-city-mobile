import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../utils/constants/colors.dart';

Widget destinationSearchField({
  required String label,
  required String? value,
  required VoidCallback onTap,
  bool isDefaultLocation = false,
  Icon? prefixIcon,
}) {
  return GestureDetector(
    onTap: onTap,
    child: AbsorbPointer(
      child: TextFormField(
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: value ?? label,
          hintStyle: TextStyle(
            fontSize: 14,
            color: isDefaultLocation ? TColors.accent : Colors.black,
            fontWeight: isDefaultLocation
                ? FontWeight.w600
                : FontWeight.normal,
          ),
          prefixIcon:
          prefixIcon ?? const Icon(Iconsax.search_normal, size: 20),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 10,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    ),
  );
}