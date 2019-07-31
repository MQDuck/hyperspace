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

class _AxisPairMap {
  final List<List<double>> _pairs;
  final Hyperspace _space;

  _AxisPairMap(this._space)
      : _pairs = List<List<double>>.generate(
      _space._dimensions, (int index) => index == 0 ? null : List<double>.filled(index, 0.0));

  void set(int xa, int xb, double val) {
    assert(xa != xb);

    if (xa < xb) {
      xa = xa + xb;
      xb = xa - xb;
      xa = xa - xb;
    }

    _pairs[xa][xb] = val;
  }

  double get(int xa, int xb) {
    assert(xa != xb);

    if (xa > xb) {
      xa = xa + xb;
      xb = xa - xb;
      xa = xa - xb;
    }

    return _pairs[xb][xa];
  }
}
