import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:safe_city_mobile/features/incident_live_map/screens/widgets/time_filter_button.dart';

import '../../../../common/widgets/shimmers/incident_pie_chart_shimmer.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/text_strings.dart';
import '../../controllers/incident_live_map_controller.dart';
import 'incident_pie_chart.dart';

class CommuneOverviewWidget extends StatelessWidget {
  final Map<String, dynamic> feature;

  const CommuneOverviewWidget({
    super.key,
    required this.feature,
  });

  @override
  Widget build(BuildContext context) {
    final properties = feature['properties'] ?? {};
    final id = properties['id']?.toString() ?? '---';
    final name = properties['name'] ?? 'Không rõ';
    final controller = Get.put(IncidentLiveMapController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initCommuneOverview(id);
    });
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Center(
              child: Text(
                "Tổng quan $name",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "• Mã khu vực: KV$id\n"
                          "• Tên: $name\n",
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    Obx(() {
                      if (controller.isOverviewLoading.value) {
                        return const IncidentPieChartShimmer();
                      }
                      return SizedBox(
                        height: 180,
                        child: IncidentPieChart(
                          traffic: controller.traffic.value,
                          security: controller.security.value,
                          infrastructure: controller.infrastructure.value,
                          environment: controller.environment.value,
                          other: controller.other.value,
                        ),
                      );
                    }),
                    const SizedBox(height: TSizes.mediumLargeSpace),
                    Obx(() {
                      return TimeFilterButtons(
                        selectedRange: controller.selectedRange.value,
                        onChanged: (range) => controller.updateCommuneOverviewRange(range, id),
                      );
                    }),

                    /// Lưu ý
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: TSizes.defaultSpace),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: TColors.warningContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Iconsax.lamp_on, color: TColors.warning),
                          const SizedBox(width: TSizes.xs),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  color: TColors.warning,
                                  fontSize: 14,
                                ),
                                children: [
                                  const TextSpan(
                                    text: '${TTexts.disclaimer}\n',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  TextSpan(text: TTexts.incidentLiveMapNotice),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          controller.focusOnCommune(Map<String, dynamic>.from(feature));
                          controller.enableCommuneFocus();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        child: const Text(
                          TTexts.communeDetail,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

