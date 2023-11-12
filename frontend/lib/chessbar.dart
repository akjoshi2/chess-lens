import 'package:flutter/material.dart';

class ChessbarWidget extends StatefulWidget {
  final bool flipped;
  const ChessbarWidget({Key? key, required this.flipped}) : super(key: key);
  @override
  ChessbarState createState() => ChessbarState();
}

class ChessbarState extends State<ChessbarWidget> {
  @override
  Widget build(BuildContext context) {
    List<Color> grad = widget.flipped
        ? [Colors.white, Colors.white, Colors.black, Colors.black]
        : [Colors.black, Colors.black, Colors.white, Colors.white];
    double topAdv = 0.0;
    String topAdvString = "+${topAdv.toString()}";
    double botAdv = topAdv;
    if (topAdv != 0) {
      botAdv = -1 * topAdv;
    }
    String botAdvString = "+${botAdv.toString()}";
    double whitePercent = 50.00;
    if (topAdv < -3) {
      whitePercent = 1.00;
    } else if (topAdv < -2) {
      whitePercent = 11.00;
    } else if (topAdv < -1) {
      whitePercent = 22.00;
    } else if (topAdv < -0.5) {
      whitePercent = 33.00;
    } else if (topAdv < -0.25) {
      whitePercent = 44.00;
    } else if (topAdv < 0.25) {
      whitePercent = 50.00;
    } else if (topAdv < 0.50) {
      whitePercent = 56.00;
    } else if (topAdv < 1) {
      whitePercent = 67.00;
    } else if (topAdv < 2) {
      whitePercent = 78.00;
    } else if (topAdv < 3) {
      whitePercent = 89.00;
    } else {
      whitePercent = 99.00;
    }
    if (!widget.flipped) {
      double temp = topAdv;
      String tempString = topAdvString;
      topAdv = botAdv;
      topAdvString = botAdvString;
      botAdv = temp;
      botAdvString = tempString;
    }
    double whiteStop = (100 - whitePercent) / 100;
    double blackStop = whitePercent / 100;
    final List<double> stops = widget.flipped
        ? [0.0, blackStop, blackStop, 1.0]
        : [0.0, whiteStop, whiteStop, 1.0];

    return Flexible(
      child: FractionallySizedBox(
        widthFactor: 1,
        heightFactor: 1,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: grad,
              stops: stops,
              end: Alignment.bottomCenter,
              begin: Alignment.topCenter,
            ),
            shape: BoxShape.rectangle,
            borderRadius: const BorderRadius.all(Radius.circular(2)),
          ),
          child: Column(children: [
            SizedBox(height: 3),
            if (topAdv > botAdv)
              Text(
                topAdvString,
                style: TextStyle(
                  fontSize: 7,
                  color: widget.flipped ? Colors.black : Colors.white,
                ),
              ),
            SizedBox(height: 274),
            if (botAdv >= topAdv)
              Text(
                botAdvString,
                style: TextStyle(
                  fontSize: 7,
                  color: widget.flipped ? Colors.white : Colors.black,
                ),
              ),
          ]),
        ),
      ),
    );
  }
}
