import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'location_filter_modal.dart';

class LocationFilterButton extends StatelessWidget {
  final VoidCallback onApply;

  const LocationFilterButton({super.key, required this.onApply});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (context) => LocationFilterModal(onApply: onApply),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(Iconsax.filter, color: Colors.black, size: 24),
            SizedBox(width: 6),
            Text("Lọc", style: TextStyle(color: Colors.black)),
          ],
        ),
      ),
    );
  }
}
