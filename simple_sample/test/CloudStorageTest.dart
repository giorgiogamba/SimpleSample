import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_sample/Controllers/CloudStorageController.dart';
import 'package:simple_sample/Models/Model.dart';
import 'package:simple_sample/Models/Record.dart';

void main() {

  test("Upload element and download", () async {

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    final model = Model();

    Record record = Record("nuovopath");
    record.setRecordOwnerID("1");

    CloudStorageController().uploadRecord(record);

    CloudStorageController().downloadRecord(record);

    String exPath = model.getExtDocPath()+"/"+record.getFilename()+"_downloaded.wav";
    File file = File(exPath);

    expect(file.exists(), true);

  });

}