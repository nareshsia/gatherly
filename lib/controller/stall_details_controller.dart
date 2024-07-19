import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:workmanager/workmanager.dart';

import '../models/stall_details_model.dart';
import '../utilz/db_helper.dart';

class StallDetailsController extends ChangeNotifier {
  /// initialization
  final ImagePicker picker = ImagePicker();

  /// variable declaration
  StallDetailsModel? stallDetailsModel;

  /// list for path & thumbnail
  List<Media> mediaListWithThumbnail = [];

  /// for upload
  List<dynamic> _mediaList = [];

  /// for load firebase url
  List<dynamic> firebaseURLList = [];

  /// for work manager
  List<String> newlyUploadedFile = [];

  /// for updating media files
  bool isUpdating = false;

  /// for get stall details
  bool isLoading = false;

  bool isMP4 = false;

  String stallName = "";
  String business = "";
  String mediaCount = "0";

  /// for track page view current index
  int currentIndex = 0;

  /// function to set value to the variable
  setStallDetailsModel({required StallDetailsModel stallDetailsModel}) {
    stallDetailsModel = stallDetailsModel;
    notifyListeners();
  }

  setIsUpdating({required bool value}) {
    isUpdating = value;
    notifyListeners();
  }

  setIsLoading({required bool value}) {
    isLoading = value;
    notifyListeners();
  }

  setIsMP4({required bool value}) {
    isMP4 = value;
    notifyListeners();
  }

  setCurrentIndex({required int value}) {
    currentIndex = value;
    notifyListeners();
  }

  ///function fetch data from db
  Future getStallDetailsById({required int id}) async {
    setIsLoading(value: true);

    /// clear data before load
    _mediaList.clear();
    mediaListWithThumbnail.clear();
    firebaseURLList.clear();
    await DBHelper.init();
    await DBHelper.getStallDetailsById(table: StallDetailsModel.table, id: id)
        .then(
      (value) async {
        if (value.isNotEmpty) {
          var result =
              value.map((item) => StallDetailsModel.fromMap(item)).toList();
          if (result.isNotEmpty) {
            stallDetailsModel = result.first;
            stallName = stallDetailsModel!.stallName;
            business = stallDetailsModel!.business;
            if (stallDetailsModel != null && stallDetailsModel!.media != null) {
              _mediaList = stallDetailsModel!.media;
              var list = stallDetailsModel!.media as List;
              if (stallDetailsModel!.firebaseUrl != null) {
                firebaseURLList = stallDetailsModel!.firebaseUrl as List;

              }

              if (list.isNotEmpty) {
                for (var item in list) {
                  {
                    var _path = item as String;
                    var splitString = _path.split(".");

                    /// check mp4 & create thumbnail for that file else add path directly to the list
                    if (splitString.last == "mp4") {
                      mediaListWithThumbnail.add(Media(
                        path: _path,
                        thumbnail:
                            await thumbnailGenerator(videoFile: File(_path)),
                        duration: await getVideoDuration(path: _path),
                      ));
                    } else {
                      mediaListWithThumbnail.add(Media(path: _path));
                    }
                  }
                }
              }

              /// for file count
              mediaCount = mediaListWithThumbnail.length.toString();
            } else {
              mediaListWithThumbnail.clear();
              mediaCount = "0";
            }
          }
        }
        setIsLoading(value: false);
      },
    ).catchError((e) {
      setIsLoading(value: false);
      Fluttertoast.showToast(msg: e.toString());
    });
    notifyListeners();
  }

  /// function to update media
  Future updateMedia(
      {required int id, required List<dynamic> mediaList}) async {
    setIsUpdating(value: true);
    await DBHelper.init();
    await DBHelper.updateMedia(
            table: StallDetailsModel.table,
            id: id,
            media: mediaList,
            lastUpdate: DateTime.now().toString())
        .then(
      (value) {
        /// delay to make loader visible to the user
        Future.delayed(const Duration(seconds: 1)).whenComplete(
          () {
            setIsUpdating(value: false);
            if (value > 0) {
              /// media updated successfully...
              getStallDetailsById(id: id);
            } else {
              mediaList.removeLast();
              Fluttertoast.showToast(msg: "Media does not added!!!");
            }
          },
        );
      },
    ).catchError((e) {
      setIsUpdating(value: false);
      Fluttertoast.showToast(msg: e.toString());
    });
  }

