import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../controllers/incident_report_controller.dart';

class FilterHistoryModal extends StatefulWidget {
  final VoidCallback onApply;

  const FilterHistoryModal({super.key, required this.onApply});

  @override
  State<FilterHistoryModal> createState() => _FilterHistoryModalState();
}

class _FilterHistoryModalState extends State<FilterHistoryModal> {
  final controller = Get.find<IncidentReportController>();
  final List<String> tabs = [
    'Khoảng thời gian',
    'Trạng thái',
    'Sắp xếp',
    'Mức độ ưu tiên',
  ];

  int selectedIndex = 0;

  ReportRange? selectedRange;
  ReportStatus? selectedStatus;
  ReportSort? selectedSort;
  ReportPriority? selectedPriority;

  @override
  void initState() {
    super.initState();
    selectedRange = controller.selectedRange.value;
    selectedStatus = controller.selectedStatus.value;
    selectedSort = controller.selectedFilterSort.value;
    selectedPriority = controller.selectedFilterPriority.value;
  }

  Widget _buildTabContent() {
    switch (selectedIndex) {
      case 0:
        return _buildList(controller.rangeOptions, selectedRange, (val) {
          setState(() => selectedRange = val);
        });
      case 1:
        return _buildList(controller.statusOptions, selectedStatus, (val) {
          setState(() => selectedStatus = val);
        });
      case 2:
        return _buildList(controller.sortOptions, selectedSort, (val) {
          setState(() => selectedSort = val);
        });
      case 3:
        return _buildList(controller.priorityOptions, selectedPriority, (val) {
          setState(() => selectedPriority = val);
        });
      default:
        return const SizedBox();
    }
  }

  Widget _buildList<T>(
    List<T> options,
    T? selected,
    void Function(T) onSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: options.map((item) {
        late String label;
        if (item is ReportRange) {
          label = item.label;
        } else if (item is ReportStatus) {
          label = item.label;
        } else if (item is ReportSort) {
          label = item.label;
        } else if (item is ReportPriority) {
          label = item.label;
        } else {
          label = item.toString();
        }

        final isSelected = selected == item;

        return ListTile(
          title: Text(label, style: const TextStyle(color: Colors.black)),
          trailing: isSelected
              ? const Icon(Icons.check, color: TColors.primary)
              : null,
          onTap: () => onSelected(item),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Row(
        children: [
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
            child: Container(
              color: Colors.white,
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
                              selectedRange = null;
                              selectedStatus = null;
                              selectedSort = null;
                              selectedPriority = null;
                            });
                          },
                          child: const Text(
                            "Thiết lập lại",
                            style: TextStyle(fontSize: 12, color: Colors.black),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            controller.updateFilters(
                              range: selectedRange,
                              status: selectedStatus,
                              sort: selectedSort,
                              priority: selectedPriority,
                            );

                            Navigator.pop(context);
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
