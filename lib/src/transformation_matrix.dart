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

class TransformationMatrix {
  List<Vector> _matrix;

  void _setToZeroMatrix() {
    _matrix = List.generate(dimensions + 1, (int _) => Vector.zeroed());
  }

  void _setToIdentityMatrix() {
    _setToZeroMatrix();
    for (var i = 0; i <= dimensions; ++i) {
      _matrix[i][i] = 1.0;
    }
  }

  TransformationMatrix.identity() {
    _setToIdentityMatrix();
  }

  TransformationMatrix.zero() {
    _setToZeroMatrix();
  }

  TransformationMatrix.rotation(int xa, int xb, double theta, {double scale = 1.0}) {
    if (xa == xb || xa < 0 || xa >= dimensions || xb < 0 || xb >= dimensions) {
      throw ArgumentError();
    }

    _setToIdentityMatrix();
    final cosTheta = scale * cos(theta);
    final sinTheta = scale * sin(theta);
    _matrix[xa][xa] = cosTheta;
    _matrix[xa][xb] = -sinTheta;
    _matrix[xb][xa] = sinTheta;
    _matrix[xb][xb] = cosTheta;
  }

  TransformationMatrix.translation(Vector translation) {
    _setToIdentityMatrix();
    for (int i = 0; i < dimensions; ++i) {
      _matrix[i][dimensions] = translation[i];
    }
  }

  TransformationMatrix.perspective(double distance) {
    _setToZeroMatrix();
    _matrix[0][0] = 1.0;
    _matrix[1][1] = 1.0;
    double homogeneous = -1.0 / distance;
    for (int i = 2; i < dimensions; ++i) {
      _matrix[dimensions][i] = homogeneous;
    }
    _matrix[dimensions][dimensions] = 1.0;
  }

  TransformationMatrix.scale(double scale) {
    _setToZeroMatrix();
    for (int i = 0; i < dimensions; ++i) {
      _matrix[i][i] = scale;
    }
    _matrix[dimensions][dimensions] = 1.0;
  }

  TransformationMatrix.from(TransformationMatrix other) {
    _matrix = List.generate(dimensions + 1, (int index) => Vector.from(other[index]));
  }

  TransformationMatrix addTranslation(Vector translation) {
    TransformationMatrix newTransform = TransformationMatrix.from(this);
    for (int i = 0; i < dimensions; ++i) {
      newTransform[i][dimensions] += translation[i];
    }
    return newTransform;
  }

  Vector transform(Vector vector) {
    final homogeneous = _matrix[dimensions] * vector;
    final newVector = Vector.zeroed();
    for (int i = 0; i < dimensions; ++i) {
      newVector[i] = (_matrix[i] * vector) / homogeneous;
    }
    newVector[dimensions] = 1.0;
    newVector.isVisible = vector.isVisible;
    return newVector;
  }

  Vector operator [](int index) => _matrix[index];

  TransformationMatrix operator *(TransformationMatrix rhs) {
    final newMatrix = TransformationMatrix.zero();
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
