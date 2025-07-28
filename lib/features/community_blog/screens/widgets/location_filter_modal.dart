import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../controllers/blog_controller.dart';
import '../../controllers/blog_filter_controller.dart';

class LocationFilterModal extends StatefulWidget {
  final VoidCallback onApply;

  const LocationFilterModal({super.key, required this.onApply});

  @override
  State<LocationFilterModal> createState() => _LocationFilterModalState();
}

class _LocationFilterModalState extends State<LocationFilterModal> {
  final List<String> tabs = ['Sắp xếp', 'Vị trí'];
  final controller = Get.put(BlogFilterController());

  int selectedIndex = 0;

  final List<String> sortOptions = ['Hoạt động gần đây', 'Bài viết mới'];
  String? selectedSort;
  String? selectedCity;
  String? selectedDistrict;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        selectedCity = controller.selectedProvince.value.isNotEmpty
            ? controller.selectedProvince.value
            : null;
        selectedDistrict = controller.selectedCommune.value.isNotEmpty
            ? controller.selectedCommune.value
            : null;
      });
    });
  }

  Widget _buildTabContent() {
    final cities = controller.provinces;
    final districts = controller.communes;
    final dark = THelperFunctions.isDarkMode(context);
    if (selectedIndex == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Sắp xếp theo",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Wrap(
            spacing: 6,
            runSpacing: 0,
            children: sortOptions
                .map(
                  (option) => Theme(
                    data: Theme.of(context).copyWith(
                      chipTheme: ChipThemeData(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                        labelStyle: const TextStyle(fontSize: 10),
                      ),
                    ),
                    child: ChoiceChip(
                      label: Text(option),
                      backgroundColor: dark ? Colors.white : Colors.white,
                      selected: selectedSort == option,
                      onSelected: (_) {
                        setState(() => selectedSort = option);
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
                        horizontal: 8,
                        vertical: 10,
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
                      controller.fetchCommunesByProvince(city);
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
        Text(
          "Phường/Xã",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Wrap(
          spacing: 6,
          runSpacing: 0,
          children: districts
              .map(
                (district) => Theme(
                  data: Theme.of(context).copyWith(
                    chipTheme: ChipThemeData(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      labelStyle: const TextStyle(fontSize: 10),
                    ),
                  ),
                  child: ChoiceChip(
                    backgroundColor: dark ? Colors.white : Colors.white,
                    label: Text(district),
                    selected: selectedDistrict == district,
                    onSelected: (_) {
                      setState(() => selectedDistrict = district);
                    },
                    selectedColor: TColors.primary,
                    labelStyle: TextStyle(
                      color: selectedDistrict == district
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Row(
        children: [
          Container(
            width: 90,
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
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(child: _buildTabContent()),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              selectedSort = null;
                              selectedCity = null;
                              selectedDistrict = null;
                            });
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
                            if (selectedDistrict != null &&
                                selectedCity != null) {
                              final provinceIndex = controller.provinces
                                  .indexOf(selectedCity!);
                              if (provinceIndex != -1) {
                                final communeId = await controller.service
                                    .getCommuneIdByName(
                                      selectedDistrict!,
                                      provinceIndex + 1,
                                    );

                                if (communeId != null) {
                                  controller.selectedProvince.value =
                                      selectedCity!;
                                  controller.selectedCommune.value =
                                      selectedDistrict!;
                                  Get.back();
                                  await BlogController.instance
                                      .fetchBlogsByCommuneId(communeId);
                                }
                              }
                            }

                            widget.onApply();
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
