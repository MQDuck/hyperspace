import 'dart:html';
import 'dart:math';

import 'package:hyperspace/hyperspace.dart';

final CanvasElement canvas = querySelector('#hypercanvas');
final CanvasRenderingContext2D ctx = canvas.getContext('2d');
final DivElement outputDiv = querySelector('#output');

void main() {
  output('Welcome to Hyperspace!');

  dimensions = 4;
  HyperObject.setDisplayCenter(canvas.width >> 1 as double, canvas.height >> 1 as double);
  ctx.strokeStyle = '#FFFFFF';

  final cube = HyperObject.hypercube(100.0);
  cube.setRotation(0, 2, pi / 6.0);
  cube.setRotation(1, 2, pi / 4.0);
  cube.setRotation(1, 3, pi / 1000.0);
  cube.update(1);

  ctx.beginPath();
  for (int i = 0; i < cube.length; ++i) {
    drawEdge(cube[i]);
  }
}

void drawEdge(Edge edge) {
  output('${edge.a} --- ${edge.b}');
  ctx.moveTo(edge.a.x, edge.a.y);
  ctx.lineTo(edge.b.x, edge.b.y);
  ctx.stroke();
}

void output(String str) {
  outputDiv.text += '$str\n';
}
