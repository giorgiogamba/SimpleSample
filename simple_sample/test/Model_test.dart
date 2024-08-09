import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_sample/Models/Model.dart';
import 'package:simple_sample/Models/Record.dart';
import 'dart:io';

void main() {

  setUpAll(() {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    // const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');
    // channel.setMockMethodCallHandler((MethodCall methodCall) async { return '.'; });
  });

  test("Creating a new path", () {
    final model = Model();

    String path = model.getNewPath();
    String exPath = model.getExtDocPath()+"/"+model.getCounter().toString()+".wav";
    expect(path, exPath);

  });

  test("Add record", () {
    final model = Model();

    Record newRec = Record("url");
    model.addRecord(newRec, 5);

    bool res = model.getRecordAt(5) != null;
    expect(res, true);

  });

  test("Get all current records", () {
    final model = Model();

    Record rec1 = Record("url");
    Record rec2 = Record("url");
    Record rec3 = Record("url");

    model.addRecord(rec1, 0);
    model.addRecord(rec2, 1);
    model.addRecord(rec3, 2);

    List<Record> list = model.getAllCurrentRecords();
    int resLength = list.length;

    expect(resLength, 3);

  });

  test("Get record with path", () {
    final model = Model();

    Record rec1 = Record("path");
    Record rec2 = Record("url");
    Record rec3 = Record("url");
    Record rec4 = Record("url");

    model.addRecord(rec1, 0);
    model.addRecord(rec2, 1);
    model.addRecord(rec3, 2);
    model.addRecord(rec4, 3);

    Record? res = model.getRecordWithPath("path");
    expect (res.getFilename(), "path");
  });


  test("isButtonFull", () {
    final model = Model();

    Record rec1 = Record("path");
    Record rec2 = Record("url");
    Record rec3 = Record("url");
    Record rec4 = Record("url");

    model.addRecord(rec1, 0);
    model.addRecord(rec2, 1);
    model.addRecord(rec3, 2);
    model.addRecord(rec4, 3);

    bool res = model.isButtonFull(3);
    expect(res, true);
  });

  test ("Change Filename only", () {
    File file = File("ciao.wav");
    file.writeAsString("ciao");
    Model().changeFileNameOnly(file, "newFilename");
    expect(file.path, "newFilename.wav");
  });

  ///INTEGRATION
  test("getPersonalPath", () {
    String filename = "test";
    String res = Model().getPersonalPath(filename);
    print(res);
    String dirpath = Model().getExtDocPath();
    String path = dirpath + "/" + res;
    expect(path, res);
  });

  ///INTEGRATION
  test("RenameRecord", () {
    Record rec = Record("URL");
    rec.setFilename("prova");
    Model().addRecord(rec, 0);
    Model().renameRecord(0, "nuovo");
    Record? res = Model().getRecordAt(0);
    expect(res.getFilename(), "nuovo");
  });

  test("getExtDirElementsList", () {
    File file1 = File(Model().getExtDocPath() + "file1.wav");
    File file2 = File(Model().getExtDocPath() + "file2.wav");
    List<String> elems = Model().getExtDirElementsList();
    int test = 0;
    if (elems.contains(file1.path) && elems.contains(file2.path)) {
      test = 1;
    }

    expect(test, 1);
  });
}