import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_sample/Models/Model.dart';
import 'package:simple_sample/Models/Record.dart';
import 'package:simple_sample/Controllers/SequencerController.dart';
import 'package:simple_sample/UI/Sequencer.dart';

void main() {

  test("initSequencerMap", () {
    SequencerController().initSequencerMap();
    HashMap<int, HashMap<int, bool>>? map = SequencerController().getSequencerMap();

    for (int i = 0; i < map!.length; i ++) {
      for (int j = 0; j < map[i]!.length; j ++) {
        bool val = SequencerController().getSequencerMapValue(j, i)!;
        expect(val, false);
      }
    }
  });

  test("Increment counter", () {

    SequencerController().resetCounter();
    SequencerController().incrementCounter();
    int value = SequencerController().getCounterValue();
    expect(value, 1);

  });

  test("Increment counter 2", () {

    SequencerController().resetCounter();
    SequencerController().incrementCounter();
    SequencerController().incrementCounter();
    SequencerController().incrementCounter();
    SequencerController().incrementCounter();
    SequencerController().incrementCounter();
    SequencerController().incrementCounter();
    SequencerController().incrementCounter();
    SequencerController().incrementCounter();
    int value = SequencerController().getCounterValue();
    expect(value, 0);

  });


  test("Reset Sequencer", () {

    SequencerController().resetSequencer();
    HashMap<int, HashMap<int, bool>>? map = SequencerController().getSequencerMap();

    for (int i = 0; i < map!.length; i ++) {
      for (int j = 0; j < map[i]!.length; j ++) {
        bool val = SequencerController().getSequencerMapValue(j, i)!;
        expect(val, false);
      }
    }

  });

  test("MAnage button press", () {
    SequencerController();
    SequencerController().manageButtonPress(5, 5); //random position
    bool? val = SequencerController().getSequencerMapValue(5, 5);
    expect(val!, true);
  });


  test("Is record at position null", () {

    WidgetsFlutterBinding.ensureInitialized();
    Model();
    bool res = SequencerController().isRecordAtPositionNull(6); //rand
    expect(res, true);

  });

  test("Is record at position null 2", () {

    WidgetsFlutterBinding.ensureInitialized();
    Model model = Model();
    Record rec = Record("url");
    model.addRecord(rec, 5);
    bool res = SequencerController().isRecordAtPositionNull(5); //rand
    expect(res, false);

  });

  test("CalculateTick", () {

    WidgetsFlutterBinding.ensureInitialized();
    Model();
    SequencerController().setBPM(60);
    SequencerController().calculateTick();
    Duration dur = SequencerController().getDur();
    Duration other = Duration(seconds: 1);
    int res = dur.compareTo(other); //returns 0 if they are equal
    expect(res, 0);

  });

  test("CalculateTick2", () {

    WidgetsFlutterBinding.ensureInitialized();
    Model();
    SequencerController().setBPM(120);
    SequencerController().calculateTick();
    Duration dur = SequencerController().getDur();
    Duration other = Duration(milliseconds: 500);
    int res = dur.compareTo(other); //returns 0 if they are equal
    expect(res, 0);

  });

}