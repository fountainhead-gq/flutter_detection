import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';

const String yolo = "Tiny YOLOv2";
typedef void Callback(List<dynamic> list, int h, int w);

class CameraHomePage extends StatefulWidget {
  static const String routName = '/camera_home';

  final List<CameraDescription> cameras;
  final Callback setRecognitions;

  CameraHomePage(this.cameras, this.setRecognitions);

  @override
  _CameraHomePageState createState() => _CameraHomePageState();
}

class _CameraHomePageState extends State<CameraHomePage> {
  String imagePath;
  CameraController controller;
  bool isDetecting = false;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    try {
      onCameraSelected(widget.cameras[0]);
      print(widget.cameras);
    } catch (e) {
      print(e.toString());
    }

    super.initState();
  }

  void onCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) await controller.dispose();
    controller = CameraController(cameraDescription, ResolutionPreset.medium);

    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        print('Camera Error: ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();

      controller.startImageStream((CameraImage img) {
        if (!isDetecting) {
          isDetecting = true;
          int startTime = new DateTime.now().millisecondsSinceEpoch;

          Tflite.detectObjectOnFrame(
            bytesList: img.planes.map((plane) {
              return plane.bytes;
            }).toList(),
            model: 'YOLO',
            imageHeight: img.height,
            imageWidth: img.width,
            imageMean: 0.0,
            imageStd: 255.0,
            numResultsPerClass: 2,
            threshold: 0.2,
          ).then((recognitions) {
            int endTime = new DateTime.now().millisecondsSinceEpoch;
            print("Detection took time: ${endTime - startTime}");

            widget.setRecognitions(recognitions, img.height, img.width);

            isDetecting = false;
          });
        }
      });
    } on CameraException catch (e) {
      print(e);
    }

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cameras.isEmpty) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(16.0),
        child: Text(
          'No Camera Found',
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.white,
          ),
        ),
      );
    }

    if (!controller.value.isInitialized) {
      return Container();
    }

    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: new Scaffold(
        key: _scaffoldKey,
        body: new Container(
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: new GestureDetector(
                  child: new Container(
                    child: CameraPreview(controller),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
