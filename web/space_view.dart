import 'dart:async';
import 'dart:html';
import 'dart:typed_data';
import 'dart:web_gl';

import 'package:hyperspace/hyperspace.dart';

class SpaceView {
  final Hyperspace space;
  final CanvasElement canvas;
  final RenderingContext gl;
  final Function(String) output;
  int targetFrameTime = 27; // TODO: modify this based on user's device type (PC, mobile, etc.).
  double _lastTimeStamp = 0.0;
  int _frameCounter = 80;
  var _dragging = false;
  Point<num> mousePosition;
  double scaleX, scaleY;
  final Program program;
  final Buffer _vertexBuffer, _indexBuffer;

  static _nullOutput(String _) => {};

  static const _vertexShaderSrc = """
attribute vec2 coordinates;

void main() {
  gl_Position = vec4(coordinates, 0.0, 1.0);
}
""";

  static const _fragmentShaderSrc = """
precision mediump float;

void main() {
  gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
}
""";

  SpaceView(int dimensions, double viewerDistance, double spaceDistance, this.canvas, this.gl,
      {this.output = _nullOutput})
      : space = Hyperspace(dimensions),
        program = gl.createProgram(),
        _vertexBuffer = gl.createBuffer(),
        _indexBuffer = gl.createBuffer() {
    space.setViewerPosition(0.0, 0.0, viewerDistance);
    space.setHyperdimensionDistance(spaceDistance);

    scaleX = 1.0 / (canvas.width >> 1);
    scaleY = 1.0 / (canvas.height >> 1);

    canvas.addEventListener('mousedown', (e) => mouseDown(e as MouseEvent));
    canvas.addEventListener('mouseup', (e) => mouseUp(e as MouseEvent));
    canvas.addEventListener('mouseout', (e) => mouseUp(e as MouseEvent));
    canvas.addEventListener('mousemove', (e) => mouseMove(e as MouseEvent));

    gl.clearColor(0.0, 0.0, 0.0, 1.0);
    gl.viewport(0, 0, canvas.width, canvas.height);

    gl.bindBuffer(WebGL.ARRAY_BUFFER, _vertexBuffer);
    gl.bufferData(WebGL.ARRAY_BUFFER, Float32List(10000), WebGL.DYNAMIC_DRAW);
    gl.bindBuffer(WebGL.ARRAY_BUFFER, null);

    gl.bindBuffer(WebGL.ELEMENT_ARRAY_BUFFER, _indexBuffer);
    gl.bufferData(WebGL.ELEMENT_ARRAY_BUFFER, Uint16List(10000), WebGL.DYNAMIC_DRAW);
    gl.bindBuffer(WebGL.ELEMENT_ARRAY_BUFFER, null);

    final vertexShader = gl.createShader(WebGL.VERTEX_SHADER);
    gl.shaderSource(vertexShader, _vertexShaderSrc);
    gl.compileShader(vertexShader);

    final fragmentShader = gl.createShader(WebGL.FRAGMENT_SHADER);
    gl.shaderSource(fragmentShader, _fragmentShaderSrc);
    gl.compileShader(fragmentShader);

    final shaderProgram = gl.createProgram();
    gl.attachShader(shaderProgram, vertexShader);
    gl.attachShader(shaderProgram, fragmentShader);
    gl.linkProgram(shaderProgram);
    gl.useProgram(shaderProgram);

    gl.bindBuffer(WebGL.ARRAY_BUFFER, _vertexBuffer);
    gl.bindBuffer(WebGL.ELEMENT_ARRAY_BUFFER, _indexBuffer);
    final coordinates = gl.getAttribLocation(shaderProgram, "coordinates");
    gl.vertexAttribPointer(coordinates, 2, WebGL.FLOAT, false, 0, 0);
    gl.enableVertexAttribArray(coordinates);

    output('Welcome to Hyperspace!');
  }

  void mouseDown(MouseEvent mouseEvent) {
    mousePosition = mouseEvent.client;
    _dragging = true;
  }

  void mouseUp(MouseEvent mouseEvent) {
    _dragging = false;
  }

  void mouseMove(MouseEvent mouseEvent) {
    if (_dragging) {
      final newPosition = mouseEvent.client;
      final diff = newPosition - mousePosition;
      space.translate(Vector.fromList(space, [diff.x, -diff.y]));
      mousePosition = newPosition;
    }
  }

  Future run() async => update(await window.animationFrame);

  void update(double delta) {
    final double diff = delta - _lastTimeStamp;
    if (diff >= targetFrameTime) {
      _lastTimeStamp = delta;
      space.update(diff);
      redraw();
      if (_frameCounter == 10000) {
        output('${1000.0 / diff} FPS');
//      output('diff = $diff');
        _frameCounter = 0;
      }
    }
    run();
  }

  redraw() {
    // TODO: support multiple objects
    final vertices = List<double>();
    final indices = List<int>();
    for (final object in space.objects) {
      vertices.addAll(object.getVertexArray(scaleX: scaleX, scaleY: scaleY));
      indices.addAll(object.getVisibleEdgeIndexArray());
    }

    gl.clear(WebGL.COLOR_BUFFER_BIT);
    gl.bufferSubData(WebGL.ARRAY_BUFFER, 0, Float32List.fromList(vertices));
    gl.bufferSubData(WebGL.ELEMENT_ARRAY_BUFFER, 0, Uint16List.fromList(indices));
    gl.drawElements(WebGL.LINES, indices.length, WebGL.UNSIGNED_SHORT, 0);

    output('redraw');
  }
}
