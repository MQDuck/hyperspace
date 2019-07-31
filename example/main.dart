/*
 * Copyright (C) 2019 Jeffrey Thomas Piercy
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

library webglapp;

import 'dart:html';
import 'dart:web_gl';

import 'package:hyperspace_web_canvas/hyperspace_web_canvas.dart';

final CanvasElement canvas = querySelector('#hypercanvas');
final RenderingContext gl = canvas.getContext3d();
final output = (String str) => querySelector('#output').text += '$str\n';
//final output = (String str) => print(str);
SpaceView spaceView;

void main() {
  spaceView = SpaceView(3, 800.0, 100.0, canvas, gl, output: output);
  spaceView.targetFrameTime = 16;

  final cube = spaceView.space.addHypercube(100.0);
  cube.setRotationVelocity(0, 1, 0.3 * 0.00062831853071795865);
  cube.setRotationVelocity(0, 2, 0.3 * 0.00062831853071795865);
  cube.setRotationVelocity(1, 2, 0.3 * 0.00062831853071795865);
//  cube.setRotationVelocity(0, 3, 0.00062831853071795865);
//  cube.setRotationVelocity(1, 2, 0.00062831853071795865);
//  cube.setRotationVelocity(1, 3, 0.00062831853071795865);
//  cube.setRotationVelocity(2, 3, 0.00062831853071795865);

  final sphere = spaceView.space.addHypersphere(100.0, 30);
  sphere.setRotationVelocity(0, 1, 0.3 * -0.00062831853071795865);
  sphere.setRotationVelocity(0, 2, 0.3 * -0.00062831853071795865);
  sphere.setRotationVelocity(1, 2, 0.3 * -0.00062831853071795865);

  spaceView.run();
}
