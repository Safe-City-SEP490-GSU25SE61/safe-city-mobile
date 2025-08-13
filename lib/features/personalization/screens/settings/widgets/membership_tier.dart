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
        final hasPoints = user.totalPoint > 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(TSizes.md),
          child: Column(
            children: [
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
                        Image.asset(TImages.bronze, width: 100, height: 100),
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
                        // Text(
                        //   rankText,
                        //   style: const TextStyle(
                        //     fontSize: 16,
                        //     fontWeight: FontWeight.w600,
                        //     color: TColors.primary,
                        //   ),
                        // ),
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
              TSectionHeading(
                title: 'Quyền lợi theo cấp bậc',
                showActionButton: false,
              ),

              const SizedBox(height: TSizes.spaceBtwItems),

              ...userController.achievements.map(
                    (achievement) => _buildRankBenefitTile(
                  rank: achievement.name,
                  benefits: achievement.benefit.split('. ').where((e) => e.isNotEmpty).toList(),
                  description: achievement.description,
                  requiredPoints: achievement.minPoint,
                  dark: dark,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildRankBenefitTile({
    required String rank,
    required List<String> benefits,
    required String description,
    required bool dark,
    required int requiredPoints,
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
                Text(
                  rank,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '$requiredPoints điểm',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: TColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: TColors.darkerGrey,
              ),
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

