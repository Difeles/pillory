import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart' as vm;

import 'pill_mesh_data.dart';

// Research spike: ONE procedural tablet, no face, rotate + recolour.
// Not production code, not the Pillory architecture.

void main() => runApp(const SpikeApp());

class SpikeApp extends StatelessWidget {
  const SpikeApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: const Color(0xFF8050D8)),
    home: const PillSpikePage(),
  );
}

/// sRGB 0..1 -> approximate linear, because baseColorFactor is linear.
double _lin(double c) => math.pow(c, 2.2).toDouble();

vm.Vector4 _linear(Color c) => vm.Vector4(_lin(c.r), _lin(c.g), _lin(c.b), 1);

const _swatches = <Color>[
  Color(0xFFF4F1EA), // off-white
  Color(0xFFF3A3C5), // pink
  Color(0xFF91AEE8), // blue
  Color(0xFF70D2C7), // mint
  Color(0xFFFFAD62), // orange
  Color(0xFF8050D8), // violet
];

class PillSpikePage extends StatefulWidget {
  const PillSpikePage({super.key});

  @override
  State<PillSpikePage> createState() => _PillSpikePageState();
}

class _PillSpikePageState extends State<PillSpikePage> {
  final Scene _scene = Scene();
  // Fixed matte finish (chalky pressed powder): fully rough, non-metallic.
  final PhysicallyBasedMaterial _material = PhysicallyBasedMaterial()
    ..roughnessFactor = 0.85
    ..metallicFactor = 0.0;
  Node? _pill;
  String? _error;

  // Orientation, driven by drag; applied to the node once per frame in onTick.
  vm.Quaternion _orientation = vm.Quaternion.axisAngle(
    vm.Vector3(1, 0, 0),
    -0.9,
  );
  // Angular velocity (rad/s) about world Y / X, for inertia after a flick.
  double _spinY = 0, _spinX = 0;
  bool _dragging = false;

  double _distance = 3.6;
  double _distanceAtGestureStart = 3.6;
  static const _minDistance = 2.2, _maxDistance = 6.0;
  static const _radiansPerPixel = 0.011;

  Color _color = _swatches[0];

  @override
  void initState() {
    super.initState();
    _applyColor();
    _init();
  }

  Future<void> _init() async {
    try {
      await Scene.initializeStaticResources();
      final d = PillMeshData.tablet();
      final geometry = MeshGeometry.fromArrays(
        positions: d.positions,
        normals: d.normals,
        texCoords: d.texCoords,
        indices: d.indices,
      );
      final node = Node(mesh: Mesh(geometry, _material))
        ..rotation = _orientation;
      _scene.add(node);
      if (!mounted) return;
      setState(() => _pill = node);
    } catch (e, s) {
      debugPrint('Scene init failed: $e\n$s');
      if (mounted) setState(() => _error = '$e');
    }
  }

  void _applyColor() => _material.baseColorFactor = _linear(_color);

  void _onScaleStart(ScaleStartDetails d) {
    _dragging = true;
    _spinX = _spinY = 0;
    _distanceAtGestureStart = _distance;
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    // Screen-right is world +X for a camera on -Z looking at the origin.
    _rotateBy(
      -d.focalPointDelta.dx * _radiansPerPixel,
      -d.focalPointDelta.dy * _radiansPerPixel,
    );
    _distance = (_distanceAtGestureStart / d.scale).clamp(
      _minDistance,
      _maxDistance,
    );
  }

  void _onScaleEnd(ScaleEndDetails d) {
    _dragging = false;
    final v = d.velocity.pixelsPerSecond;
    _spinY = -v.dx * _radiansPerPixel;
    _spinX = -v.dy * _radiansPerPixel;
  }

  void _rotateBy(double aroundY, double aroundX) {
    final dq =
        vm.Quaternion.axisAngle(vm.Vector3(0, 1, 0), aroundY) *
        vm.Quaternion.axisAngle(vm.Vector3(1, 0, 0), aroundX);
    _orientation = (dq * _orientation)..normalize();
  }

  void _onTick(Duration elapsed, double dt) {
    if (!_dragging && (_spinX.abs() > 0.02 || _spinY.abs() > 0.02)) {
      _rotateBy(_spinY * dt, _spinX * dt);
      final decay = math.exp(-3.0 * dt);
      _spinX *= decay;
      _spinY *= decay;
    }
    _pill?.rotation = _orientation;
  }

  @override
  void dispose() {
    _scene.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9FE),
      appBar: AppBar(
        title: const Text('Medicine3D spike'),
        backgroundColor: const Color(0xFFFBF9FE),
      ),
      body: Column(
        children: [
          Expanded(
            child: _error != null
                ? Center(child: Text('Init failed:\n$_error'))
                : _pill == null
                ? const Center(child: CircularProgressIndicator())
                : LayoutBuilder(
                    // Camera FOV is vertical: on a narrow portrait screen the
                    // face-on tablet is wider than the view, so back off.
                    builder: (context, box) {
                      final fit = math.min(
                        1.0,
                        box.maxWidth / box.maxHeight * 1.3,
                      );
                      return GestureDetector(
                        onScaleStart: _onScaleStart,
                        onScaleUpdate: _onScaleUpdate,
                        onScaleEnd: _onScaleEnd,
                        child: SceneView(
                          _scene,
                          cameraBuilder: (_) => PerspectiveCamera(
                            position: vm.Vector3(0, 0, -_distance / fit),
                            target: vm.Vector3.zero(),
                          ),
                          onTick: _onTick,
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  children: [
                    for (final c in _swatches)
                      Semantics(
                        button: true,
                        selected: c == _color,
                        label: 'Colour #${c.toARGB32().toRadixString(16)}',
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _color = c;
                            _applyColor();
                          }),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: c == _color
                                    ? scheme.primary
                                    : Colors.black12,
                                width: c == _color ? 3 : 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
