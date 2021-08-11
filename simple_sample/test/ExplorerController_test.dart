import 'package:flutter_test/flutter_test.dart';
import 'package:simple_sample/Controllers/ExplorerController.dart';
import 'package:simple_sample/Models/Record.dart';

void main() {

  test("AddToSelectedEntries", () {

    List<Record> entries1 = [];
    Record rec = Record("URL");
    rec.setFilename("ciao");
    entries1.add(rec);
    ExplorerController().setEntries(entries1);
    ExplorerController().addToSelectedEntries(0);
    List<Record> sel = ExplorerController().getSelectedEntries();
    expect(sel[0].getFilename(), "ciao");
  });

}