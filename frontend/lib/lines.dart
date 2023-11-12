import 'package:flutter/material.dart';

class LinesWidget extends StatefulWidget {
  final List<String> lines;
  const LinesWidget({Key? key, required this.lines}) : super(key: key);
  @override
  LinesState createState() => LinesState();
}

class LinesState extends State<LinesWidget> {
  List<String> lineEvals = ["+0.92", "+0.54", "+0.44"];
  @override
  Widget build(BuildContext context) {
    List<String> lines = widget.lines;
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
