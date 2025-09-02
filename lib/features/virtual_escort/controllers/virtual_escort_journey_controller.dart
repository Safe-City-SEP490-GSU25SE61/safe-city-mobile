import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:get/get.dart';
import 'package:safe_city_mobile/features/virtual_escort/controllers/virtual_escort_map_controller.dart';
import 'package:signalr_netcore/hub_connection.dart';

import '../../../common/widgets/popup/popup_modal.dart';
import '../../../data/services/virtual_escort/virtual_escort_service.dart';
import '../../../navigation_dart.dart';
import '../../../utils/constants/image_strings.dart';

class VirtualEscortJourneyController extends GetxController {
  static VirtualEscortJourneyController get instance => Get.find();
  final virtualEscortJourneyFormKey = GlobalKey<FormState>();
  final destination = TextEditingController();
  final origin = TextEditingController();
  final estimatedTime = '15 minutes'.obs;
  final transportMode = 'Xe máy'.obs;
  final shareLocation = true.obs;
  final currentTab = 0.obs;
  final escortService = VirtualEscortService();
  final isBatteryLow = false.obs;
  final isBatteryCritical = false.obs;
  final isInternetWeak = false.obs;
  final isGpsUnstable = false.obs;
  Timer? _locationTimer;
  final leaderLat = 0.0.obs;
  final leaderLng = 0.0.obs;
  final sosCount = 0.obs;

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  late StreamSubscription<BatteryState> _batterySubscription;

  @override
  void onInit() {
    super.onInit();
    monitorBattery();
    monitorInternet();
    monitorGps();
  }

  @override
  void onClose() {
    stopSendingLocation();
    _connectivitySubscription.cancel();
    _batterySubscription.cancel();
    super.onClose();
  }

  void monitorBattery() {
    final battery = Battery();
    _batterySubscription = battery.onBatteryStateChanged.listen((state) async {
      final level = await battery.batteryLevel;
      if (level <= 10) {
        isBatteryCritical.value = true;
        isBatteryLow.value = false;
      } else if (level <= 20) {
        isBatteryLow.value = true;
        isBatteryCritical.value = false;
      } else {
        isBatteryLow.value = false;
        isBatteryCritical.value = false;
      }
    });
  }

  void monitorInternet() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      final result = results.isNotEmpty
          ? results.first
          : ConnectivityResult.none;
      isInternetWeak.value = (result == ConnectivityResult.none);
    });
  }

  void monitorGps() {
    geo.Geolocator.getServiceStatusStream().listen((status) {
      if (status == geo.ServiceStatus.disabled) {
        isGpsUnstable.value = true;
      } else {
        isGpsUnstable.value = false;
      }
    });
  }

  void setTab(int index) => currentTab.value = index;

  void startEscort() {
    if (virtualEscortJourneyFormKey.currentState?.validate() ?? false) {
      debugPrint('Starting journey to: ${destination.text}');
      debugPrint('Time: ${estimatedTime.value}');
      debugPrint('Mode: ${transportMode.value}');
      debugPrint('Share Location: ${shareLocation.value}');
    }
  }

  Future<void> initConnection({required bool isLeader,required int memberId}) async {
    await escortService.initSignalR(isLeader: isLeader, memberId: memberId);
    if (!isLeader) {
      escortService.hubConnection?.on("ReceiveLeaderLocation", (args) {
        if (args == null || args.length < 2) return;
        final lat = args[0] as double;
        final lng = args[1] as double;

        debugPrint("👀 Observer received leader location: $lat, $lng");
        debugPrint("📡 Received location update: $lat, $lng");
        debugPrint("📡 Received location update: $lat, $lng");
        leaderLat.value = lat;
        leaderLng.value = lng;
        VirtualEscortMapController.instance.updateObserverMarker(lat, lng);
      });

      escortService.hubConnection?.on("ReceiveSos", (args) {
        if (args == null || args.length < 3) return;

        final message = args[0] as String;
        final lat = (args[1] as num).toDouble();
        final lng = (args[2] as num).toDouble();

        debugPrint("🚨 SOS received: $message at ($lat, $lng)");

        PopUpModal.instance.showOkOnlyDialogSos(
          title: "Tín hiệu SOS",
          message: "Người dùng đã gửi tín hiệu SOS!",
          lat: lat,
          lng: lng,
          onOk: () {
            VirtualEscortMapController.instance.updateObserverMarker(lat, lng);
          },
        );
      });

      escortService.hubConnection?.on("LeaderDisconnected", (args) {
        final message = (args != null && args.isNotEmpty)
            ? args[0] as String
            : "Hành trình đã kết thúc.";

        debugPrint("🏁 Journey ended by leader: $message");

        PopUpModal.instance.showOkOnlyDialog(
          title: "Thông báo",
          messageWidget: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                TImages.locationReached,
                height: 100,
              ),
              const SizedBox(height: 16),
              const Text(
                "Người tạo hành trình đã đến đích an toàn!",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          onOk: () {
            Get.offAll(() => NavigationMenu());
          },
        );
      });
    }
  }

  Future<void> startSendingLocation() async {
    if (escortService.hubConnection?.state != HubConnectionState.Connected) {
      try {
        await escortService.hubConnection?.start();
        debugPrint("✅ Hub connected");
      } catch (e) {
        debugPrint("❌ Failed to connect hub: $e");
      }
    }

    _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final position = await geo.Geolocator.getCurrentPosition(
          desiredAccuracy: geo.LocationAccuracy.high,
        );

        final lat = position.latitude;
        final lng = position.longitude;

        debugPrint("🚗 Leader sending location: $lat, $lng");

        await escortService.updateLocationSignalR(lat, lng);
      } catch (e) {
        debugPrint("❌ Failed to send location: $e");
      }
    });
  }

  Future<void> sendSosSignal() async {
    try {
      final position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );

      final lat = position.latitude;
      final lng = position.longitude;

      await escortService.hubConnection?.invoke(
        "SendSos",
        args: [lat, lng, DateTime.now().toUtc().toIso8601String()],
      );
      sosCount.value++;
      debugPrint("📢 SOS sent: $lat, $lng");
    } catch (e) {
      debugPrint("❌ Failed to send SOS: $e");
    }
  }

  void cancel() {
    Get.back();
  }

  void openAdvancedOptions() {
    setTab(1);
  }

  Future<void> stopSendingLocation() async {
    await escortService.stopSignalR();
    _locationTimer?.cancel();
    _locationTimer = null;
  }
}
