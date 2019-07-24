/*
 * Copyright (C) 2019 Jeffrey Thomas Piercy
 *
 * This file is part of Hyperspace-Dart.
 *
 * Deuce-Android is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Deuce-Android is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Deuce-Android.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:math';

var dimensions = 4;

class Vertex {
  List<double> _coords;

  Vertex() {
    _coords = List.filled(dimensions + 1, 0.0);
    _coords[dimensions] = 1.0;
  }

  Vertex.filled(double fill) {
    _coords = List.filled(dimensions + 1, fill);
    _coords[dimensions] = 1.0;
  }

  Vertex.zero() {
    _coords = List.filled(dimensions + 1, 0.0);
  }

  Vertex.from(Vertex other) {
    _coords = List.from(other._coords);
  }

  double operator [](int index) => _coords[index];
  void operator []=(int index, double val) => _coords[index] = val;

  double operator *(Vertex other) {
    var product = 0.0;
    for (int i = 0; i <= dimensions; ++i) {
      product += _coords[i] * other[i];
    }
    return product;
  }

  String toString() {
    return _coords.toString();
  }
}

class TransformMatrix {
  List<Vertex> _matrix;

  void _setToIdentityMatrix() {
    _matrix = List.generate(dimensions + 1, (int _) => Vertex.zero());
    for (var i = 0; i <= dimensions; ++i) {
      _matrix[i][i] = 1.0;
    }
  }

  TransformMatrix.identity() {
    _setToIdentityMatrix();
  }

  TransformMatrix.zero() {
    _matrix = List.generate(dimensions + 1, (int _) => Vertex.zero());
  }

  TransformMatrix.rotation(int xa, int xb, double theta) {
    if (xa == xb) {
      throw ArgumentError();
    }

    _setToIdentityMatrix();
    final cosTheta = cos(theta);
    final sinTheta = sin(theta);
    _matrix[xa][xa] = cosTheta;
    _matrix[xa][xb] = -sinTheta;
    _matrix[xb][xa] = sinTheta;
    _matrix[xb][xb] = cosTheta;
  }

  TransformMatrix.translation(Vertex translation) {
    _setToIdentityMatrix();
    for (int i = 0; i < dimensions; ++i) {
      _matrix[i][dimensions] = translation[i];
    }
  }

  Vertex transform(Vertex vertex) {
    final newVertex = Vertex.zero();
    for (int i = 0; i <= dimensions; ++i) {
      newVertex[i] = _matrix[i] * vertex;
    }
    return newVertex;
  }

  Vertex operator [](int index) => _matrix[index];

  TransformMatrix operator *(TransformMatrix other) {
    final newMatrix = TransformMatrix.zero();
    for (int i = 0; i <= dimensions; ++i) {
      for (int k = 0; k <= dimensions; ++k) {
        for (int j = 0; j <= dimensions; ++j) {
          newMatrix[i][j] += _matrix[i][k] * other[k][j];
        }
      }
    }
    return newMatrix;
  }

  String toString() {
    var str = '[${_matrix[0]}';
    for (int i = 1; i <= dimensions; ++i) {
      str += '\n ${_matrix[i]}';
    }
    return str + ']';
  }
}

class _Edge {
  final int a, b;
  _Edge(int this.a, int this.b);
}

class HSObject {
  List<Vertex> vertices = [];
  List<_Edge> edges = [];

  HSObject.hypercube(final length) {
    var vertex = Vertex.filled(-length / 2.0);
    vertex[dimensions] = 1.0;
    vertices.add(vertex);

    for (int dim = 0; dim < dimensions; ++dim) {
      final numVertices = vertices.length;
      final numEdges = edges.length;

      for (int i = 0; i < numEdges; ++i) {
        edges.add(_Edge(edges[i].a + numVertices, edges[i].b + numVertices));
      }

      for (int i = 0; i < numVertices; ++i) {
        edges.add(_Edge(i, vertices.length));
        vertex = Vertex.from(vertices[i]);
        vertex[dim] += length;
        vertices.add(vertex);
      }
    }
  }
}

void main() {
  var foo = TransformMatrix.rotation(0, 1, pi);
  final v = Vertex();
  v[0] = 1;
  v[1] = 1;
  final u = foo.transform(v);
  print(u);
}
