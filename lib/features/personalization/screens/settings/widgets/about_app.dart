import 'package:flutter/material.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../utils/constants/image_strings.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: TAppBar(title: Text('Thông tin chung'), showBackArrow: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Center(
                child: SizedBox(
                  width: 350,
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          Image.asset(TImages.lightAppLogo, height: 64),
                          const SizedBox(height: 16),
                          Text(
                            'Phiên bản 1.0.0 build 00001',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: dark ? Colors.black : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: TSizes.smallSpace),

              // Info links card
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Column(
                  children: const [
                    _SettingTile(title: 'Điều khoản sử dụng'),
                    Divider(height: 1),
                    _SettingTile(title: 'Chính sách quyền riêng tư'),
                    Divider(height: 1),
                    _SettingTile(title: 'Quy chế hoạt động'),
                  ],
                ),
              ),
              const SizedBox(height: TSizes.smallSpace),

              // Social links card
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Column(
                  children: const [
                    _SettingTile(title: 'Safe City trên Youtube'),
                    Divider(height: 1),
                    _SettingTile(title: 'Safe City trên Facebook'),
                    Divider(height: 1),
                    _SettingTile(title: 'Safe City trên Tiktok'),
                  ],
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems),

              // Company info
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    Text(
                      'Công ty Cổ phần Dịch vụ Di động Trực tuyến (Safe City)',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tầng 10, Tòa nhà Landmark, số 12 Nguyễn Huệ, Phường Bến Nghé, Quận 1, Thành phố Hồ Chí Minh',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Giấy chứng nhận đăng ký doanh nghiệp số 0305289153 do Sở Kế Hoạch và Đầu Tư Thành phố Hồ Chí Minh cấp lần đầu vào ngày 26/10/2024',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Hotline: 1900 1234 88\nEmail: hotro@safecity.vn',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String title;

  const _SettingTile({required this.title});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: dark ? Colors.black : Colors.black),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // TODO: Implement navigation
      },
    );
  }
}
