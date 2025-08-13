import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

Widget buildSuggestionTile({
  required String title,
  required String description,
  required IconData icon,
  required VoidCallback onTap,
  Color? bkgColor,
  Color? iconColor,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: (bkgColor ?? Colors.grey).withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: iconColor ?? Colors.black),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Iconsax.arrow_right_3),
        ],
      ),
    ),
  );
}
