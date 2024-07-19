import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gatherly/controller/connectivity_controller.dart';
import 'package:gatherly/models/stall_details_model.dart';
import 'package:gatherly/utilz/constant.dart';
import 'package:gatherly/utilz/firebase_helper.dart';
import 'package:gatherly/utilz/shared_pref.dart';
import 'package:provider/provider.dart';


import '../utilz/db_helper.dart';

class StallListController extends ChangeNotifier {
  List<StallDetailsModel> stallsList = [];

  ///for search
  List<StallDetailsModel> filteredStallsList = [];

  TextEditingController searchController = TextEditingController();

  ///for track the listview scroll
  bool isScrolled = false;

  /// for switch between search icon & search text field
  bool isSearching = false;

  /// for toast
  bool showToast = true;
  ///loader for get details from db
  bool isLoading = false;

  /// function for assign value to variable
  setIsScrolled({required bool value}) {
    isScrolled = value;
    notifyListeners();
  }

  setIsSearching({required bool value}) {
    isSearching = value;
    notifyListeners();
  }

  setShowToast({required bool value}) {
    showToast = value;
    notifyListeners();
  }
  setIsLoading({required bool value}) {
    isLoading = value;
    notifyListeners();
  }
  /// for get stalls list from DB
  Future getStallListFromDB() async {
    setIsLoading(value: true);
    await DBHelper.init();
    await DBHelper.getStallDetails(table: StallDetailsModel.table).then(
      (list) {
        if (list.isNotEmpty) {
          var _stallList =
              list.map((item) => StallDetailsModel.fromMap(item)).toList();
          stallsList = _stallList;

          ///for search
          filteredStallsList = stallsList;


        } else {
          Fluttertoast.showToast(msg: "Stall list is empty!!!");

        }
    Future.delayed(const Duration(seconds: 1)).whenComplete(() {
      setIsLoading(value: false);
    },);
      },
    ).catchError((e) {
      setIsLoading(value: false);
      Fluttertoast.showToast(msg: e.toString());
    });

    notifyListeners();
  }

  // updateStall({required StallDetailsModel model}) async {
  //   await dbService.updateStall(model: model);
  // }
  /// search stall based on stall name
  searchStall({required String query}) {
    final suggestions = stallsList.where(
      (stall) {
        final stallName = stall.stallName.toLowerCase();
        final input = query.toLowerCase();
        return stallName.contains(input);
      },
    ).toList();

    filteredStallsList = suggestions;
    notifyListeners();
  }

  Future<void> checkLocalDBWithFirebase() async {

    ///check firebase is empty or not
    await FirebaseHelper.getStallsFromFB(collection: StallDetailsModel.table)
        .then(
      (stallList) {
        if (stallList.isEmpty) {

          localToFB();
        } else {


          /// check Last updated date with las
          var lastSyncString = SharedPrefs.getString(LAST_SYNC);
          var lastSyncDateTime = DateTime.parse(lastSyncString);
          checkModifiedData(lastSyncDateTime: lastSyncDateTime);
        }
      },
    ).catchError((e) {
      Fluttertoast.showToast(msg: e.toString());
    });
  }

  /// local to Fire base
  Future localToFB() async {
    bool isSuccessfullySynchronized = false;
    for (var item in stallsList) {
      await FirebaseHelper.addStallToFB(
              collection: StallDetailsModel.table, stallDetailsModel: item)
          .then(
        (value) async {
          /// add return document id into local db
          addDocumentIdToDB(documentId: value, id: item.id);
        },
      ).catchError((e) {
        Fluttertoast.showToast(msg: e.toString());
      });
    }
    isSuccessfullySynchronized = true;
    if(isSuccessfullySynchronized){
      Fluttertoast.showToast(msg: "Synchronized Successfully!!!");
    }


  }

  /// store fire document Id to local
  Future addDocumentIdToDB(
      {required String documentId, required int id}) async {
    await DBHelper.init();
    DBHelper.updateDocumentId(
            table: StallDetailsModel.table,
            id: id,
            lastUpdate: DateTime.now().toString(),
            documentId: documentId)
        .then(
      (value) {
        if (value > 0) {
          /// success



          SharedPrefs.setString(LAST_SYNC, DateTime.now().toString());
        } else {
          ///failure
          Fluttertoast.showToast(msg: "Synchronization failure!!!");
        }
      },
    ).catchError((e) {
      Fluttertoast.showToast(msg: e.toString());
    });
  }

  /// check if any modified data available or not after last sync
  checkModifiedData({required DateTime lastSyncDateTime}) async {

    await DBHelper.init();
    await DBHelper.getStallDetails(table: StallDetailsModel.table).then(
      (list) {

        if (list.isNotEmpty) {
          var stallList =
              list.map((item) => StallDetailsModel.fromMap(item)).toList();
          if (stallList.isNotEmpty) {
            bool isSuccessfullySynchronized = false;
            for (var item in stallList) {
              var lastUpdateString = item.lastUpdate;
              var lastUpdateDateTime = DateTime.parse(lastUpdateString);
              if (lastSyncDateTime.isBefore(lastUpdateDateTime)) {
                /// need to update
                updateStallToFB(
                    documentId: item.documentId, stallDetailsModel: item);

              } else if (lastSyncDateTime.isAfter(lastUpdateDateTime)) {
                /// no changes all are up-to-date

              } else {
                /// both are equal
              }
            }
             isSuccessfullySynchronized = true;
            if(  isSuccessfullySynchronized){
              Fluttertoast.showToast(msg: "Synchronized Successfully!!!");
            }

          }
        } else {
          Fluttertoast.showToast(msg: "Stall list is empty!!!");
        }
      },
    ).catchError((e) {
      Fluttertoast.showToast(msg: e.toString());
    });
  }

  /// update data into fb
  Future updateStallToFB(
      {required String documentId,
      required StallDetailsModel stallDetailsModel}) async {
    await FirebaseHelper.updateStallToFB(
            collection: StallDetailsModel.table,
            documentId: documentId,
            stallDetailsModel: stallDetailsModel)
        .then(
      (value) {
        /// successfully updated
        SharedPrefs.setString(LAST_SYNC, DateTime.now().toString());
      },
    ).catchError((e) {
      Fluttertoast.showToast(msg: e.toString());
    });
  }

  /// reset data during dispose
  reset() {
    showToast = true;
    isScrolled = false;
    isSearching = false;
    stallsList.clear();
    filteredStallsList.clear();
  }
}
