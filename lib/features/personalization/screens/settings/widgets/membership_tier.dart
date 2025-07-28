import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../common/widgets/texts/section_heading.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/image_strings.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/text_strings.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../../../utils/helpers/user_rank_helper.dart';
import '../../../controllers/profile/user_profile_controller.dart';

class MembershipTierScreen extends StatelessWidget {
  MembershipTierScreen({super.key});

  final userController = Get.put(UserProfileController());

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: const TAppBar(
        title: Text('Hạng Thành Viên'),
        showBackArrow: true,
      ),
      body: Obx(() {
        final user = userController.user.value;
        final rank = getUserRankFromString(user.achievementName);
        final rankText = getRankText(rank);
        final rankImage = getRankImage(rank);
        final hasPoints = user.totalPoint > 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(TSizes.md),
          child: Column(
            children: [
              /// Card with rank info
              SizedBox(
                width: double.infinity,
                child: Card(
                  color: dark ? TColors.lightGrey : TColors.lightGrey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(TSizes.md),
                    child: Column(
                      children: [
                        Image.asset(rankImage, width: 100, height: 100),
                        const SizedBox(height: TSizes.mediumSpace),
                        Text(
                          user.fullName,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rankText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: TColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        hasPoints
                            ? RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${user.totalPoint}',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: TColors.accent,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' Điểm',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: TColors.accent),
                                    ),
                                  ],
                                ),
                              )
                            : RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '0',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: TColors.accent,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' Điểm',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: TColors.accent),
                                    ),
                                  ],
                                ),
                              ),
                        if (hasPoints && user.totalPoint > 10000)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: TColors.infoContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: TColors.info,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        color: TColors.info,
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
                                        TextSpan(text: TTexts.exceedPoints),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: TSizes.spaceBtwItems),

              /// Rank Progress & Benefits
              TSectionHeading(
                title: 'Quyền lợi theo cấp bậc',
                showActionButton: false,
              ),

              const SizedBox(height: TSizes.spaceBtwItems),

              _buildRankBenefitTile(
                imagePath: TImages.bronze,
                rank: 'Hạng Đồng',
                benefits: [
                  'Ưu tiên xử lý báo cáo sự cố mức cơ bản',
                  'Bài viết Blog được duyệt nhanh hơn',
                ],
                dark: dark,
                requiredPoints: 1000,
              ),

              _buildRankBenefitTile(
                imagePath: TImages.silver,
                rank: 'Hạng Bạc',
                benefits: [
                  'Ưu tiên xử lý báo cáo cao hơn',
                  'Blog được duyệt ưu tiên',
                  'Tạo tối đa 7 nhóm hộ tống ảo',
                  'Giảm 15% phí dịch vụ trong app',
                ],
                dark: dark,
                requiredPoints: 3000,
              ),

              _buildRankBenefitTile(
                imagePath: TImages.gold,
                rank: 'Hạng Vàng',
                benefits: [
                  'Báo cáo được ưu tiên xử lý sớm nhất',
                  'Blog xuất hiện sớm trên trang cộng đồng',
                  'Tạo tối đa 10 nhóm hộ tống ảo',
                  'Mỗi nhóm tăng tối đa thành viên từ 5 lên 10 người',
                  'Giảm 15% phí dịch vụ trong app',
                ],
                dark: dark,
                requiredPoints: 5000,
              ),

              _buildRankBenefitTile(
                imagePath: TImages.platinum,
                rank: 'Hạng Bạch Kim',
                benefits: [
                  'Xử lý tức thời các báo cáo khẩn cấp',
                  'Blog được ghim nổi bật nếu có chất lượng',
                  'Tạo tối đa 10 nhóm hộ tống ảo',
                  'Mỗi nhóm tăng thành viên tối đa lên 15 người',
                  'Giảm 15% phí dịch vụ trong app',
                  'Tham gia sự kiện đặc biệt từ hệ thống',
                ],
                dark: dark,
                requiredPoints: 7000,
              ),

              _buildRankBenefitTile(
                imagePath: TImages.protector,
                rank: 'Người bảo vệ',
                benefits: [
                  'Sở hữu tất cả quyền lợi từ các cấp bậc trước',
                  'Huy hiệu danh dự trong hồ sơ & bình luận',
                  'Được mời vào nhóm phản ứng nhanh địa phương',
                  'Ưu tiên tiếp cận tính năng mới của ứng dụng',
                  'Tham gia ban quản lý cộng đồng (xét duyệt bài viết, hỗ trợ thành viên)',
                ],
                dark: dark,
                requiredPoints: 10000,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildRankBenefitTile({
    required String imagePath,
    required String rank,
    required List<String> benefits,
    required bool dark,
    required int requiredPoints, // NEW PARAM
  }) {
    return Card(
      color: dark ? TColors.lightGrey : TColors.lightGrey,
      margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(imagePath, width: 40, height: 40),
                    const SizedBox(width: 12),
                    Text(
                      rank,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Text(
                  '$requiredPoints điểm',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: TColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ...benefits.map(
              (b) => Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: TColors.success,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        b,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
