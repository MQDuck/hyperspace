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

part of hyperspace;

class TransformationMatrix {
  List<Vector> _matrix;
  final Hyperspace space;

  void _setToZeroMatrix() {
    _matrix = List.generate(space._dimensions + 1, (int _) => Vector.zeroed(space));
  }

  void _setToIdentityMatrix() {
    _setToZeroMatrix();
    for (var i = 0; i <= space._dimensions; ++i) {
      _matrix[i][i] = 1.0;
    }
  }

  TransformationMatrix.identity(this.space) {
    _setToIdentityMatrix();
  }

  TransformationMatrix.zero(this.space) {
    _setToZeroMatrix();
  }

  TransformationMatrix.rotation(this.space, int xa, int xb, double theta, {double scale = 1.0}) {
    if (xa == xb || xa < 0 || xa >= space._dimensions || xb < 0 || xb >= space._dimensions) {
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

  TransformationMatrix.translation(this.space, Vector translation) {
    _setToIdentityMatrix();
    for (int i = 0; i < space._dimensions; ++i) {
      _matrix[i][space._dimensions] = translation[i];
    }
  }

  TransformationMatrix.perspective(this.space, double distance) {
    _setToZeroMatrix();
    _matrix[0][0] = 1.0;
    _matrix[1][1] = 1.0;
    double homogeneous = -1.0 / distance;
    for (int i = 2; i < space._dimensions; ++i) {
      _matrix[space._dimensions][i] = homogeneous;
    }
    _matrix[space._dimensions][space._dimensions] = 1.0;
  }

  TransformationMatrix.scale(this.space, double scale) {
    _setToZeroMatrix();
    for (int i = 0; i < space._dimensions; ++i) {
      _matrix[i][i] = scale;
    }
    _matrix[space._dimensions][space._dimensions] = 1.0;
  }

  TransformationMatrix.from(this.space, TransformationMatrix other) {
    _matrix = List.generate(space._dimensions + 1, (int index) => Vector.from(space, other[index]));
  }

  TransformationMatrix addTranslation(Vector translation) {
    TransformationMatrix newTransform = TransformationMatrix.from(space, this);
    for (int i = 0; i < space._dimensions; ++i) {
      newTransform[i][space._dimensions] += translation[i];
    }
    return newTransform;
  }

  Vector transform(Vector vector) {
    final homogeneous = _matrix[space._dimensions] * vector;
    final newVector = Vector.zeroed(space);
    for (int i = 0; i < space._dimensions; ++i) {
      newVector[i] = (_matrix[i] * vector) / homogeneous;
    }
    newVector[space._dimensions] = 1.0;
    newVector.isVisible = vector.isVisible;
    return newVector;
  }

  Vector operator [](int index) => _matrix[index];

  TransformationMatrix operator *(TransformationMatrix rhs) {
    final newMatrix = TransformationMatrix.zero(space);
    for (int i = 0; i <= space._dimensions; ++i) {
      for (int k = 0; k <= space._dimensions; ++k) {
        for (int j = 0; j <= space._dimensions; ++j) {
          newMatrix[i][j] += _matrix[i][k] * rhs[k][j];
        }
      }
    }
    return newMatrix;
  }

  String toString() {
    var str = '[${_matrix[0]}';
    for (int i = 1; i <= space._dimensions; ++i) {
      str += '\n ${_matrix[i]}';
    }
    return str + ']';
  }
}
