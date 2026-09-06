import 'package:dh_switch/dh_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Container track(WidgetTester tester) {
    return tester.widget<Container>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.constraints?.maxWidth == 44 &&
            widget.constraints?.maxHeight == 24,
      ),
    );
  }

  Alignment trackAlignment(WidgetTester tester) {
    return track(tester).alignment! as Alignment;
  }

  Color? trackColor(WidgetTester tester) {
    return (track(tester).decoration! as ShapeDecoration).color;
  }

  testWidgets('calls onChanged immediately before the animation completes',
      (tester) async {
    final changes = <bool>[];

    await tester.pumpWidget(
      DHSwitch(
        value: false,
        onChanged: changes.add,
      ),
    );

    await tester.tap(find.byType(GestureDetector));

    expect(changes, <bool>[true]);
    expect(trackAlignment(tester), Alignment.centerLeft);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(trackAlignment(tester).x, closeTo(0, 0.01));

    await tester.pump(const Duration(milliseconds: 100));
    expect(trackAlignment(tester), Alignment.centerRight);
  });

  testWidgets('switches immediately when isFirstRender is false',
      (tester) async {
    final changes = <bool>[];

    await tester.pumpWidget(
      DHSwitch(
        value: false,
        isFirstRender: false,
        onChanged: changes.add,
      ),
    );

    await tester.tap(find.byType(GestureDetector));
    await tester.pump();

    expect(changes, <bool>[true]);
    expect(trackAlignment(tester), Alignment.centerRight);
  });

  testWidgets('remains interactive without onChanged', (tester) async {
    await tester.pumpWidget(
      DHSwitch(
        value: false,
        isFirstRender: false,
      ),
    );

    await tester.tap(find.byType(GestureDetector));
    await tester.pump();
    expect(trackAlignment(tester), Alignment.centerRight);

    await tester.tap(find.byType(GestureDetector));
    await tester.pump();
    expect(trackAlignment(tester), Alignment.centerLeft);
  });

  testWidgets('disabled is the only state that blocks interaction',
      (tester) async {
    final changes = <bool>[];

    await tester.pumpWidget(
      DHSwitch(
        value: false,
        disabled: true,
        onChanged: changes.add,
      ),
    );

    expect(find.byType(GestureDetector), findsNothing);
    expect(changes, isEmpty);
    expect(trackAlignment(tester), Alignment.centerLeft);
  });

  testWidgets('ignores taps while animating', (tester) async {
    final changes = <bool>[];

    await tester.pumpWidget(
      DHSwitch(
        value: false,
        onChanged: changes.add,
      ),
    );

    await tester.tap(find.byType(GestureDetector));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.byType(GestureDetector));
    expect(changes, <bool>[true]);

    await tester.pumpAndSettle();
    expect(trackAlignment(tester), Alignment.centerRight);
  });

  testWidgets('ignores taps during the throttle duration', (tester) async {
    final changes = <bool>[];

    await tester.pumpWidget(
      DHSwitch(
        value: false,
        isFirstRender: false,
        throttleDuration: const Duration(seconds: 1),
        onChanged: changes.add,
      ),
    );

    await tester.tap(find.byType(GestureDetector));
    await tester.pump();
    await tester.tap(find.byType(GestureDetector));
    expect(changes, <bool>[true]);

    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byType(GestureDetector));
    await tester.pump();
    expect(changes, <bool>[true, false]);
  });

  testWidgets('keeps animating when an unrelated parent rebuilds',
      (tester) async {
    final changes = <bool>[];

    await tester.pumpWidget(
      DHSwitch(
        value: false,
        onChanged: changes.add,
      ),
    );
    await tester.tap(find.byType(GestureDetector));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.pumpWidget(
      DHSwitch(
        value: false,
        activeTrackColor: Colors.green,
        onChanged: changes.add,
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(trackAlignment(tester), Alignment.centerRight);
    expect(changes, <bool>[true]);
  });

  testWidgets('interpolates colors during the animation', (tester) async {
    const inactive = Color(0xFF000000);
    const active = Color(0xFFFFFFFF);

    await tester.pumpWidget(
      DHSwitch(
        value: false,
        inactiveTrackColor: inactive,
        activeTrackColor: active,
      ),
    );

    await tester.tap(find.byType(GestureDetector));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(trackColor(tester), Color.lerp(inactive, active, 0.5));
  });

  testWidgets('syncs when the external value changes', (tester) async {
    final changes = <bool>[];

    await tester.pumpWidget(
      DHSwitch(
        value: false,
        isFirstRender: false,
        onChanged: changes.add,
      ),
    );

    await tester.pumpWidget(
      DHSwitch(
        value: true,
        isFirstRender: false,
        onChanged: changes.add,
      ),
    );

    expect(trackAlignment(tester), Alignment.centerRight);
    expect(changes, isEmpty);
  });
}
