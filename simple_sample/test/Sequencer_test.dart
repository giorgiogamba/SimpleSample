import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_sample/UI/Sequencer.dart';

void main() {

  testWidgets('Sequencer Commands', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Sequencer(),));
    final play = find.widgetWithIcon(ElevatedButton, Icons.play_arrow);
    final stop = find.widgetWithIcon(ElevatedButton, Icons.stop);
    final pause = find.widgetWithIcon(ElevatedButton, Icons.pause);
    final reset = find.text("Reset");
    expect(play, findsNWidgets(1));
    expect(stop, findsNWidgets(1));
    expect(pause, findsNWidgets(1));
    expect(reset, findsNWidgets(1));

  });

  testWidgets('Pointer Numbers', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Sequencer(),));
    final a = find.widgetWithText(ElevatedButton, "1");
    final b = find.widgetWithText(ElevatedButton, "2");
    final c = find.widgetWithText(ElevatedButton, "3");
    final d = find.widgetWithText(ElevatedButton, "4");
    final e = find.widgetWithText(ElevatedButton, "5");
    final f = find.widgetWithText(ElevatedButton, "6");
    final g = find.widgetWithText(ElevatedButton, "7");
    final h = find.widgetWithText(ElevatedButton, "8");
    expect(a, findsNWidgets(1));
    expect(b, findsNWidgets(1));
    expect(c, findsNWidgets(1));
    expect(d, findsNWidgets(1));
    expect(e, findsNWidgets(1));
    expect(f, findsNWidgets(1));
    expect(g, findsNWidgets(1));
    expect(h, findsNWidgets(1));
  });
}