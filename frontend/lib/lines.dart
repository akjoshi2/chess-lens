import 'package:flutter/material.dart';

class LinesWidget extends StatefulWidget {
  final List<String> lines;
  final List<String> lineEvals;
  const LinesWidget({Key? key, required this.lines, required this.lineEvals})
      : super(key: key);
  @override
  LinesState createState() => LinesState();
}

class LinesState extends State<LinesWidget> {
  @override
  Widget build(BuildContext context) {
    List<String> lines = widget.lines;
    List<String> lineEvals = widget.lineEvals;
    return Container(
            height: 95,
            padding: const EdgeInsets.all(10.0),
            width: 411,
            decoration: BoxDecoration(color: Colors.white),
            child: ListView.builder(
                itemCount: lines.length,
                itemBuilder: (content, index) {
                  return Text("${lineEvals[index]} ${lines[index]}");
                }));
  }
}
