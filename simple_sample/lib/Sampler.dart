import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_sample/AudioController.dart';
import 'package:simple_sample/ToUpdateListController.dart';

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
    print("********************** INIT STATE SAMPLER *******************"); //chaimato solo una volta
    _controller = AudioController();
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
          ElevatedButton(onPressed: () => showDialog(
            context: context,
            builder: (context) => ToUploadList(),
          ), child: Text("Upload")), //todo on press apre menu con lista dei samples
        ],
      ),
    );
  }
}


class ToUploadList extends StatefulWidget {
  const ToUploadList({Key? key}) : super(key: key);

  @override
  _ToUploadListState createState() => _ToUploadListState();
}

class _ToUploadListState extends State<ToUploadList> {

  List<String> entries = ToUpdateListController().getElementsList();
  List<String> selectedEntries = [];

  String parseFilename(String path) {
    var splitted = path.split("/");
    return splitted[splitted.length-1];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        children: [
          Container(
            width: 100,
            height: 500,
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: entries.length,
              itemBuilder: (BuildContext context, int index) {
                return ToUploadItem(
                    item: parseFilename(entries[index]),
                    isSelected: (bool value) {
                      setState(() {
                        if (value) {
                          selectedEntries.add(entries[index]);
                          //Aggiunta al controller
                          ToUpdateListController().addElement(entries[index]);
                        } else {
                          selectedEntries.remove(entries[index]);
                          ToUpdateListController().removeElement(entries[index]);
                        }
                      });
                    },
                    key: Key(entries[index].length.toString()));
              },
              separatorBuilder: (BuildContext context, int index) => const Divider(),
            ),
          ),
          ElevatedButton(
              onPressed: () { ToUpdateListController().uploadSelectedElements(); },
              child: Text("Upload Selected Elements")),
        ],
      ),
    );
  }
}


class ToUploadItem extends StatefulWidget {

  final Key key;
  final String item;
  final ValueChanged<bool> isSelected;

  const ToUploadItem({required this.item, required this.isSelected, required this.key}) : super(key: key);

  @override
  _ToUploadItemState createState() => _ToUploadItemState();
}

class _ToUploadItemState extends State<ToUploadItem> {

  bool isSelected = false;

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: () {
        setState(() {
          isSelected = !isSelected;
          widget.isSelected(isSelected);
        });
      },
      child: Stack(
        children: [
          Text(widget.item),
          isSelected ? Container(
            width: 80,
              height: 10,
              child: Align( //se lo seleziono aggiunge il pallino blu
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.blue,
                  ),
                ),
              )
          ) : Container(width: 80, height: 10), //se lo deseleziono sostituisco il pallino bli con un container vuoto
        ],
      ),
    );
  }
}
