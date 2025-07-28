import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:safe_city_mobile/common/widgets/media/image_fullscreen_widget.dart';
import 'package:safe_city_mobile/common/widgets/media/video_player_widget.dart';
import 'package:safe_city_mobile/features/incident_report/screens/widgets/cancel_report_model.dart';
import 'package:safe_city_mobile/utils/constants/colors.dart';

import '../../../common/widgets/appbar/appbar.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../models/report_history_model.dart';

class ReportDetailScreen extends StatelessWidget {
  final ReportHistoryModel report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final statusEnum = ReportStatus.values.firstWhere(
      (e) => e.value == report.status,
      orElse: () => ReportStatus.pending,
    );
    return Scaffold(
      appBar: const TAppBar(
        title: Text('Chi tiết báo cáo'),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoTile(context, 'Loại sự cố', report.type),
            _buildInfoTile(context, 'Phân loại chi tiết', report.subCategory!),
            _buildInfoTileWithWidget(
              context,
              'Mức độ nghiêm trọng',
              buildPriorityLabel(report.priorityLevel),
            ),
            _buildInfoTile(context, 'Mô tả', report.description),
            _buildInfoTile(context, 'Địa chỉ', report.address),
            _buildInfoTile(
              context,
              'Thời gian xảy ra',
              DateFormat('HH:mm yyyy-MM-dd').format(report.occurredAt),
            ),
            _buildInfoTile(
              context,
              'Trạng thái',
              statusEnum.label,
              valueColor: statusEnum.color,
            ),
            _buildInfoTile(
              context,
              'Ẩn danh',
              report.isAnonymous ? 'Có' : 'Không',
            ),

            const SizedBox(height: TSizes.mediumSpace),
            if (report.imageUrls.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hình ảnh',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 150,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: report.imageUrls.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => FullScreenImageViewer(
                                  images: report.imageUrls,
                                  initialIndex: index,
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(report.imageUrls[index]),
                          ),
                        );
                      },
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                    ),
                  ),
                ],
              ),

            if (report.videoUrl != null) ...[
              const SizedBox(height: TSizes.mediumSpace),
              const Text(
                'Video',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AdvancedVideoPlayer(videoUrl: report.videoUrl!),
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: statusEnum == ReportStatus.pending
          ? Padding(
              padding: const EdgeInsets.all(TSizes.md),
              child: OutlinedButton(
                onPressed: () {
                  showModalBottomSheet(
                    backgroundColor: Colors.white,
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (_) => CancelReportModal(reportId: report.id),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: TColors.error),
                  foregroundColor: TColors.error,
                ),
                child: const Text('Hủy bỏ đơn báo cáo'),
              ),
            )
          : null,
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    String title,
    String value, {
    Color? valueColor,
  }) {
    final dark = THelperFunctions.isDarkMode(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: TSizes.smallSpace),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: dark ? TColors.lightDarkGrey : Colors.black,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              Expanded(
                flex: 3,
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: valueColor ?? (dark ? TColors.white : Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(
          color: dark ? Colors.white24 : Colors.grey.shade300,
          thickness: 1,
          height: TSizes.mediumSpace,
        ),
      ],
    );
  }
}

Widget buildPriorityLabel(String priorityLevel) {
  final priorityEnum = ReportPriority.values.firstWhere(
    (e) => e.value == priorityLevel.trim().toLowerCase(),
    orElse: () => ReportPriority.low,
  );

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        margin: const EdgeInsets.only(right: 6),
        decoration: BoxDecoration(
          color: priorityEnum.color,
          shape: BoxShape.circle,
        ),
      ),
      Text(
        priorityEnum.label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: priorityEnum.color,
        ),
      ),
    ],
  );
}

Widget _buildInfoTileWithWidget(
  BuildContext context,
  String title,
  Widget valueWidget,
) {
  final dark = THelperFunctions.isDarkMode(context);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: TSizes.smallSpace),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: dark ? TColors.lightDarkGrey : Colors.black,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerRight,
                child: valueWidget,
              ),
            ),
          ],
        ),
      ),
      Divider(
        color: dark ? Colors.white24 : Colors.grey.shade300,
        thickness: 1,
        height: TSizes.mediumSpace,
      ),
    ],
  );
}
