import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';

class ChessboardWidget extends StatefulWidget {
  final bool flipped;
  final String fen;
  const ChessboardWidget({Key? key, required this.flipped, required this.fen})
      : super(key: key);
  @override
  ChessboardState createState() => ChessboardState();
}

class ChessboardState extends State<ChessboardWidget> {
  String flipBoard(String fen) {
    List<String> arr = fen.split(" ")[0].split("/");
    String newstr = "";
    for (int i = arr.length - 1; i >= 0; i--) {
      String str = arr[i];
      String reversedStr = "";
      for (int j = str.length - 1; j >= 0; j--) {
        reversedStr += str[j];
      }
      if (i == 0) {
        newstr += reversedStr;
      } else {
        newstr += "$reversedStr/";
      }
    }
    return "$newstr ${fen.split(" ").sublist(1).join(" ")}";
  }

  var inputFen = 'r3r1k1/pp3nPp/1b1p1B2/1q1P1N2/8/P4Q2/1P3PK1/R6R w KQkq - 0 1';
  ChessBoardController? controller;

  @override
  Widget build(BuildContext context) {
    // Initialize the ChessBoardController inside the build method
    var flippedFen = widget.flipped ? flipBoard(widget.fen) : (widget.fen);
    controller = ChessBoardController.fromFEN(flippedFen);

    return IgnorePointer(
        child: FractionallySizedBox(
      widthFactor: 1,
      heightFactor: 1,
      child: ChessBoard(
        controller: controller!,
        boardColor: BoardColor.orange,
        boardOrientation: PlayerColor.white,
      ),
    ));
  }
}
