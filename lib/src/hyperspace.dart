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

class Hyperspace {
  final List<HyperObject> objects = [];
  TransformationMatrix _perspectiveMatrix;
  Vector _globalTranslation;
  var _dimensions = 4;
  var usePerspective = true;

  Hyperspace(this._dimensions) {
    _perspectiveMatrix = TransformationMatrix.identity(this);
    _globalTranslation = Vector(this);
  }

  void setViewerPosition(double x, double y, double other) {
    final displayTranslation = Vector(this);
    displayTranslation[0] = x;
    displayTranslation[1] = y;
    _perspectiveMatrix =
        TransformationMatrix.translation(this, displayTranslation) * TransformationMatrix.perspective(this, other);
  }

  void setHyperdimensionDistance(double distance) {
    for (int i = 2; i < _dimensions; ++i) {
      _globalTranslation[i] = distance;
    }
  }

  void update(double time) {
    for (final object in objects) {
      object._update(time);
    }
  }

  HyperObject addHypercube(final double length) {
    final cube = HyperObject.hypercube(this, length);
    objects.add(cube);
    return cube;
  }

  HyperObject addHypersphere(final double radius, final int precision) {
    final sphere = HyperObject.hypersphere(this, radius, precision);
    objects.add(sphere);
    return sphere;
  }

  void translate(Vector translation) => _globalTranslation += translation;
}
