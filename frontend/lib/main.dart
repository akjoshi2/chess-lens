import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:frontend/lines.dart';
import 'package:frontend/chessbar.dart';
import 'package:frontend/moves.dart';
import 'camera.dart';
import 'package:flutter/services.dart';
import 'chessboard.dart';
import 'package:http/http.dart' as http;

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
  List<String> moves = [
    "e4",
    "e5",
    "Nf3",
    "Nf6",
    "Nxe5",
    "Nc6",
    "Nxc6",
    "dxc6",
    "d3",
    "Bc5",
    "a3"


  ];
  Map<String, dynamic> jsonOutput = {
    "fen": "r1bqk2r/ppp2ppp/2p2n2/2b5/4P3/P2P4/1PP2PPP/RNBQKB1R b KQkq - 0 6",
    "evaluation": (-5.3).toString(),
    "move": "",
    'lines': {"1": {'evaluation': -9993, 'lines': 'Bxf2 Rxd1+ Kxe2 Qxc2+ Nd2 Rxd2+ Kf3 Qf5+ Ke3 Qxf2+ Ke4 Nf6+ Ke5 Qxa1#'}, "2": {'evaluation': -9997, 'lines': 'Kxf2 Qd4+ Kf1 hxg1=Q+ Rxg1 Qxg1#'}}
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
    PageController pgcont = PageController();
    List<String> stockLines = ['Bg4 Be3 Bxe3 fxe3 Qf6', "Ng4 Be3 Bxe3 fxe3 Qf6"];
    List<String> stockEvals = ["-6.2","-5.8"];

    return Scaffold(
        body: PageView(controller: pgcont, children: [
      GridView.count(
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
                    if (val["move"] == "CLR") {
                      moves = [];
                    } else if (val["move"] != "") {
                      moves.add(val["move"]);
                    }
                    print("CHECK");
                    /*if (val["lines"] != "") {
                      print(val["lines"]);
                      stockLines = [];
                      for (int i = 1; i < 3; i++) {
                        if (jsonOutput["lines"] != null) {
                          stockLines.add(jsonOutput["lines"][i.toString()]["lines"].toString());
                        }
                      }
                      print(stockLines);
                      stockEvals = [];
                      for (int i = 1; i < 3; i++) {
                        if (jsonOutput["lines"] != null) {
                          stockEvals.add(jsonOutput["lines"][i.toString()]["evaluation"].toString());
                        }
                      }
                    }*/
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
                        MediaQuery.of(context).orientation ==
                                Orientation.portrait
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
                            child: ChessbarWidget(
                                flipped: !_controller.value,
                                eval: double.parse(jsonOutput["evaluation"]))),
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
                      child: LinesWidget(
                        lines: stockLines,
                        lineEvals: stockEvals,
                      ), // Replace YourWidget with your desired widget
                    )
                  ])
                ])
          ]),
      Scaffold(
          appBar: AppBar(
            title: Text('En Passant Coin'),
          ),
          body: Text("hi"))
    ]));
  }
}


class EnPassantWidget extends StatelessWidget{
  String url = "https://hedera.onrender.com";
  String getCurrNumber() async{
      var uri = Uri.http("url", "/numbers");
      resp = await http.get(url);
      return jsonDecode(resp.body)["ans"];
  }

   String getCurrNFT() async{
      var uri = Uri.http("url", "/nft");
      resp = await http.get(url);
      return jsonDecode(resp.body)["ans"];
  }
  @override 
  Widget build(BuildContext buildContext){
      https.get(https://hedera.onrender.com)

      return Center(child: Column(children: [Container( child :
      InputDecorator(
    decoration: InputDecoration(
      labelText: 'LIMITED TIME NFT (YOU OWN THIS!!!!!)',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    ),
    child: Image.network(getCurrNFT())),
  ),
       , Container(child:  InputDecorator(
    decoration: InputDecoration(
      labelText: 'GOOGLE EN PASSANT COUNT',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    ),
    child: 
        Text(getCurrNumber()))) ]))
  }
}
