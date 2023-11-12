import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:frontend/lines.dart';
import 'package:frontend/chessbar.dart';
import 'package:frontend/moves.dart';
import 'camera.dart';
import 'package:flutter/services.dart';
import 'chessboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack).then(
    (_) => runApp(const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.white,
              background: Color.fromRGBO(211, 211, 211, 1.0)),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _controller = ValueNotifier<bool>(true);
  List<String> moves = [];
  Map<String, dynamic> jsonOutput = {
    "fen": "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
    "evaluation": 0.0.toString(),
    "move" : "KC6",
    "line" : {"0": "a5", "1": "b5", "2": "c5"},
  };

  bool whiteToPlay = true;
  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        whiteToPlay = _controller.value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print(jsonOutput["line"].toString());
    List<String> getStockLines() {
      List<String> stockLines = [];
      for (int i = 0; i < 3; i ++)
      {
        if(jsonOutput["line"] != null)
        {
          stockLines.add(jsonOutput["line"][i.toString()]);
        }
      }
      return stockLines;
    }

    return Scaffold(
        body: GridView.count(
            crossAxisCount:
                MediaQuery.of(context).orientation == Orientation.portrait
                    ? 1
                    : 2,
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
            padding: const EdgeInsets.all(0),
            children: [
          CameraWidget(
              key: const ObjectKey(1),
              orientation: MediaQuery.of(context).orientation,
              callback: (val) {
                setState(() {
                  jsonOutput = val;
                  if (val["move"] != "")
                  {
                    moves.add(val["move"]);
                  }
                });
              }),
          Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MediaQuery.of(context).orientation == Orientation.portrait
                          ? SizedBox()
                          : SizedBox(width: 10),
                      Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          width: MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? MediaQuery.of(context).size.width * .7
                              : MediaQuery.of(context).size.height * .7,
                          height: 288,
                          child: ChessboardWidget(
                              flipped: !_controller.value,
                              fen: jsonOutput["fen"])),
                      const SizedBox(width: 10),
                      Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          width: 25,
                          height: 288,
                          child: ChessbarWidget(flipped: !_controller.value, eval: double.parse(jsonOutput["evaluation"]))),
                      const SizedBox(width: 10),
                      Column(children: [
                        Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            width: 78,
                            height: 35,
                            child: AdvancedSwitch(
                              controller: _controller,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(2)),
                              width: 68,
                              height: 20,
                              activeColor: Colors.white,
                              inactiveColor: Colors.black,
                              activeChild: const Text('WHITE',
                                  style: TextStyle(color: Colors.black)),
                              inactiveChild: const Text('BLACK',
                                  style: TextStyle(color: Colors.white)),
                            )),
                        SizedBox(height: 10),
                        Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: MovesWidget(moves: moves))
                      ])
                    ]),
                SizedBox(height: 10),
                Row(children: [
                  MediaQuery.of(context).orientation == Orientation.portrait
                      ? SizedBox()
                      : SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child:
                        LinesWidget(lines: getStockLines()), // Replace YourWidget with your desired widget
                  )
                ])
              ])
        ]));
  }
}
