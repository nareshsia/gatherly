import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gatherly/controller/stall_list_controller.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

Widget searchStall({required ScrollController scrollController,required StallListController stallListController}){
  return  AnimatedSwitcher(
    duration: const Duration(milliseconds: 500),
    child: stallListController.isScrolled
        ? Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 10.h,
        child: stallListController.isSearching
            ?

        ///search
        TextFormField(
          controller:
          stallListController.searchController,
          cursorColor: Colors.black,
          decoration: InputDecoration(
            hintText: "Search",
            prefixIcon: const Icon(
              Icons.search,
              color: Colors.grey,
            ),
            border: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(100),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(100),
              borderSide: const BorderSide(
                color: Color(0xfff2f2f7),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(100),
              borderSide: const BorderSide(
                color: Color(0xfff2f2f7),
              ),
            ),
          ),
          onChanged: (value) {
            stallListController.searchStall(
                query: value);
          },
        )
            : Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: [
            ///list title
            Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 20),
              child: Text(
                "Stalls",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp),
              ),
            ),

            /// search icon
            InkWell(
                onTap: () {
                  stallListController.setIsSearching(
                      value: true);
                },
                child:
                const Icon(Icons.search_outlined))
          ],
        ),
      ),
    )
        : Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///search
          TextFormField(
            controller:
            stallListController.searchController,
            cursorColor: Colors.black,
            decoration: InputDecoration(
              hintText: "Search",
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.grey,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: const BorderSide(
                  color: Color(0xfff2f2f7),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: const BorderSide(
                  color: Color(0xfff2f2f7),
                ),
              ),
            ),
            onChanged: (value) {
              stallListController.searchStall(query: value);
            },
          ),

          ///list title
          Padding(
            padding:
            const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              "Stalls",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp),
            ),
          ),
        ],
      ),
    ),
  );
}