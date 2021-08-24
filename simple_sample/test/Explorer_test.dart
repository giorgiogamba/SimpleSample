import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_sample/UI/Explorer.dart';

import 'setupCloudFirestoreMock.dart';

void main() {

  setupCloudFirestoreMocks();

  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });

  testWidgets('Explorer Test', (WidgetTester tester) async {
    await tester.pumpWidget(const Explorer());
    final a = find.widgetWithText(DropdownMenuItem, "Tags");
    expect(a, findsOneWidget);

  });
}