import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_sample/Model.dart';

import 'Record.dart';

///Class that represents the audio controller, which connects the UI with the Model

const int playersNumber = 16;

///todo la versione di esempio fa uso del setState
///todo pensare se sia il caso di creare uno stateful wodget
class AudioController {

  static final AudioController _instance = AudioController._internal();

  List<AudioPlayer?> _players = List.empty();
  List<bool> _isPlayerInited = List.filled(16, false);
  FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecorderInited = false;
  bool _playbackReady = false; //todo true quando finisce il recorder

  factory AudioController() {
    return _instance;
  }

  AudioController._internal() {
    print("Inizializzazione Audio Controller");
    initAudioController();
  }

  List<AudioPlayer?> createPlayersList() {
    List<AudioPlayer?> players = List.generate(16, (index) => null);
    for (int i = 0; i < playersNumber; i ++) {
      players.insert(i, AudioPlayer());
      _isPlayerInited[i] = true;
      print("Player " +i.toString()+" inizializzato");
    }
    return players;
  }

  void initAudioController() {

    _recorder = FlutterSoundRecorder();
    openRecorder().then((value) => _isRecorderInited = true);
    _players = createPlayersList();
    print("********** AudioController Initialization Completed **********");
  }

  Future<void> openRecorder() async {
    print("Inizio metodo openRecorder");
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

  int getBPM() {
    return Model().getBPM();
  }

  void setBPM (int newBPM) {
    Model().setBPM(newBPM);
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
    String path = Model().getNewPath();
    if (_isRecorderInited == true) {
      _recorder.startRecorder(toFile: path);
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

  void play(int index) {
    if (_isPlayerInited[index]) {
      if (_playbackReady) {
        if (_recorder.isStopped) {
          Record? toPlay = Model().getRecordAt(index);
          if (toPlay != null) {
            _players[index]?.play(toPlay.getUrl());
            print("***** ha suonato il player "+index.toString());
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
}

