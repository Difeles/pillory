import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/design_system/motion.dart';

void main() {
  testWidgets('a press shrinks only the innermost Pressable', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: Pressable(
            child: Pressable(
              child: TextButton(onPressed: () {}, child: const Text('go')),
            ),
          ),
        ),
      ),
    );
    final scales = find.byType(AnimatedScale);
    final g = await tester.startGesture(tester.getCenter(find.text('go')));
    await tester.pump(const Duration(milliseconds: 20));
    expect(tester.widget<AnimatedScale>(scales.at(0)).scale, 1);
    expect(tester.widget<AnimatedScale>(scales.at(1)).scale, lessThan(1));
    await g.up();
    await tester.pumpAndSettle();
    expect(tester.widget<AnimatedScale>(scales.at(1)).scale, 1);

    // The outer one still reacts when pressed on its own.
    final h = await tester.startGesture(
      tester.getTopLeft(scales.at(0)) + const Offset(1, 1),
    );
    await tester.pump(const Duration(milliseconds: 20));
    await h.up();
  });
}
