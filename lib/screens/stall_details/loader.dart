import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

Widget loader() {
  return Container(
    width: 100.w,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10), color: Colors.black),
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.scale(
              scale: 0.4,
              child: const CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "Attach file...",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}