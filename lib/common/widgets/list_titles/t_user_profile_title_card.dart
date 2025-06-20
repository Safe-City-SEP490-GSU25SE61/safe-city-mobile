import 'package:iconsax/iconsax.dart';
import 'package:safe_city_mobile/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/helpers/helper_functions.dart';

class TUserProfileCard extends StatelessWidget {
  const TUserProfileCard({
    super.key,
    required this.onPressed,
    required this.fullName,
    required this.phone,
    required this.profilePicture,
    required this.isNetworkImage,
    required this.rank,
    required this.isBiometricVerified,
    required this.membershipDateLeft,
  });

  final VoidCallback onPressed;
  final String fullName;
  final String phone;
  final String profilePicture;
  final bool isNetworkImage;
  final UserRank rank;
  final bool isBiometricVerified;
  final int membershipDateLeft;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          /// Main Card
          Container(
            margin: const EdgeInsets.only(top: 40),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: dark ? TColors.black : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const SizedBox(height: TSizes.lg),
                Text(
                  fullName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: dark ? TColors.white : TColors.black,
                  ),
                ),
                const SizedBox(height: 4),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      phone,
                      style: TextStyle(
                        fontSize: 14,
                        color: dark ? TColors.white : TColors.black,
                      ),
                    ),
                    if (isBiometricVerified) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: TColors.success,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Đã sinh trắc học',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),

                // 2 Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                getRankImage(rank),
                                width: 30,
                                height: 30,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                getRankText(rank),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: dark ? TColors.white : TColors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Iconsax.calendar_2,
                                color: Colors.pink,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$membershipDateLeft ngày premium',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: dark ? TColors.white : TColors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// Floating Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.pink.shade100,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: profilePicture.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: isNetworkImage
                        ? Image.network(
                            profilePicture,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            profilePicture,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                  )
                : Center(
                    child: Text(
                      fullName.isNotEmpty ? fullName[0] : '',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
