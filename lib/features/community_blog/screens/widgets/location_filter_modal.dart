import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safe_city_mobile/common/widgets/effects/shimmer_effect.dart';
import 'package:safe_city_mobile/utils/constants/sizes.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../controllers/blog_controller.dart';

class LocationFilterModal extends StatefulWidget {
  final VoidCallback onApply;

  const LocationFilterModal({super.key, required this.onApply});

  @override
  State<LocationFilterModal> createState() => _LocationFilterModalState();
}

class _LocationFilterModalState extends State<LocationFilterModal> {
  final List<String> tabs = ['Sắp xếp', 'Vị trí'];
  final blogController = Get.put(BlogController());

  int selectedIndex = 0;

  final List<String> sortPriorityOptions = [
    'Cảnh báo',
    'Mẹo vặt',
    'Sự kiện',
    'Tin tức',
  ];
  String? selectedSort;
  String? selectedCity;
  String? selectedDistrict;

  @override
  void initState() {
    super.initState();

    selectedSort = blogController.selectedBlogType.value?.viLabel;
    final defaultProvince = blogController.provinces.isNotEmpty
        ? blogController.provinces.first.name
        : null;

    selectedCity = blogController.selectedProvince.value.isNotEmpty
        ? blogController.selectedProvince.value
        : defaultProvince;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (selectedCity != null && blogController.communes.isEmpty) {
        blogController.selectedProvince.value = selectedCity!;
        await blogController.fetchCommunesByProvince(selectedCity!);
      }
    });
    selectedDistrict = blogController.selectedCommune.value.isNotEmpty
        ? blogController.selectedCommune.value
        : null;
  }

  void loadInitialCommunes() {
    final city = blogController.selectedProvince.value;
    if (city.isNotEmpty) {
      final province = blogController.provinces.firstWhereOrNull(
        (p) => p.name == city,
      );

      if (province != null) {
        blogController.communes.value = province.communes;
      }
    }
  }

  Widget _buildTabContent() {
    final cities = blogController.provinces.map((e) => e.name).toSet().toList();
    final dark = THelperFunctions.isDarkMode(context);

    if (selectedIndex == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Loại bài viết",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Wrap(
            spacing: 6,
            runSpacing: 0,
            children: sortPriorityOptions
                .map(
                  (option) => Theme(
                    data: Theme.of(context).copyWith(
                      chipTheme: ChipThemeData(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 0,
                        ),
                        labelStyle: const TextStyle(fontSize: 10),
                      ),
                    ),
                    child: ChoiceChip(
                      label: Text(option),
                      backgroundColor: dark ? Colors.white : Colors.white,
                      selected: selectedSort == option,
                      onSelected: (_) {
                        final type = mapBlogToType(option);
                        setState(() {
                          selectedSort = option;
                          blogController.selectedBlogType.value = type;
                        });
                      },
                      selectedColor: TColors.primary,
                      labelStyle: TextStyle(
                        color: selectedSort == option
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tỉnh/Thành phố",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Wrap(
          spacing: 6,
          runSpacing: 0,
          children: cities
              .map(
                (city) => Theme(
                  data: Theme.of(context).copyWith(
                    chipTheme: ChipThemeData(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 6,
                      ),
                      labelStyle: const TextStyle(fontSize: 10),
                    ),
                  ),
                  child: ChoiceChip(
                    backgroundColor: dark ? Colors.white : Colors.white,
                    label: Text(city),
                    selected: selectedCity == city,
                    onSelected: (_) {
                      setState(() {
                        selectedCity = city;
                        selectedDistrict = null;
                      });
                      blogController.fetchCommunesByProvince(city);
                    },
                    selectedColor: TColors.primary,
                    labelStyle: TextStyle(
                      color: selectedCity == city ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
        const Text(
          "Phường/Xã",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        Obx(() {
          final isLoading =
              blogController.status.value == FilterStatus.loadingCommunes;
          final communeItems = isLoading
              ? List.generate(
                  6,
                  (_) => const TShimmerEffect(width: 80, height: 40),
                )
              : blogController.communes.map((commune) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      chipTheme: ChipThemeData(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 6,
                        ),
                        labelStyle: const TextStyle(fontSize: 10),
                      ),
                    ),
                    child: ChoiceChip(
                      backgroundColor: dark ? Colors.white : Colors.white,
                      label: Text(commune.name),
                      selected: selectedDistrict == commune.name,
                      onSelected: (_) =>
                          setState(() => selectedDistrict = commune.name),
                      selectedColor: TColors.primary,
                      labelStyle: TextStyle(
                        color: selectedDistrict == commune.name
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  );
                }).toList();

          return Wrap(spacing: 6, runSpacing: 0, children: communeItems);
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Row(
        children: [
          Container(
            width: 85,
            color: Colors.grey.shade100,
            child: ListView.builder(
              itemCount: tabs.length,
              itemBuilder: (context, index) {
                final isSelected = selectedIndex == index;
                return InkWell(
                  onTap: () => setState(() => selectedIndex = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.grey.shade100,
                      border: isSelected
                          ? const Border(
                              left: BorderSide(
                                color: TColors.primary,
                                width: 4,
                              ),
                            )
                          : null,
                    ),
                    child: Text(
                      tabs[index],
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(TSizes.mediumSpace),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(child: _buildTabContent()),
                  ),
                  const SizedBox(height: TSizes.mediumSpace),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () async {
                            setState(() {
                              selectedSort = null;
                              selectedCity = null;
                              selectedDistrict = null;
                            });
                            blogController.selectedBlogType.value = null;
                            blogController.selectedProvince.value = '';
                            blogController.selectedCommune.value = '';
                            await blogController.fetchInitialDataOnce(
                              isFirstRequest: true,
                            );
                            widget.onApply();
                            Get.back();
                          },
                          child: const Text(
                            "Thiết lập lại",
                            style: TextStyle(fontSize: 12, color: Colors.black),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            final type = selectedSort != null
                                ? mapBlogToType(selectedSort!)
                                : null;
                            final province = selectedCity ?? '';
                            final commune = selectedDistrict ?? '';
                            final communeId = blogController.blogService
                                .getCommuneIdByName(province, commune);
                            final bool isFirstRequest =
                                (communeId == null || communeId == 0);

                            await blogController.fetchInitialDataOnce(
                              provinceName: province.isEmpty ? null : province,
                              communeName: commune.isEmpty ? null : commune,
                              type: type,
                              isFirstRequest: isFirstRequest,
                              searchQuery: blogController.searchController.text
                                  .trim(),
                            );

                            blogController.selectedProvince.value = province;
                            blogController.selectedCommune.value = commune;
                            blogController.selectedBlogType.value = type;

                            if (province.isNotEmpty) {
                              await blogController.fetchCommunesByProvince(
                                province,
                              );
                            }

                            widget.onApply();
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                          child: const Text("Áp dụng"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
