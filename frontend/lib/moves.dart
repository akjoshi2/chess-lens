import 'package:flutter/material.dart';

class MovesWidget extends StatefulWidget {
  const MovesWidget({Key? key}) : super(key: key);
  @override
  MovesState createState() => MovesState();
}

class MovesState extends State<MovesWidget> {
  List<String> moves = [
    "e4",
    "e5",
    "Nf3",
    "Nc6",
    "Bb5",
    "Nf6",
    "d3",
    "Bc5",
    "Ba4",
    "O-O",
    "O-O",
    "Re8",
    "c3",
    "Bf8",
    "Re1",
    "h6",
    "Nbd2",
    "d6"
  ];
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
                height: 244,
                padding: const EdgeInsets.all(10.0),
                width: 78,
                decoration: BoxDecoration(color: Colors.white),
                child: ListView.builder(
                    itemCount: moves.length,
                    itemBuilder: (content, index) {
                      return Text("${index + 1}. ${moves[index]}");
                    }))));
  }
}
