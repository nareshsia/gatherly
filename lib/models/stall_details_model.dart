import 'dart:convert';

import 'model.dart';

class StallDetailsModel extends Model {
  static String table = "expo";

  int id;
  dynamic documentId;
  String stallName;
  String stallImage;

  String business;
  String period;
  dynamic media;
  dynamic firebaseUrl;
  String lastUpdate;

  StallDetailsModel(
      {required this.id,
      required this.documentId,
      required this.stallName,
      required this.stallImage,
      required this.business,
      required this.period,
      this.firebaseUrl,
      this.media,
      required this.lastUpdate});

  static StallDetailsModel fromMap(Map<String, dynamic> json) {
    return StallDetailsModel(
        id: json['id'],
        documentId: json['documentId'],
        stallName: json['stallName'],
        stallImage: json['stallImage'],
        business: json['business'],
        period: json['period'],
        media:
            json['media'] == null ? json['media'] : jsonDecode(json['media']),
        firebaseUrl: json['firebaseUrl'] == null
            ? json['firebaseUrl']
            : jsonDecode(json['firebaseUrl']),
        lastUpdate: json['lastUpdate']);
  }

  @override
  toJson() {
    Map<String, dynamic> map = {
      'id': id,
      'documentId': documentId,
      'stallName': stallName,
      'stallImage': stallImage,
      'business': business,
      'period': period,
      'media': media,
      'firebaseUrl': firebaseUrl,
      'lastUpdate': lastUpdate,
    };
    map['id'] = id;
    return map;
  }
}
