/*
 * Copyright (C) 2019 Jeffrey Thomas Piercy
 *
 * This file is part of hyperspace.
 *
 * hyperspace is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * hyperspace is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with hyperspace.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'globals.dart';

class AxisPairMap {
  List<List<double>> pairs =
      List<List<double>>.generate(dimensions, (int index) => index == 0 ? null : List<double>.filled(dimensions, 0.0));

  void set(int xa, int xb, double val) {
    assert(xa != xb);

    if (xa < xb) {
      xa = xa + xb;
      xb = xa - xb;
      xa = xa - xb;
    }

    pairs[xa][xb] = val;
  }

  double get(int xa, int xb) {
    assert(xa != xb);

    if (xa > xb) {
      xa = xa + xb;
      xb = xa - xb;
      xa = xa - xb;
    }

    return pairs[xb][xa];
  }
}
