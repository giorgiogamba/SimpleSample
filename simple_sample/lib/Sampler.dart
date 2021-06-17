import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:simple_sample/AudioController.dart';
import 'package:simple_sample/NotificationController.dart';
import 'package:simple_sample/SamplerController.dart';
import 'package:simple_sample/ShareDialogController.dart';
import 'package:simple_sample/ToUpdateListController.dart';

import 'Explorer.dart';
import 'Model.dart';
import 'Record.dart';

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

  AudioController _audioController = AudioController();
  SamplerController _samplerController = SamplerController();

  @override
  void initState() {
    NotificationController();

    //todo eseguire inizializzazione recorder
    _samplerController.disableItemSelection();
    super.initState();
  }

  /*@override
  void dispose() {
  //todo eseguire dispose recorder
    print("Dispose sampler");
    //_controller?.disposeSampler();
    super.dispose();
  }*/

  ButtonStyle getSamplerButtonStyle(int index) {
    return ButtonStyle(
      backgroundColor: getSamplerColor(index),
      elevation: MaterialStateProperty.resolveWith((states) => elevationValue),
      shadowColor: MaterialStateProperty.resolveWith((states) =>
      Colors.pinkAccent),
      enableFeedback: true,
      minimumSize: MaterialStateProperty.resolveWith((states) =>
          Size(buttonSize, buttonSize)),
    );
  }

  MaterialStateProperty<Color?>? getSamplerColor(int index) {
    if (_samplerController.checkIsButtonIsFull(
        index)) { //there is a record on this button
      return MaterialStateColor.resolveWith((states) => Colors.pink);
    } else {
      return MaterialStateColor.resolveWith((states) => Colors.teal);
    }
  }

  Widget createButton(int index) {
    return Stack(
      children: [
        GestureDetector(
          onLongPress: () =>
          !_samplerController.isEnabledItemSelection()
              ? _audioController.record(index)
              : {},
          onLongPressUp: () {
            _audioController.stopRecorder();
            setState(() {});
          },
          child: ElevatedButton(
            //child: Center(
              //child: Container(
                //width: buttonSize,
                //height: buttonSize,
                child: Text(_samplerController.getButtonName(index)),
              //),
            //),
            onPressed: () {
              if (!_samplerController.isEnabledItemSelection()) { //Item selection not enablesd playing record
                _audioController.play(index);
              } else { //Item selection enabled

                print("siRenameRunning; "+_samplerController.isRenameRunning().toString());
                print("siSharingRunning; "+_samplerController.isSharingRunning().toString());

                if (!_samplerController.isRenameRunning() && !_samplerController.isSharingRunning()) { //Loading
                  setState(() {
                    print("Associating button to record");
                    _samplerController.associateFileToButton(index);
                    _samplerController.disableItemSelection();
                    _audioController.enablePlayback();
                  });
                } else if (_samplerController.isRenameRunning()) { //Renaming
                  print("Associating button for renaming");
                  _samplerController.setSelectedItemForRename(index);
                  showDialog(
                    context: context,
                    builder: (context) => RenamePage(samplerController: _samplerController,)).then((value) {
                      if (_samplerController.getRenameSubmitted()) {
                        _samplerController.renameRecord().then((value) {
                          _samplerController.disableRenaming();
                          _samplerController.disableItemSelection();
                          setState(() {});
                        });
                      } else {
                        print("No selected item, rename is not possible");
                      }
                    });
                } else if (_samplerController.isSharingRunning()) { //sharing
                  print("Associating button for sharing");
                  _samplerController.disableItemSelection();
                  setState(() {});

                  Record? toShare = _samplerController.getSelectedItemForSharing(index);
                  if (toShare != null) {
                    showDialog(
                      context: context,
                      builder: (context) => SharingDialog(record: toShare, key: Key(toShare.getFilename())),
                    ).then((value) => _samplerController.disableSharing());
                    print("Sono dpo il dialog");

                  } else {
                    print("Sampler -- Share Button -- sleected item is null");
                  }
                }
              }
            },
            style: getSamplerButtonStyle(index),
          ),
        ),
        _samplerController.isEnabledItemSelection() ?
        Container(
            width: 10,
            height: 10,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.pink,
                ),
              ),
            )
        ) : Container(width: 10, height: 10,),
      ],
    );
  }

  Widget selectButtonWidgetChild() {
    if (!_samplerController.isRenameRunning()) {
      return Text("Rename");
    } else {
      return Text("Cancel");
    }
  }

  Widget selectSharingButtonName() {
    if (_samplerController.isSharingRunning()) {
      return Text("Cancel");
    } else {
      return Text("Share");
    }
  }

  ButtonStyle getRenameButtonStyle() {
    if (_samplerController.isRenameRunning()) {
      return ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.red),);
    } else {
      return ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.blueGrey),);
    }
  }

  ButtonStyle getSharingButtonStyle() {
    if (_samplerController.isSharingRunning()) {
      return ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.red),);
    } else {
      return ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.blueGrey),);
    }
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
        SizedBox(width: horizontalSpacing),
        createButton(indexes[1]),
        SizedBox(width: horizontalSpacing),
        createButton(indexes[2]),
        SizedBox(width: horizontalSpacing),
        createButton(indexes[3]),
        SizedBox(width: horizontalSpacing),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, //to avoid keyboard overflow
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 30,
            width: 400,
            child: Center(
              child: Text(
                _samplerController.getOperationInformationText(),
                style: TextStyle(fontSize: 30),
              ),
            ),
          ),
          SizedBox(height: verticalSpacing,),
          createSamplerRow(0),
          SizedBox(height: verticalSpacing,),
          createSamplerRow(4),
          SizedBox(height: verticalSpacing,),
          createSamplerRow(8),
          SizedBox(height: verticalSpacing,),
          createSamplerRow(12),
          SizedBox(height: verticalSpacing,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: () {
                if (!_samplerController.isSharingRunning() && !_samplerController.isRenameRunning()) {
                  _samplerController.pickFile().then((value) {
                    setState(() {
                      _samplerController.enableItemSelection();
                      print("*** Ho cambiato lo stato, itemSelection vale: " +
                          _samplerController.isEnabledItemSelection()
                              .toString());
                      if (value != null && value != "") {
                        _samplerController.setSelectedURL(value);
                        print("Ho impostato URL");
                      } else {
                        print("ERROR: the selected URL is null");
                      }
                    });
                  });
                } else {
                  print("Another operation is running");
                }
              },
                child: Text("Load"),
                style: ButtonStyle(backgroundColor:  MaterialStateColor.resolveWith((states) => Colors.blueGrey),),
              ),
              SizedBox(width: 20),
              ElevatedButton(onPressed: () {
                if (_samplerController.checkIfUserConnected()) {
                  if (!_samplerController.isSharingRunning() &&
                      !_samplerController.isRenameRunning()) {
                    showDialog(
                      context: context,
                      builder: (context) => ToUploadList(),
                    );
                  } else {
                    print("Another operation is running");
                  }
                } else {
                  print("User is not connected");
                }
              },
                child: Text("Upload"),
                style: ButtonStyle(backgroundColor:  MaterialStateColor.resolveWith((states) => Colors.blueGrey),),
              ),
              SizedBox(width: 20),
              ElevatedButton( onPressed: () {
                if (_samplerController.checkIfUserConnected()) { //user is connected
                  if (!_samplerController.isRenameRunning()) {
                    setState(() {
                      if (!_samplerController.isSharingRunning()) {
                        //Enabling sharing
                        _samplerController.enableItemSelection();
                        print("Enabled item selection for sharing");
                        _samplerController.enableSharing();
                      } else {
                        //Disabling sharing
                        setState(() {
                          _samplerController.disableSharing();
                          _samplerController.disableItemSelection();
                        });
                      }
                    });
                  } else {
                    print("Another operation is running");
                  }
                } else { //user is not connected
                  print("User is not connected");
                }
              },
                child: selectSharingButtonName(),
                style: getSharingButtonStyle(),
              ),
              SizedBox(width: 20),
              ElevatedButton(onPressed: () {
                if (!_samplerController.isSharingRunning()) {
                  if (!_samplerController.isRenameRunning()) { //Enable Renaming
                    setState(() {
                      _samplerController.enableItemSelection();
                      _samplerController.enableRenaming();
                    });
                  } else { //Disable renaming
                    print("DIsabling renamning");
                    setState(() {
                      _samplerController.disableItemSelection();
                      _samplerController.disableRenaming();
                    });
                  }
                } else {
                  print("Another operation is running");
                }
              },
                child: selectButtonWidgetChild(),
              style: getRenameButtonStyle(),),
            ],
          ),
        ],
      ),
    );
  }
}


