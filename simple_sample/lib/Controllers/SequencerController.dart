import 'dart:async';
import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'AudioController.dart';
import '../Models/Model.dart';
import '../Models/Record.dart';

const int bpmBase = 60;
const int maxBpm = 200;

class SequencerController {

  static final SequencerController _instance = SequencerController._internal();

  //mappa con 16 righe e 8 colonne. La mappa esterna contiene colonne, la seconda righe
  HashMap<int, HashMap<int, bool>>? _sequencerMap = HashMap();
  AudioController? _audioController;
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


  ///Sets to false all the map
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

  ///Makes an action depending on the button state
  void manageButtonPress(int row, int col) {
    print("Managing row "+row.toString() + " on col "+col.toString());
    HashMap<int, bool>? tempMap = _sequencerMap?[col];
    if (tempMap?[row] == true) {
      tempMap?.update(row, (existing) => false);
    } else {
      tempMap?.update(row, (existing) => true);
    }
  }

  ///Plays all the files in the given row
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

  ///Returns the current value in the map at position (row, col)
  bool? getSequencerMapValue(int row, int col) {
    HashMap<int, bool>? tempMap = _sequencerMap?[col];
    return tempMap?[row];
  }

  ///Calculates the duration between a column audio play and the next one
  void calculateTick() {
    int? currentBPM = getBPM();
    double value = bpmBase / currentBPM;

    var splitted = value.toString().split("."); //splits in 2 parts
    int seconds = int.parse(splitted[0]);
    int decimal = int.parse(splitted[1]);
    if (decimal < 10) {
      decimal = decimal * 100;
    } else if (decimal > 10 && decimal < 100) {
      decimal = decimal * 10;
    } else if (decimal > 1000) {
      //Possible duration overflow, truncating result
      decimal = int.parse(decimal.toString().substring(0, 3));
    }
    _dur = Duration(seconds: seconds, milliseconds: decimal);
  }

  void startTimeout() {
    _timer = Timer.periodic(_dur, (Timer t) => handleTimeout());
  }

  ///Called by "Play" button
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

  ///Called by "Stop" button
  void handleStop() {
    _timer?.cancel();
    resetCounter();
    setIsRunning(false);
  }

  ///Called by "Pause" button
  void handlePause() {
    _timer?.cancel();
    setIsRunning(false);
  }

  void resetCounter() {
    counter.value = 0;
  }

  ///Called every time Dur object goes to 0, so the next row has to be played
  void handleTimeout() {
    incrementCounter();
    playPosition(counter.value);
  }

  ///Manipulates counter value between 0 and 7
  void incrementCounter() {
    counter.value ++;
    if (counter.value > 7) {
      counter.value = 0;
    }
  }

  ///Takes back sequencer map to default state (everything false)
  void resetSequencer() {
    for (int i = 0; i < 8; i ++) {
      HashMap<int, bool>? newMap = _sequencerMap?[i];
      for (int j = 0; j < 16; j ++) {
        newMap?.update(j, (existing) => false);
      }
    }
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

  int getMaxBpm() {
    return maxBpm;
  }

  HashMap<int, HashMap<int, bool>>? getSequencerMap() {
    return this._sequencerMap;
  }

  int getCounterValue() {
    return this.counter.value;
  }

  Duration getDur() {
    return this._dur;
  }

}