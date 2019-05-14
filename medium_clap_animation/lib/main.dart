import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clap animation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Medium Clap Animation'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final duration = new Duration(milliseconds: 300);
  Timer timer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _increment(Timer t) {
    setState(() {
      _counter++;
    });
  }

  void onTapDown(TapDownDetails tap) {
    increment(null);
    timer = new Timer.periodic(duration, increment);
  }

  void onTapUp(TapUpDetails tap) {
    timer.cancel();
  }

  Widget getScoreButton() {
    return new Positioned(
      child: new Opacity(opacity: 1.0, child: new Container(
        height: 50.0,
        width: 50.0,
        decoration: new ShapeDecoration(
            shape: new CircleBorder(
              side: BorderSide.none
            ),
            color: Colors.pink,
        ), // ShapeDirection
        child: new Center(
          child: new Text(
            "+" + _counter.toString(),
            style: new TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15.0
            ), // TextStyle
          ),
        ),
      )),
      bottom: 100.0,
    );
  }

  Widget getClapButton() {
    return new GestureDetector(
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      child: new Container(
        height: 60.0,
        width: 60.0,
        padding: new EdgeInsets.all(10.0),
        decoration: new BoxDecoration(
          border: new Border.all(color: Colors.pink, width: 1.0),
          borderRadius: new BorderRadius.circular(50.0),
          color: Colors.white,
          boxShadow: [new BoxShadow(color: Colors.pink, blurRadius: 8.0)]
        ),
        child: new ImageIcon(new AssetImage("images/clap.png"), color: Colors.pink, size: 40.0),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              'You have pushed the button this many times:',
            ),
            new Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: new Padding(
        padding: new EdgeInsets.only(right: 20.0),
        child: new Stack(
          alignment: FractionalOffset.center,
          overflow: Overflow.visible,
          children: <Widget>[
            getScoreButton(),
            getClapButton(),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
