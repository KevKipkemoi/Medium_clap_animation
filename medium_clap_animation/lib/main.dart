import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

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
  double _sparklesAngle = 0.0;
  final duration = new Duration(milliseconds: 300);
  final oneSecond = new Duration(seconds: 1);
  Timer timer, holdTimer, scoreOutETA;
  AnimationController scoreInAnimationController, scoreOutAnimationController,
      scoreSizeAnimationController, sparklesAnimationController;
  Animation scoreOutPositionAnimation, sparklesAnimation;
  CurvedAnimation bounceInAnimation;
  Random random;
  ScoreWidgetStatus _scoreWidgetStatus = ScoreWidgetStatus.HIDDEN;

  void initState() {
    super.initState();
    scoreInAnimationController = new AnimationController(vsync: this, duration: new Duration(milliseconds: 150));
    scoreInAnimationController.addListener(() {
      setState(() {});
    });

    scoreOutAnimationController = new AnimationController(vsync: this, duration: duration);
    scoreOutPositionAnimation = new Tween(begin: 100.0, end: 150.0).animate(
      new CurvedAnimation(parent: scoreOutAnimationController, curve: Curves.easeOut)
    );
    scoreOutPositionAnimation.addListener(() {
      setState(() {});
    });
    scoreOutAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _scoreWidgetStatus = ScoreWidgetStatus.HIDDEN;
      }
    });

    scoreSizeAnimationController = new AnimationController(vsync: this, duration: new Duration(milliseconds: 150));
    scoreSizeAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        scoreSizeAnimationController.reverse();
      }
    });
    scoreSizeAnimationController.addListener(() {
      setState(() {});
    });

    sparklesAnimationController = new AnimationController(vsync: this, duration: duration);
    sparklesAnimation = new CurvedAnimation(parent: sparklesAnimationController, curve: Curves.easeIn);
    sparklesAnimation.addListener(() {
      setState(() {});
    });
  }

  void dispose() {
    super.dispose();
    scoreInAnimationController.dispose();
    scoreOutAnimationController.dispose();
  }

  void increment(Timer t) {
    scoreSizeAnimationController.forward(from: 0.0);
    sparklesAnimationController.forward(from: 0.0);
    setState(() {
      _counter++;
      _sparklesAngle = random.nextDouble() * (2*pi);
    });
  }

  void onTapDown(TapDownDetails tap) {
    if (scoreOutETA != null) scoreOutETA.cancel();
    if (_scoreWidgetStatus == ScoreWidgetStatus.BECOMING_INVISIBLE) {
      scoreOutAnimationController.stop(canceled: true);
      _scoreWidgetStatus = ScoreWidgetStatus.VISIBLE;
    } else if (_scoreWidgetStatus == ScoreWidgetStatus.HIDDEN) {
      _scoreWidgetStatus = ScoreWidgetStatus.BECOMING_VISIBLE;
      scoreInAnimationController.forward(from: 0.0);
    }
    increment(null);
    holdTimer = new Timer.periodic(duration, increment);
  }

  void onTapUp(TapUpDetails tap) {
    scoreOutETA = new Timer(oneSecond, () {
      scoreOutAnimationController.forward(from: 0.0);
      _scoreWidgetStatus = ScoreWidgetStatus.BECOMING_INVISIBLE;
    });
    holdTimer.cancel();
  }

  Widget getScoreButton() {
    var scorePosition = 0.0;
    var scoreOpacity = 0.0;
    var extraSize = 0.0;
    switch(_scoreWidgetStatus) {
      case ScoreWidgetStatus.BECOMING_VISIBLE:
      case ScoreWidgetStatus.HIDDEN:
        break;
      case ScoreWidgetStatus.VISIBLE:
        scorePosition = scoreInAnimationController.value * 100;
        scoreOpacity = scoreInAnimationController.value;
        extraSize = scoreSizeAnimationController.value * 3;
        break;
      case ScoreWidgetStatus.BECOMING_INVISIBLE:
        scorePosition = scoreOutPositionAnimation.value;
        scoreOpacity = 1.0 - scoreOutAnimationController.value;
    }

    var stackChildren = <Widget>[];
    var firstAngle = _sparklesAngle;
    var sparkleRadius = (sparklesAnimationController.value * 50);
    var sparklesOpacity = (1 - sparklesAnimation.value);

    for (int i = 0; i < 5; ++i) {
      var currentAngle = (firstAngle + ((2*pi)/5)*(i));
      var sparklesWidget =
        new Positioned(
          child: new Transform.rotate(
            angle: currentAngle - pi/2,
            child: new Opacity(
              opacity: sparklesOpacity,
              child: new Image.asset("images/sparkles.png", width: 14.0, height: 14.0)),
          ),
          left: (sparkleRadius * cos(currentAngle)) + 20,
          top: (sparkleRadius * sin(currentAngle)) + 20,
        );
      stackChildren.add(sparklesWidget);
    }
    stackChildren.add(
      new Opacity(
        opacity: scoreOpacity,
        child: new Container(
          height: 50.0 + extraSize,
          width: 50.0 + extraSize,
          decoration: new ShapeDecoration(
            shape: CircleBorder(side: BorderSide.none),
            color: Colors.pink,
          ),
          child: new Center(
            child: new Text(
              "+" + _counter.toString(),
              style: new TextStyle(
                color: Colors.white,
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      )
    );
    var widget = new Positioned(
      child: new Stack(
        alignment: FractionalOffset.center,
        overflow: Overflow.visible,
        children: stackChildren,
      ),
      bottom: scorePosition,
    );
    return widget;
  }

  Widget getClapButton() {
    var extraSize = 0.0;
    if (_scoreWidgetStatus == ScoreWidgetStatus.VISIBLE || _scoreWidgetStatus == ScoreWidgetStatus.BECOMING_VISIBLE) {
      extraSize = scoreSizeAnimationController.value * 3;
    }
    return new GestureDetector(
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      child: new Container(
        height: 60.0 + extraSize,
        width: 60.0 + extraSize,
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
