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

import 'package:hyperspace/hyperspace_web_canvas.dart';

final DivElement wrapper = querySelector('#hyperwrapper');
final CanvasElement canvas = querySelector('#hypercanvas');
final RenderingContext gl = canvas.getContext3d();
final CheckboxInputElement perspectiveCheckbox = querySelector('#perspective');
final output = (String str) => querySelector('#output').text += '$str\n';
//final output = (String str) => print(str);
SpaceView spaceView;

void main() {
  final wrapperWidthStr = wrapper
      .getComputedStyle()
      .width;
  final wrapperHeightStr = wrapper
      .getComputedStyle()
      .height;
  canvas.width = double.parse(wrapperWidthStr.substring(0, wrapperWidthStr.length - 2)).toInt();
  canvas.height = double.parse(wrapperHeightStr.substring(0, wrapperHeightStr.length - 2)).toInt();

  spaceView = SpaceView(4, 800.0, 100.0, canvas, gl, output: output);
  spaceView.targetFrameTime = 16;
//  spaceView.space.usePerspective = false;
//  output('${canvas.height}');

  perspectiveCheckbox.addEventListener('change', (_) => spaceView.space.usePerspective = perspectiveCheckbox.checked);

  final cube = spaceView.space.addHypercube(100.0, dimensions: 4);
  cube.setRotationVelocity(0, 1, 0.3 * 0.00062831853071795865);
  cube.setRotationVelocity(0, 2, 0.3 * 0.00062831853071795865);
  cube.setRotationVelocity(1, 2, 0.3 * 0.00062831853071795865);
//  cube.setRotationVelocity(0, 3, 0.45 * 0.00062831853071795865);
//  cube.setRotationVelocity(1, 2, 0.40 * 0.00062831853071795865);
//  cube.setRotationVelocity(1, 3, 0.35 * 0.00062831853071795865);
//  cube.setRotationVelocity(2, 3, 0.30 * 0.00062831853071795865);

//  final sphere = spaceView.space.addHypersphere(100.0, 30, dimensions: 3);
//  sphere.setRotationVelocity(0, 1, 0.3 * -0.00062831853071795865);
//  sphere.setRotationVelocity(0, 2, 0.3 * -0.00062831853071795865);
//  sphere.setRotationVelocity(1, 2, 0.3 * -0.00062831853071795865);
//  sphere.setRotationVelocity(0, 3, 0.3 * -0.00062831853071795865);

  spaceView.run();
}
