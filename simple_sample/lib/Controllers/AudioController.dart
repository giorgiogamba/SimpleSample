import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_sample/Models/Model.dart';

import '../Models/Record.dart';

import 'dart:async';
import 'dart:io';

///Class that represents the audio controller, which connects the UI with the Model

const int playersNumber = 16;

class AudioController {

  static final AudioController _instance = AudioController._internal();

  List<AudioPlayer?> _players = List.empty();
  List<bool> _isPlayerInited = List.filled(16, false);
  late FlutterSoundRecorder _recorder;
  bool _isRecorderInited = false;
  bool _playbackReady = false;

  factory AudioController() {
    return _instance;
  }

  AudioController._internal() {
    initAudioController();
  }

  List<AudioPlayer?> createPlayersList() {
    List<AudioPlayer?> players = List.generate(16, (index) => null);
    for (int i = 0; i < playersNumber; i ++) {
      players.insert(i, AudioPlayer(mode: PlayerMode.LOW_LATENCY)); //aggiunta lwlatency
      _isPlayerInited[i] = true;
      print("Player " +i.toString()+" initialized");
    }
    return players;
  }

  void initAudioController() {
    _players = createPlayersList();
    print("*** AudioController Initialization Completed ***");
  }

  Future<void> initRecorder() async {
    _recorder = FlutterSoundRecorder();
    await openRecorder();
  }

  void disposeRecorder() {
    _recorder.closeAudioSession();
  }

  FlutterSoundRecorder getRecorder() {
    return this._recorder;
  }


  Future<void> openRecorder() async {
    if (!kIsWeb) {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        print("************ PERMISSION NOT GRANTED ************");
        throw RecordingPermissionException("No microphone permission granted");
      }
    }
    await _recorder.openAudioSession().then((value) => _isRecorderInited = true);
    print("********** Recorder opened **********");
  }

  void disposeSampler() {
    for (int i = 0; i < playersNumber-1; i ++) {
      _players[i]?.dispose();
      _isPlayerInited[i] = false;
    }

    _recorder.closeAudioSession();
    _isRecorderInited = false;
  }

  //Faccio la creazione della registrazione all'inizio dello svolgimento perchè il metodo startRecorder restituisce void
  void record(int index) {
    this._playbackReady = false;
    String path = Model().getNewPath();
    if (_isRecorderInited == true) {
      _recorder.startRecorder(toFile: path, codec: Codec.pcm16WAV);
      Record record = new Record(path);
      record.setPosition(index);
      Model().addRecord(record, index);
    } else {
      throw Exception("Record: recorder is not inited");
    }
  }

  void stopRecorder() async {
    await _recorder.stopRecorder().then((value) => {
      _playbackReady = true,
    });
  }

  void enablePlayback() {
    this._playbackReady = true;
  }

  void play(int index) {
    if (_isPlayerInited[index]) {
      if (_playbackReady) {
        if (_recorder.isStopped) {
          Record? toPlay = Model().getRecordAt(index);
          if (toPlay != null) {
            File file = new File(toPlay.getUrl());
            print("*** Play path: "+file.path);
            _players[index]?.play(toPlay.getUrl());
          }
        } else {
          throw Exception("Recorder o player not stoppati");
        }
      } else {
        throw Exception ("Playback not ready");
      }
    } else {
      throw ("Play: player non inizializzato");
    }

  }

  void playAtURL(String URL) {
    AudioPlayer player = AudioPlayer();
    player.play(URL);
  }

}

