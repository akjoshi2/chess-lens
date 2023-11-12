import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

typedef MapCallback = void Function(Map<String, dynamic> val);

@override
class CameraWidget extends StatefulWidget {
  final Orientation? orientation;
  final MapCallback callback;
  @override
  State<StatefulWidget> createState() => CameraWidgetState();
  const CameraWidget(
      {required Key key, required this.orientation, required this.callback});
}

class CameraWidgetState extends State<CameraWidget> {
  late CameraController controller;
  List<CameraDescription>? cameras;

  bool timer = true;
  var _cameraInitialized = false;

  Uint8List convertImgToBytes(CameraImage img) {
    int totBytes = 0;
    for (Plane plane in img.planes) {
      totBytes += plane.bytes.length;
    }
    Uint8List bytes = Uint8List(totBytes);
    int offset = 0;
    for (Plane plane in img.planes) {
      bytes.setRange(offset, offset + plane.bytes.length, plane.bytes);
      offset += plane.bytes.length;
    }
    return bytes;
  }

  void _initCamera() async {
    cameras = await availableCameras();
    controller = CameraController(cameras![0], ResolutionPreset.max);
    controller.initialize().then((_) async {
      // Start ImageStream
      await controller.startImageStream((CameraImage image) async {
        if (timer) {
          Future.delayed(const Duration(seconds: 5), () {
            timer = true;
          });

          Uint8List myBytes = convertImgToBytes(image);
          var b64 = base64Encode(myBytes);
          final queryParams = {
            "width": image.width.toString(),
            "height": image.height.toString(),
            "image": b64,
            "whiteToMove": 0,
          };

          timer = false;
          var uri = Uri.http("localhost:5000", "/getFen");
          var response = await http.post(uri, body: queryParams);
          widget.callback(jsonDecode(response.body));
          // String base64Image = base64Encode(imageBytes);
          // printw(base64);
        }
      });
      setState(() {
        _cameraInitialized = true;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double midway = MediaQuery.of(context).orientation == Orientation.portrait
        ? (MediaQuery.of(context).size.width * 0.5) - 35
        : (MediaQuery.of(context).size.height * 0.5) - 35;

    return Stack(children: <Widget>[
      FractionallySizedBox(
          widthFactor: widget.orientation == Orientation.portrait ? 1 : 1,
          heightFactor: widget.orientation == Orientation.portrait ? 1 : 1,
          child: (_cameraInitialized)
              ? AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: CameraPreview(controller))
              : LoadingAnimationWidget.stretchedDots(
                  color: Colors.white,
                  size: 200,
                )),
      Container(
        margin: EdgeInsets.fromLTRB(midway, 335, 0, 10),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
              shape: CircleBorder(side: BorderSide(color: Colors.black)),
              minimumSize: Size(70, 70),
              backgroundColor: Colors.white, // Set the background color here
              elevation: 8.0,
              shadowColor: Colors.black),
          child: Icon(
            Icons.refresh,
            size: 45.0,
            color: Colors.green,
          ),
        ),
      ),
    ]);
  }
}
