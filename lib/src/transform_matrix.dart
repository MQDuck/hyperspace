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

import 'dart:math';

import 'globals.dart';
import 'vector.dart';

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
    final sinTheta = sin(theta);
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
