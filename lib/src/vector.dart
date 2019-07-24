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
