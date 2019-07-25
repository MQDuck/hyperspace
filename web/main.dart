import 'dart:html';

import 'space_view.dart';

final CanvasElement canvas = querySelector('#hypercanvas');
final CanvasRenderingContext2D ctx = canvas.getContext('2d');
//final output = (String str) => querySelector('#output').text += '$str\n';
final output = (String str) => print(str);
SpaceView spaceView;

void main() {
  ctx.strokeStyle = '#FFFFFF';

  spaceView =
      SpaceView(3, 800.0, 100.0, canvas, ctx, output: output);
  final cube = spaceView.space.addHypercube(100.0);
  cube.setRotationVelocity(0, 2, 0.00062831853071795865);
  spaceView.run();
}
