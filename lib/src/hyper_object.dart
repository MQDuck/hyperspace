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

enum HyperObjectType { hypercube, hypersphere }

class HyperObject {
  final List<Vector> _vertices;
  final List<Vector> _positionVertices;
  final List<Vector> _drawingVertices;
  final List<_EdgeIndices> _edges;
  Vector _translation;
  final _rotations;
  final _rotation_velocities;
  final Hyperspace space;
  final HyperObjectType type;

  HyperObject.hypercube(this.space, final double length)
      : _translation = Vector(space),
        _rotations = AxisPairMap(space),
        _rotation_velocities = AxisPairMap(space),
        _vertices = List<Vector>(1 << space._dimensions),
        _positionVertices = List<Vector>(1 << space._dimensions),
        _drawingVertices = List<Vector>(1 << space._dimensions),
        _edges = List<_EdgeIndices>(space._dimensions * (1 << (space._dimensions - 1))),
        type = HyperObjectType.hypercube {
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

  HyperObject.hypersphere(this.space, final double radius, final int precision)
      : _translation = Vector(space),
        _rotations = AxisPairMap(space),
        _rotation_velocities = AxisPairMap(space),
        _vertices = List<Vector>(((space._dimensions * (space._dimensions - 1)) >> 1) * precision),
        _positionVertices = List<Vector>(((space._dimensions * (space._dimensions - 1)) >> 1) * precision),
        _drawingVertices = List<Vector>(((space._dimensions * (space._dimensions - 1)) >> 1) * precision),
        _edges = List<_EdgeIndices>(((space._dimensions * (space._dimensions - 1)) >> 1) * precision),
        type = HyperObjectType.hypersphere {
    final delta = 2.0 * pi / precision;
    int vi = 0;
    int ei = 0;
    for (int xa = 0; xa < space._dimensions - 1; ++xa) {
      for (int xb = xa + 1; xb < space._dimensions; ++xb) {
        for (int k = 0; k < precision; ++k) {
          final vertex = Vector(space);
          vertex[xa] = cos(k * delta) * radius;
          vertex[xb] = sin(k * delta) * radius;
          _vertices[vi] = vertex;
          ++vi;
          if (k == precision - 1) {
            _edges[ei] = _EdgeIndices(vi - precision, vi - 1);
            ++ei;
          } else {
            _edges[ei] = _EdgeIndices(vi - 1, vi);
            ++ei;
          }
        }
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
      _positionVertices[i] = vertex;
      if (vertex.isVisible && space.usePerspective) {
        _drawingVertices[i] = space._perspectiveMatrix.transform(vertex);
      } else {
        _drawingVertices[i] = vertex;
      }
    }
  }

  List<double> getVertexList({final scaleX = 1.0, final scaleY = 1.0}) {
    final vertexList = List<double>(_drawingVertices.length << 1);
    for (int i = 0; i < _drawingVertices.length; ++i) {
      vertexList[i << 1] = scaleX * _drawingVertices[i].x;
      vertexList[(i << 1) + 1] = scaleY * _drawingVertices[i].y;
    }
    return vertexList;
  }

  List<int> getVisibleEdgeIndexList() {
    final edgeList = List<int>();
    for (final edge in _edges) {
      if (_drawingVertices[edge.a].isVisible && _drawingVertices[edge.b].isVisible) {
        edgeList.add(edge.a);
        edgeList.add(edge.b);
      }
    }
    return edgeList;
  }

  List<double> getDepthColorList() {
    final distances = List<double>(_drawingVertices.length);
    var maxDistance = 0.0;
    var minDistance = 1.0 / 0.0;
    for (int i = 0; i < _positionVertices.length; ++i) {
      if (_positionVertices[i].isVisible) {
        final distance = _positionVertices[i].distance(space._viewerPosition);
        if (distance > maxDistance) {
          maxDistance = distance;
        }
        if (distance < minDistance) {
          minDistance = distance;
        }
        distances[i] = distance;
      } else {
        distances[i] = 0.0;
      }
    }

    final maxMinDiff = maxDistance - minDistance;
    final colorList = List<double>();
    for (int i = 0; i < distances.length; ++i) {
      final relative = (distances[i] - minDistance) / maxMinDiff;
      colorList.addAll([1.0 - relative, 0.0, relative]);
    }
    return colorList;
  }

  int get numEdges => _edges.length;

  Edge getEdge(int index) => Edge(_drawingVertices[_edges[index].a], _drawingVertices[_edges[index].b]);
}
