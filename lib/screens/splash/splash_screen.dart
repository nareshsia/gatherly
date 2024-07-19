import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gatherly/controller/splash_controller.dart';
import 'package:gatherly/screens/stall_list/stall_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  SplashController? _splashController;



  @override
  void initState() {

    _splashController = Provider.of<SplashController>(context,listen: false);
    Future.delayed(Duration.zero).whenComplete(() {
      _splashController!.checkDB(context: context);
    },);

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return   Scaffold(
    backgroundColor: Colors.white,
      body: Center(
         child: Text("GATHERLY",
           style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 25.sp),),
      ),
    );
  }
}
