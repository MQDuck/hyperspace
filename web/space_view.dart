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
  final Buffer vbo;

  static _nullOutput(String _) => {};

  static const _vertexShaderSrc = """
attribute vec2 position;

void main() {
  gl_Position = vec4(position, 0.0, 1.0);
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
        vbo = gl.createBuffer() {
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

    // Compile shaders and link
    final Shader vs = gl.createShader(WebGL.VERTEX_SHADER);
    gl.shaderSource(vs, _vertexShaderSrc);
    gl.compileShader(vs);

    Shader fs = gl.createShader(WebGL.FRAGMENT_SHADER);
    gl.shaderSource(fs, _fragmentShaderSrc);
    gl.compileShader(fs);

    gl.attachShader(program, vs);
    gl.attachShader(program, fs);
    gl.linkProgram(program);
    gl.useProgram(program);

    // Check if shaders were compiled properly
    if (!gl.getShaderParameter(vs, WebGL.COMPILE_STATUS)) {
      output(gl.getShaderInfoLog(vs));
    }

    if (!gl.getShaderParameter(fs, WebGL.COMPILE_STATUS)) {
      output(gl.getShaderInfoLog(fs));
    }

    if (!gl.getProgramParameter(program, WebGL.LINK_STATUS)) {
      output(gl.getProgramInfoLog(program));
    }

    if (gl == null) {
      output("Your browser doesn't seem to support WebGL.");
      return;
    }

    gl.bindBuffer(WebGL.ARRAY_BUFFER, vbo);
    gl.bufferData(
        WebGL.ARRAY_BUFFER, Float32List(10000), WebGL.DYNAMIC_DRAW); // TODO: Don't just pass a really big list

    int posAttrib = gl.getAttribLocation(program, "position");
    gl.enableVertexAttribArray(0);
    gl.vertexAttribPointer(posAttrib, 2, WebGL.FLOAT, false, 0, 0);

    output('Welcome to Hyperspace!');
  }

  void mouseDown(MouseEvent mouseEvent) {
//    output('${mouseEvent.client.x}, ${mouseEvent.client.y}');
    mousePosition = mouseEvent.client;
    _dragging = true;
  }

  void mouseUp(MouseEvent mouseEvent) {
//    output('${mouseEvent.client.x}, ${mouseEvent.client.y}');
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
    final vertices = List<double>();
    for (final object in space.objects) {
      for (int i = 0; i < object.length; ++i) {
        final edge = object[i];
        if (edge.a.isVisible && edge.b.isVisible) {
          vertices.addAll([edge.a.x * scaleX, edge.a.y * scaleY, edge.b.x * scaleX, edge.b.y * scaleY]);
        }
      }
    }

    gl.clear(WebGL.COLOR_BUFFER_BIT);
    gl.bufferSubData(WebGL.ARRAY_BUFFER, 0, Float32List.fromList(vertices));
    gl.drawArrays(WebGL.LINES, 0, vertices.length >> 1);
  }
}
