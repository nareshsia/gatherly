
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../stall_details/stall_details_screen.dart';

Widget stallItem(
    {required int id,
      required String stallImage,
      required String period,
      required String stallName,
      required String business,
      required String mediaCount,
      required BuildContext context}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 16),
    child: InkWell(
      onTap: () {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => StallDetailsScreen(
                id: id,
              ),
            ));
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color(0xfff2f2f7)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///stall image
            ///clipRRect for cut the corner of the image
            ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
                child: Image.network(
                  stallImage,
                  height: 25.h,
                  width: 100.w,
                  fit: BoxFit.fill,
                )),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ///details
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ///period
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          period,
                          style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w400,
                              fontSize: 18.sp),
                        ),
                      ),

                      ///stall name
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          stallName,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 18.sp),
                        ),
                      ),

                      ///business
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          business,
                          style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.normal,
                              fontSize: 18.sp),
                        ),
                      ),

                      ///media count
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          "$mediaCount Files",
                          style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.normal,
                              fontSize: 18.sp),
                        ),
                      ),
                    ],
                  ),

                  ///floating button
                  Container(
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Color(0xffc65659)),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    ),
  );
}