class SharingDialog extends StatefulWidget {

  //final SamplerController controller;
  final Record record;
  final Key key;

  const SharingDialog({/*required this.controller*/ required this.record, required this.key}) : super(key: key);

  @override
  _SharingDialogState createState() => _SharingDialogState();
}

class _SharingDialogState extends State<SharingDialog> {

  ShareDialogController _controller = ShareDialogController();
  TextEditingController _textFieldController = TextEditingController();

  Widget makePage() {
    return AlertDialog (
      content: Container(
        width: 250,
        height: 470,
        child: Column(
          children: [
            Text("Insert Sample Infos:"),
            SizedBox(height: 20,),
            TextField(
              controller: _textFieldController,
              decoration: InputDecoration (
                border: OutlineInputBorder(),
                labelText: "Sample Name",
              ),
            ),
            SizedBox(height: 20),
            Text("Choose one or more tags"),
            SizedBox(height: 20),
            makeTagList(),
            ElevatedButton(
              onPressed: () => _controller.share(_textFieldController.text).then((value) => Navigator.pop(context)),
              child: Text("Share"),
            ),
          ],
        ),
      ),
    );
  }


  Widget makeTagList() {
    return Container(
      width: 200,
      height: 250,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.teal,
        ),
      ),
      child: ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          return TagListButton(
            item: index,
            isSelected: (value) {
              if (value) {
                _controller.addToSelectedTags(index);
              } else {
                _controller.removeFromSelectedTags(index);
              }
            },
            key: Key(_controller.getTagsListLength().toString()),
            controller: _controller,
          );
        },
        separatorBuilder: (BuildContext context, int index) => MyDivider(),
        itemCount: _controller.getTagsListLength(),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    _controller.setSelectedEntry(widget.record);
    return makePage();
  }
}


