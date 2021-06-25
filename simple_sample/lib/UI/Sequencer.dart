import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:simple_sample/Controllers/AudioController.dart';
import 'package:simple_sample/Controllers/SequencerController.dart';

/// Class representing Sequencer UI

const double buttonSize = 25;
const double buttonContainerWidth = 40;
const double sizedBoxWidth = 5;
const double rowContainerHeight = 30;

class Sequencer extends StatefulWidget {
  const Sequencer({Key? key}) : super(key: key);

  @override
  _SequencerState createState() => _SequencerState();
}

class _SequencerState extends State<Sequencer> {

  late SequencerController _sequencerController;

  @override
  void initState() {
    _sequencerController = SequencerController();
    _sequencerController.calculateTick();
    super.initState();
  }

  ButtonStyle getSequencerButtonStyle(int row, int col) {

    bool? value = _sequencerController.getSequencerMapValue(row, col);
    Color colorToFill = Colors.teal;
    if (value != null && value) {
      colorToFill = Colors.pink;
    }

    return ButtonStyle(
      backgroundColor: MaterialStateColor.resolveWith((states) => colorToFill),
      minimumSize: MaterialStateProperty.resolveWith((states) => Size(buttonSize, buttonSize)),
    );
  }

  Color? setContainerRowColor(int index) {
    if (_sequencerController.isRecordAtPositionNull(index)) { //record is null
      return null;
    } else { //record is not null
      return Colors.red;
    }
  }

