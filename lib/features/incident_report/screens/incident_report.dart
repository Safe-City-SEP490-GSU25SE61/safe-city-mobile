import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../common/widgets/appbar/appbar.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/validators/validation.dart';
import '../../authentication/controllers/login/login_controller.dart';

class IncidentReportScreen extends StatelessWidget {
  const IncidentReportScreen({super.key});

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    // 🔥 TODO: Add your API call here to refresh membership data
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final controller = Get.put(
      LoginController(),
    ); // Reuse controller for form handling

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: TColors.primary,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // 🔘 Anonymous toggle button here (Switch or Checkbox)
            const SizedBox(height: TSizes.spaceBtwItems),

            Form(
              key: controller.loginFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TAppBar(
                    title: Text(
                      'Báo cáo sự cố',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium!.apply(color: TColors.white),
                    ),
                    showBackArrow: false,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Thông tin người báo cáo",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Iconsax.refresh,
                                  color: Colors.black,
                                  size: 20,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Lịch sử',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: TSizes.spaceBtwItems),
                  const Text(
                    "Thông tin vụ việc",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: TSizes.spaceBtwItems),

                  /// Loại báo cáo
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Loại báo cáo *",
                      prefixIcon: Icon(Iconsax.activity),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'type1', child: Text("Loại 1")),
                      DropdownMenuItem(value: 'type2', child: Text("Loại 2")),
                    ],
                    onChanged: (value) {},
                    validator: (value) =>
                        value == null ? 'Vui lòng chọn loại báo cáo' : null,
                  ),

                  const SizedBox(height: TSizes.spaceBtwInputFields),

                  /// Địa điểm xảy ra
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Địa điểm xảy ra *",
                      prefixIcon: Icon(Iconsax.location),
                      suffixIcon: Icon(Iconsax.location_tick),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'location1',
                        child: Text("Địa điểm 1"),
                      ),
                      DropdownMenuItem(
                        value: 'location2',
                        child: Text("Địa điểm 2"),
                      ),
                    ],
                    onChanged: (value) {},
                    validator: (value) =>
                        value == null ? 'Vui lòng chọn địa điểm' : null,
                  ),

                  const SizedBox(height: TSizes.spaceBtwInputFields),

                  /// Thời gian xảy ra
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Chọn ngày *",
                            prefixIcon: Icon(Iconsax.calendar),
                          ),
                          readOnly: true,
                          onTap: () {
                            // TODO: Show date picker
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Chọn thời gian",
                            prefixIcon: Icon(Iconsax.clock),
                          ),
                          readOnly: true,
                          onTap: () {
                            // TODO: Show time picker
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: TSizes.spaceBtwInputFields),

                  /// Bằng chứng
                  Container(
                    width: double.infinity,
                    height: 150,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        "📎 Nhấn để tải lên hình ảnh hoặc video liên quan đến vụ việc\nTối đa 3 bức ảnh và 1 video không quá 5 phút",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    // 🖼️ Replace this with your image/video upload widget later
                  ),

                  const SizedBox(height: TSizes.spaceBtwInputFields),

                  /// Mô tả chi tiết
                  TextFormField(
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: "Mô tả chi tiết",
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        TValidator.validateEmptyText("Mô tả", value),
                  ),

                  const SizedBox(height: TSizes.spaceBtwItems),

                  /// Lưu ý
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "⚠️ Lưu ý\nNếu bạn đang gặp nguy hiểm hoặc tình huống cần sự giúp đỡ thì hãy liên hệ các cơ quan chức năng gần nhất để được giúp đỡ kịp thời.",
                      style: TextStyle(fontSize: 13),
                    ),
                  ),

                  const SizedBox(height: TSizes.spaceBtwItems),

                  /// Gửi báo cáo
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                      ),
                      onPressed: () {
                        // TODO: Validate and submit
                      },
                      child: const Text("Gửi báo cáo"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
