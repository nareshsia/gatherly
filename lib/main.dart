import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gatherly/controller/connectivity_controller.dart';
import 'package:gatherly/controller/splash_controller.dart';
import 'package:gatherly/controller/stall_details_controller.dart';
import 'package:gatherly/controller/stall_list_controller.dart';
import 'package:gatherly/models/stall_details_model.dart';
import 'package:gatherly/screens/splash/splash_screen.dart';
import 'package:gatherly/utilz/constant.dart';
import 'package:gatherly/utilz/db_helper.dart';
import 'package:gatherly/utilz/shared_pref.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:workmanager/workmanager.dart';
import 'firebase_options.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    /// Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    /// Initialize Shared Preference
    await SharedPrefs.init();
    /// Retrieve input data
    String localPath = inputData!['localPath'];
    int id = inputData['id'];
    List<String> firebaseURLList = [];
    List<String> listOfStrings = List<String>.from(jsonDecode(localPath));

    try {
      for (var item in listOfStrings) {
        // Upload the file to Firebase Storage
        File file = File(item);
        String fileName = basename(file.path);
        UploadTask uploadTask = FirebaseStorage.instance
            .ref()
            .child('uploads/$fileName')
            .putFile(file);

        TaskSnapshot taskSnapshot = await uploadTask;
        String firebaseUrl = await taskSnapshot.ref.getDownloadURL();
        Directory appDir = await getApplicationDocumentsDirectory();
        String localPath = '${appDir.path}/$fileName';
        await file.copy(localPath);
        firebaseURLList.add(firebaseUrl);
        print('Firebase URL: $firebaseURLList');
        print("localPath:${localPath}");

      }
     print("yes come outside");
      // Check if the firebaseURLList is not empty
      if (firebaseURLList.isNotEmpty) {
        await DBHelper.init();

        // Get existing Firebase URLs from DB
        try {
          await DBHelper.getFirebaseURLList(
            table: StallDetailsModel.table,
            id: id,
          ).then( (existingFirebaseURLList) async{
            var result = existingFirebaseURLList.first['firebaseUrl'];
            if(result != null){
              var existingList = jsonDecode(result) as List<dynamic>;
              existingList.addAll(firebaseURLList);
              await DBHelper.updateFirebaseURL(
                table: StallDetailsModel.table,
                id: id,
                lastUpdate: DateTime.now().toString(),
                firebaseUrl: existingList,
              );
            }else{
              await DBHelper.updateFirebaseURL(
                table: StallDetailsModel.table,
                id: id,
                lastUpdate: DateTime.now().toString(),
                firebaseUrl: firebaseURLList,
              );
            }

          },);

          /// Set the last sync time
          SharedPrefs.setString(LAST_SYNC, DateTime.now().toString());
        } catch (dbError) {
          print('Error during database operations: $dbError');
          return Future.value(false);
        }
      }

      // Indicate success
      return Future.value(true);
    } catch (e) {
      print('Error during image upload: $e');
      return Future.value(false);
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ///for shared preference
  await SharedPrefs.init();

  ///for firebase initialization
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// work manager initialization
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  runApp(const MyApp());
  ///for status bar background color
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.dark,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        /// connectivity controller
        ChangeNotifierProvider<ConnectivityController>(
          create: (context) => ConnectivityController(),
        ),
        /// splash controller
        ChangeNotifierProvider<SplashController>(
          create: (context) => SplashController(),
        ),

        /// stall list controller
        ChangeNotifierProvider<StallListController>(
          create: (context) => StallListController(),
        ),

        /// stall details controller
        ChangeNotifierProvider<StallDetailsController>(
          create: (context) => StallDetailsController(),
        ),
      ],
      child: ResponsiveSizer(
        builder: (p0, p1, p2) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: SplashScreen(),
          );
        },
      ),
    );
  }
}
