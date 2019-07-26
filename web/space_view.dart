import 'dart:async';
import 'dart:html';

import 'package:hyperspace/hyperspace.dart';

class SpaceView {
  final Hyperspace space;
  final CanvasElement canvas;
  final CanvasRenderingContext2D ctx;
  final Function(String) output;
  int targetFrameTime = 27; // TODO: modify this based on user's device type (PC, mobile, etc.).
  double _lastTimeStamp = 0.0;
  int _frameCounter = 80;
  var _dragging = false;
  Point<num> mousePosition;

  static _nullOutput(String _) => {};

  SpaceView(int dimensions, double viewerDistance, double spaceDistance, this.canvas, this.ctx,
      {this.output = _nullOutput})
      : space = Hyperspace(dimensions) {
    space.setViewerPosition(canvas.width >> 1 as double, canvas.height >> 1 as double, viewerDistance);
    space.setHyperdimensionDistance(spaceDistance);

    canvas.addEventListener('mousedown', (e) => mouseDown(e as MouseEvent));
    canvas.addEventListener('mouseup', (e) => mouseUp(e as MouseEvent));
    canvas.addEventListener('mouseout', (e) => mouseUp(e as MouseEvent));
    canvas.addEventListener('mousemove', (e) => mouseMove(e as MouseEvent));

    output('Welcome to Hyperspace!');
  }

  void mouseDown(MouseEvent mouseEvent) {
//    print('${mouseEvent.client.x}, ${mouseEvent.client.y}');
    mousePosition = mouseEvent.client;
    _dragging = true;
  }

  void mouseUp(MouseEvent mouseEvent) {
//    print('${mouseEvent.client.x}, ${mouseEvent.client.y}');
    _dragging = false;
  }

  void mouseMove(MouseEvent mouseEvent) {
    if (_dragging) {
      final newPosition = mouseEvent.client;
      final diff = newPosition - mousePosition;
      space.translate(Vector.fromList(space, [diff.x, diff.y]));
      mousePosition = newPosition;
    }
  }

  Future run() async => update(await window.animationFrame);

  void update(double delta) {
    final double diff = delta - _lastTimeStamp;
    if (diff >= targetFrameTime) {
      _lastTimeStamp = delta;
      space.update(diff);
      redraw();
      ++_frameCounter;
      if (_frameCounter == 100) {
        output('${1000.0 / diff} FPS');
//      output('diff = $diff');
        _frameCounter = 0;
      }
    }
    run();
  }

  void redraw() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    for (final object in space.objects) {
      ctx.beginPath();
      for (int i = 0; i < object.length; ++i) {
        final edge = object[i];
        if (edge.a.isVisible && edge.b.isVisible) {
//          output('$edge');
//          output('visible');
          ctx.moveTo(edge.a.x, edge.a.y);
          ctx.lineTo(edge.b.x, edge.b.y);
          ctx.stroke();
        } else {
//          output('$edge');
//          output('invisible');
        }
      }
    }
  }

  void testDraw(CanvasRenderingContext2D testctx) {
    for (final object in space.objects) {
      testctx.beginPath();
      for (int i = 0; i < object.length; ++i) {
        final edge = object[i];
        if (edge.a.isVisible && edge.b.isVisible) {
          output('$edge');
          output('visible');
          testctx.moveTo(edge.a.x, edge.a.y);
          testctx.lineTo(edge.b.x, edge.b.y);
          testctx.stroke();
        } else {
          output('$edge');
          output('invisible');
        }
      }
    }
  }
}
