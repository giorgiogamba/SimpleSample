import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_sample/Controllers/GoogleDriveController.dart';
import 'package:simple_sample/Models/Record.dart';

void main() {

  setUpAll(() {
    WidgetsFlutterBinding.ensureInitialized();
  });

  ///INTEGRATION
  test("Upload", () async {
    Record r1 = Record("URL");
    r1.setFilename("r1");
    GoogleDriveController().upload(r1);
    List<String> urls = await GoogleDriveController().listGoogleDriveFiles();
    expect(urls.contains(r1), true);
  });

  ///INTEGRATION
  test("Upload 2", () async {
    Record r1 = Record("URL");
    r1.setFilename("r1");

    Record r2 = Record("URL");
    r1.setFilename("r2");

    Record r3 = Record("URL");
    r1.setFilename("r3");

    GoogleDriveController().upload(r1);
    GoogleDriveController().upload(r2);
    GoogleDriveController().upload(r3);

    List<String> urls = await GoogleDriveController().listGoogleDriveFiles();
    expect(urls.contains(r1) && urls.contains(r2) && urls.contains(r3), true);
  });

}