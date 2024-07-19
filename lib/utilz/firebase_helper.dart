import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gatherly/models/stall_details_model.dart';

class FirebaseHelper {
  static FirebaseFirestore fireStore = FirebaseFirestore.instance;

  ///for add stall
  static Future<String> addStallToFB(
      {required String collection,
      required StallDetailsModel stallDetailsModel}) async {
    try {
      var doc = await fireStore
          .collection(collection)
          .add(stallDetailsModel.toJson());
      return doc.id;
    } catch (e) {
      Fluttertoast.showToast(msg: "AddStallToFB:${e.toString()}");
      return "";
    }
  }

  ///for get stall
  static Future<List<Map<String, dynamic>>> getStallsFromFB(
      {required String collection}) async {
    try {
      QuerySnapshot querySnapshot =
          await fireStore.collection(collection).get();

      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      Fluttertoast.showToast(msg: "getStalls:${e.toString()}");
      return [];
    }
  }

  static Future updateStallToFB(
      {required String collection,
      required String documentId,
      required StallDetailsModel stallDetailsModel}) async {
    try {
      await fireStore
          .collection(collection)
          .doc(documentId)
          .update(stallDetailsModel.toJson());
    } catch (e) {
      Fluttertoast.showToast(msg: "updateStall:${e.toString()}");
    }
  }
}
