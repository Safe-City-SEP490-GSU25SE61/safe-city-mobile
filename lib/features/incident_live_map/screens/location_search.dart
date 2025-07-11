import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../controllers/incident_live_map_controller.dart';

class LocationSearchScreen extends StatelessWidget {
  const LocationSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mapController = Get.find<IncidentLiveMapController>();

    return Scaffold(
      appBar: AppBar(title: const Text("Tìm kiếm địa điểm")),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            TextFormField(
              autofocus: true,
              controller: mapController.searchController,
              decoration: const InputDecoration(
                hintText: 'Nhập tên địa điểm...',
                prefixIcon: Icon(Iconsax.search_normal),
                border: OutlineInputBorder(),
              ),
              onChanged: mapController.searchPlace,
              textInputAction: TextInputAction.search,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (mapController.predictions.isEmpty) {
                  return const Center(child: Text('Không có gợi ý'));
                }
                return ListView.builder(
                  itemCount: mapController.predictions.length,
                  itemBuilder: (context, index) {
                    final prediction = mapController.predictions[index];
                    return ListTile(
                      title: Text(prediction.description),
                      onTap: () {
                        Get.back(result: prediction.placeId);
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
