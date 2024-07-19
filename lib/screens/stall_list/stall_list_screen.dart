import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gatherly/controller/stall_list_controller.dart';
import 'package:gatherly/screens/stall_list/search_stall.dart';

import 'package:gatherly/screens/stall_list/stall_item.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../controller/connectivity_controller.dart';

class StallListScreen extends StatefulWidget {
  const StallListScreen({super.key});

  @override
  State<StallListScreen> createState() => _StallListScreenState();
}

class _StallListScreenState extends State<StallListScreen> {
  StallListController? _stallListController;

  ///for list view
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _stallListController =
        Provider.of<StallListController>(context, listen: false);
    
    Future.delayed(Duration.zero).whenComplete(() {
      ///get stall details from db
      _stallListController!.getStallListFromDB();
    },);
   

    _scrollController.addListener(() {
      ///for show and hide search text field
      if (_scrollController.offset > 50 && !_stallListController!.isScrolled) {
        _stallListController!.setIsScrolled(value: true);
        _stallListController!.setIsSearching(value: false);
      } else if (_scrollController.offset <= 50 &&
          _stallListController!.isScrolled) {
        _stallListController!.setIsScrolled(value: false);
        _stallListController!.setIsSearching(value: false);
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _stallListController!.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// for make status bar transparent
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<StallListController>(
        builder: (context, stallListController, child) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 7.h,
                ),

                /// search
                searchStall(
                    scrollController: _scrollController,
                    stallListController: stallListController),

                ///stall list
                stallListController.isLoading
                    ? const Expanded(
                        child: Center(
                          child: CircularProgressIndicator(
                          color: Colors.black,
                      ),
                        ))
                    : Expanded(
                        child: MediaQuery.removePadding(
                          context: context,
                          removeTop: true,
                          child: RefreshIndicator(
                            onRefresh: () async {
                              ///check network connection
                              final connectivityProvider = Provider.of<ConnectivityController>(context, listen: false);
                              bool isConnected = await connectivityProvider.checkConnection();
                              if(isConnected){
                                stallListController.checkLocalDBWithFirebase();
                              }else{
                                Fluttertoast.showToast(msg: "Please check your network connection");
                              }

                            },
                            child: ListView.builder(
                              controller: _scrollController,
                              itemCount:
                                  stallListController.filteredStallsList.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                var stallImage = stallListController
                                    .filteredStallsList[index].stallImage;
                                var id = stallListController
                                    .filteredStallsList[index].id;
                                var period = stallListController
                                    .filteredStallsList[index].period;
                                var stallName = stallListController
                                    .filteredStallsList[index].stallName;
                                var business = stallListController
                                    .filteredStallsList[index].business;
                                var mediaCount = stallListController
                                            .filteredStallsList[index].media !=
                                        null
                                    ? stallListController
                                        .stallsList[index].media!.length
                                        .toString()
                                    : "0";
                                return stallItem(
                                    id: id,
                                    stallImage: stallImage,
                                    period: period,
                                    stallName: stallName,
                                    business: business,
                                    mediaCount: mediaCount,
                                    context: context);
                              },
                            ),
                          ),
                        ),
                      )
              ]);
        },
      ),
    );
  }
}
