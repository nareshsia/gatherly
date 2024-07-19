import 'package:flutter/material.dart';
import 'package:gatherly/controller/stall_details_controller.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

imageVideoBottomSheet(
    {required BuildContext context,
    required StallDetailsController stallDetailsController,
    required int id}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20))),
    builder: (context) {
      return SizedBox(
        height: 20.h,
        width: 100.w,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: Text(
                  "Choose yours",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 18.sp),
                ),
              ),

              /// photos
              InkWell(
                onTap: () {
                  Navigator.pop(context);

                  ///check storage permission
                  stallDetailsController.checkStoragePermission(
                      id: id, image: true);
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.image_outlined,
                      size: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 13),
                      child: Text(
                        "Photos",
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Colors.grey,
                            fontSize: 17.sp),
                      ),
                    )
                  ],
                ),
              ),

              ///Videos
              InkWell(
                onTap: () {
                  Navigator.pop(context);

                  ///check storage permission
                  stallDetailsController.checkStoragePermission(
                      id: id, image: false);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.video_call_outlined,
                        size: 40,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "Videos",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Colors.grey,
                              fontSize: 17.sp),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      );
    },
  );
}
