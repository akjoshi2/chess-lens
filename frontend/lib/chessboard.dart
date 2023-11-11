import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';

class ChessboardWidget extends StatefulWidget {
  const ChessboardWidget({Key? key}) : super(key: key);
  @override
  ChessboardState createState() => ChessboardState();
}

class ChessboardState extends State<ChessboardWidget> {
  ChessBoardController controller = ChessBoardController();

  @override
  Widget build(BuildContext context) {
    return Center(
        child: ChessBoard(
      controller: controller,
      boardColor: BoardColor.orange,
      boardOrientation: PlayerColor.white,
      arrows: [
        BoardArrow(
          from: 'd2',
          to: 'd4',
          color: Colors.red.withOpacity(0.5),
        ),
      ],
    ));
  }
}
