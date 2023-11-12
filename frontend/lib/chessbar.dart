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
    double botAdv = 0.0;
    String botAdvString = "+${botAdv.toString()}";
    double whitePercent = 50.00;
    double whiteStop = (100 - whitePercent) / 100;
    final List<double> stops = [0.0, whiteStop, whiteStop, 1.0];

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
            if (topAdv >= botAdv)
              Text(
                topAdvString,
                style: TextStyle(
                  fontSize: 7,
                  color: widget.flipped ? Colors.black : Colors.white,
                ),
              ),
            SizedBox(height: 265),
            if (botAdv > topAdv)
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
