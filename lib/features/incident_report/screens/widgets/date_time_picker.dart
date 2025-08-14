import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/validators/validation.dart';

class DateTimePickerField extends StatefulWidget {
  final void Function(DateTime? dateTime)? onChanged;

  const DateTimePickerField({super.key, this.onChanged});

  @override
  State<DateTimePickerField> createState() => _DateTimePickerFieldState();
}

class _DateTimePickerFieldState extends State<DateTimePickerField> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  void _notifyChange() {
    if (selectedDate != null && selectedTime != null) {
      final fullDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );
      widget.onChanged?.call(fullDateTime);
    }
  }

  Future<void> selectDate() async {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: yesterday,
      lastDate: now,
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        dateController.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
      _notifyChange();
    }
  }

  Future<void> selectTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );

    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
        timeController.text = pickedTime.format(context);
      });
      _notifyChange();
    }
  }

  @override
  void dispose() {
    dateController.dispose();
    timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: dateController,
            decoration: InputDecoration(
              label: RichText(
                text: TextSpan(
                  text: 'Chọn ngày ',
                  style: TextStyle(
                    color: dark ? Colors.white : TColors.darkerGrey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  children: const [
                    TextSpan(
                      text: '*',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              prefixIcon: const Icon(Iconsax.calendar),
            ),
            readOnly: true,
            onTap: selectDate,
            validator: (value) => TValidator.validateDateTime('ngày', value),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: timeController,
            decoration: InputDecoration(
              label: RichText(
                text: TextSpan(
                  text: 'Chọn thời gian ',
                  style: TextStyle(
                    color: dark ? Colors.white : TColors.darkerGrey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  children: const [
                    TextSpan(
                      text: '*',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              prefixIcon: const Icon(Iconsax.clock),
            ),
            readOnly: true,
            onTap: selectTime,
            validator: (value) =>
                TValidator.validateDateTime('thời gian', value),
          ),
        ),
      ],
    );
  }
}
