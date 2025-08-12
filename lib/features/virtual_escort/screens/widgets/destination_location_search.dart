import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/virtual_escort_map_controller.dart';

class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({super.key});

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final mapController = Get.put(VirtualEscortMapController());
  late VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    _listener = () {
      if (mounted) {
        setState(() {});
      }
    };
    mapController.searchController.addListener(_listener);
  }

  @override
  void dispose() {
    mapController.searchController.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TAppBar(
        title: const Text("Tìm kiếm địa điểm"),
        showBackArrow: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.smallSpace),
        child: Column(
          children: [
            TextFormField(
              autofocus: true,
              controller: mapController.searchController,
              decoration: InputDecoration(
                hintText: 'Nhập tên địa điểm...',
                prefixIcon: const Icon(Iconsax.search_normal),
                suffixIcon: mapController.searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Iconsax.close_circle),
                        onPressed: () {
                          mapController.searchController.clear();
                          mapController.predictions.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: mapController.searchPlace,
              textInputAction: TextInputAction.search,
            ),
            const SizedBox(height: TSizes.mediumSpace),
            Expanded(
              child: Obx(() {
                if (mapController.predictions.isEmpty) {
                  return const Center(child: Text('Không có gợi ý'));
                }
                return ListView.separated(
                  itemCount: mapController.predictions.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final prediction = mapController.predictions[index];
                    return ListTile(
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Iconsax.location),
                          if (prediction.formattedDistance != null)
                            Text(
                              prediction.formattedDistance!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                      trailing: const Icon(Iconsax.send),
                      title: Text(
                        prediction.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        Get.back(result: {
                          'placeId': prediction.placeId,
                          'description': prediction.description,
                        });
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
