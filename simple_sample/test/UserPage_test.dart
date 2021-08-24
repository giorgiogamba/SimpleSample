import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_sample/Controllers/UserPageController.dart';
import 'package:simple_sample/UI/UserPage.dart';

void main() {

  testWidgets('Downloads', (WidgetTester tester) async {

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    await tester.pumpWidget(MaterialApp(home: UserPage(),));
    final a = find.text("Downloads");
    expect(a, findsNWidgets(1));

  });

  testWidgets('ListButtons', (WidgetTester tester) async {

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    await tester.pumpWidget(MaterialApp(home: UserPage(),));
    final a = find.widgetWithIcon(ElevatedButton, Icons.play_arrow);
    final b = find.widgetWithIcon(ElevatedButton, Icons.delete);
    final c = find.widgetWithIcon(ElevatedButton, Icons.star);
    expect(a, findsWidgets);
    expect(b, findsWidgets);
    expect(c, findsWidgets);

  });


  testWidgets('SettingsPage', (WidgetTester tester) async {

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    await tester.pumpWidget(MaterialApp(home: SettingsPage(controller: UserPageController(),),));
    final a = find.text("Set Username");
    final b = find.text("Settings");
    final c = find.text("Logout");
    final d = find.text("Delete account");
    expect(a, findsNWidgets(1));
    expect(b, findsNWidgets(1));
    expect(c, findsNWidgets(1));
    expect(d, findsNWidgets(1));

  });


  testWidgets('DeleteAccountWidget', (WidgetTester tester) async {

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    await tester.pumpWidget(MaterialApp(home: DeleteAccountWidget(controller: UserPageController(), key: Key("key"))));
    final a = find.text("No");
    final b = find.text("Yes");
    expect(a, findsNWidgets(1));
    expect(b, findsNWidgets(1));

  });


  testWidgets('LanguageWidget', (WidgetTester tester) async {

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    await tester.pumpWidget(MaterialApp(home: ChangeLanguageDialog(controller: UserPageController())));
    final a = find.text("English");
    final b = find.text("Italiano");
    final c = find.text("Francais");
    expect(a, findsNWidgets(1));
    expect(b, findsNWidgets(1));
    expect(c, findsNWidgets(1));

  });

}