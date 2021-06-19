import 'dart:async';
import 'dart:collection';

import 'package:flutter/cupertino.dart';

import 'AudioController.dart';
import 'Model.dart';
import 'Record.dart';

const int bpmBase = 120;

class SequencerController {

  static final SequencerController _instance = SequencerController._internal();

  //mappa con 16 righe e 8 colonne. La mappa esterna contiene colonne, la seconda righe
  HashMap<int, HashMap<int, bool>>? _sequencerMap = HashMap();
  AudioController? _audioController;
  int _tick = 0;
  int _remainder = 0;
  Duration _dur = new Duration();
  Timer? _timer;
  final counter = ValueNotifier(0);
  bool _isRunning = false;

  SequencerController._internal() {
    print("Initializing Sequencer Controller");
    initSequencerController();
  }

  factory SequencerController() {
    return _instance;
  }

  void initSequencerController() {
    _audioController = AudioController();
    initSequencerMap();
    print("Sequencer Controller initialization completed");
  }


  void initSequencerMap() {
    for (int i = 0; i < 8; i ++) {
      HashMap<int, bool>? newMap = HashMap();
      for (int j = 0; j < 16; j ++) {
        newMap.putIfAbsent(j, () => false);
      }
      _sequencerMap?.putIfAbsent(i, () => newMap);
    }
    printSequencerMap();
  }

  void printSequencerMap() {
    List<String> strings = List.filled(16, "");
    for (int i = 0; i < 8; i ++) {
      HashMap<int, bool>? extMap = _sequencerMap?[i];
      for (int j = 0; j < 15; j ++) {
        strings[j] = strings[j] + extMap![j].toString() + " ";
      }
    }

    for (int i = 0; i < 16; i ++) {
      print(strings[i]);
    }
  }


  void manageButtonPress(int row, int col) {
    print("Managing row "+row.toString() + " on col "+col.toString());
    HashMap<int, bool>? tempMap = _sequencerMap?[col];
    if (tempMap?[row] == true) {
      tempMap?.update(row, (existing) => false);
    } else {
      tempMap?.update(row, (existing) => true);
    }
  }

  void playPosition(int pos) {
    print("Playing position "+pos.toString());
    HashMap<int, bool>? posList = _sequencerMap?[pos];
    if (posList != null) {
      for (int i = 0; i < 16; i ++) {
        if (posList[i] == true) {
          _audioController?.play(i);
        }
      }
    }
  }

  bool? getSequencerMapValue(int row, int col) {
    HashMap<int, bool>? tempMap = _sequencerMap?[col];
    return tempMap?[row];
  }

  void calculateTick() {
    int? currentBPM = getBPM();
    _tick = bpmBase ~/ currentBPM;
    _remainder = bpmBase % currentBPM;
    _dur = Duration(seconds: _tick, milliseconds: _remainder);
  }

  void startTimeout() {
    print("Duration vale: "+_dur.toString());
    _timer = Timer.periodic(_dur, (Timer t) => handleTimeout());
  }

  void handlePlay() {
    if (!isSequencerRunning()) {
      setIsRunning(true);
      playPosition(0);
      calculateTick();
      startTimeout();
    } else {
      print("SequencerController -- handlePlay -- sequencer is already running");
    }
  }

  void handleStop() {
    _timer?.cancel();
    resetCounter();
    setIsRunning(false);
  }

  void handlePause() {
    _timer?.cancel();
  }
  void resetCounter() {
    counter.value = 0;
  }

  void handleTimeout() {
    incrementCounter();
    playPosition(counter.value);
  }

  void incrementCounter() {
    counter.value ++;
    if (counter.value > 7) {
      counter.value = 0;
    }
  }

  void resetSequencer() {
    for (int i = 0; i < 8; i ++) {
      HashMap<int, bool>? newMap = _sequencerMap?[i];
      for (int j = 0; j < 16; j ++) {
        newMap?.update(j, (existing) => false);
      }
    }
    printSequencerMap();
    print("Sequencer resetted");
  }

  int getBPM() {
    return Model().getBPM();
  }

  void setBPM (int newBPM) {
    Model().setBPM(newBPM);
  }

  bool isSequencerRunning() {
    return this._isRunning;
  }

  void setIsRunning(bool value) {
    this._isRunning = value;
  }

  bool isRecordAtPositionNull(int index) {
    Record? record = Model().getRecordAt(index);
    if (record != null) {
      if (record.getFilename() == null) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

}