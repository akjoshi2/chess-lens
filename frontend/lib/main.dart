import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:frontend/lines.dart';
import 'package:frontend/chessbar.dart';
import 'package:frontend/lines.dart';
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
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a blue toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _controller = ValueNotifier<bool>(true);
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
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
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
              orientation: MediaQuery.of(context).orientation),
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
                          child: ChessboardWidget(flipped: !_controller.value)),
                      SizedBox(width: 10),
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
                          child: ChessbarWidget(flipped: !_controller.value)),
                      SizedBox(width: 10),
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
                            child: MovesWidget())
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
                        LinesWidget(), // Replace YourWidget with your desired widget
                  )
                ])
              ])
        ]));
  }
}
