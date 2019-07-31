/*
 * Copyright (C) 2019 Jeffrey Thomas Piercy
 *
 * This file is part of hyperspace.
 *
 * hyperspace is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * hyperspace is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with hyperspace.  If not, see <http://www.gnu.org/licenses/>.
 */

part of hyperspace;

class TransformationMatrix {
  List<Vector> _matrix;
  final Hyperspace _space;

  void _setToZeroMatrix() {
    _matrix = List.generate(_space._dimensions + 1, (int _) => Vector.zeroed(_space));
  }

  void _setToIdentityMatrix() {
    _setToZeroMatrix();
    for (var i = 0; i <= _space._dimensions; ++i) {
      _matrix[i][i] = 1.0;
    }
  }

  TransformationMatrix.identity(this._space) {
    _setToIdentityMatrix();
  }

  TransformationMatrix.zero(this._space) {
    _setToZeroMatrix();
  }

  TransformationMatrix.rotation(this._space, int xa, int xb, double theta, {double scale = 1.0}) {
    if (xa == xb || xa < 0 || xa >= _space._dimensions || xb < 0 || xb >= _space._dimensions) {
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

  TransformationMatrix.translation(this._space, Vector translation) {
    _setToIdentityMatrix();
    for (int i = 0; i < _space._dimensions; ++i) {
      _matrix[i][_space._dimensions] = translation[i];
    }
  }

  TransformationMatrix.perspective(this._space, double distance) {
    _setToZeroMatrix();
    _matrix[0][0] = 1.0;
    _matrix[1][1] = 1.0;
    double homogeneous = -1.0 / distance;
    for (int i = 2; i < _space._dimensions; ++i) {
      _matrix[_space._dimensions][i] = homogeneous;
    }
    _matrix[_space._dimensions][_space._dimensions] = 1.0;
  }

  TransformationMatrix.scale(this._space, double scale) {
    _setToZeroMatrix();
    for (int i = 0; i < _space._dimensions; ++i) {
      _matrix[i][i] = scale;
    }
    _matrix[_space._dimensions][_space._dimensions] = 1.0;
  }

  TransformationMatrix.from(this._space, TransformationMatrix other) {
    _matrix = List.generate(_space._dimensions + 1, (int index) => Vector.from(_space, other[index]));
  }

  TransformationMatrix addTranslation(Vector translation) {
    TransformationMatrix newTransform = TransformationMatrix.from(_space, this);
    for (int i = 0; i < _space._dimensions; ++i) {
      newTransform[i][_space._dimensions] += translation[i];
    }
    return newTransform;
  }

  Vector transform(Vector vector) {
    final homogeneous = _matrix[_space._dimensions] * vector;
    final newVector = Vector.zeroed(_space);
    for (int i = 0; i < _space._dimensions; ++i) {
      newVector[i] = (_matrix[i] * vector) / homogeneous;
    }
    newVector[_space._dimensions] = 1.0;
    newVector.isVisible = vector.isVisible;
    return newVector;
  }

  Vector operator [](int index) => _matrix[index];

  TransformationMatrix operator *(TransformationMatrix rhs) {
    final newMatrix = TransformationMatrix.zero(_space);
    for (int i = 0; i <= _space._dimensions; ++i) {
      for (int k = 0; k <= _space._dimensions; ++k) {
        for (int j = 0; j <= _space._dimensions; ++j) {
          newMatrix[i][j] += _matrix[i][k] * rhs[k][j];
        }
      }
    }
    return newMatrix;
  }

  String toString() {
    var str = '[${_matrix[0]}';
    for (int i = 1; i <= _space._dimensions; ++i) {
      str += '\n ${_matrix[i]}';
    }
    return str + ']';
  }
}
