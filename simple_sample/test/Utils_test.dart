import 'package:flutter_test/flutter_test.dart';
import 'package:simple_sample/Utils.dart';

void main() {

  test("Get filename from URL", () {
    String path = "test/iondex/url.wav";
    String filename = Utils.getFilenameFromURL(path);
    expect(filename, "url.wav");
  });

  test("Remove Extension", () {
    String filename = "filename.wav";
    String res = Utils.removeExtension(filename);
    expect(res, "filename");
  });

  test("wrap text", () {
    String complete = "testingfilename.wav";
    String res = Utils.wrapText(complete, 5);
    expect(res, "test..");
  });

  test("wrap text 2", () {
    String complete = "testingfilename.wav";
    String res = Utils.wrapText(complete, 8);
    expect(res, "testing..");
  });

  test("Remove 3", () {
    String complete = "testingfilename.wav";
    String res = Utils.remove3(complete);
    expect("tingfilename.", res);
  });

  test("Get extension", () {
    String complete = "testingfilename.wav";
    String res = Utils.getExtension(complete);
    expect("wav", res);
  });

}