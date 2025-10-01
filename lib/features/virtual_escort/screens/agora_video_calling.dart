import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:iconsax/iconsax.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../common/widgets/appbar/appbar.dart';
import '../../../utils/popups/loaders.dart';

class AgoraVideoCallingScreen extends StatefulWidget {
  const AgoraVideoCallingScreen({super.key});

  @override
  State<AgoraVideoCallingScreen> createState() =>
      _AgoraVideoCallingScreenState();
}

class _AgoraVideoCallingScreenState extends State<AgoraVideoCallingScreen> {
  RtcEngine? _engine;
  bool localUserJoined = false;
  int? remoteUserUid;
  bool engineInitialize = false;
  final agoraAppId = dotenv.env['AGORA_APP_ID']!;
  final agoraToken = dotenv.env['AGORA_TOKEN']!;
  final agoraChannelName = dotenv.env['AGORA_CHANNEL']!;
  bool isMicOn = true;
  bool isCameraOn = true;

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    await joinChannel();
    setState(() {
      localUserJoined = false;
      remoteUserUid = null;
    });
  }

  Future<void> initializeAgoraVoiceSDK() async {
    await requestCameraAndMicPermissions();
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(
      RtcEngineContext(
        appId: agoraAppId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );
    await _engine?.enableVideo();
    await _engine?.startPreview();
    setupEventHandlers();
  }

  void setupEventHandlers() {
    _engine?.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("Local user ${connection.localUid} joined");
          setState(() => localUserJoined = true);
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("Remote user $remoteUid joined");
          setState(() => remoteUserUid = remoteUid);
        },
        onUserOffline:
            (
              RtcConnection connection,
              int remoteUid,
              UserOfflineReasonType reason,
            ) {
              debugPrint("Remote user $remoteUid left");
              setState(() => remoteUserUid = null);
            },
      ),
    );
  }

  Future<void> joinChannel() async {
    if (!engineInitialize) {
      await initializeAgoraVoiceSDK();
      engineInitialize = true;
    }
    await _engine?.joinChannel(
      token: agoraToken,
      channelId: agoraChannelName,
      options: const ChannelMediaOptions(
        autoSubscribeVideo: true,
        autoSubscribeAudio: true,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
      uid: 0,
    );
  }

  String generateChannelName(String ownerId) {
    final timestamp = DateTime.now().toUtc().millisecondsSinceEpoch;
    return "SOS_Video_Calling_${ownerId}_$timestamp";
  }

  Future<void> requestCameraAndMicPermissions() async {
    var cameraStatus = await Permission.camera.status;
    if (cameraStatus.isDenied) {
      cameraStatus = await Permission.camera.request();
      if (cameraStatus.isDenied) {
        return TLoaders.warningSnackBar(
          title: 'Không thành công',
          message: 'Ứng dụng cần quyền truy cập Camera',
        );
      }
    }

    if (cameraStatus.isPermanentlyDenied) {
      return TLoaders.warningSnackBar(
        title: 'Không thành công',
        message:
            'Quyền Camera đã bị từ chối vĩnh viễn. Vui lòng bật trong cài đặt.',
      );
    }

    var micStatus = await Permission.microphone.status;
    if (micStatus.isDenied) {
      micStatus = await Permission.microphone.request();
      if (micStatus.isDenied) {
        return TLoaders.warningSnackBar(
          title: 'Không thành công',
          message: 'Ứng dụng cần quyền truy cập Micro',
        );
      }
    }

    if (micStatus.isPermanentlyDenied) {
      return TLoaders.warningSnackBar(
        title: 'Không thành công',
        message:
            'Quyền Micro đã bị từ chối vĩnh viễn. Vui lòng bật trong cài đặt.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TAppBar(
        title: Text('Cuộc gọi khẩn cấp hành trình'),
        showBackArrow: true,
      ),
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 300,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: localUserJoined
                    ? AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: _engine!,
                          canvas: VideoCanvas(uid: 0),
                        ),
                      )
                    : const Center(
                        child: Text(
                          "Chủ phòng (Bạn)",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
              ),

              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _toggleButton(
                      isOn: isMicOn,
                      icon: Iconsax.microphone,
                      onTap: () => setState(() => isMicOn = !isMicOn),
                    ),
                    _toggleButton(
                      isOn: isCameraOn,
                      icon: Iconsax.video,
                      onTap: () => setState(() => isCameraOn = !isCameraOn),
                    ),
                    _toggleButton(
                      isOn: isCameraOn,
                      icon: Iconsax.refresh,
                      onTap: () async {
                        await _engine!.switchCamera();
                      },
                    ),
                    GestureDetector(
                      onTap: () async {
                        await _engine?.leaveChannel();
                        await _engine?.stopPreview();
                        await _engine?.release();
                        engineInitialize = false;
                        setState(() {
                          localUserJoined = false;
                          remoteUserUid = null;
                        });
                      },
                      child: _roundButton(
                        Iconsax.call,
                        Colors.white,
                        Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // === BOTTOM: Observers Box ===
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueGrey, width: 1),
              ),
              child: remoteUserUid != null
                  ? AgoraVideoView(
                      controller: VideoViewController.remote(
                        rtcEngine: _engine!,
                        canvas: VideoCanvas(uid: remoteUserUid),
                        connection: RtcConnection(channelId: agoraChannelName),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Người giám sát:",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Expanded(
                          child: Center(
                            child: Text(
                              "Chưa có người giám sát nào",
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Toggle button for mic & camera
  Widget _toggleButton({
    required bool isOn,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 26,
        backgroundColor: isOn ? Colors.white : Colors.red,
        child: Icon(icon, color: isOn ? Colors.black : Colors.white, size: 26),
      ),
    );
  }

  /// Always circular (e.g., End call)
  Widget _roundButton(IconData icon, Color iconColor, Color bgColor) {
    return CircleAvatar(
      radius: 26,
      backgroundColor: bgColor,
      child: Icon(icon, color: iconColor, size: 26),
    );
  }
}
