/*
 * Copyright (C) 2019 Jeffrey Thomas Piercy
 *
 * This file is part of hyperspace-web-canvas.
 *
 * hyperspace-web-canvas is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * hyperspace-web-canvas is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with hyperspace-web-canvas.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:async';
import 'dart:html';
import 'dart:typed_data';
import 'dart:web_gl';

import 'package:hyperspace/hyperspace.dart';

class SpaceView {
  final Hyperspace space;
  final CanvasElement _canvas;
  final RenderingContext _gl;
  final Function(String) output;
  int targetFrameTime = 27; // TODO: modify this based on user's device type (PC, mobile, etc.).
  double _lastTimeStamp = 0.0;
  var _dragging = false;
  Point<num> _mousePosition;
  double _scaleX, _scaleY;
  final Buffer _vertexBuffer, _indexBuffer, _colorBuffer;

  static _nullOutput(String _) => {};

  static const _vertexShaderSrc = """
    attribute vec2 coordinates;
    attribute vec3 color;
    varying vec3 vColor;
    
    void main() {
      gl_Position = vec4(coordinates, 0.0, 1.0);
      vColor = color;
    }
""";

  static const _fragmentShaderSrc = """
    precision mediump float;
    varying vec3 vColor;
    
    void main() {
      gl_FragColor = vec4(vColor, 1.0);
    }
""";

  SpaceView(int dimensions, double viewerDistance, double spaceDistance, this._canvas, this._gl,
      {this.output = _nullOutput})
      : space = Hyperspace(dimensions),
        _vertexBuffer = _gl.createBuffer(),
        _indexBuffer = _gl.createBuffer(),
        _colorBuffer = _gl.createBuffer() {
    space.setViewerPosition(0.0, 0.0, viewerDistance);
    space.setHyperdimensionDistance(spaceDistance);

    _scaleX = 1.0 / (_canvas.width >> 1);
    _scaleY = 1.0 / (_canvas.height >> 1);

    _canvas.addEventListener('mousedown', (e) => mouseDown(e as MouseEvent));
    _canvas.addEventListener('mouseup', (e) => mouseUp(e as MouseEvent));
    _canvas.addEventListener('mouseout', (e) => mouseUp(e as MouseEvent));
    _canvas.addEventListener('mousemove', (e) => mouseMove(e as MouseEvent));

    _gl.clearColor(0.0, 0.0, 0.0, 1.0);
    _gl.viewport(0, 0, _canvas.width, _canvas.height);

    _gl.bindBuffer(WebGL.ARRAY_BUFFER, _vertexBuffer);
    _gl.bufferData(WebGL.ARRAY_BUFFER, Float32List(10000), WebGL.DYNAMIC_DRAW);
    _gl.bindBuffer(WebGL.ARRAY_BUFFER, null);

    _gl.bindBuffer(WebGL.ELEMENT_ARRAY_BUFFER, _indexBuffer);
    _gl.bufferData(WebGL.ELEMENT_ARRAY_BUFFER, Uint16List(10000), WebGL.DYNAMIC_DRAW);
    _gl.bindBuffer(WebGL.ELEMENT_ARRAY_BUFFER, null);

    _gl.bindBuffer(WebGL.ARRAY_BUFFER, _colorBuffer);
    _gl.bufferData(WebGL.ARRAY_BUFFER, Float32List(30000), WebGL.DYNAMIC_DRAW);
    _gl.bindBuffer(WebGL.ARRAY_BUFFER, null);

    final vertexShader = _gl.createShader(WebGL.VERTEX_SHADER);
    _gl.shaderSource(vertexShader, _vertexShaderSrc);
    _gl.compileShader(vertexShader);

    final fragmentShader = _gl.createShader(WebGL.FRAGMENT_SHADER);
    _gl.shaderSource(fragmentShader, _fragmentShaderSrc);
    _gl.compileShader(fragmentShader);

    final shaderProgram = _gl.createProgram();
    _gl.attachShader(shaderProgram, vertexShader);
    _gl.attachShader(shaderProgram, fragmentShader);
    _gl.linkProgram(shaderProgram);
    _gl.useProgram(shaderProgram);

    _gl.bindBuffer(WebGL.ARRAY_BUFFER, _vertexBuffer);
    _gl.bindBuffer(WebGL.ELEMENT_ARRAY_BUFFER, _indexBuffer);
    final coordinates = _gl.getAttribLocation(shaderProgram, "coordinates");
    _gl.vertexAttribPointer(coordinates, 2, WebGL.FLOAT, false, 0, 0);
    _gl.enableVertexAttribArray(coordinates);

    _gl.bindBuffer(WebGL.ARRAY_BUFFER, _colorBuffer);
    final color = _gl.getAttribLocation(shaderProgram, "color");
    _gl.vertexAttribPointer(color, 3, WebGL.FLOAT, false, 0, 0);
    _gl.enableVertexAttribArray(color);

    output('Welcome to Hyperspace!');
  }

  void mouseDown(MouseEvent mouseEvent) {
    _mousePosition = mouseEvent.client;
    _dragging = true;
  }

  void mouseUp(MouseEvent mouseEvent) {
    _dragging = false;
  }

  void mouseMove(MouseEvent mouseEvent) {
    if (_dragging) {
      final newPosition = mouseEvent.client;
      final diff = newPosition - _mousePosition;
      space.translate(Vector.fromList(space, [diff.x, -diff.y]));
      _mousePosition = newPosition;
    }
  }

  Future run() async => update(await window.animationFrame);

  void update(double delta) {
    final double diff = delta - _lastTimeStamp;
    if (diff >= targetFrameTime) {
      _lastTimeStamp = delta;
      space.update(diff);
      redraw();
    }
    run();
  }

  void redraw() {
    _gl.clear(WebGL.COLOR_BUFFER_BIT);

    for (final object in space.objects) {
      final vertices = object.getVertexList(scaleX: _scaleX, scaleY: _scaleY);
      final indices = object.getVisibleEdgeIndexList();

      /*final colors = List<double>();
      for (int i = 0; i < vertices.length >> 2; ++i) {
        colors.addAll([1.0, 0.0, 0.0]);
      }
      for (int i = 0; i < vertices.length >> 2; ++i) {
        colors.addAll([0.0, 0.0, 1.0]);
      }*/

      final colors = object.getDepthColorList();

      _gl.bindBuffer(WebGL.ARRAY_BUFFER, _vertexBuffer);
      _gl.bufferSubData(WebGL.ARRAY_BUFFER, 0, Float32List.fromList(vertices));
      _gl.bindBuffer(WebGL.ARRAY_BUFFER, _colorBuffer);
      _gl.bufferSubData(WebGL.ARRAY_BUFFER, 0, Float32List.fromList(colors));

      _gl.bufferSubData(WebGL.ELEMENT_ARRAY_BUFFER, 0, Uint16List.fromList(indices));
      _gl.drawElements(WebGL.LINES, indices.length, WebGL.UNSIGNED_SHORT, 0);
    }
  }

/*int _benchmarkRedraw() {
    final stopwatch = Stopwatch();
    stopwatch.start();
    for (int i = 0; i < 1000; ++i) {
      redraw();
    }
    stopwatch.stop();
    return stopwatch.elapsedMilliseconds;
  }*/
}
