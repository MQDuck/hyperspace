import 'dart:html';
import 'dart:math';

import 'space_view.dart';

final CanvasElement canvas = querySelector('#hypercanvas');
final CanvasRenderingContext2D ctx = canvas.getContext('2d');

void main() {
  ctx.strokeStyle = '#FFFFFF';

  final spaceView =
  SpaceView(3, 800.0, 100.0, canvas, ctx, output: (String str) => querySelector('#output').text += '$str\n');

  final cube2 = spaceView.space.addHypercube(100.0);
  cube2.setRotationVelocity(0, 2, pi / 6.0);
  cube2.setRotationVelocity(1, 2, pi / 4.0);
  spaceView.update(1);
  spaceView.draw();

  cube2.setRotationVelocity(0, 2, 0);
  cube2.setRotationVelocity(1, 2, 0);
  cube2.translateFromList([200.0, 200.0, 0.0, 0.0]);
  spaceView.update(1);
  spaceView.draw();

  cube2.translateFromList([200.0, 200.0, 0.0, 0.0]);
  spaceView.update(1);
  spaceView.draw();
}
