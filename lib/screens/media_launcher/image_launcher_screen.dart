import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:video_player/video_player.dart';

class MediaLauncherScreen extends StatefulWidget {
  final String path;
  final bool image;

  const MediaLauncherScreen(
      {super.key, required this.path, required this.image});

  @override
  State<MediaLauncherScreen> createState() => _MediaLauncherScreenState();
}

class _MediaLauncherScreenState extends State<MediaLauncherScreen> {







  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body:

            ///for render image
            Padding(
          padding: EdgeInsets.symmetric(vertical: 7.h),
          child: Stack(
            children: [
              SizedBox(
                width: 100.w,
                height: 100.h,
                child: Image.file(
                  File(widget.path),
                  fit: BoxFit.fill,
                ),
              ),
              Positioned(
                right: 16,
                child: InkWell(
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
              )
            ],
          ),
        ));
  }
}
