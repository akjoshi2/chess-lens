import 'package:flutter/material.dart';

class LinesWidget extends StatefulWidget {
  const LinesWidget({Key? key}) : super(key: key);
  @override
  LinesState createState() => LinesState();
}

class LinesState extends State<LinesWidget> {
  List<String> lineEvals = ["+0.92", "+0.54", "+0.44"];
  List<String> lines = ["exf5", "Nc3", "e5"];
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
            height: 95,
            padding: const EdgeInsets.all(10.0),
            width: 411,
            decoration: BoxDecoration(color: Colors.white),
            child: ListView.builder(
                itemCount: lines.length,
                itemBuilder: (content, index) {
                  return Text("${lineEvals[index]} ${lines[index]}");
                })));
  }
}
