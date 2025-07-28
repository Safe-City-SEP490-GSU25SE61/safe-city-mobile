import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/popups/loaders.dart';
import '../../controllers/incident_report_controller.dart';
import '../report_incident_history.dart';

class CancelReportModal extends StatefulWidget {
  final String reportId;

  const CancelReportModal({super.key, required this.reportId});

  @override
  State<CancelReportModal> createState() => _CancelReportModalState();
}

class _CancelReportModalState extends State<CancelReportModal> {
  String? selectedReason;
  final TextEditingController otherReasonController = TextEditingController();
  final List<String> reasons = [
    'Tôi gửi nhầm',
    'Không còn cần thiết nữa',
    'Thông tin sai',
    'Khác',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          children: [
            const Text(
              "Lý do hủy báo cáo",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            ...reasons.map(
              (reason) => RadioListTile<String>(
                title: Text(reason, style: TextStyle(color: Colors.black)),
                value: reason,
                groupValue: selectedReason,
                onChanged: (value) {
                  setState(() {
                    selectedReason = value!;
                  });
                },
              ),
            ),
            if (selectedReason == 'Khác')
              TextField(
                controller: otherReasonController,
                maxLines: 3,
                maxLength: 100,
                style: const TextStyle(color: Colors.black),
                cursorColor: Colors.black,
                decoration: const InputDecoration(
                  labelText: 'Nhập lý do',
                  labelStyle: TextStyle(color: Colors.black),
                  floatingLabelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: TColors.error),
                      ),
                      child: Text(
                        'Huỷ',
                        style: TextStyle(fontSize: 12, color: Colors.black),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                      onPressed: () async {
                        final reason = selectedReason == 'Khác'
                            ? otherReasonController.text.trim()
                            : selectedReason;

                        if (reason == null || reason.isEmpty) {
                          TLoaders.warningSnackBar(
                            title: 'Thiếu lý do',
                            message: 'Vui lòng chọn hoặc nhập lý do hủy.',
                          );
                          return;
                        }

                        final success =
                            await Get.find<IncidentReportController>()
                                .cancelReport(widget.reportId, reason);

                        if (success) {
                          Get.to(ReportHistoryScreen());
                        }
                      },
                      child: const Text('Xác nhận'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
