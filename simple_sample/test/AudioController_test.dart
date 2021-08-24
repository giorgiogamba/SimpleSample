
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_sample/Controllers/AudioController.dart';
import 'package:simple_sample/Models/Model.dart';

void main() {

  ///todo forse questi sono più degli integration test o UI test

  test("record_test", () async {

    WidgetsFlutterBinding.ensureInitialized();
    Model model = Model();
    int index = 0;
    await AudioController().initRecorder();
    AudioController().record(index);
    AudioController().stopRecorder();

    expect( (model.getRecordAt(0) != null), true );

  });

}