class TagListButton extends StatefulWidget {

  final int item;
  final ValueChanged<bool> isSelected;
  final Key key;
  final ShareDialogController controller;

  const TagListButton({required this.item, required this.isSelected, required this.key, required this.controller}) : super(key: key);

  @override
  _TagListButtonState createState() => _TagListButtonState();
}

class _TagListButtonState extends State<TagListButton> {

  bool isSelected = false;

  Color getColor() {
    if (isSelected) {
      return Colors.red;
    } else {
      return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          color: getColor(),
        ),
        child: Text(widget.controller.getTagAt(widget.item)),
      ),
      onTap: () {
        setState(() {
          isSelected = !isSelected;
          widget.isSelected(isSelected);
        });
      }
    );
  }
}


class LoadDialog extends StatelessWidget {
  const LoadDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        children: [
          Text("File Loading Dialog, implement"),
          ElevatedButton(onPressed: () => SamplerController().pickFile(), child: Text("LOAD")),
        ],
      ),
    );
  }
}


class RenamePage extends StatelessWidget {
  const RenamePage({Key? key, required this.samplerController}) : super(key: key);

  final SamplerController samplerController;

  @override
  Widget build(BuildContext context) {

    samplerController.setRenameSubmitted(false);

    return AlertDialog(
      content: Container(
        width: 200,
        height: 150,
        child: Column(
          children: [
            Text("Choose a new name for the Sampler",),
            Padding(padding: EdgeInsets.symmetric(vertical: 4),),
            TextField(
              controller: samplerController.getTextEditingController(),
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 4),),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(onPressed: () {
                  Navigator.pop(context);
                }, child: Text("Cancel")),
                ElevatedButton(onPressed: () {
                  samplerController.setRenameSubmitted(true);
                  Navigator.pop(context);
                }, child: Text("Submit")),
              ],
            ),
          ],
        ),
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

  ToUpdateListController _toUpdateListController = ToUpdateListController();
  List<Record> entries = [];
  List<Record> selectedEntries = [];

  @override
  void initState() {
    entries = _toUpdateListController.getElementsList();
    super.initState();
  }

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
            width: 200,
            height: 500,
            child: ListView.separated(
              padding: const EdgeInsets.all(8), //porre a 0 se si vuole che riempa tutto lo spazion padre
              physics: ClampingScrollPhysics(),
              itemCount: entries.length,
              itemBuilder: (BuildContext context, int index) {
                return ToUploadItem(
                  item: entries[index].getFilename(),
                  isSelected: (bool value) {
                    setState(() {
                      if (value) {
                        selectedEntries.add(entries[index]);
                        _toUpdateListController.addElement(entries[index]);
                      } else {
                        selectedEntries.remove(entries[index]);
                        _toUpdateListController.removeElement(entries[index]);
                      }
                    });},
                  key: Key(entries.length.toString()),
                );
              },
              separatorBuilder: (BuildContext context, int index) => const Divider(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel"),
                style: ButtonStyle(backgroundColor:  MaterialStateColor.resolveWith((states) => Colors.blueGrey),),
              ),
              Padding(padding: EdgeInsets.all(5)),
              ElevatedButton(
                onPressed: () {
                  if (entries.length > 0) {
                    _toUpdateListController.uploadSelectedElements();
                  };
                },
                child: Text("Upload Selected Elements"),
                style: ButtonStyle(backgroundColor:  MaterialStateColor.resolveWith((states) => Colors.blueGrey),)
              ),
            ],
          ),
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













