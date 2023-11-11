import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

@override
class CameraWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CameraWidgetState();
  const CameraWidget({super.key});
}

class CameraWidgetState extends State<CameraWidget> {
  late CameraController controller;
  List<CameraDescription>? cameras;
  var _cameraInitialized = false;
  void _initCamera() async {
    cameras = await availableCameras();
    controller = CameraController(cameras![0], ResolutionPreset.max);
    controller.initialize().then((_) async {
      // Start ImageStream
      await controller.startImageStream((CameraImage image) => ());
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
    return Flexible(
        child: FractionallySizedBox(
            widthFactor: 1,
            heightFactor: .5,
            child: (_cameraInitialized)
                ? AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: CameraPreview(controller))
                : const CircularProgressIndicator()));
  }
}
