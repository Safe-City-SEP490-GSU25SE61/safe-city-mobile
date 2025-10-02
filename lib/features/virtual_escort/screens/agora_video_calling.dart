import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../common/widgets/appbar/appbar.dart';
import '../../../utils/popups/loaders.dart';
import '../../personalization/controllers/profile/user_profile_controller.dart';

class AgoraVideoCallingScreen extends StatefulWidget {
  final String? token;
  final String? channelName;
  final int userId;
  final bool isLeader;
  final int? leaderUid;

  const AgoraVideoCallingScreen({
    super.key,
    required this.token,
    required this.channelName,
    required this.userId,
    this.isLeader = false,
    this.leaderUid,
  });

  @override
  State<AgoraVideoCallingScreen> createState() =>
      _AgoraVideoCallingScreenState();
}

class _AgoraVideoCallingScreenState extends State<AgoraVideoCallingScreen> {
  RtcEngine? _engine;
  bool localUserJoined = false;
  bool engineInitialize = false;
  final List<int> remoteUserUids = [];
  final Map<int, bool> remoteVideoMuted = {};

  final agoraAppId = dotenv.env['AGORA_APP_ID']!;
  late String agoraToken;
  late String agoraChannelName;
  late int userId;

  bool isMicOn = true;
  bool isLocalCameraOn = true;

  final userController = Get.put(UserProfileController());

  @override
  void initState() {
    super.initState();
    agoraToken = widget.token!;
    agoraChannelName = widget.channelName!;
    userId = widget.userId;
    _initAgora();
  }

  Future<void> _initAgora() async {
    await joinChannel();
    setState(() {
      localUserJoined = false;
      remoteUserUids.clear();
      remoteVideoMuted.clear();
    });
  }

  Future<void> initializeAgoraVoiceSDK() async {
    await requestCameraAndMicPermissions();
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(
      RtcEngineContext(
        appId: agoraAppId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
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
          if (remoteUid == widget.userId) return;
          setState(() {
            if (!remoteUserUids.contains(remoteUid)) {
              remoteUserUids.add(remoteUid);
            }
          });
        },
        onUserOffline:
            (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint("Remote user $remoteUid left");
          setState(() {
            remoteUserUids.remove(remoteUid);
            remoteVideoMuted.remove(remoteUid);
          });
        },
        onUserMuteVideo:
            (RtcConnection connection, int remoteUid, bool muted) {
          debugPrint("Remote user $remoteUid video ${muted ? "muted" : "unmuted"}");
          setState(() {
            remoteVideoMuted[remoteUid] = muted;
          });
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
      options: ChannelMediaOptions(
        autoSubscribeVideo: true,
        autoSubscribeAudio: true,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
      uid: userId,
    );
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
        message: 'Quyền Camera đã bị từ chối vĩnh viễn. Vui lòng bật trong cài đặt.',
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
        message: 'Quyền Micro đã bị từ chối vĩnh viễn. Vui lòng bật trong cài đặt.',
      );
    }
  }

  @override
  void dispose() {
    _engine?.leaveChannel();
    _engine?.stopPreview();
    _engine?.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = userController.user.value;
    final fullName = user.fullName;
    List<int> observersOrdered = List.from(remoteUserUids);
    if (!widget.isLeader && widget.leaderUid != null && observersOrdered.contains(widget.leaderUid)) {
      observersOrdered.remove(widget.leaderUid);
      observersOrdered.insert(0, widget.leaderUid!);
    }

    return Scaffold(
      appBar: const TAppBar(
        title: Text('Cuộc gọi khẩn cấp hành trình'),
        showBackArrow: true,
      ),
      body: Column(
        children: [
          // TOP: Big video (local) — leader or observer's own big view
          Container(
            width: double.infinity,
            height: 300,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: widget.isLeader ? Colors.green : Colors.blueGrey, width: 2),
            ),
            child: widget.isLeader ? _buildLocalVideo(fullName) : _buildSelfAsObserver(fullName),
          ),

          // CONTROLS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _toggleButton(
                  isOn: isMicOn,
                  icon: Iconsax.microphone,
                  onTap: () async {
                    setState(() => isMicOn = !isMicOn);
                    await _engine?.muteLocalAudioStream(!isMicOn);
                  },
                ),
                _toggleButton(
                  isOn: isLocalCameraOn,
                  icon: Iconsax.video,
                  onTap: () async {
                    setState(() => isLocalCameraOn = !isLocalCameraOn);
                    await _engine?.muteLocalVideoStream(!isLocalCameraOn);
                  },
                ),
                _toggleButton(
                  isOn: isLocalCameraOn,
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
                      remoteUserUids.clear();
                      remoteVideoMuted.clear();
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

          // BOTTOM: observers grid
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
              child: _buildObserversGrid(observersOrdered),
            ),
          ),
        ],
      ),
    );
  }

  /// Build local (big) video
  Widget _buildLocalVideo(String name) {
    return localUserJoined && isLocalCameraOn
        ? AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine!,
        canvas: VideoCanvas(uid: widget.userId),
      ),
    )
        : Center(
      child: Text(
        "$name (Bạn)",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// For observers: big self view (same as local view, kept as separate method for clarity)
  Widget _buildSelfAsObserver(String name) => _buildLocalVideo(name);

  /// Build a remote participant tile (video or fallback when camera muted)
  Widget _buildRemoteTile(int uid, {bool highlightLeader = false}) {
    final muted = remoteVideoMuted[uid] ?? false;
    final isLeaderTile = widget.leaderUid != null && widget.leaderUid == uid;
    return Container(
      decoration: BoxDecoration(
        color: muted ? Colors.black54 : Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isLeaderTile ? Colors.green : Colors.transparent, width: 2),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (!muted)
            AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: _engine!,
                canvas: VideoCanvas(uid: uid),
                connection: RtcConnection(channelId: agoraChannelName),
              ),
            )
          else
            Center(
              child: Text(
                isLeaderTile ? "Leader (UID $uid)" : "UID $uid\n(Camera tắt)",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          // small uid label
          Positioned(
            left: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "UID $uid",
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreTile(int extra) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          "+$extra",
          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// Observers grid: show max 4 squares; if more than 4 show "+N" in 4th square.
  Widget _buildObserversGrid(List<int> observers) {
    final total = observers.length;

    if (total == 0) {
      return const Center(
        child: Text(
          "Chưa có thành viên nào",
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    // If more than 4 participants, show first 3 and a +N tile.
    final bool needMoreTile = total > 4;
    final List<int> toShow = needMoreTile ? observers.sublist(0, 3) : observers.toList();
    final int itemCount = toShow.length + (needMoreTile ? 1 : 0);

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: List.generate(itemCount, (index) {
        if (index < toShow.length) {
          final uid = toShow[index];
          return _buildRemoteTile(uid);
        } else {
          final extra = total - 3;
          return _buildMoreTile(extra);
        }
      }),
    );
  }

  /// Toggle button for mic & camera (kept same style as you had)
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

  Widget _roundButton(IconData icon, Color iconColor, Color bgColor) {
    return CircleAvatar(
      radius: 26,
      backgroundColor: bgColor,
      child: Icon(icon, color: iconColor, size: 26),
    );
  }
}

