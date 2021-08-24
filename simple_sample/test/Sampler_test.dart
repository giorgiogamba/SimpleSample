import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_sample/Controllers/SamplerController.dart';
import 'package:simple_sample/UI/Sampler.dart';
import 'package:simple_sample/Models/Record.dart';

void main() {


  testWidgets('Main Sampler', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Sampler()));

    final a = find.widgetWithIcon(ElevatedButton, Icons.add_to_drive);
    final b = find.widgetWithText(ElevatedButton, "Rename");
    final c = find.widgetWithText(ElevatedButton, "Load");
    final d = find.widgetWithText(ElevatedButton, "Share");

    expect(a, findsNWidgets(1));
    expect(b, findsNWidgets(1));
    expect(c, findsNWidgets(1));
    expect(d, findsNWidgets(1));

  });

  testWidgets('ShareLoading', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: SharingDialog(record: Record("URL"), key: Key("key")),));
    final a = find.text("Insert Sample Infos:");
    final b = find.text("Choose one or more tags");
    expect(a, findsNWidgets(1));
    expect(b, findsNWidgets(1));
  });

  
  testWidgets('ToUploadList', (WidgetTester tester) async {
    await tester.pumpWidget(ToUploadList());
    final a = find.text("Upload Selected Elements");
    expect(a, findsNWidgets(1));
  });

  

  testWidgets('LoadingDialog', (WidgetTester tester) async {

    final List<String> titles = [
      "Load elements from filesystem or Drive",
      "Load built-in elements",
      "Load from Documents folder",
    ];

    await tester.pumpWidget(LoadingDialog(controller: SamplerController(), key: Key("key")));
    
    final a = find.widgetWithText(LoadingListItem, titles[0]);
    final b = find.widgetWithText(LoadingListItem, titles[1]);
    final c = find.widgetWithText(LoadingListItem, titles[2]);

    expect(a, findsNWidgets(1));
    expect(b, findsNWidgets(1));
    expect(c, findsNWidgets(1));
    
  });


  testWidgets('AssetsLoading', (WidgetTester tester) async {
    await tester.pumpWidget(AssetsLoadingDialog(controller: SamplerController(), key: Key("key")));
    String text = "Select an asset to Load";
    final a = find.text(text);
    expect(a, findsNWidgets(1));
  });

  testWidgets('DocumentsDialogLoading', (WidgetTester tester) async {
    await tester.pumpWidget(DocumentsLoadingDialog(controller: SamplerController(), key: Key("key")));
    String text = "Select a file to Load";
    final a = find.text(text);
    expect(a, findsNWidgets(1));
  });


}