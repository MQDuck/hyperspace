//import 'dart:html';
//
//import 'space_view.dart';
//
//final CanvasElement canvas = querySelector('#hypercanvas');
//final CanvasRenderingContext2D ctx = canvas.getContext('2d');
////final output = (String str) => querySelector('#output').text += '$str\n';
//final output = (String str) => print(str);
//SpaceView spaceView;
//
//void main() {
//  ctx.strokeStyle = '#FFFFFF';
//
//  spaceView =
//      SpaceView(4, 800.0, 100.0, canvas, ctx, output: output);
//  spaceView.targetFrameTime = 16;
//  final cube = spaceView.space.addHypercube(100.0);
//  cube.setRotationVelocity(0, 2, 0.00062831853071795865);
//  cube.setRotationVelocity(0, 1, 0.00062831853071795865);
//  spaceView.run();
//}

library webglapp;

import 'dart:html';
import 'dart:web_gl';

import 'space_view.dart';

final CanvasElement canvas = querySelector('#hypercanvas');
final RenderingContext gl = canvas.getContext3d();
final output = (String str) => querySelector('#output').text += '$str\n';
//final output = (String str) => print(str);
SpaceView spaceView;

void main() {
  spaceView = SpaceView(4, 800.0, 100.0, canvas, gl, output: output);
  spaceView.targetFrameTime = 16;
  final cube = spaceView.space.addHypercube(100.0);
  cube.setRotationVelocity(0, 2, 0.00062831853071795865);
  cube.setRotationVelocity(0, 1, 0.00062831853071795865);
  spaceView.run();
}
