import 'dart:html';

import 'package:hyperspace/hyperspace.dart';

class SpaceView {
  final Hyperspace space;
  final CanvasElement canvas;
  final CanvasRenderingContext2D ctx;
  final Function(String) output;

  static _nullOutput(String _) => {};

  SpaceView(int dimensions, double viewerDistance, double spaceDistance, this.canvas, this.ctx,
      {this.output = _nullOutput})
      : space = Hyperspace(dimensions) {
    space.setViewerPosition(canvas.width >> 1 as double, canvas.height >> 1 as double, viewerDistance);
    space.setHyperdimensionDistance(spaceDistance);

    output('Welcome to Hyperspace!');
  }

  void update(int time) => space.update(time);

  void draw() {
    for (final object in space.objects) {
      ctx.beginPath();
      for (int i = 0; i < object.length; ++i) {
        final edge = object[i];
        if (edge.a.isVisible && edge.b.isVisible) {
          output('$edge');
          output('visible');
          ctx.moveTo(edge.a.x, edge.a.y);
          ctx.lineTo(edge.b.x, edge.b.y);
          ctx.stroke();
        } else {
          output('$edge');
          output('invisible');
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
