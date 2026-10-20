import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/design_system/motion.dart';

class _Counter extends StatefulWidget {
  const _Counter();
  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int n = 0;
  @override
  Widget build(BuildContext context) =>
      TextButton(onPressed: () => setState(() => n++), child: Text('n$n'));
}

void main() {
  testWidgets(
    'TabStack keeps a tab\'s state across a glide and shows one tab',
    (tester) async {
      Widget app(int i) => MaterialApp(
        home: TabStack(index: i, children: const [_Counter(), Text('other')]),
      );
      await tester.pumpWidget(app(0));
      await tester.tap(find.text('n0'));
      await tester.pump();
      expect(find.text('n1'), findsOneWidget);

      await tester.pumpWidget(app(1));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('other'), findsOneWidget); // gliding: both are on stage
      await tester.pumpAndSettle();
      expect(find.text('n1'), findsNothing); // idle: only the current tab

      await tester.pumpWidget(app(0));
      await tester.pumpAndSettle();
      expect(find.text('n1'), findsOneWidget); // state survived
      expect(find.text('other'), findsNothing);
    },
  );
}
