import 'dart:async';

import 'package:flutter/material.dart';

// Temporary diagnostic entrypoint: plain Flutter Material UI only.
// No flutter_scene import, no Flutter GPU. Delete after the surface check.

void main() => runApp(const SurfaceSmokeApp());

class SurfaceSmokeApp extends StatelessWidget {
  const SurfaceSmokeApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SurfaceSmokePage(),
  );
}

class SurfaceSmokePage extends StatefulWidget {
  const SurfaceSmokePage({super.key});

  @override
  State<SurfaceSmokePage> createState() => _SurfaceSmokePageState();
}

class _SurfaceSmokePageState extends State<SurfaceSmokePage> {
  late final Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => _now = DateTime.now()),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = _now.toIso8601String().substring(11, 19);
    return Scaffold(
      appBar: AppBar(title: const Text('Pillory — Surface Test')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Flutter frame rendered',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFF8050D8),
                borderRadius: BorderRadius.circular(32),
              ),
            ),
            const SizedBox(height: 24),
            Text('Time: $t', style: const TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}
