import 'dart:html';
import 'dart:math';

import 'package:hyperspace/hyperspace.dart';

final CanvasElement canvas = querySelector('#hypercanvas');
final CanvasRenderingContext2D ctx = canvas.getContext('2d');
final DivElement outputDiv = querySelector('#output');

void main() {
  output('Welcome to Hyperspace!');

//  Hyperspace.dimensions = 3;
//  Hyperspace.setViewerPosition(canvas.width >> 1 as double, canvas.height >> 1 as double, 8000.0);
//  Hyperspace.setHyperdimensionDistance(1000.0);
  ctx.strokeStyle = '#FFFFFF';

  final space = Hyperspace(3);
  space.setViewerPosition(canvas.width >> 1 as double, canvas.height >> 1 as double, 8000.0);
  space.setHyperdimensionDistance(1000.0);

  final cube = space.addHypercube(100.0);
  cube.setRotationVelocity(0, 2, pi / 6.0);
  cube.setRotationVelocity(1, 2, pi / 4.0);
  space.update(1);
  drawObject(cube);

  cube.setRotationVelocity(0, 2, 0);
  cube.setRotationVelocity(1, 2, 0);
  cube.translateFromList([150.0, 150.0, 0.0, 0.0]);
  space.update(1);
  drawObject(cube);

  cube.translateFromList([150.0, 150.0, 0.0, 0.0]);
  space.update(1);
  drawObject(cube);
}

void drawObject(HyperObject object) {
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

void output(String str) {
  outputDiv.text += '$str\n';
}
