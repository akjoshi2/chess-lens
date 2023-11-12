import 'package:flutter/material.dart';

class MovesWidget extends StatefulWidget {
  const MovesWidget({Key? key}) : super(key: key);
  @override
  MovesState createState() => MovesState();
}

class MovesState extends State<MovesWidget> {
  List<String> whiteMoves = [
    "e4",
    "Nf3",
    "Bb5",
    "d3",
    "Ba4",
    "O-O",
    "Re8",
    "Bf8",
    "Nbd2",
  ];

  List<String> blackMoves = [
    "e5",
    "Nc6",
    "Nf6",
    "Bc5",
    "O-O",
    "c3",
    "h6",
    "d6",
    "Re1",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 244,
      width: 78,
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(color: Colors.white),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Moves",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: whiteMoves.length,
              itemBuilder: (context, index) {
                return Text(
                  "${index + 1}. ${whiteMoves[index]}  ${blackMoves[index]}",
                  style: TextStyle(
                    fontSize: 9,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
