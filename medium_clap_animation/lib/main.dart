import 'package:flutter/material.dart';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Clap animation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Medium Clap Animation'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum ScoreWidgetStatus {
  HIDDEN,
  BECOMING_VISIBLE,
  VISIBLE,
  BECOMING_INVISIBLE
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int _counter = 0;
  final duration = new Duration(milliseconds: 300);
  Timer timer, holdTimer, scoreOutETA;
  AnimationController scoreInAnimationController, scoreOutAnimationController;
  CurvedAnimation bounceInAnimation;
  ScoreWidgetStatus _scoreWidgetStatus;

  void initState() {
    super.initState();
    scoreInAnimationController = new AnimationController(vsync: this, duration: new Duration(milliseconds: 150));
    scoreInAnimationController.addListener(() {
      setState(() {});
    });
    scoreInAnimationController.forward(from: 0.0);
    scoreOutAnimationController = new Tween(begin: 100.0, end: 150.0).animate(
      new CurvedAnimation(parent: scoreInAnimationController, curve: Curves.easeOut)
    );
    scoreOutAnimationController.addListener(() {
      setState(() {});
    });
    scoreOutAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _scoreWidgetStatus = ScoreWidgetStatus.HIDDEN;
      }
    });
    bounceInAnimation = new CurvedAnimation(parent: scoreInAnimationController, curve: Curves.bounceIn);
  }

  void dispose() {
    super.dispose();
  }

  void increment(Timer t) {
    setState(() {
      _counter++;
    });
  }

  void onTapDown(TapDownDetails tap) {
    increment(null);
    timer = new Timer.periodic(duration, increment);
    if (scoreOutETA != null) scoreOutETA.cancel();
    if (_scoreWidgetStatus != null) {
      scoreInAnimationController.forward(from: 0.0);
      _scoreWidgetStatus = ScoreWidgetStatus.BECOMING_VISIBLE;
    }
    increment(null);
    holdTimer = new Timer.periodic(duration, increment);
  }

  void onTapUp(TapUpDetails tap) {
    scoreOutETA = new Timer(duration, () {
      scoreOutAnimationController.forward(from: 0.0);
      _scoreWidgetStatus = ScoreWidgetStatus.BECOMING_INVISIBLE;
    });
    holdTimer.cancel();
  }

  Widget getScoreButton() {
    var scorePosition = 0.0;
    var scoreOpacity = 0.0;
    switch(_scoreWidgetStatus) {
      case ScoreWidgetStatus.VISIBLE:
      case ScoreWidgetStatus.HIDDEN:
        break;
      case ScoreWidgetStatus.BECOMING_VISIBLE:
        scorePosition = scoreInAnimationController.value * 100;
        scoreOpacity = scoreInAnimationController.value;
        break;
      case ScoreWidgetStatus.BECOMING_INVISIBLE:
        scorePosition = scoreInAnimationController.value;
        scoreOpacity = 1.0 - scoreInAnimationController.value;
    }
    return new Positioned(
      child: new Opacity(opacity: scoreOpacity, child: new Container(
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
      bottom: scorePosition,
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
      appBar: new AppBar(
        title: new Text(widget.title),
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
