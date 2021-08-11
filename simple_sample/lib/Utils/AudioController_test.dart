import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_sample/Controllers/AudioController.dart';

void main() {

  test("CreatePlayersList", () {

    AudioController().createPlayersList();
    List<AudioPlayer?> players = AudioController().getPlayersList();
    expect(players.length, 16);

  });

}