import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_sample/Controllers/CloudStorageController.dart';
import 'package:simple_sample/Controllers/ExplorerController.dart';
import 'package:simple_sample/Models/Record.dart';

import 'setupCloudFirestoreMock.dart';

void main() {

  setupCloudFirestoreMocks();

  test("AddToSelectedEntries 1", () async {

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    List<Record> entries1 = [];
    Record rec = Record("URL");
    rec.setFilename("ciao");
    entries1.add(rec);
    ExplorerController().setEntries(entries1);
    ExplorerController().addToSelectedEntries(0);
    List<Record> sel = ExplorerController().getSelectedEntries();
    expect(sel[0].getFilename(), "ciao");
  });

  test("AddToSelectedEntries 2", () async {

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    List<Record> entries1 = [];
    Record rec = Record("URL");
    rec.setFilename("ciao");
    entries1.add(rec);

    Record rec2 = Record("URL");
    rec2.setFilename("second");
    entries1.add(rec2);

    ExplorerController().setEntries(entries1);
    ExplorerController().addToSelectedEntries(0);
    ExplorerController().addToSelectedEntries(1);
    List<Record> sel = ExplorerController().getSelectedEntries();
    expect(sel[1].getFilename(), "second");
  });

  ///INTEGRATION TEST
  test("Manage Favs", () async {

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    Record record = Record("URL");
    record.setFilename("record");
    CloudStorageController().addToFavourites(record);
    ExplorerController().getFavourites();
    ExplorerController().manageFavouritesButton(record); //Should remove

    List<Record> favs = await CloudStorageController().getFavouritesFromDB();
    expect(favs.contains(record), false);
  });

  ///INTEGRATION TEST
  test("Manage Favs 2", () async {

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    Record record = Record("URL");
    record.setFilename("record");
    ExplorerController().getFavourites();
    ExplorerController().manageFavouritesButton(record); //Should add

    List<Record> favs = await CloudStorageController().getFavouritesFromDB();
    expect(favs.contains(record), true);
  });

}