import 'dart:math' as Math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_a_3d_renderer/model.dart';

class ViewPanel extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ViewPanelState();
}

class _ViewPanelState extends State<ViewPanel> {
  List<GraphicsObject> graphicObjects = [];
  var _random = Math.Random();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.grey,
          child: Column(
            children: [
              Flexible(
                flex: 11,
                child: AspectRatio(
                  aspectRatio: 1/1,
                  child: Container(
                    color: Colors.white,
                    child: CustomPaint(
                      willChange: true,
                      isComplex: true,
                      size: Size.infinite,
                      painter: MyPainter(this),
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Container(
                  color: Colors.blueGrey,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Bottom"),
                    ],
                  ),
                ),
              )
            ],
          ),
        )
      ),
      floatingActionButton: FloatingActionButton(
        child: Text("+"),
        onPressed: () => addRandomPoint(),
      ),
    );
  }

  void addRandomPoint() {
    setState(() {
      var p = Point(x:_random.nextDouble()*100,y:_random.nextDouble()*100);
      graphicObjects.add(p);
    });
  }
}

class MyPainter extends CustomPainter {
  _ViewPanelState _panelState;
  List<GraphicsObject> _graphicsObjects;

  MyPainter(this._panelState): _graphicsObjects = _panelState.graphicObjects;

  @override
  void paint(Canvas canvas, Size size) {
    _graphicsObjects = _panelState.graphicObjects;

    _panelState.graphicObjects.forEach((element) => element.draw(canvas, size));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return _graphicsObjects != _panelState.graphicObjects;
  }
}
