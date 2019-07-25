import 'dart:html';

import 'package:hyperspace/hyperspace.dart';

final CanvasElement canvas = querySelector('#hypercanvas');
final CanvasRenderingContext2D ctx = canvas.getContext('2d');
final DivElement outputDiv = querySelector('#output');

void main() {
  output('Welcome to Hyperspace!');

  dimensions = 3;

  final cube = HyperObject.hypercube(100.0);
  cube.update(0);

  for (int i = 0; i < cube.length; ++i) {
    final edge = cube[i];
    output('${edge.a} --- ${edge.b}');
  }
}

void output(String str) {
  outputDiv.text += '$str\n';
}
