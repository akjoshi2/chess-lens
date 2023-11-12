import 'package:flutter/material.dart';

class MovesWidget extends StatefulWidget {
  final List<String> moves;
  const MovesWidget({Key? key, required List<String> this.moves}) : super(key: key);
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
    whiteMoves = [];
    blackMoves = [];
    for(int i = 0; i < widget.moves.length; i++){
      if(i % 2 == 0){
          whiteMoves.add(widget.moves[i]);
      }
      else{
        blackMoves.add(widget.moves[i]);
      }
    }
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
                  blackMoves.length < whiteMoves.length && index == whiteMoves.length-1? "${index + 1}. ${whiteMoves[index]}" : "${index + 1}. ${whiteMoves[index]}  ${blackMoves[index]}" ,
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