  ///check permission
  checkStoragePermission({required int id, required bool image}) async {
    /// for getting android sdk version
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final android = await deviceInfoPlugin.androidInfo;
    if (android.version.sdkInt >= 33) {
      /// for access gallery
      image ? multiImagePicker(id: id) : multiVideoPicker(id: id);
    } else {
      PermissionStatus status = await Permission.storage.status;
      if (status.isGranted) {
        /// for access gallery
        image ? multiImagePicker(id: id) : multiVideoPicker(id: id);
      } else {
        /// request permission for storage
        status = await Permission.storage.request();
        if (status.isGranted) {
          /// for access gallery
          image ? multiImagePicker(id: id) : multiVideoPicker(id: id);
        } else {
          Fluttertoast.showToast(msg: "Storage permission not granted.");
        }
      }
    }
  }

  /// for pick multiple image
  multiImagePicker({required int id}) async {
    newlyUploadedFile.clear();
    final List<XFile> multiImageList =
        await picker.pickMultiImage(imageQuality: 20);
    if (multiImageList.isNotEmpty) {
      for (var item in multiImageList) {
        _mediaList.add(item.path);
        newlyUploadedFile.add(item.path);
      }
      if (_mediaList.isNotEmpty) {
        updateMedia(id: id, mediaList: _mediaList);
      }

      /// assign task to work manager to store image to firebase storage and then store the return url into db
      if (newlyUploadedFile.isNotEmpty) {
        assignTaskToWorkManager(mediaList: newlyUploadedFile, id: id);
      }
    }
  }

  /// for pick multiple video
  Future<void> multiVideoPicker({required int id}) async {
    newlyUploadedFile.clear();
    FilePickerResult? multiVideoFile = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: true,
    );
    if (multiVideoFile != null) {
      List<PlatformFile> files = multiVideoFile.files;
      for (var item in files) {
        _mediaList.add(item.path);
        newlyUploadedFile.add(item.path!);
      }
      FilePickerStatus.done;

      /// update media in db
      if(_mediaList.isNotEmpty){
        updateMedia(id: id, mediaList: _mediaList);
      }
      if(newlyUploadedFile.isNotEmpty){
        assignTaskToWorkManager(mediaList: newlyUploadedFile, id: id);
      }

    }
  }

  assignTaskToWorkManager({required List<String> mediaList, required int id}) {
    final Constraints constraints = Constraints(
      networkType: NetworkType.connected,
    );

    // Schedule the WorkManager task with the constraints
    Workmanager().registerOneOffTask(
      "uploadImageTask",
      "uploadImage",
      inputData: {'localPath': jsonEncode(newlyUploadedFile), 'id': id},
      constraints: constraints,
    );
  }

  /// for generate thumbnail for video
  Future<String> thumbnailGenerator({required File videoFile}) async {
    try {
      var thumbnailPath = await VideoThumbnail.thumbnailFile(
          video: videoFile.path,
          thumbnailPath: (await getTemporaryDirectory()).path,
          imageFormat: ImageFormat.PNG);
      if (thumbnailPath != null) {
        return thumbnailPath;
      } else {
        return "";
      }
    } catch (e) {
      throw e.toString();
    }
  }

  /// for get video duration
  Future<String> getVideoDuration({required String path}) async {
    VideoPlayerController videoPlayerController =
        VideoPlayerController.file(File(path));
    await videoPlayerController.initialize();

    var minutes = videoPlayerController.value.duration.inMinutes.remainder(60);
    var seconds = videoPlayerController.value.duration.inSeconds.remainder(60);
    String formattedMinutes = minutes.toString().padLeft(2, '0');
    String formattedSeconds = seconds.toString().padLeft(2, '0');

    return "$formattedMinutes:$formattedSeconds";
  }

  /// for open image in launcher
  Future<void> openImageFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        // Open the file using platform-specific method
        await OpenFile.open(file.path);
      } else {
        throw 'File not found';
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error opening file: $e');
      // Handle error as needed
    }
  }

  /// get image from firebase url and store that into local path then return tha local path
  Future<String> cacheImage(String url, String localPath) async {

    try {
      var response = await Dio()
          .get(url, options: Options(responseType: ResponseType.bytes));

      if (response.statusCode == 200) {
        File file = File(localPath);
        await file.writeAsBytes(response.data);

        return localPath;
      } else {

        throw Exception(
            'Failed to fetch image. Status code: ${response.statusCode}');
      }
    } catch (e) {

      return "";
    }
  }

  /// reset data during dispose
  reset() {
    mediaListWithThumbnail.clear();
    _mediaList.clear();
    newlyUploadedFile.clear();
    isUpdating = false;
    stallName = "";
    business = "";
    mediaCount = "0";
    currentIndex = 0;
  }
}

///  for create thumbnail for video file
class Media {
  String? thumbnail;
  String? duration;
  String? firebaseUrl;
  final String path;

  Media({this.thumbnail, required this.path, this.duration, this.firebaseUrl});
}
