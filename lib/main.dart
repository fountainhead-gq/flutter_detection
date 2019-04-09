import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';

import 'package:flutter_detection/src/load_page.dart';

List<CameraDescription> cameras;

Future<Null> main() async {
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: $e.code \n Error Message: $e.message');
  }

  runApp(MyApp());

  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

class MyApp extends StatelessWidget {
  final Widget child;

  MyApp({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "frame detection",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xffe7d345),
      ),
      home: LoadPage(cameras),
      initialRoute: '/',
      // routes: <String, WidgetBuilder>{
      //   CameraHomePage.routName: (BuildContext context) =>
      //       CameraHomePage(cameras),
      // },
    );
  }
}
