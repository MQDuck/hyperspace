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

  double operator [](int i) => _coords[i];
  void operator []=(int i, double val) => _coords[i] = val;

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
  List<Vertex> matrix;

  void _setToIdentityMatrix() {
    matrix = List.generate(dimensions + 1, (int _) => Vertex.zero());
    for (var i = 0; i <= dimensions; ++i) {
      matrix[i][i] = 1.0;
    }
  }

  TransformMatrix.identity() {
    _setToIdentityMatrix();
  }

  TransformMatrix.rotation(int xa, int xb, double theta) {
    if (xa == xb) {
      throw ArgumentError();
    }

    _setToIdentityMatrix();
    final cosTheta = cos(theta);
    final sinTheta = sin(theta);
    matrix[xa][xa] = cosTheta;
    matrix[xa][xb] = -sinTheta;
    matrix[xb][xa] = sinTheta;
    matrix[xb][xb] = cosTheta;
  }

  TransformMatrix.translation(List<double> translation) {
    assert(translation.length == dimensions + 1 || translation.length == dimensions);

    _setToIdentityMatrix();
    for (int i = 0; i < dimensions; ++i) {
      matrix[i][dimensions] = translation[i];
    }
  }

  List<double> transform(List<double> vector) {
    assert(vector.length == dimensions + 1);

    final newVec = List.filled(dimensions + 1, 0.0);
    for (int i = 0; i <= dimensions; ++i) {
      for (int j = 0; j <= dimensions; ++j) {
        newVec[i] += matrix[i][j] * vector[j];
      }
    }
    return newVec;
  }

  Vertex operator *(Vertex vertex) {
    final newVertex = Vertex.zero();
    for (int i = 0; i <= dimensions; ++i) {
      newVertex[i] = matrix[i] * vertex;
    }
    return newVertex;
  }

  String toString() {
    var str = '[${matrix[0]}';
    for (int i = 1; i <= dimensions; ++i) {
      str += '\n ${matrix[i]}';
    }
    return str + ']';
  }
}

class _Edge {
  final a, b;
  _Edge(this.a, this.b);
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

  void rotate(int xa, int xb, double theta) {

  }
}

void main() {
  var foo = TransformMatrix.rotation(0, 1, pi);
  final v = Vertex();
  v[0] = 1;
  v[1] = 1;
  print(foo.transform([1, 1, 1, 1, 1]));
  final u = foo * v;
  print(u);
}
