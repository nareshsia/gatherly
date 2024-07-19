import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/stall_details_model.dart';
import '../screens/stall_list/stall_list_screen.dart';
import '../utilz/db_helper.dart';
import '../utilz/firebase_helper.dart';

class SplashController extends ChangeNotifier {
  /// dummy data for stall details
  List<StallDetailsModel> stallDetailsList = [
    StallDetailsModel(
        id: 1,
        documentId: "",
        stallName: "Voltas",
        stallImage: "https://musicalabacus.com/test/voltas.jpg",
        business: "Cooling Solutions",
        period: "Jun 24 - Jun 25, 2024",
        lastUpdate: DateTime.now().toString()),
    StallDetailsModel(
        id: 2,
        documentId: "",
        stallName: "Suzuki",
        stallImage: "https://musicalabacus.com/test/suzuki.jpg",
        business: "Automobiles Manufactures",
        period: "Jun 24 - Jun 25, 2024",
        lastUpdate: DateTime.now().toString()),
    StallDetailsModel(
        id: 3,
        documentId: "",
        stallName: "Bean Bliss",
        stallImage:
            "https://musicalabacus.com/test/coffee-making-with-machine-cups.jpg",
        business: "Coffee House",
        period: "Jun 24 - Jun 25, 2024",
        lastUpdate: DateTime.now().toString()),
    StallDetailsModel(
        id: 4,
        documentId: "",
        stallName: "Decor Delight",
        stallImage:
            "https://musicalabacus.com/test/beautiful-view-construction-site-city-sunset.jpg",
        business: "Decor Construction",
        period: "Jun 24 - Jun 25, 2024",
        lastUpdate: DateTime.now().toString()),
  ];

  /// db calls
  Future checkDB({required BuildContext context}) async {
    await DBHelper.init();

    ///check db is empty or not
    await DBHelper.getStallDetails(table: StallDetailsModel.table).then(
      (list) {
        if (list.isEmpty) {
          getStallFromFB(context: context);
        } else {
          /// not empty means nav to stall list page
          if (context.mounted) navToStallList(context: context);
        }
      },
    ).catchError((e) {
      Fluttertoast.showToast(msg: e.toString());
    });
  }

  /// get stall details from db
  Future getStallFromFB({required BuildContext context}) async {
    await FirebaseHelper.getStallsFromFB(collection: StallDetailsModel.table)
        .then(
      (stallList) {
        if (stallList.isNotEmpty) {

          for (var item in stallList) {
            var stallDetailsModel = StallDetailsModel(
                id: item['id'],
                documentId: item['documentId'],
                firebaseUrl: jsonEncode(item['firebaseUrl']),
                stallName: item['stallName'],
                stallImage: item['stallImage'],
                business: item['business'],
                period: item['period'],
                lastUpdate: item['lastUpdate'],
                media: jsonEncode(
                  item['media'],
                ));
            DBHelper.insertStall(
                    table: StallDetailsModel.table, model: stallDetailsModel)
                .then(
              (value) {},
            )
                .catchError((e) {
              Fluttertoast.showToast(msg: e.toString());
            });
          }
          if (context.mounted) navToStallList(context: context);
        } else {
          /// if empty add stall details to db
          for (var item in stallDetailsList) {
            DBHelper.insertStall(table: StallDetailsModel.table, model: item)
                .then(
              (value) {},
            )
                .catchError((e) {
              Fluttertoast.showToast(msg: e.toString());
            });
          }
          if (context.mounted) navToStallList(context: context);
        }
      },
    ).catchError((e) {
      Fluttertoast.showToast(msg: e.toString());
    });
  }
}

/// for navigation
navToStallList({required BuildContext context}) {
  Future.delayed(const Duration(seconds: 3)).whenComplete(
    () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const StallListScreen(),
          ));
    },
  );
}
