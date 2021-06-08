import 'dart:async';
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:simple_sample/AudioController.dart';
import 'package:simple_sample/Model.dart';
import 'package:simple_sample/MyBottomNavigationBar.dart';

import 'Record.dart';

/// Class representing Sequencer UI

const double buttonSize = 25;
const double buttonContainerWidth = 40;
const double sizedBoxWidth = 5;
const double rowContainerHeight = 30;

const int bpmBase = 120;

class Sequencer extends StatefulWidget {
  const Sequencer({Key? key}) : super(key: key);

  @override
  _SequencerState createState() => _SequencerState();
}

class _SequencerState extends State<Sequencer> {

  AudioController? _controller;
  final _counter = ValueNotifier(0);
  HashMap<int, HashMap<int, bool>>? _sequencerMap = HashMap(); //mappa con 16 righe e 8 colonne. La mappa esterna contiene colonne, la seconda righe
  int tick = 0;
  Duration dur = new Duration();
  Timer? timer;

  @override
  void initState() {

    calculateTick();
    _controller = AudioController();
    //initSequencerMap();

    super.initState();
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

  void calculateTick() {
    int? currentBPM = _controller?.getBPM();

    setState(() {
      if (currentBPM != null) {
        tick = bpmBase ~/ currentBPM;
      }
      dur = Duration(seconds: tick);
    });
  }

  //Called when hit play
  void startTimeout(Duration duration) {
    calculateTick();
    print("Duration vale: "+duration.toString());
    timer = Timer.periodic(duration, (Timer t) => handleTimeout());
  }

  void handleStop() {
    timer?.cancel();
    resetCounter();
  }

  void handlePause() {
    timer?.cancel();
  }

  void handleTimeout() {
    playPosition(_counter.value);
    incrementCounter();
  }

  void resetCounter() {
    _counter.value = 0;
  }

  void incrementCounter() {
    _counter.value ++;
    if (_counter.value > 7) {
      _counter.value = 0;
    }
  }

  void playPosition(int pos) {
    print("Playing position "+pos.toString());
    HashMap<int, bool>? posList = _sequencerMap?[pos];
    if (posList != null) {
      for (int i = 0; i < 16; i ++) {
        if (posList[i] == true) {
          _controller?.play(i);
        }
      }
    }
  }

  bool? getSequencerMapValue(int row, int col) {
    HashMap<int, bool>? tempMap = _sequencerMap?[col];
    return tempMap?[row];
  }

  void manageButtonPress(int row, int col) {
    print("Managing row "+row.toString() + " on col "+col.toString());
    HashMap<int, bool>? tempMap = _sequencerMap?[col];
    if (tempMap?[row] == true) {
      setState(() {
        tempMap?.update(row, (existing) => false);
      });
    } else {
      setState(() {
        tempMap?.update(row, (existing) => true);
      });
    }
  }

  ButtonStyle getSequencerButtonStyle(int row, int col) {

    bool? value = getSequencerMapValue(row, col);
    Color colorToFill = Colors.teal;
    if (value != null && value) {
      colorToFill = Colors.pink;
    }

    return ButtonStyle(
      backgroundColor: MaterialStateColor.resolveWith((states) => colorToFill),
      minimumSize: MaterialStateProperty.resolveWith((states) => Size(buttonSize, buttonSize)),
    );
  }

  Widget createSequencerRow(int number) {
    return Container(
      height: rowContainerHeight,
      child: Row(
        children: [
          SizedBox(width: sizedBoxWidth,),
          Container(
            width: buttonContainerWidth,
            child: Text("S "+number.toString()),
          ),
          Container(
            width: buttonContainerWidth,
            child: ElevatedButton(onPressed: () => manageButtonPress(number, 0), child: null, style: getSequencerButtonStyle(number, 0),),
          ),
          SizedBox(width: sizedBoxWidth,),
          Container(
            width: buttonContainerWidth,
            child: ElevatedButton(onPressed: () => manageButtonPress(number, 1), child: null, style: getSequencerButtonStyle(number, 1),),
          ),
          SizedBox(width: sizedBoxWidth,),
          Container(
            width: buttonContainerWidth,
            child: ElevatedButton(onPressed: () => manageButtonPress(number, 2), child: null, style: getSequencerButtonStyle(number, 2),),
          ),
          SizedBox(width: sizedBoxWidth,),
          Container(
            width: buttonContainerWidth,
            child: ElevatedButton(onPressed: () => manageButtonPress(number, 3), child: null, style: getSequencerButtonStyle(number, 3),),
          ),
          SizedBox(width: sizedBoxWidth,),
          Container(
            width: buttonContainerWidth,
            child: ElevatedButton(onPressed: () => manageButtonPress(number, 4), child: null, style: getSequencerButtonStyle(number, 4),),
          ),
          SizedBox(width: sizedBoxWidth,),
          Container(
            width: buttonContainerWidth,
            child: ElevatedButton(onPressed: () => manageButtonPress(number, 5), child: null, style: getSequencerButtonStyle(number, 5),),
          ),
          SizedBox(width: sizedBoxWidth,),
          Container(
            width: buttonContainerWidth,
            child: ElevatedButton(onPressed: () => manageButtonPress(number, 6), child: null, style: getSequencerButtonStyle(number, 6),),
          ),
          SizedBox(width: sizedBoxWidth,),
          Container(
            width: buttonContainerWidth,
            child: ElevatedButton(onPressed: () => manageButtonPress(number, 7), child: null, style: getSequencerButtonStyle(number, 7),),
          ),
        ],
      ),
    );
  }

  Widget buildSequencer() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ValueListenableBuilder(
              valueListenable: _counter,
              builder: (context, value, child) {
                return SequencerPointer(_counter);
          }),
          createSequencerRow(0),
          createSequencerRow(1),
          createSequencerRow(2),
          createSequencerRow(3),
          createSequencerRow(4),
          createSequencerRow(5),
          createSequencerRow(6),
          createSequencerRow(7),
          createSequencerRow(8),
          createSequencerRow(9),
          createSequencerRow(10),
          createSequencerRow(11),
          createSequencerRow(12),
          createSequencerRow(13),
          createSequencerRow(14),
          createSequencerRow(15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: () => startTimeout(dur), child: Text("play"), style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.blueGrey),),),
              SizedBox(width: sizedBoxWidth,),
              ElevatedButton(onPressed: handleStop, child: Text("stop"), style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.blueGrey),),),
              SizedBox(width: sizedBoxWidth,),
              ElevatedButton(onPressed: handlePause, child: Text("pause"), style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.blueGrey),),),
              SizedBox(width: sizedBoxWidth*2,),
              BPMSelector(controller: _controller),
            ],
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  buildSequencer(),
    );
  }
}

