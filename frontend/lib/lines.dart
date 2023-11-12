import 'package:flutter/material.dart';

class LinesWidget extends StatefulWidget {
  const LinesWidget({Key? key}) : super(key: key);
  @override
  LinesState createState() => LinesState();
}

class LinesState extends State<LinesWidget> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
            height: 95,
            padding: const EdgeInsets.all(10.0),
            width: 411,
            decoration: BoxDecoration(color: Colors.white),
            child: Text("Line 1")));
  }
}
