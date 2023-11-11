import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';

class ChessboardWidget extends StatefulWidget {
  const ChessboardWidget({Key? key}) : super(key: key);
  @override
  ChessboardState createState() => ChessboardState();
}

class ChessboardState extends State<ChessboardWidget> {
  var inputFen = 'r3r1k1/pp3nPp/1b1p1B2/1q1P1N2/8/P4Q2/1P3PK1/R6R w KQkq - 0 1';
  ChessBoardController? controller;

  @override
  Widget build(BuildContext context) {
    // Initialize the ChessBoardController inside the build method
    controller ??= ChessBoardController.fromFEN(inputFen);

    return Flexible(
      child: FractionallySizedBox(
        widthFactor: 1,
        heightFactor: .5,
        child: ChessBoard(
          controller: controller!,
          boardColor: BoardColor.orange,
          boardOrientation: PlayerColor.white,
        ),
      ),
    );
  }
}
