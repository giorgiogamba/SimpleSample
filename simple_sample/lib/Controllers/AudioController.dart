import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_sample/Models/Model.dart';

import '../Models/Record.dart';

import 'dart:async';
import 'dart:io';

///Class managing audio, playback and recording, which connects the UI with the Model

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

  ///The first time this class is called, it is initialized
  AudioController._internal() {
    initAudioController();
  }

  ///Creates and initializes the list of playersNumber players
  List<AudioPlayer?> createPlayersList() { ///TESTED
    List<AudioPlayer?> players = List.generate(16, (index) => null);
    for (int i = 0; i < playersNumber; i ++) {
      players.insert(i, AudioPlayer(mode: PlayerMode.LOW_LATENCY));
      _isPlayerInited[i] = true;
      print("Player " +i.toString()+" initialized");
    }
    return players;
  }

  void initAudioController() { ///OK
    _players = createPlayersList();
    print("*** AudioController Initialization Completed ***");
  }

  Future<void> initRecorder() async { ///OK
    _recorder = FlutterSoundRecorder();
    await openRecorder();
  }

  ///Called to free the resources when the recorder is closed
  void disposeRecorder() { ///OK
    _recorder.closeAudioSession();
  }

  FlutterSoundRecorder getRecorder() {
    return this._recorder;
  }


  Future<void> openRecorder() async { ///OK
    if (!kIsWeb) {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        print("*** !!! PERMISSION NOT GRANTED !!! ***");
        throw RecordingPermissionException("No microphone permission granted");
      }
    }
    await _recorder.openAudioSession().then((value) => _isRecorderInited = true);
    print("*** Recorder opened ***");
  }

  ///Called to free device resources when the sampler is closed
  void disposeSampler() { ///OK
    for (int i = 0; i < playersNumber-1; i ++) {
      _players[i]?.dispose();
      _isPlayerInited[i] = false;
    }

    _recorder.closeAudioSession();
    _isRecorderInited = false;
  }

  ///Method for audio registration
  void record(int index) { ///TESTED
    this._playbackReady = false; //Disables playback so no other file can play
    String path = Model().getNewPath(); //Creates a new path for the audio file to be recorder
    if (_isRecorderInited == true) {
      _recorder.startRecorder(toFile: path, codec: Codec.pcm16WAV);
      Record record = new Record(path); //After recording, creates a Reccord object representing the new audio file
      record.setPosition(index);
      Model().addRecord(record, index); //Associates the new Record object to the Sampler button
    } else {
      throw Exception("Record: recorder is not inited");
    }
  }

  ///Called when the recording button is not pressed anymore, enables playback
  void stopRecorder() async { ///OK
    await _recorder.stopRecorder().then((value) => {
      _playbackReady = true,
    });
  }

  void enablePlayback() { ///OK
    this._playbackReady = true;
  }

  ///Plays the audio file associated to the pressed button (Represented by index)
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
          throw Exception("AudioController: Recorder not stopped");
        }
      } else {
        throw Exception ("AudioController: Playback not ready");
      }
    } else {
      throw ("Audio Controller: player is not inited");
    }

  }

  ///Plays the audio file at the desired location URL
  ///Used to play network audio files
  void playAtURL(String URL) { ///OK
    AudioPlayer player = AudioPlayer();
    player.play(URL);
  }

  List<AudioPlayer?> getPlayersList() {
    return this._players;
  }

}