  Widget createSequencerRow(int number) {
    return Container(
      height: rowContainerHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: buttonContainerWidth,
            child: Text("S "+number.toString(), style: TextStyle(color: Colors.white), textAlign: TextAlign.center,),
            color: setContainerRowColor(number),
          ),
          Container(
            width: buttonContainerWidth,
            child: ElevatedButton(
              onPressed: () {
                _sequencerController.manageButtonPress(number, 0);
                setState(() {});
              },
              child: null,
              style: getSequencerButtonStyle(number, 0),
            ),
          ),
          Container(
            width: buttonContainerWidth,
            child: ElevatedButton(
              onPressed: () {
                _sequencerController.manageButtonPress(number, 1);
                setState(() {});
              },
              child: null,
              style: getSequencerButtonStyle(number, 1),
            ),
          ),
          Container(
            width: buttonContainerWidth,
            child: ElevatedButton(
              onPressed: () {
                _sequencerController.manageButtonPress(number, 2);
                setState(() {});
              },
              child: null,
              style: getSequencerButtonStyle(number, 2),
            ),
          ),
          Container(
            width: buttonContainerWidth,
            child: ElevatedButton(
              onPressed: () {
                _sequencerController.manageButtonPress(number, 3);
                setState(() {});
              },
              child: null,
              style: getSequencerButtonStyle(number, 3),
            ),
          ),
          Container(
            width: buttonContainerWidth,
            child: ElevatedButton(
              onPressed: () {
                _sequencerController.manageButtonPress(number, 4);
                setState(() {});
              },
              child: null,
              style: getSequencerButtonStyle(number, 4),
            ),
          ),
          Container(
            width: buttonContainerWidth,
            child: ElevatedButton(
              onPressed: () {
                _sequencerController.manageButtonPress(number, 5);
                setState(() {});
              },
              child: null,
              style: getSequencerButtonStyle(number, 5),
            ),
          ),
          Container(
            width: buttonContainerWidth,
            child: ElevatedButton(
              onPressed: () {
                _sequencerController.manageButtonPress(number, 6);
                setState(() {});
              },
              child: null,
              style: getSequencerButtonStyle(number, 6),
            ),
          ),
          Container(
            width: buttonContainerWidth,
            child: ElevatedButton(
              onPressed: () {
                _sequencerController.manageButtonPress(number, 7);
                setState(() {});
              },
              child: null,
              style: getSequencerButtonStyle(number, 7),
            ),
          ),
          Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
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
              valueListenable: _sequencerController.counter,
              builder: (context, value, child) {
                return SequencerPointer(_sequencerController.counter);
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
          Padding(padding: EdgeInsets.symmetric(vertical: 5),),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _sequencerController.handlePlay(),
                child: Icon(Icons.play_arrow),
                style: ButtonStyle(
                  backgroundColor: MaterialStateColor.resolveWith((states) => Colors.blueGrey),),
              ),
              Padding(padding: EdgeInsets.symmetric(horizontal: 3),),
              ElevatedButton(
                onPressed: _sequencerController.handleStop,
                child: Icon(Icons.stop),
                style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.blueGrey),),
              ),
              Padding(padding: EdgeInsets.symmetric(horizontal: 3),),
              ElevatedButton(
                onPressed: _sequencerController.handlePause,
                child: Icon(Icons.pause),
                style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.blueGrey),),
              ),
              Padding(padding: EdgeInsets.symmetric(horizontal: 3),),
              ElevatedButton(
                onPressed: () {
                  _sequencerController.resetSequencer();
                  setState(() {});
                },
                child: Text("Reset"),
                style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.blueGrey),),
              ),
              Padding(padding: EdgeInsets.symmetric(horizontal: 3),),
              BPMSelector(controller: _sequencerController),
            ],
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Container(
        child: buildSequencer(),
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
            colors: [
              Color.fromRGBO(20, 30, 48, 1),
              Color.fromRGBO(36, 59, 85, 1),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
      ),
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
        Container(
          width: buttonContainerWidth,
          child: null,
        ),
        Container(
          width: buttonContainerWidth,
          child: ElevatedButton(onPressed: () {}, child: Text("1"), style: getSequencerButtonStyle(0)),
        ),
        Container(
          width: buttonContainerWidth,
          child: ElevatedButton(onPressed: () {}, child: Text("2"), style: getSequencerButtonStyle(1)),
        ),
        Container(
          width: buttonContainerWidth,
          child: ElevatedButton(onPressed: () {}, child: Text("3"), style: getSequencerButtonStyle(2)),
        ),
        Container(
          width: buttonContainerWidth,
          child: ElevatedButton(onPressed: () {}, child: Text("4"), style: getSequencerButtonStyle(3)),
        ),
        Container(
          width: buttonContainerWidth,
          child: ElevatedButton(onPressed: () {}, child: Text("5"), style: getSequencerButtonStyle(4)),
        ),
        Container(
          width: buttonContainerWidth,
          child: ElevatedButton(onPressed: () {}, child: Text("6"), style: getSequencerButtonStyle(5)),
        ),
        Container(
          width: buttonContainerWidth,
          child: ElevatedButton(onPressed: () {}, child: Text("7"), style: getSequencerButtonStyle(6)),
        ),
        Container(
          width: buttonContainerWidth,
          child: ElevatedButton(onPressed: () {}, child: Text("8"), style: getSequencerButtonStyle(7)),
        ),
        Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
      ],
    );
  }
}


class BPMSelector extends StatefulWidget {

  final SequencerController controller;

  const BPMSelector({Key? key, required this.controller}) : super(key: key);

  @override
  _BPMSelectorState createState() => _BPMSelectorState();
}

class _BPMSelectorState extends State<BPMSelector> {
  int counter = 0;

  @override
  void initState() {
    counter =  widget.controller.getBPM();
    super.initState();
  }

  void increment() {
    setState(() {
      if (counter < widget.controller.getMaxBpm()) {
        counter ++;
        widget.controller.setBPM(counter);
      }
    });
  }

  void decrement() {
    setState(() {
      if (counter > 0) {
        counter --;
        widget.controller.setBPM(counter);
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
            child: Text(counter.toString(), style: TextStyle(color: Colors.white),),
          ),
        ),
    );
  }
}

