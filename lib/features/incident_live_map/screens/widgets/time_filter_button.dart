import 'package:flutter/material.dart';

import '../../../../utils/constants/colors.dart';

class TimeFilterButtons extends StatelessWidget {
  final String selectedRange;
  final Function(String) onChanged;

  const TimeFilterButtons({
    super.key,
    required this.selectedRange,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = ['week', 'month', 'quarter'];
    final labels = ['1 tuần', '1 tháng', '1 quý'];

    return Center(
      child: ToggleButtons(
        isSelected: List.generate(
          options.length,
              (index) => options[index] == selectedRange,
        ),
        onPressed: (index) => onChanged(options[index]),
        borderRadius: BorderRadius.circular(8),
        selectedColor: Colors.white,
        color: Colors.black,
        fillColor: TColors.accent,
        textStyle: const TextStyle(fontSize: 14),
        constraints: const BoxConstraints(minHeight: 36, minWidth: 80),
        children: labels.map((label) => Text(label)).toList(),
      ),
    );
  }
}

