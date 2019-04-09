import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:fluttertoast/fluttertoast.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'package:path_provider/path_provider.dart';
import 'photo_page.dart';
import 'camera_home.dart';
import 'bbox.dart';

const String yolo = "Tiny YOLOv2";

class LoadPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  LoadPage(this.cameras);

  @override
  LoadPageState createState() => new LoadPageState();
}

class LoadPageState extends State<LoadPage>
    with SingleTickerProviderStateMixin {
  String imagePath;
  CameraController controller;

  var _visible = true;
  AnimationController animationController;
  Animation<double> animation;
  DateTime _lastPressedAt;

  List<dynamic> _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;
  String _model = "";

  loadModel() async {
    String res;
    switch (_model) {
      case yolo:
        res = await Tflite.loadModel(
          model: "assets/yolov2_tiny.tflite",
          labels: "assets/yolov2_tiny.txt",
        );
        break;
      default:
        res = await Tflite.loadModel(
            model: "assets/yolov2_tiny.tflite",
            labels: "assets/yolov2_tiny.txt");
        break;
    }
    print(res);
  }

  onSelectInit(model) {
    setState(() {
      _model = model;
    });
    loadModel();
  }

  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  @override
  void initState() {
    super.initState();
    onSelectInit(yolo);
    animationController = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 1),
    );
    animation =
        new CurvedAnimation(parent: animationController, curve: Curves.easeOut);

    animation.addListener(() => this.setState(() {}));
    animationController.forward();

    setState(() {
      _visible = !_visible;
    });
    // startTime();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          CameraHomePage(
            widget.cameras,
            setRecognitions,
          ),
          BndBox(
            _recognitions == null ? [] : _recognitions,
            math.max(_imageHeight, _imageWidth),
            math.min(_imageHeight, _imageWidth),
            MediaQuery.of(context).size.height,
            MediaQuery.of(context).size.width,
          ),
          // Align(
          //   alignment: Alignment.bottomCenter,
          //   child: Material(
          //     color: Colors.transparent,
          //     child: InkWell(
          //       borderRadius: BorderRadius.all(Radius.circular(30.0)),
          //       onTap: () {
          //         onTakePictureButtonPressed();
          //       },
          //       child: Container(
          //           padding:
          //               EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          //           child: new SizedBox(
          //               child: new Opacity(
          //             opacity: 0.8,
          //             child: Icon(
          //               Icons.photo_camera,
          //               color: Color(0xfff275a4),
          //               size: 60,
          //             ),
          //           ))),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  void navigatorToDetailPhoto(imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (BuildContext context) {
        return PhotoDetailPage(imagePath);
      }),
    );
  }

  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
        });
        if (filePath != null) {
          print('Picture saved to $filePath');
          navigatorToDetailPhoto(imagePath);
        }
      }
    });
  }

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      print('Error: select a camera first.');
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Camera/Images';
    await new Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      print(e);
      return null;
    }
    return filePath;
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<bool> _onWillPop() async {
    if (_lastPressedAt == null ||
        DateTime.now().difference(_lastPressedAt) > Duration(seconds: 1)) {
      _lastPressedAt = DateTime.now();
      Fluttertoast.showToast(
          msg: '再按一次退出',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          textColor: Theme.of(context).primaryColor,
          backgroundColor: Colors.transparent,
          fontSize: 18.0);
      return false;
    }
    return true;
  }
}
