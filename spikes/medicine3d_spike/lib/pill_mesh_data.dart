import 'dart:math' as math;
import 'dart:typed_data';

/// Raw vertex data for a procedural tablet. Pure Dart (no flutter_scene /
/// GPU imports) so the winding and normals can be unit-tested without a GPU.
///
/// The tablet is a solid of revolution around +Y. Its cross-section is a
/// superellipse |r/a|^n + |y/b|^n = 1 for each face, with a short straight
/// side band between the top and bottom halves. The normals come from the
/// analytic gradient, so they are exact and smooth, not averaged from faces.
class PillMeshData {
  PillMeshData({
    required this.positions,
    required this.normals,
    required this.texCoords,
    required this.indices,
  });

  final Float32List positions; // 3 floats per vertex
  final Float32List normals; // 3 floats per vertex
  final Float32List texCoords; // 2 floats per vertex
  final List<int> indices; // CCW (right-handed) triangles, outward-facing

  int get vertexCount => positions.length ~/ 3;
  int get triangleCount => indices.length ~/ 3;

  /// [radius] is the tablet radius, [halfThickness] the dome height above
  /// the band, [bandHeight] the straight side band, [edgeExponent] the
  /// superellipse exponent n (2 = ellipse, larger = squarer, sharper edge).
  factory PillMeshData.tablet({
    double radius = 1.0,
    double halfThickness = 0.17,
    double bandHeight = 0.10,
    double edgeExponent = 2.6,
    int profileSamples = 40,
    int radialSegments = 96,
  }) {
    final a = radius;
    final b = halfThickness;
    final n = edgeExponent;
    final shift = bandHeight / 2;
    final p = 2 / n;

    // Profile from the top pole down to the bottom pole: (r, y, nr, ny).
    final profile = <List<double>>[];
    void addHalf(bool top) {
      for (var i = 0; i <= profileSamples; i++) {
        // Angle from the pole (0) to the equator (pi/2) of the superellipse.
        final t = (i / profileSamples) * math.pi / 2;
        final s = math.sin(t);
        final c = math.cos(t);
        final r = a * math.pow(s, p).toDouble();
        final yLocal = b * math.pow(c, p).toDouble();
        // Gradient of F(r, y) = (r/a)^n + (y/b)^n, normalised.
        var nr = r <= 0 ? 0.0 : math.pow(r / a, n - 1).toDouble() / a;
        var ny = yLocal <= 0 ? 0.0 : math.pow(yLocal / b, n - 1).toDouble() / b;
        final len = math.sqrt(nr * nr + ny * ny);
        nr /= len;
        ny /= len;
        if (top) {
          profile.add([r, yLocal + shift, nr, ny]);
        } else {
          profile.add([r, -yLocal - shift, nr, -ny]);
        }
      }
    }

    // Top half pole -> equator, then bottom half equator -> pole.
    addHalf(true);
    final bottom = <List<double>>[];
    final saved = List<List<double>>.of(profile);
    profile.clear();
    addHalf(false);
    bottom.addAll(profile.reversed);
    profile
      ..clear()
      ..addAll(saved)
      ..addAll(bottom);

    final rings = profile.length;
    final cols = radialSegments + 1; // +1: duplicated seam vertex for UVs
    final positions = Float32List(rings * cols * 3);
    final normals = Float32List(rings * cols * 3);
    final texCoords = Float32List(rings * cols * 2);

    for (var i = 0; i < rings; i++) {
      final pr = profile[i];
      for (var k = 0; k < cols; k++) {
        final phi = (k / radialSegments) * 2 * math.pi;
        final cp = math.cos(phi);
        final sp = math.sin(phi);
        final v = i * cols + k;
        positions[v * 3] = pr[0] * cp;
        positions[v * 3 + 1] = pr[1];
        positions[v * 3 + 2] = pr[0] * sp;
        normals[v * 3] = pr[2] * cp;
        normals[v * 3 + 1] = pr[3];
        normals[v * 3 + 2] = pr[2] * sp;
        texCoords[v * 2] = k / radialSegments;
        texCoords[v * 2 + 1] = i / (rings - 1);
      }
    }

    // Quad (A=(i,k), B=(i,k+1), C=(i+1,k), D=(i+1,k+1)). Moving to B is +phi
    // (toward +Z at phi=0), moving to C is down the profile (outward at the
    // top), so (B-A)x(C-A) = +Y at the top face: outward. Triangles are
    // (A,B,C) and (B,D,C), CCW seen from outside. Triangles that collapse at
    // a pole (two coincident vertices) are skipped.
    final indices = <int>[];
    bool degenerate(int x, int y, int z) {
      bool same(int u, int w) =>
          positions[u * 3] == positions[w * 3] &&
          positions[u * 3 + 1] == positions[w * 3 + 1] &&
          positions[u * 3 + 2] == positions[w * 3 + 2];
      return same(x, y) || same(y, z) || same(x, z);
    }

    for (var i = 0; i < rings - 1; i++) {
      for (var k = 0; k < radialSegments; k++) {
        final A = i * cols + k;
        final B = A + 1;
        final C = (i + 1) * cols + k;
        final D = C + 1;
        if (!degenerate(A, B, C)) indices.addAll([A, B, C]);
        if (!degenerate(B, D, C)) indices.addAll([B, D, C]);
      }
    }

    return PillMeshData(
      positions: positions,
      normals: normals,
      texCoords: texCoords,
      indices: indices,
    );
  }
}
