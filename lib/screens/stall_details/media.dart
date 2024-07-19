import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gatherly/controller/stall_details_controller.dart';
import 'package:gatherly/screens/media_launcher/image_launcher_screen.dart';
import 'package:gatherly/screens/media_launcher/video_launcher_screen.dart';

import 'package:responsive_sizer/responsive_sizer.dart';

import '../stall_list/stall_list_screen.dart';

Widget media(
    {required BuildContext context,
    required StallDetailsController stallDetailsController,
    required PageController pageController}) {
  return SizedBox(
      height: 65.h,
      width: 100.w,
      child: Stack(
        children: [
          PageView.builder(
            controller: pageController,
            itemCount: stallDetailsController.mediaListWithThumbnail.length,
            itemBuilder: (context, index) {
              var localPath =
                  stallDetailsController.mediaListWithThumbnail[index].path;

              /// in order separate image & video file
              var splitString = localPath.split(".");
              if (splitString.last == "mp4") {
                /// for video file
                return InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              VideoLaunchScreen(path: localPath),
                        ));
                    //   stallDetailsController.openImageFile(localPath);
                  },
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        top: 0,
                        child: Image.file(
                          File(stallDetailsController
                              .mediaListWithThumbnail[index].thumbnail!),
                          width: 100.w,
                          fit: BoxFit.fill,
                        ),
                      ),

                      /// video play button
                      Positioned(
                        bottom: 3.h,
                        left: 5.w,
                        child: Container(
                          width: 14.w,
                          height: 14.h,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: Color(0xffc65659)),
                          child: const Center(
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                      ),

                      ///video duration
                      Positioned(
                        bottom: 8.h,
                        right: 5.w,
                        child: Row(
                          children: [
                            ///duration
                            Text(
                              stallDetailsController
                                  .mediaListWithThumbnail[index].duration!,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w600),
                            ),

                            /// video play icon
                            const Icon(
                              Icons.play_circle_outline_rounded,
                              color: Colors.black,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              } else {
                /// for image file
                return InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MediaLauncherScreen(
                            path: localPath,
                            image: true,
                          ),
                        ));
                    //   stallDetailsController.openImageFile(localPath);
                  },
                  child: Image.file(
                    File(localPath),
                    width: 100.w,
                    fit: BoxFit.fill,
                  ),
                );
              }
            },
          ),

          /// back & share button
          Positioned(
            top: 20,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// back button
                InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StallListScreen(),
                        ));
                  },
                  child: Container(
                    width: 12.w,
                    height: 12.h,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                /// share button
                Container(
                  width: 12.w,
                  height: 12.h,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white),
                  child: const Center(
                    child: Icon(
                      Icons.ios_share_rounded,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// indicator
          stallDetailsController.mediaListWithThumbnail.length > 1
              ? Positioned(
                  bottom: 1.h,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                            stallDetailsController
                                .mediaListWithThumbnail.length, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            width: 7.w,
                            height: 0.3.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color:
                                  stallDetailsController.currentIndex == index
                                      ? Colors.black
                                      : Colors.white,
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ));
}
