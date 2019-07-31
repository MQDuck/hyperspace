/*
 * Copyright (C) 2019 Jeffrey Thomas Piercy
 *
 * This file is part of hyperspace.
 *
 * hyperspace is free software: you can redistribute it and/or modify
 * it under the terms of the GNU LesserGeneral Public License as published by
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

class Vector {
  List<double> _coords;
  bool isVisible = false;
  final Hyperspace space;

  Vector(this.space) {
    _coords = List.filled(space._dimensions + 1, 0.0);
    _coords[space._dimensions] = 1.0;
  }

  Vector.filled(this.space, double fill) {
    _coords = List.filled(space._dimensions + 1, fill);
    _coords[space._dimensions] = 1.0;
  }

  Vector.zeroed(this.space) {
    _coords = List.filled(space._dimensions + 1, 0.0);
  }

  Vector._nulled(this.space) {
    _coords = List<double>(space._dimensions + 1);
  }

  Vector.from(this.space, Vector other) {
    _coords = List.from(other._coords);
  }

  Vector.fromList(this.space, List<double> list) {
    if (list.length == space._dimensions + 1) {
      _coords = List.from(list);
    } else if (list.length <= space._dimensions) {
      _coords = List<double>.filled(space._dimensions + 1, 0.0);
      for (int xi = 0; xi < list.length; ++xi) {
        _coords[xi] = list[xi];
      }
      _coords[space._dimensions] = 1.0;
    } else {
      throw ArgumentError();
    }
  }

  double operator [](int index) => _coords[index];
  void operator []=(int index, double val) => _coords[index] = val;

  Vector operator +(Vector rhs) {
    final sum = Vector._nulled(space);
    for (int i = 0; i < space._dimensions; ++i) {
      sum[i] = _coords[i] + rhs[i];
    }
    sum[space._dimensions] = 1.0;
    return sum;
  }

  Vector operator -(Vector rhs) {
    final difference = Vector._nulled(space);
    for (int i = 0; i < space._dimensions; ++i) {
      difference[i] = _coords[i] - rhs[i];
    }
    difference[space._dimensions] = 1.0;
    return difference;
  }

  void setVisible() {
    isVisible = true;
    for (int i = 2; i < space._dimensions; ++i) {
      if (_coords[i] < 0.0) {
        isVisible = false;
        return;
      }
    }
  }

  double operator *(Vector other) {
    var product = 0.0;
    for (int i = 0; i <= space._dimensions; ++i) {
      product += _coords[i] * other[i];
    }
    return product;
  }

  double get x => _coords[0];

  double get y => _coords[1];

  double get z => _coords[2];

  String toString() {
    return _coords.toString();
  }
}
