import 'package:flutter/material.dart';

class ChessbarWidget extends StatefulWidget {
  const ChessbarWidget({Key? key}) : super(key: key);
  @override
  ChessbarState createState() => ChessbarState();
}

class ChessbarState extends State<ChessbarWidget> {
  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: FractionallySizedBox(
          widthFactor: 1,
          heightFactor: .5,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.rectangle,
            ),
          )),
    );
  }
}
