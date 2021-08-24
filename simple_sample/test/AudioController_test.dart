
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_sample/Controllers/AudioController.dart';
import 'package:simple_sample/Models/Model.dart';

void main() {

  setUpAll(() {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '.';
    });
  });

  test("record_test", () async {
    Model model = Model();
    int index = 0;
    await AudioController().initRecorder();
    AudioController().record(index);
    AudioController().stopRecorder();

    expect( (model.getRecordAt(0) != null), true );

  });

  test("Players List", () {
    List<AudioPlayer?> players = AudioController().createPlayersList();

    int count = 0;
    for (int i = 0; i < players.length; i ++) {
      if (players[i].runtimeType == AudioPlayer) {
        count ++;
      }
    }

    expect(count, 16);
  });

}