class SequencerPointer extends StatelessWidget {
  final ValueListenable<int> number;

  //Costruttore
  SequencerPointer(this.number);

  Color takeColor(int index) {
    if (index == number.value) {
      return Colors.yellow;
    } else {
      return Colors.blueGrey;
    }
  }

  ButtonStyle getSequencerButtonStyle(int index) {
    return ButtonStyle(
      backgroundColor: MaterialStateColor.resolveWith((states) => takeColor(index)),
      minimumSize: MaterialStateProperty.resolveWith((states) => Size(buttonSize, buttonSize)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: sizedBoxWidth,),
        Container(
          width: buttonContainerWidth,
          child: null,
        ),
        //Metto onpressed vuoto altrimenti i bottoni non vengono abilitati
        Container(
          width: buttonContainerWidth,
          child: ElevatedButton(onPressed: () {}, child: Text("1"), style: getSequencerButtonStyle(0)),
        ),
        SizedBox(width: sizedBoxWidth,),
        Container(
          width: buttonContainerWidth,
          child: ElevatedButton(onPressed: () {}, child: Text("2"), style: getSequencerButtonStyle(1)),
        ),
        SizedBox(width: sizedBoxWidth,),
        Container(
          width: buttonContainerWidth,
          child: ElevatedButton(onPressed: () {}, child: Text("3"), style: getSequencerButtonStyle(2)),
        ),
        SizedBox(width: sizedBoxWidth,),
        Container(
          width: buttonContainerWidth,
          child: ElevatedButton(onPressed: () {}, child: Text("4"), style: getSequencerButtonStyle(3)),
        ),
        SizedBox(width: sizedBoxWidth,),
        Container(
          width: buttonContainerWidth,
          child: ElevatedButton(onPressed: () {}, child: Text("5"), style: getSequencerButtonStyle(4)),
        ),
        SizedBox(width: sizedBoxWidth,),
        Container(
          width: buttonContainerWidth,
          child: ElevatedButton(onPressed: () {}, child: Text("6"), style: getSequencerButtonStyle(5)),
        ),
        SizedBox(width: sizedBoxWidth,),
        Container(
          width: buttonContainerWidth,
          child: ElevatedButton(onPressed: () {}, child: Text("7"), style: getSequencerButtonStyle(6)),
        ),
        SizedBox(width: sizedBoxWidth,),
        Container(
          width: buttonContainerWidth,
          child: ElevatedButton(onPressed: () {}, child: Text("8"), style: getSequencerButtonStyle(7)),
        ),
      ],
    );
  }
}


class BPMSelector extends StatefulWidget {

  final AudioController? controller;

  const BPMSelector({Key? key, required this.controller}) : super(key: key);

  @override
  _BPMSelectorState createState() => _BPMSelectorState(controller: controller);
}

class _BPMSelectorState extends State<BPMSelector> {
  int counter = 0;
  AudioController? controller;

  _BPMSelectorState({required this.controller});

  @override
  void initState() {
    counter =  controller!.getBPM();
    super.initState();
  }

  void increment() {
    setState(() {
      if (counter < 120) {
        counter ++;
        controller?.setBPM(counter);
      }
    });
  }

  void decrement() {
    setState(() {
      if (counter > 0) {
        counter --;
        controller?.setBPM(counter);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onVerticalDragUpdate: (DragUpdateDetails details) {
          if (details.delta.dy > 0) { //To the bottom
            decrement();
          } else if (details.delta.dy < 0){ //to the top
            increment();
          }

        },
        child: Container (
          decoration: BoxDecoration(
              border: Border.all(color: Colors.teal, width: 3.0)
          ),
          width: buttonContainerWidth,
          height: buttonContainerWidth,
          child: Center(
            child: Text(counter.toString(),),
          ),
        ),
    );
  }
}

