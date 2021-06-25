import 'dart:convert';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
    print("Inizializzazione Audio Controller");
    initAudioController();
  }

  List<AudioPlayer?> createPlayersList() {
    List<AudioPlayer?> players = List.generate(16, (index) => null);
    for (int i = 0; i < playersNumber; i ++) {
      players.insert(i, AudioPlayer(mode: PlayerMode.LOW_LATENCY)); //aggiunta lwlatency
      _isPlayerInited[i] = true;
      print("Player " +i.toString()+" inizializzato");
    }
    return players;
  }

  void initAudioController() {
    _players = createPlayersList();
    print("********** AudioController Initialization Completed **********");
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
            print("******************* file ha lunghezza: "+file.lengthSync().toString());
            print("******************* path path: "+file.path);
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

  void playAtURL(String URL) {
    AudioPlayer player = AudioPlayer();
    player.play(URL);
  }

  void sumTest() async {
    //Reading two records ad bytes
    String url1 = Model().getRecordAt(0)!.getUrl();
    print(url1);
    File firstFile = File(url1);
    Uint8List first = firstFile.readAsBytesSync();
    print(first.toString());
    String url2 = Model().getRecordAt(1)!.getUrl();
    print(url2);
    File secondFile = File(url2);
    Uint8List second = secondFile.readAsBytesSync();
    print("inizio secondo");
    print(second.toString());
    print("Fine secondo");
    List<int> sum = first + second;
    Uint8List correctSum = Uint8List.fromList(sum);
    print(correctSum.toString());
    File newFile = await File(Model().getExtDocPath()+"/"+"nuovo.wav").writeAsBytes(correctSum, mode: FileMode.write, flush: true);
    print("FINE SOMMA");
  }


}

