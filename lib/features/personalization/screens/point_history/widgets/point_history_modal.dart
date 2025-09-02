import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../controllers/profile/user_profile_controller.dart';

class PointHistoryFilterModal extends StatefulWidget {
  final VoidCallback onApply;

  const PointHistoryFilterModal({super.key, required this.onApply});

  @override
  State<PointHistoryFilterModal> createState() => _PointHistoryFilterModalState();
}

class _PointHistoryFilterModalState extends State<PointHistoryFilterModal> {
  final controller = Get.find<UserProfileController>();
  final List<String> tabs = ["Khoảng thời gian", "Nguồn điểm", "Sắp xếp"];
  int selectedIndex = 0;

  late PointHistoryRange selectedRange;
  PointHistorySource? selectedSource;
  late PointHistorySort selectedSort;

  @override
  void initState() {
    super.initState();
    selectedRange = controller.selectedRange.value;
    selectedSource = controller.selectedSource.value;
    selectedSort = controller.selectedSort.value;
  }

  Widget _buildList<T>(List<T> options, T? selected, void Function(T) onSelected) {
    return Column(
      children: options.map((item) {
        String label = (item is PointHistoryRange)
            ? item.label
            : (item is PointHistorySource)
            ? item.label
            : (item is PointHistorySort)
            ? item.label
            : item.toString();

        final isSelected = selected == item;

        return ListTile(
          title: Text(label),
          trailing: isSelected ? const Icon(Icons.check, color: TColors.primary) : null,
          onTap: () => onSelected(item),
        );
      }).toList(),
    );
  }

  Widget _buildTabContent() {
    switch (selectedIndex) {
      case 0:
        return _buildList(PointHistoryRange.values, selectedRange, (val) {
          setState(() => selectedRange = val);
        });
      case 1:
        return _buildList(PointHistorySource.values, selectedSource, (val) {
          setState(() => selectedSource = val);
        });
      case 2:
        return _buildList(PointHistorySort.values, selectedSort, (val) {
          setState(() => selectedSort = val);
        });
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Row(
        children: [
          // Tabs
          Container(
            width: 120,
            color: Colors.grey.shade100,
            child: ListView.builder(
              itemCount: tabs.length,
              itemBuilder: (context, index) {
                final isSelected = selectedIndex == index;
                return InkWell(
                  onTap: () => setState(() => selectedIndex = index),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.grey.shade100,
                      border: isSelected
                          ? const Border(
                        left: BorderSide(color: TColors.primary, width: 4),
                      )
                          : null,
                    ),
                    child: Text(
                      tabs[index],
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Options
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(child: SingleChildScrollView(child: _buildTabContent())),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            selectedRange = PointHistoryRange.month;
                            selectedSource = null;
                            selectedSort = PointHistorySort.desc;
                          });
                          controller.updateFilters(
                            range: PointHistoryRange.month,
                            source: null,
                            sort: PointHistorySort.desc,
                          );
                        },
                        child: const Text("Thiết lập lại", style: TextStyle(color: Colors.black)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          controller.updateFilters(
                            range: selectedRange,
                            source: selectedSource,
                            sort: selectedSort,
                          );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: TColors.primary),
                        child: const Text("Áp dụng"),
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
