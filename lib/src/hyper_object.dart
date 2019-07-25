/*
 * Copyright (C) 2019 Jeffrey Thomas Piercy
 *
 * This file is part of Hyperspace-Dart.
 *
 * Hyperspace-Dart is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Hyperspace-Dart is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Hyperspace-Dart.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'axis_pair_map.dart';
import 'globals.dart';
import 'transformation_matrix.dart';
import 'vector.dart';

class _EdgeIndices {
  int a, b;

  _EdgeIndices(this.a, this.b);

  String toString() {
    return '$a-$b';
  }
}

class Edge {
  Vector a, b;

  Edge(this.a, this.b);
}

class HyperObject {
  static var _perspectiveMatrix = TransformationMatrix.perspective(1000.0);
  static var usePerspective = true;
  static var _globalTranslation = Vector();

  List<Vector> _vertices;
  List<Vector> _drawingVertices;
  List<_EdgeIndices> _edges;
  Vector _translation = Vector.zeroed();
  final _rotations = AxisPairMap();

  static setPerspective(double distance) => _perspectiveMatrix = TransformationMatrix.perspective(distance);

  HyperObject.hypercube(final length) {
    _vertices = List<Vector>(1 << dimensions);
    _drawingVertices = List<Vector>(_vertices.length);
    _edges = List<_EdgeIndices>(dimensions * (1 << (dimensions - 1)));

    var vertex = Vector.filled(-length / 2.0);
    vertex[dimensions] = 1.0;
    _vertices[0] = vertex;

    var vi = 1;
    var ei = 0;

    for (int dim = 0; dim < dimensions; ++dim) {
      final numVertices = vi;
      final numEdges = ei;

      for (int i = 0; i < numEdges; ++i) {
        _edges[ei] = _EdgeIndices(_edges[i].a + numVertices, _edges[i].b + numVertices);
        ++ei;
      }

      for (int i = 0; i < numVertices; ++i) {
        _edges[ei] = _EdgeIndices(i, vi);
        ++ei;
        vertex = Vector.from(_vertices[i]);
        vertex[dim] += length;
        _vertices[vi] = vertex;
        ++vi;
      }
    }
  }

  void translate(Vector translation) => _translation += translation;

  void setRotation(int xa, int xb, double theta) => _rotations.set(xa, xb, theta);

  static void setDisplayCenter(double x, double y) {
    final center = Vector();
    center[0] = x;
    center[1] = y;
    _globalTranslation = center;
  }

  void update(int time) {
    var movement = TransformationMatrix.identity();
    for (int xa = 0; xa < dimensions - 1; ++xa) {
      for (int xb = xa + 1; xb < dimensions; ++xb) {
        movement = TransformationMatrix.rotation(xa, xb, _rotations.get(xb, xa) * time) * movement;
      }
    }

    for (int i = 0; i < _vertices.length; ++i) {
      _vertices[i] = movement.transform(_vertices[i]);
    }

    var drawTransform = TransformationMatrix.translation(_translation + _globalTranslation);
    if (usePerspective) {
      drawTransform = drawTransform * _perspectiveMatrix;
    }
    for (int i = 0; i < _vertices.length; ++i) {
      final drawingVertex = drawTransform.transform(_vertices[i]);
      drawingVertex.setHidden();
      _drawingVertices[i] = drawingVertex;
    }
  }

  int get length => _edges.length;

  Edge operator [](int index) => Edge(_drawingVertices[_edges[index].a], _drawingVertices[_edges[index].b]);
}

void main() {
  const pi = 3.141592653589793;
}
