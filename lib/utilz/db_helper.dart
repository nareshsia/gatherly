import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gatherly/models/model.dart';
import 'package:gatherly/models/stall_details_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

abstract class DBHelper {
  static Database? _db;

  static int get _version => 1;

  static Future<void> init() async {
    if (_db != null) {
      return;
    }
    try {
      var databasePath = await getDatabasesPath();
      String _path = p.join(databasePath, "gatherly.db");
      _db = await openDatabase(
        _path,
        version: _version,
        onCreate: (db, version) async {
          String sqlQuery =
              'CREATE TABLE expo (id INTEGER PRIMARY KEY, documentId TEXT, stallName STRING, stallImage TEXT, business STRING, period STRING, media TEXT, firebaseUrl TEXT, lastUpdate STRING)';
          await db.execute(sqlQuery);
        },
      );
    } catch (e) {
      print("databaseException:$e");
    }
  }

  /// query for retrieve all data
  static Future<List<Map<String, dynamic>>> getStallDetails(
      {required String table}) async {
    try {
      return _db!.query(table);
    } catch (e) {
      Fluttertoast.showToast(msg: "GetAllStallDetails:${e.toString()}");
      return [];
    }
  }

  /// for insert a data into table
  static Future<int> insertStall(
      {required String table, required Model model}) async {
    return await _db!.insert(table, model.toJson());
  }

  /// for update specific row in the table
  static Future<int> update(
      {required String table, required StallDetailsModel model}) async {
    return await _db!
        .update(table, model.toJson(), where: 'id = ?', whereArgs: [model.id]);
  }

  /// for delete the row from the table
  static Future<int> delete(
      {required String table, required StallDetailsModel model}) async {
    return await _db!.delete(table, where: 'id = ?', whereArgs: [model.id]);
  }

  /// get stall details by id
  static Future<List<Map<String, dynamic>>> getStallDetailsById(
      {required String table, required int id}) async {
    try {
      List<Map<String, dynamic>> result =
          await _db!.query(table, where: 'id = ?', whereArgs: [id]);
      return result;
    } catch (e) {
      Fluttertoast.showToast(msg: "GetStallDetailsById:$e");
      return [];
    }
  }

  /// for update media file
  static Future<int> updateMedia(
      {required String table,
      required int id,
      required String lastUpdate,
      required List<dynamic> media}) async {
    try {
      String jsonString = jsonEncode(media);
      int result = await _db!.update(
          table, {'media': jsonString, 'lastUpdate': lastUpdate},
          where: 'id = ?', whereArgs: [id]);
      return result;
    } catch (e) {
      Fluttertoast.showToast(msg: "updateMedia:$e");
      return 0;
    }
  }

  /// for update firebase url
  static Future<int> updateFirebaseURL(
      {required String table,
      required int id,
      required String lastUpdate,
      required List<dynamic> firebaseUrl}) async {
    try {
      String jsonString = jsonEncode(firebaseUrl);
      int result = await _db!.update(
          table, {'firebaseUrl': jsonString, 'lastUpdate': lastUpdate},
          where: 'id = ?', whereArgs: [id]);
      return result;
    } catch (e) {
      Fluttertoast.showToast(msg: "updateMedia:$e");
      return 0;
    }
  }

  ///fetch firebase url from particular row
  static Future<List<Map<String, dynamic>>> getFirebaseURLList({
    required String table,
    required int id,
  }) async {
    List<Map<String, dynamic>> result = await _db!.query(
      table,
      columns: ['firebaseUrl'], // Specify the column you want to fetch
      where: "id = ?",
      whereArgs: [id],
    );



    return result;
  }

  /// for documentId;
  static Future<int> updateDocumentId(
      {required String table,
      required int id,
      required String lastUpdate,
      required String documentId}) async {
    try {
      int result = await _db!.update(
          table, {'documentId': documentId, 'lastUpdate': lastUpdate},
          where: 'id = ?', whereArgs: [id]);
      return result;
    } catch (e) {
      Fluttertoast.showToast(msg: "updateMedia:$e");
      return 0;
    }
  }
}
