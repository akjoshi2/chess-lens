import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

@override
class CameraWidget extends StatefulWidget {
  final Orientation? orientation;
  @override
  State<StatefulWidget> createState() => CameraWidgetState();
  const CameraWidget({required Key key, required this.orientation});
}

class CameraWidgetState extends State<CameraWidget> {
  late CameraController controller;
  List<CameraDescription>? cameras;
  bool timer = true;
  var _cameraInitialized = false;
  void _initCamera() async {
    cameras = await availableCameras();
    controller = CameraController(cameras![0], ResolutionPreset.max);
    controller.initialize().then((_) async {
      // Start ImageStream
      await controller.startImageStream((CameraImage image) {
        if (timer) {
          // Future.delayed(const Duration(seconds: 5)).then() getPictures
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
    return FractionallySizedBox(
        widthFactor: widget.orientation == Orientation.portrait ? 1 : 1,
        heightFactor: widget.orientation == Orientation.portrait ? 1 : 1,
        child: (_cameraInitialized)
            ? AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: CameraPreview(controller))
            : LoadingAnimationWidget.stretchedDots(
                color: Colors.white,
                size: 200,
              ));
  }
}
