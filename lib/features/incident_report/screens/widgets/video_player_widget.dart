import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../utils/helpers/helper_functions.dart';

class AdvancedVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool isFullscreen;

  const AdvancedVideoPlayer({
    super.key,
    required this.videoUrl,
    this.isFullscreen = false,
  });

  @override
  State<AdvancedVideoPlayer> createState() => _AdvancedVideoPlayerState();
}

class _AdvancedVideoPlayerState extends State<AdvancedVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isControlsVisible = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) => setState(() {}));
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _hideTimer?.cancel();
      } else {
        _controller.play();
        _startHideTimer();
      }
    });
  }

  void _toggleControlsVisibility() {
    setState(() {
      _isControlsVisible = !_isControlsVisible;
    });

    if (_isControlsVisible && _controller.value.isPlaying) {
      _startHideTimer();
    } else {
      _hideTimer?.cancel();
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (_controller.value.isPlaying) {
        setState(() {
          _isControlsVisible = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final video = AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    );

    return GestureDetector(
      onTap: _toggleControlsVisibility,
      child: Stack(
        alignment: Alignment.center,
        children: [
          widget.isFullscreen ? Center(child: video) : video,

          if (_isControlsVisible) _buildControlsOverlay(),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: VideoProgressIndicator(
              _controller,
              allowScrubbing: true,
              padding: const EdgeInsets.all(8),
              colors: VideoProgressColors(
                playedColor: Colors.red,
                backgroundColor: Colors.grey.shade300,
                bufferedColor: Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsOverlay() {
    final position = _controller.value.position;
    final duration = _controller.value.duration;
    final dark = THelperFunctions.isDarkMode(context);
    String formatDuration(Duration duration) {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      final minutes = twoDigits(duration.inMinutes.remainder(60));
      final seconds = twoDigits(duration.inSeconds.remainder(60));
      return '${twoDigits(duration.inHours)}:$minutes:$seconds';
    }

    return Stack(
      children: [
        Center(
          child: IconButton(
            icon: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              size: 56,
              color: Colors.white,
            ),
            onPressed: _togglePlayPause,
          ),
        ),

        Positioned(
          left: 12,
          bottom: 12,
          child: Text(
            '${formatDuration(position)} / ${formatDuration(duration)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              shadows: [Shadow(color: Colors.black, blurRadius: 4)],
            ),
          ),
        ),

        Positioned(
          right: 12,
          bottom: 2,
          child: IconButton(
            icon: Icon(
              widget.isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
              color: Colors.white,
            ),
            onPressed: () {
              if (widget.isFullscreen) {
                Navigator.pop(context);
              } else {
                _toggleFullscreen();
              }
            },
          ),
        ),
      ],
    );
  }

  void _toggleFullscreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Center(
              child: AdvancedVideoPlayer(
                videoUrl: widget.videoUrl,
                isFullscreen: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
