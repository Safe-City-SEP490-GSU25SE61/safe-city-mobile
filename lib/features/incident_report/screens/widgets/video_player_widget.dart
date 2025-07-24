import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../utils/helpers/helper_functions.dart';

class AdvancedVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const AdvancedVideoPlayer({super.key, required this.videoUrl});

  @override
  State<AdvancedVideoPlayer> createState() => _AdvancedVideoPlayerState();
}

class _AdvancedVideoPlayerState extends State<AdvancedVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isControlsVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) => setState(() {}));
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  void _toggleControlsVisibility() {
    setState(() {
      _isControlsVisible = !_isControlsVisible;
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

    return GestureDetector(
      onTap: _toggleControlsVisibility,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),

          if (_isControlsVisible) _buildControlsOverlay(),

          VideoProgressIndicator(
            _controller,
            allowScrubbing: true,
            padding: const EdgeInsets.all(8),
            colors: VideoProgressColors(
              playedColor: Colors.red,
              backgroundColor: Colors.grey.shade300,
              bufferedColor: Colors.grey.shade500,
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
            icon: Text(
              String.fromCharCode(Icons.fullscreen.codePoint),
              style: TextStyle(
                fontSize: 24,
                fontFamily: Icons.fullscreen.fontFamily,
                package: Icons.fullscreen.fontPackage,
                color: Colors.white,
                shadows: const [
                  Shadow(
                    color: Colors.black,
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
            onPressed: _toggleFullscreen,
          ),
        ),
      ],
    );
  }

  void _toggleFullscreen() {
    final dark = THelperFunctions.isDarkMode(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                ),
                Positioned(
                  top: 24,
                  left: 8,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: dark ? Colors.white : Colors.black,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
