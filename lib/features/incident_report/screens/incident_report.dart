import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:safe_city_mobile/features/incident_report/screens/widgets/date_time_picker.dart';
import 'package:safe_city_mobile/features/incident_report/screens/widgets/live_map.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../common/widgets/appbar/appbar.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/constants/text_strings.dart';
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
    final controller = Get.put(LoginController());

    return Scaffold(
      appBar: TAppBar(
        title: Text(
          'Báo cáo sự cố',
          style: Theme
              .of(context)
              .textTheme
              .headlineMedium!,
        ),
        showBackArrow: false,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: TColors.primary,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Form(
                key: controller.loginFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                SizedBox(height: TSizes.spaceBtwItems),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                          () =>
                          Checkbox(
                            value: controller.rememberMe.value,
                            onChanged: (value) =>
                            controller.rememberMe.value =
                            !controller.rememberMe.value,
                          ),
                    ),
                    Expanded(
                      child: Text(
                        TTexts.anonymousReport,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: TSizes.spaceBtwItems),
                const Text(
                  "Thông tin vụ việc",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: TSizes.spaceBtwItems),

                /// Loại báo cáo
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    label: RichText(
                      text: TextSpan(
                        text: 'Loại báo cáo ',
                        style: TextStyle(
                          color: dark ? Colors.white : Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
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
                    prefixIcon: Icon(Iconsax.activity),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Littering',
                      child: Text("Xả rác"),
                    ),
                    DropdownMenuItem(
                      value: 'TrafficJam',
                      child: Text("Kẹt xe"),
                    ),
                    DropdownMenuItem(
                      value: 'Accident',
                      child: Text("Tai nạn"),
                    ),
                    DropdownMenuItem(value: 'Fighting', child: Text("Ẩu đả")),
                    DropdownMenuItem(value: 'Theft', child: Text("Trộm cắp")),
                    DropdownMenuItem(
                      value: 'PublicDisorder',
                      child: Text("Gây rối trật tự công cộng"),
                    ),
                    DropdownMenuItem(
                      value: 'Vandalism',
                      child: Text("Phá hoại tài sản"),
                    ),
                    DropdownMenuItem(value: 'Other', child: Text("Khác")),
                  ],
                  onChanged: (value) {},
                  validator: (value) =>
                  value == null ? 'Vui lòng chọn loại báo cáo' : null,
                ),

                const SizedBox(height: TSizes.spaceBtwInputFields),

                /// Địa điểm xảy ra
                TextFormField(
                  controller: controller.email,
                  decoration: InputDecoration(
                    label: RichText(
                      text: TextSpan(
                        text: 'Địa điểm xảy ra ',
                        style: TextStyle(
                          color: dark ? Colors.white : Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
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
                    prefixIcon: const Icon(Iconsax.location),
                    suffixIcon: IconButton(
                      icon: const Icon(Iconsax.location_tick),
                      onPressed: () async {
                        await Get.to(() => const LiveMapScreen());
                      },
                    ),
                  ),
                  validator: (value) =>
                  value == null || value
                      .trim()
                      .isEmpty
                      ? 'Vui lòng chọn địa điểm'
                      : null,
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),
                const DateTimePickerField(),
                const SizedBox(height: TSizes.spaceBtwInputFields),

            /// Mô tả chi tiết
            TextFormField(
              maxLines: 5,
              decoration: InputDecoration(
                label: RichText(
                  text: TextSpan(
                    text: 'Mô tả chi tiết ',
                    style: TextStyle(
                      color: dark ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
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
                prefixIcon: const Icon(Iconsax.edit),
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  TValidator.validateEmptyText("Mô tả", value),
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

            /// Lưu ý
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TColors.warningContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: TColors.warning,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: TColors.warning,
                          fontSize: 14,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Important Notice\n',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          TextSpan(text: TTexts.emergencyHelpNotice),
                        ],
                      ),
                    ),
                  ),
                ],
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
    ),)
    ,
    );
  }
}
