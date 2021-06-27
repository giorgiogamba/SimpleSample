import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_sample/Controllers/SamplerController.dart';
import 'package:simple_sample/Models/Model.dart';
import 'package:simple_sample/Models/Record.dart';

void main() {


  test("getButtonName", () {
    WidgetsFlutterBinding.ensureInitialized();
    final model = Model();

    Record rec = Record("URL");
    rec.setFilename("Ciao");
    model.addRecord(rec, 0);
    String name = SamplerController().getButtonName(0);
    expect(name, "Ciao");
  });

  test("getButtonName2", () {
    WidgetsFlutterBinding.ensureInitialized();
    final model = Model();
    String name = SamplerController().getButtonName(0);
    expect(name, "Bt0");
  });

}