import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_sample/AudioController.dart';

/// Class representing Sampler UI

const double horizontalSpacing = 30;
const double verticalSpacing = 30;
const double elevationValue = 20;
const double buttonSize = 70;

class Sampler extends StatefulWidget {
  const Sampler({Key? key}) : super(key: key);

  @override
  _SamplerState createState() => _SamplerState();
}

class _SamplerState extends State<Sampler> {

  AudioController? _controller;

  @override
  void initState() {
    print("********************** CHIAMATO INIT STATE *******************"); //chaimato solo una volta
    _controller = AudioController();
    //_controller?.initAudioController();
    super.initState();
  }

  /*@override
  void dispose() {
    print("Dispose sampler");
    //_controller?.disposeSampler();
    super.dispose();
  }*/

  ButtonStyle getSamplerButtonStyle() {
    return ButtonStyle(
      backgroundColor: MaterialStateColor.resolveWith((states) => Colors.teal),
      elevation: MaterialStateProperty.resolveWith((states) => elevationValue),
      shadowColor: MaterialStateProperty.resolveWith((states) => Colors.pinkAccent),
      enableFeedback: true,
      minimumSize: MaterialStateProperty.resolveWith((states) => Size(buttonSize, buttonSize)),
    );
  }

  Widget createButton(int index) {
    return GestureDetector(
      onLongPress: () => _controller?.record(index),
      onLongPressUp: () => _controller?.stopRecorder(),
      child: ElevatedButton(
        child: Text("Lp "+index.toString()),
        onPressed: () => _controller?.play(index),
        style: getSamplerButtonStyle(),
      ),
    );
  }

  ///Create a sampler Row
  Widget createSamplerRow(int startIndex) {

    List<int> indexes = List.filled(4, 0);
    for (int i = 0; i < indexes.length; i ++) {
      indexes[i] = startIndex + i;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        createButton(indexes[0]),
        SizedBox(width:horizontalSpacing),
        createButton(indexes[1]),
        SizedBox(width:horizontalSpacing),
        createButton(indexes[2]),
        SizedBox(width:horizontalSpacing),
        createButton(indexes[3]),
        SizedBox(width:horizontalSpacing),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          createSamplerRow(0),
          SizedBox(height: verticalSpacing,),
          createSamplerRow(4),
          SizedBox(height: verticalSpacing,),
          createSamplerRow(8),
          SizedBox(height: verticalSpacing,),
          createSamplerRow(12),
          SizedBox(height: verticalSpacing,),
          Text("TIMER")
        ],
      ),
    );
  }
}
