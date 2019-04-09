import 'dart:io';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'package:photo_view/photo_view.dart';
import 'package:photos_saver/photos_saver.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PhotoDetailPage extends StatefulWidget {
  final String photoPath;
  PhotoDetailPage(this.photoPath);
  @override
  _PhotoDetailPageState createState() => _PhotoDetailPageState();
}

class _PhotoDetailPageState extends State<PhotoDetailPage> {
  final windowWidth = MediaQueryData.fromWindow(window).size.width;
  final windowHeight = MediaQueryData.fromWindow(window).size.height;
  final windowtopbar = MediaQueryData.fromWindow(window).padding.top;

  bool isSuccess;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      body: new Container(
        child: Stack(
          children: <Widget>[
            Container(
              color: Colors.transparent,
              margin: const EdgeInsets.symmetric(vertical: 0.0),
              child: PhotoView(
                imageProvider: AssetImage(widget.photoPath),
                initialScale: PhotoViewComputedScale.covered,
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.all(Radius.circular(50.0)),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 20.0),
                      child: new SizedBox(
                        child: new Icon(
                          // Icons.keyboard_arrow_left,
                          SimpleLineIcons.getIconData('arrow-left'),
                          color: Colors.white,
                          size: 32,
                        ),
                      )),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.all(Radius.circular(50.0)),
                  onTap: () {
                    savePicture(widget.photoPath);
                    Navigator.of(context).pushReplacementNamed("/camera_home");
                  },
                  child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 20.0),
                      child: new SizedBox(
                        child: new Icon(
                          // Ionicons.getIconData('ios-arrow-dropdown'),
                          SimpleLineIcons.getIconData('arrow-down-circle'),
                          color: Colors.white,
                          size: 40,
                        ),
                      )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color gradientStart = Color(0xff000000).withOpacity(0.0); // light blue
  Color gradientStop = Color(0xff000000).withOpacity(0.5);

  savePicture(photoPath) async {
    var imageData = await rootBundle.load(photoPath);
    String filePath =
        await PhotosSaver.saveFile(fileData: imageData.buffer.asUint8List());
    var savedFile = File.fromUri(Uri.file(filePath));

    if (savedFile.toString().contains("File")) {
      String savedFilePath = "已保存至相册";
      // String savedFilePath = "已保存至相册:" + filePath.toString();
      // print(savedFilePath);
      Fluttertoast.showToast(
          msg: savedFilePath,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          textColor: Colors.white54,
          backgroundColor: Colors.transparent,
          fontSize: 20.0);
    } else {}
  }
}
