import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gatherly/controller/stall_details_controller.dart';
import 'package:gatherly/screens/stall_details/image_video_bottom_sheet.dart';
import 'package:gatherly/screens/stall_details/media.dart';
import 'package:gatherly/screens/stall_list/stall_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:video_player/video_player.dart';

import 'loader.dart';

class StallDetailsScreen extends StatefulWidget {
  final int id;

  const StallDetailsScreen({
    super.key,
    required this.id,
  });

  @override
  State<StallDetailsScreen> createState() => _StallDetailsScreenState();
}

class _StallDetailsScreenState extends State<StallDetailsScreen> {
  /// for provider
  StallDetailsController? _stallDetailsController;

  /// page view controller initialization
  final PageController _pageController = PageController(
    initialPage: 0,
    viewportFraction: 1,
  );

  @override
  void initState() {
    _stallDetailsController =
        Provider.of<StallDetailsController>(context, listen: false);

    /// for get stall details
    Future.delayed(Duration.zero).whenComplete(
      () {
        _stallDetailsController!.getStallDetailsById(id: widget.id);
      },
    );

    /// callback listener for page view
    _pageController.addListener(() {
      _stallDetailsController!
          .setCurrentIndex(value: _pageController.page!.round());
    });

    super.initState();
  }

  @override
  void dispose() {
    /// for reset data
    _stallDetailsController!.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// for make status bar transparent
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          Brightness.light, // Use Brightness.light for light icons
    ));

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const StallListScreen(),
            ));
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Consumer<StallDetailsController>(
          builder: (context, stallDetailsController, child) {
            return Column(
              children: [
                ///visible during get stall detail
                stallDetailsController.isLoading
                    ? SizedBox(
                        height: 65.h,
                        width: 100.w,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 1.w,
                          ),
                        ),
                      )
                    :

                    /// visible when media content is not empty
                    stallDetailsController.mediaListWithThumbnail.isNotEmpty
                        ? media(
                            context: context,
                            stallDetailsController: stallDetailsController,
                            pageController: _pageController)
                        :

                        /// visible when media content is empty
                        SizedBox(
                            height: 7.h,
                          ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ///stall name
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          stallDetailsController.stallName,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 22.sp),
                        ),
                      ),

                      ///business
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          stallDetailsController.business,
                          style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w400,
                              fontSize: 16.sp),
                        ),
                      ),

                      ///media count
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          "${stallDetailsController.mediaCount} Files",
                          style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w400,
                              fontSize: 16.sp),
                        ),
                      ),

                      ///attach file container
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: InkWell(
                          onTap: () {
                            // stallDetailsController.checkStoragePermission(
                            //     id: widget.id);
                            imageVideoBottomSheet(
                                context: context,
                                stallDetailsController: stallDetailsController,
                                id: widget.id);
                          },
                          child: stallDetailsController.isUpdating
                              ? loader()
                              : DottedBorder(
                                  borderType: BorderType.RRect,
                                  radius: const Radius.circular(12),
                                  padding: const EdgeInsets.all(6),
                                  dashPattern: const [12, 8],
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(12)),
                                    child: SizedBox(
                                      height: 12.h,
                                      width: 100.w,
                                      child: Center(
                                          child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 4),
                                            child:
                                                Icon(Icons.file_copy_outlined),
                                          ),
                                          Text(
                                            "Attach file",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ],
                                      )),
                                    ),
                                  ),
                                ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
