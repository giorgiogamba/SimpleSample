import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_sample/Models/Model.dart';
import 'package:simple_sample/Models/Record.dart';

void main() {

  test("Creating a new path", () {

    WidgetsFlutterBinding.ensureInitialized();
    final model = Model();

    String path = model.getNewPath();
    String exPath = model.getExtDocPath()+"/"+model.getCounter().toString()+".wav";
    expect(path, exPath);

  });

  test("Add record", () {

    WidgetsFlutterBinding.ensureInitialized();
    final model = Model();

    Record newRec = Record("url");
    model.addRecord(newRec, 5);

    bool res = model.getRecordAt(5) != null;
    expect(res, true);

  });

  test("Get all current records", () {

    WidgetsFlutterBinding.ensureInitialized();
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

    WidgetsFlutterBinding.ensureInitialized();
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
    expect (res!.getFilename(), "path");
  });


  test("isButtonFull", () {

    WidgetsFlutterBinding.ensureInitialized();
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


}