import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:medicine3d_spike/pill_mesh_data.dart';
import 'package:vector_math/vector_math.dart' as vm;

vm.Vector3 _pos(PillMeshData d, int i) =>
    vm.Vector3(d.positions[i * 3], d.positions[i * 3 + 1], d.positions[i * 3 + 2]);
vm.Vector3 _nrm(PillMeshData d, int i) =>
    vm.Vector3(d.normals[i * 3], d.normals[i * 3 + 1], d.normals[i * 3 + 2]);

void main() {
  final data = PillMeshData.tablet();

  test('indices are in range and form whole triangles', () {
    expect(data.indices.length % 3, 0);
    expect(data.indices.every((i) => i >= 0 && i < data.vertexCount), isTrue);
    expect(data.triangleCount, greaterThan(1000));
  });

  test('every triangle is CCW seen from outside (not inside-out)', () {
    // A tablet is convex and centred on the origin, so for every outward
    // facing triangle the right-handed face normal points away from the
    // origin: dot(faceNormal, triangleCentroid) > 0.
    var bad = 0;
    for (var t = 0; t < data.triangleCount; t++) {
      final a = _pos(data, data.indices[t * 3]);
      final b = _pos(data, data.indices[t * 3 + 1]);
      final c = _pos(data, data.indices[t * 3 + 2]);
      final face = (b - a).cross(c - a);
      expect(face.length, greaterThan(0), reason: 'zero-area triangle $t');
      final centroid = (a + b + c) / 3;
      if (face.dot(centroid) <= 0) bad++;
    }
    expect(bad, 0, reason: '$bad triangles wound clockwise (inside-out)');
  });

  test('vertex normals are unit length and agree with the face winding', () {
    for (var i = 0; i < data.vertexCount; i++) {
      expect(_nrm(data, i).length, closeTo(1.0, 1e-5));
    }
    var disagree = 0;
    for (var t = 0; t < data.triangleCount; t++) {
      final ia = data.indices[t * 3];
      final ib = data.indices[t * 3 + 1];
      final ic = data.indices[t * 3 + 2];
      final face = (_pos(data, ib) - _pos(data, ia))
          .cross(_pos(data, ic) - _pos(data, ia))
        ..normalize();
      final avg = _nrm(data, ia) + _nrm(data, ib) + _nrm(data, ic);
      if (face.dot(avg.normalized()) < 0.9) disagree++;
    }
    expect(disagree, 0,
        reason: '$disagree triangles whose winding and stored normals differ');
  });

  test('bounds match the requested dimensions and no vertex is NaN', () {
    var maxR = 0.0, maxY = -1e9, minY = 1e9;
    for (var i = 0; i < data.vertexCount; i++) {
      final p = _pos(data, i);
      expect(p.x.isFinite && p.y.isFinite && p.z.isFinite, isTrue);
      maxR = math.max(maxR, math.sqrt(p.x * p.x + p.z * p.z));
      maxY = math.max(maxY, p.y);
      minY = math.min(minY, p.y);
    }
    expect(maxR, closeTo(1.0, 1e-4));
    expect(maxY, closeTo(0.17 + 0.05, 1e-4));
    expect(minY, closeTo(-(0.17 + 0.05), 1e-4));
  });
}
