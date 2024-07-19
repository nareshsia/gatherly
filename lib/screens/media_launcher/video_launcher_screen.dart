import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:video_player/video_player.dart';

class VideoLaunchScreen extends StatefulWidget {
  final String path;

  const VideoLaunchScreen({super.key, required this.path});

  @override
  _VideoLaunchScreenState createState() => _VideoLaunchScreenState();
}

class _VideoLaunchScreenState extends State<VideoLaunchScreen> {
  late VideoPlayerController _videoPlayerController;
  bool _isPlaying = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.file(File(widget.path))
      ..initialize().then((_) {
        setState(() {
          _isPlaying = true;
          _videoPlayerController.play();
        });
      })
      ..addListener(updateState);
    ;
  }

  @override
  void dispose() {
    ///remove listener and controller
    _videoPlayerController.removeListener(updateState);
    _videoPlayerController.dispose();
    super.dispose();
  }

  updateState() {
    setState(() {});
  }

  togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _videoPlayerController.play();
      } else {
        _videoPlayerController.pause();
      }
    });
  }

  toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void skipForward() {
    final currentPosition = _videoPlayerController.value.position;
    final maxDuration = _videoPlayerController.value.duration;
    final newPosition = currentPosition + const Duration(seconds: 10);
    if (newPosition < maxDuration) {
      _videoPlayerController.seekTo(newPosition);
    } else {
      _videoPlayerController.seekTo(maxDuration);
    }
  }

  void skipBackward() {
    final currentPosition = _videoPlayerController.value.position;
    final newPosition = currentPosition - Duration(seconds: 10);
    if (newPosition > Duration.zero) {
      _videoPlayerController.seekTo(newPosition);
    } else {
      _videoPlayerController.seekTo(Duration.zero);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _videoPlayerController.value.isInitialized
          ? GestureDetector(
              onTap: toggleControls,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Center(
                    child: AspectRatio(
                      aspectRatio: _videoPlayerController.value.aspectRatio,
                      child: VideoPlayer(_videoPlayerController),
                    ),
                  ),
                  _showControls ? _buildControls() : const SizedBox.shrink(),
                ],
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget _buildControls() {
    return Stack(
      children: [
        /// close icon
        Positioned(
          top: 40,
          right: 16,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              width: 12.w,
              height: 12.h,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.white),
              child: const Center(
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.black,
                  size: 40,
                ),
              ),
            ),
          ),
        ),

        ///indicator
        Positioned(
          bottom: 150,
          left: 20.0,
          right: 20.0,
          child: VideoProgressIndicator(
            _videoPlayerController,
            allowScrubbing: true,
            colors: const VideoProgressColors(
              playedColor: Colors.red,
              backgroundColor: Colors.grey,
            ),
          ),
        ),

        ///duration
        Positioned(
          bottom: 130,
          left: 20.0,
          right: 20.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_videoPlayerController.value.position),
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400),
              ),
              Text(
                _formatDuration(_videoPlayerController.value.duration),
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),

        ///pause play button
        Positioned(
            bottom: 40, // Adjust the top position as needed
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ///backward
                IconButton(
                  icon: const Icon(
                    Icons.replay_10,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: skipBackward,
                ),

                ///pause and play
                InkWell(
                  onTap: () {
                    togglePlayPause();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      width: 12.w,
                      height: 12.h,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Color(0xffc65659)),
                      child: Center(
                        child: Icon(
                          _isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),

                ///forward
                IconButton(
                  icon: const Icon(
                    Icons.forward_10,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: skipForward,
                ),
              ],
            )),
      ],
    );
  }

  String _formatDuration(Duration position) {
    final minutes = position.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = position.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
