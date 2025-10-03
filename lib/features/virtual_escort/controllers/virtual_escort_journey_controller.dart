import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:get/get.dart';
import 'package:safe_city_mobile/features/virtual_escort/controllers/virtual_escort_map_controller.dart';
import 'package:signalr_netcore/hub_connection.dart';

import '../../../common/widgets/popup/popup_modal.dart';
import '../../../data/services/virtual_escort/virtual_escort_service.dart';
import '../../../navigation_dart.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/helpers/network_manager.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loaders.dart';
import '../screens/agora_video_calling.dart';

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
  final videoCallToken = RxnString();
  final videoCallAlertId = "".obs;
  final videoCallChannelName = "".obs;
  final uidToName = <int, String>{}.obs;
  late int leaderUid;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  late StreamSubscription<BatteryState> _batterySubscription;
  bool isDialogOpen = false;

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

  Future<void> initConnection({
    required bool isLeader,
    required int memberId,
  }) async {
    await escortService.initSignalR(isLeader: isLeader, memberId: memberId);
    if (isLeader) {
      escortService.hubConnection?.on("ReceiveToken", (args) {
        if (args == null || args.length < 5) return;

        final token = args[0] as String;
        final channelName = args[1] as String;
        final alertId = args[2].toString();
        final uid = args[3] as int;
        final watchers = args[4] as List<dynamic>;

        uidToName.clear();
        for (var w in watchers) {
          if (w is Map) {
            final key = w["key"];
            final value = w["value"];
            if (key != null && value != null) {
              uidToName[int.parse(key.toString())] = value.toString();
            }
          }
        }

        debugPrint("🎯 Leader received SOS token + channelName + alertId");
        debugPrint("🔑 Token: $token");
        debugPrint("📡 ChannelName: $channelName");
        debugPrint("🆔 AlertId: $alertId");
        for (final entry in uidToName.entries) {
          debugPrint("👤 Member UID: ${entry.key}, Name: ${entry.value}");
        }

        leaderUid = uid;
        videoCallToken.value = token;
        videoCallChannelName.value = channelName;
        videoCallAlertId.value = alertId;
      });
    } else {
      escortService.hubConnection?.on("ReceiveLeaderLocation", (args) {
        if (args == null || args.length < 2) return;
        final lat = args[0] as double;
        final lng = args[1] as double;
        final isGPSAvailable = args[2] as bool;
        final isInternetAvailable = args[3] as bool;
        final isUserBatteryLow = args[4] as bool;

        debugPrint("👀 Observer received leader location: $lat, $lng");
        debugPrint(
          "📡 GPS: $isGPSAvailable, Internet: $isInternetAvailable, BatteryLow: $isUserBatteryLow",
        );

        isGpsUnstable.value = !isGPSAvailable;
        isInternetWeak.value = !isInternetAvailable;
        isBatteryLow.value = isUserBatteryLow;
        leaderLat.value = lat;
        leaderLng.value = lng;
        VirtualEscortMapController.instance.updateObserverMarker(lat, lng);
      });

      escortService.hubConnection?.on("ReceiveSos", (args) {
        if (args == null || args.length < 3) return;

        final message = args[0] as String;
        final lat = (args[1] as num).toDouble();
        final lng = (args[2] as num).toDouble();

        final sosMessage = message;
        final sosLat = lat.toStringAsFixed(6);
        final sosLng = lng.toStringAsFixed(6);

        debugPrint("🚨 SOS received");
        debugPrint("📝 Message: $sosMessage");
        debugPrint("📍 Location: ($sosLat, $sosLng)");

        if (isDialogOpen) return;
        isDialogOpen = true;
        PopUpModal.instance.showOkOnlyDialogSos(
          title: "Tín hiệu SOS",
          message: "Người dùng đã gửi tín hiệu SOS!",
          lat: lat,
          lng: lng,
          onOk: () {
            isDialogOpen = false;
            VirtualEscortMapController.instance.updateObserverMarker(lat, lng);
          },
        );
      });

      escortService.hubConnection?.on("ReceiveVideoCall", (args) {
        if (args == null || args.length < 3) return;

        final message = args[0] as String;
        final alertId = args[1].toString();
        final watchers = args[2] as List<dynamic>;

        uidToName.clear();
        for (var w in watchers) {
          if (w is Map) {
            final key = w["key"];
            final value = w["value"];
            if (key != null && value != null) {
              uidToName[int.parse(key.toString())] = value.toString();
            }
          }
        }

        debugPrint("📞 Video call started by leader");
        debugPrint("📝 Message: $message");
        debugPrint("🆔 AlertId: $alertId");
        debugPrint("👥 Watchers in this call: $uidToName");

        videoCallAlertId.value = alertId;

        if (isDialogOpen) return;
        isDialogOpen = true;
        PopUpModal.instance.showOkOnlyDialogCall(
          title: "Cuộc gọi khẩn cấp",
          message: message,
          alertId: alertId,
          onJoinCall: () async {
            isDialogOpen = false;
            final result = await escortService.joinWatcher(int.parse(alertId));

            if (result["success"] == true) {
              final channelName = result["channelName"];
              final token = result["token"];
              final uid = result["uid"];

              Get.to(
                () => AgoraVideoCallingScreen(
                  token: token,
                  channelName: channelName,
                  userId: uid,
                  isLeader: false,
                  uidToName: uidToName,
                ),
              );
            } else {
              debugPrint("❌ Failed to join watcher: ${result["message"]}");
              TLoaders.warningSnackBar(
                message: "Không thể tham gia cuộc gọi",
                title: "Lỗi",
              );
            }
          },
          onCancel: () {
            isDialogOpen = false;
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
              Image.asset(TImages.locationReached, height: 100),
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

    _locationTimer = Timer.periodic(const Duration(seconds: 6), (timer) async {
      try {
        final position = await geo.Geolocator.getCurrentPosition(
          locationSettings: const geo.LocationSettings(
            accuracy: geo.LocationAccuracy.best,
            distanceFilter: 5,
          ),
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

  Future<void> sendSosSignal({bool isVideoCall = false}) async {
    try {
      final position = await geo.Geolocator.getCurrentPosition(
        locationSettings: const geo.LocationSettings(
          accuracy: geo.LocationAccuracy.best,
          distanceFilter: 5,
        ),
      );

      final lat = position.latitude;
      final lng = position.longitude;

      await escortService.hubConnection?.invoke(
        "SendSos",
        args: [lat, lng, DateTime.now().toUtc().toIso8601String(), isVideoCall],
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

  Future<void> stopSendingLocation({bool isLeader = false}) async {
    if (isLeader &&
        escortService.hubConnection?.state == HubConnectionState.Connected) {
      try {
        await escortService.hubConnection?.invoke("EndJourney");
        debugPrint("🏁 Leader ended journey on server");
      } catch (e) {
        debugPrint("❌ Failed to end journey: $e");
      }
    }
    _locationTimer?.cancel();
    _locationTimer = null;
    try {
      await escortService.stopSignalR();
      debugPrint("✅ SignalR disconnected");
    } catch (e) {
      debugPrint("❌ Failed to stop SignalR: $e");
    }
  }

  Future<void> startVideoCall() async {
    try {
      TFullScreenLoader.openLoadingDialog(
        "Đang tạo cuộc gọi...",
        TImages.loadingCircle,
      );

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      await sendSosSignal(isVideoCall: true);

      final watchersList = uidToName.entries
          .map((entry) => {"key": entry.key, "value": entry.value})
          .toList();

      await escortService.hubConnection?.invoke(
        "StartVideoCall",
        args: [watchersList],
      );
      TFullScreenLoader.stopLoading();
      Get.to(
        () => AgoraVideoCallingScreen(
          token: videoCallToken.value,
          channelName: videoCallChannelName.value,
          userId: leaderUid,
          isLeader: true,
          uidToName: uidToName,
        ),
      );
      debugPrint("✅ StartVideoCall invoked successfully.");
    } catch (e) {
      debugPrint("❌ Error calling StartVideoCall: $e");
    }
  }

  Future<void> leaveSosVideoCallingLeader() async {
    try {
      TFullScreenLoader.openLoadingDialog(
        "Đang thoát cuộc gọi...",
        TImages.loadingCircle,
      );

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        TLoaders.warningSnackBar(
          title: "Mất kết nối",
          message: "Vui lòng kiểm tra kết nối Internet của bạn",
        );
        return;
      }

      final result = await escortService.leaveCallLeader(
        int.parse(videoCallAlertId.value),
      );

      TFullScreenLoader.stopLoading();

      if (result["success"] == true) {
        Get.back();
        TLoaders.successSnackBar(
          title: "Thành công",
          message: "Đã rời khỏi cuộc gọi",
        );
      } else {
        TLoaders.warningSnackBar(
          title: "Thất bại",
          message: "Xảy ra lỗi khi rời khỏi cuộc gọi",
        );
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error ending journey: $e");

      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(
        title: "Lỗi",
        message: "Đã xảy ra sự cố, vui lòng thử lại",
      );
    }
  }

  Future<void> leaveSosVideoCallingObserver() async {
    try {
      TFullScreenLoader.openLoadingDialog(
        "Đang thoát cuộc gọi...",
        TImages.loadingCircle,
      );

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        TLoaders.warningSnackBar(
          title: "Mất kết nối",
          message: "Vui lòng kiểm tra kết nối Internet của bạn",
        );
        return;
      }

      final result = await escortService.leaveCallObserver(
        int.parse(videoCallAlertId.value),
      );

      TFullScreenLoader.stopLoading();

      if (result["success"] == true) {
        Get.back();

        TLoaders.successSnackBar(
          title: "Thành công",
          message: "Đã rời khỏi cuộc gọi",
        );
      } else {
        TLoaders.warningSnackBar(
          title: "Thất bại",
          message: "Xảy ra lỗi khi rời khỏi cuộc gọi",
        );
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error leaving watcher: $e");

      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(
        title: "Lỗi",
        message: "Đã xảy ra sự cố, vui lòng thử lại",
      );
    }
  }
}
