import 'package:flutter/material.dart';

class MovesWidget extends StatefulWidget {
  const MovesWidget({Key? key}) : super(key: key);
  @override
  MovesState createState() => MovesState();
}

class MovesState extends State<MovesWidget> {
  final List<String> moves = ["Kxd8", "e5", "c5"];
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
            height: 244,
            padding: const EdgeInsets.all(10.0),
            width: 78,
            decoration: BoxDecoration(color: Colors.white),
            child: ListView.builder(
                itemCount: moves.length,
                itemBuilder: (content, index) {
                  return Text("${index + 1}. ${moves[index]}");
                })));
  }
}
