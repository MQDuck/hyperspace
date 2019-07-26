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

class _EdgeIndices {
  int a, b;

  _EdgeIndices(this.a, this.b);

  String toString() {
    return '$a-$b';
  }
}

class Edge {
  Vector a, b;

  Edge(this.a, this.b);

  String toString() {
    return '$a --- $b';
  }
}

class HyperObject {
  List<Vector> _vertices;
  List<Vector> _drawingVertices;
  List<_EdgeIndices> _edges;
  Vector _translation;
  final _rotations;
  final _rotation_velocities;
  final Hyperspace space;

  HyperObject.hypercube(this.space, final length)
      : _translation = Vector(space),
        _rotations = AxisPairMap(space),
        _rotation_velocities = AxisPairMap(space) {
    _vertices = List<Vector>(1 << space._dimensions);
    _drawingVertices = List<Vector>(_vertices.length);
    _edges = List<_EdgeIndices>(space._dimensions * (1 << (space._dimensions - 1)));

    var vertex = Vector.filled(space, -length / 2.0);
    vertex[space._dimensions] = 1.0;
    _vertices[0] = vertex;

    var vi = 1;
    var ei = 0;

    for (int dim = 0; dim < space._dimensions; ++dim) {
      final numVertices = vi;
      final numEdges = ei;

      for (int i = 0; i < numEdges; ++i) {
        _edges[ei] = _EdgeIndices(_edges[i].a + numVertices, _edges[i].b + numVertices);
        ++ei;
      }

      for (int i = 0; i < numVertices; ++i) {
        _edges[ei] = _EdgeIndices(i, vi);
        ++ei;
        vertex = Vector.from(space, _vertices[i]);
        vertex[dim] += length;
        _vertices[vi] = vertex;
        ++vi;
      }
    }
  }

  void translate(Vector translation) => _translation += translation;

  void translateFromList(List<double> translation) => _translation += Vector.fromList(space, translation);

  void setRotationVelocity(int xa, int xb, double theta) => _rotation_velocities.set(xa, xb, theta);

  void _update(double time) {
    var drawMatrix = TransformationMatrix.identity(space);
    for (int xa = 0; xa < space._dimensions - 1; ++xa) {
      for (int xb = xa + 1; xb < space._dimensions; ++xb) {
        final theta = _rotations.get(xa, xb) + _rotation_velocities.get(xa, xb) * time;
        _rotations.set(xa, xb, theta);
        drawMatrix = TransformationMatrix.rotation(space, xa, xb, theta) * drawMatrix;
      }
    }
    drawMatrix = TransformationMatrix.translation(space, _translation + space._globalTranslation) * drawMatrix;

    for (int i = 0; i < _vertices.length; ++i) {
      var vertex = drawMatrix.transform(_vertices[i]);
      vertex.setVisible();
      if (vertex.isVisible && space.usePerspective) {
        vertex = space._perspectiveMatrix.transform(vertex);
      }
      _drawingVertices[i] = vertex;
    }
  }

  int get length => _edges.length;

  Edge operator [](int index) => Edge(_drawingVertices[_edges[index].a], _drawingVertices[_edges[index].b]);
}
