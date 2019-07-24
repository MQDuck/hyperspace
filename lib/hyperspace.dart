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

class Vector {
  List<double> _coords;

  Vector() {
    _coords = List.filled(dimensions + 1, 0.0);
    _coords[dimensions] = 1.0;
  }

  Vector.filled(double fill) {
    _coords = List.filled(dimensions + 1, fill);
    _coords[dimensions] = 1.0;
  }

  Vector.zero() {
    _coords = List.filled(dimensions + 1, 0.0);
  }

  Vector.from(Vector other) {
    _coords = List.from(other._coords);
  }

  double operator [](int index) => _coords[index];
  void operator []=(int index, double val) => _coords[index] = val;

  double operator *(Vector other) {
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
  List<Vector> _matrix;

  void _setToIdentityMatrix() {
    _matrix = List.generate(dimensions + 1, (int _) => Vector.zero());
    for (var i = 0; i <= dimensions; ++i) {
      _matrix[i][i] = 1.0;
    }
  }

  TransformMatrix.identity() {
    _setToIdentityMatrix();
  }

  TransformMatrix.zero() {
    _matrix = List.generate(dimensions + 1, (int _) => Vector.zero());
  }

  TransformMatrix.rotation(int xa, int xb, double theta) {
    if (xa == xb || xa < 0 || xa >= dimensions || xb < 0 || xb >= dimensions) {
      throw ArgumentError();
    }

    _setToIdentityMatrix();
    final cosTheta = cos(theta);
    final sinTheta = 1 - cosTheta * cosTheta;
    _matrix[xa][xa] = cosTheta;
    _matrix[xa][xb] = -sinTheta;
    _matrix[xb][xa] = sinTheta;
    _matrix[xb][xb] = cosTheta;
  }

  TransformMatrix.translation(Vector translation) {
    _setToIdentityMatrix();
    for (int i = 0; i < dimensions; ++i) {
      _matrix[i][dimensions] = translation[i];
    }
  }

  TransformMatrix.perspective(double distance) {
    _matrix = List.generate(dimensions + 1, (int _) => Vector.zero());
    _matrix[0][0] = 1.0;
    _matrix[1][1] = 1.0;
    double homogeneous = -1.0 / distance;
    for (int i = 2; i < dimensions; ++i) {
      _matrix[dimensions][i] = homogeneous;
    }
    _matrix[dimensions][dimensions] = 1.0;
  }

  TransformMatrix.scale(double scale) {
    _matrix = List.generate(dimensions + 1, (int _) => Vector.zero());
    for (int i = 0; i < dimensions; ++i) {
      _matrix[i][i] = scale;
    }
    _matrix[dimensions][dimensions] = 1.0;
  }

  TransformMatrix.from(TransformMatrix other) {
    _matrix = List.generate(dimensions + 1, (int index) => Vector.from(other[index]));
  }

  TransformMatrix addTranslation(Vector translation) {
    TransformMatrix newTransform = TransformMatrix.from(this);
    for (int i = 0; i < dimensions; ++i) {
      newTransform[i][dimensions] += translation[i];
    }
    return newTransform;
  }

  Vector transform(Vector vector) {
    final homogeneous = _matrix[dimensions] * vector;
    final newVector = Vector.zero();
    for (int i = 0; i < dimensions; ++i) {
      newVector[i] = (_matrix[i] * vector) / homogeneous;
    }
    newVector[dimensions] = 1.0;
    return newVector;
  }

  Vector operator [](int index) => _matrix[index];

  TransformMatrix operator *(TransformMatrix rhs) {
    final newMatrix = TransformMatrix.zero();
    for (int i = 0; i <= dimensions; ++i) {
      for (int k = 0; k <= dimensions; ++k) {
        for (int j = 0; j <= dimensions; ++j) {
          newMatrix[i][j] += _matrix[i][k] * rhs[k][j];
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

class _EdgeIndices {
  final int a, b;

  _EdgeIndices(int this.a, int this.b);
}

class Edge {
  final Vector a, b;

  Edge(Vector this.a, Vector this.b);
}

class HSObject {
  static var _perspectiveMatrix = TransformMatrix.perspective(1000.0);
  static var usePerspective = true;

  List<Vector> _vertices = [];
  List<Vector> _drawVertices;
  List<_EdgeIndices> _edges = [];
  Vector _translation = Vector.zero();

  static setPerspective(double distance) => _perspectiveMatrix = TransformMatrix.perspective(distance);

  HSObject.hypercube(final length) {
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

    _drawVertices = List<Vector>(_vertices.length);
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
      _drawVertices[i] = transformation.transform(_vertices[i]);
    }
  }

  int numEdges() => _edges.length;

  Edge operator [](int index) => Edge(_drawVertices[_edges[index].a], _drawVertices[_edges[index].b]);
}

void main() {
  var foo = TransformMatrix.rotation(0, 1, pi);
  final v = Vector();
  v[0] = 1;
  v[1] = 1;
  final u = foo.transform(v);
  print(u);
}
