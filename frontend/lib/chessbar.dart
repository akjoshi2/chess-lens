import 'package:flutter/material.dart';

class ChessbarWidget extends StatefulWidget {
  const ChessbarWidget({Key? key}) : super(key: key);
  @override
  ChessbarState createState() => ChessbarState();
}

class ChessbarState extends State<ChessbarWidget> {
  @override
  Widget build(BuildContext context) {
    List<Color> grad = [Colors.black, Colors.black, Colors.white, Colors.white];
    double whiteAdv = 0.0;
    String whiteAdvString = whiteAdv.toString();
    double whitePercent = 50.00;
    double whiteStop = (100 - whitePercent) / 100;
    final List<double> stops = [0.0, whiteStop, whiteStop, 1.0];

    return Flexible(
      child: FractionallySizedBox(
        widthFactor: .1,
        heightFactor: .5,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: grad,
              stops: stops,
              end: Alignment.bottomCenter,
              begin: Alignment.topCenter,
            ),
            shape: BoxShape.rectangle,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          child: Column(children: [
            Text(whiteAdvString,
                style: const TextStyle(
                  color: Colors.white,
                ))
          ]),
        ),
      ),
    );
  }
}
