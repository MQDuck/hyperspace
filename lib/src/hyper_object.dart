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

import 'globals.dart';
import 'transform_matrix.dart';
import 'vector.dart';

class _EdgeIndices {
  int a, b;

  _EdgeIndices(int this.a, int this.b);
}

class Edge {
  Vector a, b;

  Edge(Vector this.a, Vector this.b);
}

class HyperObject {
  static var _perspectiveMatrix = TransformMatrix.perspective(1000.0);
  static var usePerspective = true;

  List<Vector> _vertices = [];
  List<Vector> _drawingVertices;
  List<_EdgeIndices> _edges = [];
  Vector _translation = Vector.zero();

  static setPerspective(double distance) => _perspectiveMatrix = TransformMatrix.perspective(distance);

  HyperObject.hypercube(final length) {
    var vertex = Vector.filled(-length / 2.0);
    vertex[dimensions] = 1.0;
    _vertices.add(vertex);

    for (int dim = 0; dim < dimensions; ++dim) {
      final numVertices = _vertices.length;
      final numEdges = _edges.length;

      for (int i = 0; i < numEdges; ++i) {
        _edges.add(_EdgeIndices(_edges[i].a + numVertices, _edges[i].b + numVertices));
      }

      for (int i = 0; i < numVertices; ++i) {
        _edges.add(_EdgeIndices(i, _vertices.length));
        vertex = Vector.from(_vertices[i]);
        vertex[dim] += length;
        _vertices.add(vertex);
      }
    }

    _drawingVertices = List<Vector>(_vertices.length);
  }

  void update() {
    // TODO: Do rotations and whatever on _vertices here

    TransformMatrix transformation;
    if (usePerspective) {
      transformation = TransformMatrix.translation(_translation) * _perspectiveMatrix;
    } else {
      transformation = TransformMatrix.translation(_translation);
    }

    for (int i = 0; i < _vertices.length; ++i) {
      _drawingVertices[i] = transformation.transform(_vertices[i]);
    }
  }

  int get length => _edges.length;

  Edge operator [](int index) => Edge(_drawingVertices[_edges[index].a], _drawingVertices[_edges[index].b]);

  void __rotate(int xa, int xb, double theta) {
    final rotation = TransformMatrix.rotation(xa, xb, theta);
    for (int i = 0; i < _vertices.length; ++i) {
      _vertices[i] = rotation.transform(_vertices[i]);
    }
  }
}

void main() {
  const pi = 3.141592653589793;
//  var foo = TransformMatrix.rotation(0, 1, 3.141592653589793);
//  final v = Vector();
//  v[0] = 1;
//  v[1] = 1;
//  final u = foo.transform(v);
//  print(u);

  final square = HyperObject.hypercube(100);
  print(square._vertices);
  square.__rotate(0, 1, pi / 4);
  print(square._vertices);
  print(square._edges);
}
