import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:simple_sample/Controllers/AudioController.dart';
import 'package:simple_sample/Controllers/AuthenticationController.dart';
import 'package:simple_sample/Controllers/CloudStorageController.dart';
import 'package:simple_sample/Controllers/GoogleDriveController.dart';
import 'package:simple_sample/Controllers/NotificationController.dart';
import 'package:simple_sample/Controllers/SamplerController.dart';
import 'package:simple_sample/Controllers/ShareDialogController.dart';
import 'package:simple_sample/Controllers/ToUpdateListController.dart';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:simple_sample/Utils/Languages.dart';
import 'package:simple_sample/Utils/LocaleConstant.dart';
import 'package:simple_sample/main.dart';

import 'Explorer.dart';
import '../Models/Model.dart';
import '../Models/Record.dart';
import '../Utils.dart';

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
  StreamSubscription? _recorderSubscription;
  double _screenHeight = 0;
  double _screenWidth = 0;

  @override
  void initState() {
    NotificationController();
    //GoogleDriveController(); //so I'm sure it's already initialized

    _audioController.initRecorder().then((value) {
      //Recording time initialization
      initializeDateFormatting();
      _recorderSubscription = _audioController.getRecorder().onProgress!.listen((e) {
        //todo IOS: non viene eseguito il metodo listen -> impedisce di avere il cronometro
        var date = DateTime.fromMillisecondsSinceEpoch(e.duration.inMilliseconds, isUtc: true);
        var txt = DateFormat('mm:ss:SS', 'en_GB').format(date);

        setState(() {
          _samplerController.setOperationInformationTxt(txt.substring(0, 8));
        });
      });

    });

    _samplerController.disableItemSelection();
    super.initState();
  }

  @override
  void dispose() {
    print("Dispose sampler");
    _audioController.disposeRecorder();
    super.dispose();
  }

  Color chooseIconColor(int index) {
    if (_samplerController.checkIsButtonIsFull(index)) {
      return Colors.teal;
    } else {
      return Colors.pink;
    }
  }

  ButtonStyle getSamplerButtonStyle(int index) {
    return ButtonStyle(
      backgroundColor: getSamplerColor(index),
      elevation: MaterialStateProperty.resolveWith((states) => elevationValue),
      shadowColor: MaterialStateProperty.resolveWith((states) => Colors.pinkAccent),
      enableFeedback: true,
      minimumSize: MaterialStateProperty.resolveWith((states) =>
          /*Size(buttonSize, buttonSize))*/ Size(/*70*/ _screenWidth/5.85, /*70*/ _screenWidth/5.85)),
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
            child: Text(Utils.wrapText(Utils.removeExtension(_samplerController.getButtonName(index)), 5)),
            onPressed: () {
              if (!_samplerController.isEnabledItemSelection()) { //Item selection not enablesd playing record
                _audioController.play(index);
              } else { //Item selection enabled

                if (_samplerController.isLoadingRunning()) { //Loading
                  setState(() {
                    print("Associating button to record");
                    _samplerController.associateFileToButton(index);
                    _samplerController.disableItemSelection();
                    _samplerController.disableLoading();
                    _audioController.enablePlayback();
                  });
                } else if (_samplerController.isRenameRunning()) { //Renaming
                  print("Associating button for renaming");

                  if (_samplerController.isRenamePossible(index)) {
                    _samplerController.setSelectedItemForRename(index);
                    showDialog(
                      barrierDismissible: false,
                        context: context,
                        builder: (context) =>
                            RenamePage(samplerController: _samplerController,))
                        .then((value) {
                      if (_samplerController.getRenameSubmitted()) {
                        _samplerController.renameRecord().then((value) {
                          _samplerController.disableRenaming();
                          _samplerController.disableItemSelection();
                          setState(() {});
                        });
                      } else {
                        print("No selected item, rename is not possible");
                        setState(() {
                          _samplerController.disableRenaming();
                          _samplerController.disableItemSelection();
                        });
                      }
                    });
                  } else {
                    Utils.showToast(context, Languages.of(context)!.cannotSelect);
                  }
                } else if (_samplerController.isSharingRunning()) { //sharing
                  print("Associating button for sharing");
                  setState(() {});

                  Record? toShare = _samplerController.getSelectedItemForSharing(index);
                  if (toShare != null) {
                    _samplerController.disableItemSelection();
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) => SharingDialog(record: toShare, key: Key(toShare.getFilename())),
                    ).then((value) {
                      setState(() {
                        _samplerController.disableSharing();
                      });
                    });

                  } else {
                    print("Sampler -- Share Button -- sleected item is null");
                    Utils.showToast(context, Languages.of(context)!.cannotSelect);
                  }
                }
              }
            },
            style: getSamplerButtonStyle(index),
          ),
        ),
        (_samplerController.isEnabledItemSelection() &&
            (_samplerController.checkIsButtonIsFull(index) || _samplerController.isLoadingRunning())) ?
        Container(
            width: /*10*/ _screenWidth/41,
            height: /*10*/ _screenWidth/41,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Icon(
                  Icons.check_circle,
                  color: chooseIconColor(index),
                ),
              ),
            )
        ) : Container(width: /*10*/ _screenWidth/41, height: /*10*/ _screenWidth/41,),
      ],
    );
  }

  Widget selectButtonWidgetChild() {
    if (!_samplerController.isRenameRunning()) {
      return Text(Languages.of(context)!.renameName);
    } else {
      return Text(Languages.of(context)!.cancelName);
    }
  }

  Widget selectSharingButtonName() {
    if (_samplerController.isSharingRunning()) {
      //return Text("Cancel");
      return Text(Languages.of(context)!.cancelName);
    } else {
      //return Text("Share");
      return Text(Languages.of(context)!.shareName);
    }
  }

  Widget getLoadButtonName() {
    if (_samplerController.isLoadingRunning()) {
      return Text(Languages.of(context)!.cancelName);
    } else {
      return Text(Languages.of(context)!.loadName);
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

  ButtonStyle getLoadingButtonStyle() {
    if (_samplerController.isLoadingRunning()) {
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
        Padding(padding: EdgeInsets.symmetric(horizontal: /*10*/ _screenWidth/41)),
        createButton(indexes[1]),
        Padding(padding: EdgeInsets.symmetric(horizontal: /*10*/ _screenWidth/41)),
        createButton(indexes[2]),
        Padding(padding: EdgeInsets.symmetric(horizontal: /*10*/ _screenWidth/41)),
        createButton(indexes[3]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    //Getting sceen's size
    _screenHeight = MediaQuery.of(context).size.height;
    _screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false, //to avoid keyboard overflow
      body: Container(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: /*30*/ _screenHeight/22.76,
              width: /*300*/ _screenWidth/1.37, //prima era 400
              child: Center(
                child: Text(
                  _samplerController.getOperationInformationText(),
                  style: TextStyle(fontSize: 30, color: Colors.white),
                ),
              ),
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: /*20*/_screenWidth/20.55)),
            createSamplerRow(0),
            Padding(padding: EdgeInsets.symmetric(vertical: /*10*/ _screenWidth/41)),
            createSamplerRow(4),
            Padding(padding: EdgeInsets.symmetric(vertical: /*10*/ _screenWidth/41)),
            createSamplerRow(8),
            Padding(padding: EdgeInsets.symmetric(vertical: /*10*/ _screenWidth/41)),
            createSamplerRow(12),
            Padding(padding: EdgeInsets.symmetric(vertical: /*10*/ _screenWidth/41)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: () async { //LOAD BUTTON
                  if (!_samplerController.isSharingRunning() && !_samplerController.isRenameRunning()) {
                    var result = await showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) => LoadingDialog(
                        controller: _samplerController,
                        key: Key("key"),
                      ),
                    );

                    if (result != "NO SELECTION") {
                      _samplerController.setOperationInformationTxt(Languages.of(context)!.selectButton);
                      setState(() {
                        _samplerController.enableLoading();
                        _samplerController.enableItemSelection();
                        if (result != null && result != "") {
                          _samplerController.setSelectedURL(result);
                        } else {
                          throw("ERROR: the selected URL is null");
                        }
                      });
                    }

                  } else {
                    print("Another operation is running");
                  }
                },
                  child: getLoadButtonName(),
                  style: getLoadingButtonStyle(),
                ),
                Padding(padding: EdgeInsets.symmetric(horizontal: /*10*/ _screenWidth/41)),
                ElevatedButton(onPressed: () { //UPLOAD ON DRIVE BUTTON
                  if (_samplerController.checkIfUserConnected()) {
                    if (!_samplerController.isSharingRunning() &&
                        !_samplerController.isRenameRunning()) {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) => ToUploadList(),
                      );
                    } else {
                      print("Another operation is running");
                    }
                  } else {
                    print("User is not connected");
                    Utils.showToast(context, Languages.of(context)!.userNotConnected);
                  }
                },
                  child: Icon(Icons.add_to_drive),
                  style: ButtonStyle(backgroundColor:  MaterialStateColor.resolveWith((states) => Colors.blueGrey),),
                ),
                Padding(padding: EdgeInsets.symmetric(horizontal: /*10*/ _screenWidth/41)),
                ElevatedButton( onPressed: () { //SHARE BUTTON
                  if (_samplerController.checkIfUserConnected()) { //user is connected
                    if (!_samplerController.isRenameRunning()) {
                      setState(() {
                        if (!_samplerController.isSharingRunning()) {
                          _samplerController.enableItemSelection();
                          _samplerController.enableSharing(context);
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
                    Utils.showToast(context, Languages.of(context)!.userNotConnected);
                  }
                },
                  child: selectSharingButtonName(),
                  style: getSharingButtonStyle(),
                ),
                Padding(padding: EdgeInsets.symmetric(horizontal: /*10*/ _screenWidth/41)),
                ElevatedButton(onPressed: () { //RENAME BUTTON
                  if (!_samplerController.isSharingRunning()) {
                    if (!_samplerController.isRenameRunning()) { //Enable Renaming
                      setState(() {
                        _samplerController.enableItemSelection();
                        _samplerController.enableRenaming(context);
                      });
                    } else { //Disable renaming
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
      ),
    );
  }

}


class SharingDialog extends StatefulWidget {

  //final SamplerController controller;
  final Record record;
  final Key key;

  const SharingDialog({required this.record, required this.key}) : super(key: key);

  @override
  _SharingDialogState createState() => _SharingDialogState();
}

class _SharingDialogState extends State<SharingDialog> {

  ShareDialogController _controller = ShareDialogController();
  TextEditingController _textFieldController = TextEditingController();
  double _screenHeight = 0;
  double _screenWidth = 0;

  Widget makePage() {
    return AlertDialog (
      backgroundColor: Color.fromRGBO(36, 59, 85, 1),
      content: Container(
        width: /*250*/ _screenWidth/1.644,
        height: /*470*/ _screenHeight/1.54,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Insert Sample Infos:", style: TextStyle(color: Colors.white)),
            TextField(
              controller: _textFieldController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: new BorderSide(color: Colors.white, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: new BorderSide(color: Colors.white, width: 2),
                ),
                labelText: "New Sample Name",
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),
            Text("Choose one or more tags", style: TextStyle(color: Colors.white)),
            makeTagList(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(Languages.of(context)!.cancelName),
                  style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.red),),
                ),
                ElevatedButton(
                  onPressed: () => _controller.share(_textFieldController.text).then((value) => Navigator.pop(context)),
                  child: Text(Languages.of(context)!.shareName),
                  style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.blueGrey),),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget makeTagList() {
    return Container(
      width: /*200*/ _screenWidth/2,
      height: /*250*/ _screenHeight/2.732,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
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

    //Getting sceen's size
    _screenHeight = MediaQuery.of(context).size.height;
    _screenWidth = MediaQuery.of(context).size.width;

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
      return Colors.pink;
    } else {
      return  Color.fromRGBO(36, 59, 85, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          color: getColor(),
        ),
        child: Text(widget.controller.getTagAt(widget.item), style: TextStyle(color: Colors.white), textAlign: TextAlign.center,),
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


/*class LoadDialog extends StatelessWidget {
  const LoadDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        children: [
          Text("File Loading Dialog, implement"),
          ElevatedButton(onPressed: () => SamplerController().pickFile(), child: Text(Languages.of(context)!.loadName),),
        ],
      ),
    );
  }
}*/


class RenamePage extends StatelessWidget {
  const RenamePage({Key? key, required this.samplerController}) : super(key: key);

  final SamplerController samplerController;

  @override
  Widget build(BuildContext context) {

    //Getting sceen's size
    double _screenHeight = MediaQuery.of(context).size.height;
    double _screenWidth = MediaQuery.of(context).size.width;

    samplerController.setRenameSubmitted(false);

    return AlertDialog(
      backgroundColor: Color.fromRGBO(36, 59, 85, 1),
      content: Container(
        width: /*200*/ _screenWidth/2,
        height: /*180*/ _screenHeight/3.79,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(Languages.of(context)!.renameInstructionsName, style:TextStyle(color: Colors.white), textAlign: TextAlign.center,),
            TextField(
              controller: samplerController.getTextEditingController(),
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: new BorderSide(color: Colors.white, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: new BorderSide(color: Colors.white, width: 2),
                ),
                labelText: "New Sample Name",
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(onPressed: () {
                  Navigator.pop(context);
                },
                  child: Text(Languages.of(context)!.cancelName),
                  style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.red),),
                ),
                ElevatedButton(onPressed: () {
                  samplerController.setRenameSubmitted(true);
                  Navigator.pop(context);
                },
                  child: Text(Languages.of(context)!.submitName),
                  style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.blueGrey),),),
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
  List<Record> selectedEntries = [];
  double _screenHeight = 0;
  double _screenWidth = 0;

  @override
  void initState() {
    super.initState();
  }

  String parseFilename(String path) {
    var splitted = path.split("/");
    return splitted[splitted.length-1];
  }

  @override
  Widget build(BuildContext context) {

    //Getting sceen's size
    _screenHeight = MediaQuery.of(context).size.height;
    _screenWidth = MediaQuery.of(context).size.width;

    _toUpdateListController.getElementsList();

    return AlertDialog(
      backgroundColor: Color.fromRGBO(36, 59, 85, 1),
      content: Column(
        children: [
          Container(
            width: /*300*/ _screenWidth/1.37,
            height: /*500*/ _screenHeight/1.366,
            child: ListView.separated(
              padding: const EdgeInsets.all(5), //non può essere relativo
              physics: ClampingScrollPhysics(),
              itemCount: _toUpdateListController.getElementsListLength(),
              itemBuilder: (BuildContext context, int index) {
                return ToUploadItem(
                  itemIndex: index,
                  isSelected: (bool value) {
                    setState(() {
                      if (value) {
                        _toUpdateListController.addElement(index);
                      } else {
                        _toUpdateListController.removeElement(index);
                      }
                    });},
                  key: Key(_toUpdateListController.getElementsListLength().toString()),
                  controller: _toUpdateListController,
                );
              },
              separatorBuilder: (BuildContext context, int index) => const MyDivider(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: /*Text("Cancel")*/ Text(Languages.of(context)!.cancelName),
                style: ButtonStyle(backgroundColor:  MaterialStateColor.resolveWith((states) => Colors.red),),
              ),
              Padding(padding: EdgeInsets.all(_screenWidth/82)),
              ElevatedButton(
                onPressed: () {
                  if (_toUpdateListController.getElementsListLength() >0) {
                    _toUpdateListController.uploadSelectedElements();
                    Navigator.pop(context);
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
  final int itemIndex;
  final ValueChanged<bool> isSelected;
  final ToUpdateListController controller;

  const ToUploadItem({required this.itemIndex, required this.isSelected, required this.key, required this.controller}) : super(key: key);

  @override
  _ToUploadItemState createState() => _ToUploadItemState();
}

class _ToUploadItemState extends State<ToUploadItem> {

  bool isSelected = false;
  double _screenWidth = 0;
  double _screenHeight = 0;

  @override
  Widget build(BuildContext context) {

    //Getting sceen's size
    _screenHeight = MediaQuery.of(context).size.height;
    _screenWidth = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: () {
        setState(() {
          isSelected = !isSelected;
          widget.isSelected(isSelected);
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: /*180*/ _screenWidth/2.28,
            child: Text(
              Utils.removeExtension(widget.controller.getElementAt(widget.itemIndex).getFilename()),
              style: TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
            onPressed: () => widget.controller.playRecord(widget.controller.getElementAt(widget.itemIndex).getUrl()),
            child: Icon(Icons.play_arrow),
            style: ButtonStyle(
              minimumSize:MaterialStateProperty.resolveWith((states) => Size(/*20*/ _screenWidth/20.5, /*20*/ _screenWidth/20.5)),
              backgroundColor:  MaterialStateColor.resolveWith((states) => Colors.blueGrey),
            ),
          ),
          Stack(
            children: [
              isSelected ? Center(
                child: Container(
                    width: /*30*/ _screenWidth/13.7,
                    height: /*30*/ _screenWidth/13.7,
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
                ),
              ) : Container(width: /*30*/ _screenWidth/13.7, height: /*30*/ _screenWidth/13.7),
            ],
          ),
        ],
      ),
    );
  }
}


class LoadingDialog extends StatelessWidget {

  final SamplerController controller;
  final Key key;

  LoadingDialog({required this.controller, required this.key}) : super(key: key);

  final List<String> titles = [
    "Load elements from filesystem or Drive",
    "Load built-in elements",
    "Load elements from Drive",
  ];

  @override
  Widget build(BuildContext context) {

    //Getting sceen's size
    double _screenHeight = MediaQuery.of(context).size.height;
    double _screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      backgroundColor: Color.fromRGBO(36, 59, 85, 1),
      content: Container(
        width: /*200*/ _screenWidth/2,
        height: /*180*/ _screenHeight/3.3,
        child: Column(
          children: [
            Container(
              width: /*200*/ _screenWidth/2,
              height: /*100*/ _screenHeight/5,
              child: ListView.separated(
                itemBuilder:  (BuildContext context, int index) {
                  return LoadingListItem(
                    title: titles[index],
                    index: index,
                    controller: controller,
                    key: Key(index.toString()),
                  );
                },
                separatorBuilder: (BuildContext context, int index) => const MyDivider(),
                itemCount: 3,
              ),
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 15)),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, "NO SELECTION"),
              child: /*Text("Cancel",)*/ Text(Languages.of(context)!.cancelName),
              style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) => Colors.red),),
            ),
          ],
        ),
      ),
    );
  }
}

class LoadingListItem extends StatelessWidget {

  final String title;
  final int index;
  final SamplerController controller;
  final Key key;

  const LoadingListItem({required this.title, required this.index, required this.controller, required this.key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    double _screenWidth = MediaQuery.of(context).size.width;
    double _screenHeight = MediaQuery.of(context).size.height;

    return InkWell(
      onTap: () async {
        if (index == 0) { //loading with filepicker
          controller.pickFile().then((value) {
            Navigator.pop(context, value); //returning selection result di Sampler UUI
          });
        } else if (index == 1){ //loadinf assets

          var result = await showDialog(
            context: context,
            builder: (builder) => AssetsLoadingDialog(
              controller: controller,
              key: Key("key"),
            ),
          );
          Navigator.pop(context, result);

        } else if (index == 2) {

          var result = await showDialog(
            context: context,
            builder: (builder) => IOSGoogleDriveMenu(
              controller: controller,
              key: Key("key"),
            ),
          );
          Navigator.pop(context, result);

        }
      },
      child: Container(
        width: /*200*/ _screenWidth/2,
        height: /*40*/ _screenHeight/17,
        child: Center(
          child: Text(title, style: TextStyle(color: Colors.white), textAlign: TextAlign.center,),
        ),
      ),
    );
  }
}


class AssetsLoadingDialog extends StatefulWidget {

  final SamplerController controller;
  final Key key;

  const AssetsLoadingDialog({required this.controller, required this.key}) : super(key: key);

  @override
  _AssetsLoadingDialogState createState() => _AssetsLoadingDialogState();
}

class _AssetsLoadingDialogState extends State<AssetsLoadingDialog> {

  @override
  Widget build(BuildContext context) {

    double _screenWidth = MediaQuery.of(context).size.width;
    double _screenHeight = MediaQuery.of(context).size.height;

    widget.controller.loadAssets();

    return AlertDialog(
      backgroundColor: Color.fromRGBO(36, 59, 85, 1),
      content: Container(
        width: /*200*/ _screenWidth/2,
        height: /*450*/ _screenHeight/1.51,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //Padding(padding: EdgeInsets.symmetric(vertical: 2)),
            Text("Select an asset to Load", style: TextStyle(color: Colors.white, fontSize: 20),),
            Container(
              height: /*300*/ _screenHeight/2.27,
              child: ListView.separated(
                itemBuilder: (BuildContext context, int index) {
                  return AssetsLoadingDialogListItem(
                    itemName: widget.controller.getAssetAt(index),
                    index: index,
                    key: Key(index.toString()),
                    controller: widget.controller,
                  );
                },
                separatorBuilder: (BuildContext context, int index) => const MyDivider(),
                itemCount: widget.controller.getAssetsLength(),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, "NO SELECTION"),
              child: Text(Languages.of(context)!.cancelName),
              style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.red),),),
          ],
        ),

      ),
    );
  }
}



class AssetsLoadingDialogListItem extends StatefulWidget {

  final String itemName;
  final int index;
  final Key key;
  final SamplerController controller;

  const AssetsLoadingDialogListItem({required this.itemName, required this.index, required this.key, required this.controller}) : super(key: key);

  @override
  _AssetsLoadingDialogListItemState createState() => _AssetsLoadingDialogListItemState();
}

class _AssetsLoadingDialogListItemState extends State<AssetsLoadingDialogListItem> {

  @override
  Widget build(BuildContext context) {

    double _screenWidth = MediaQuery.of(context).size.width;
    double _screenHeight = MediaQuery.of(context).size.height;

    return InkWell(
      onTap: () {
        Navigator.pop(context, widget.itemName);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            Utils.removeExtension(Utils.getFilenameFromURL(widget.itemName)),
            textAlign: TextAlign.center, style: TextStyle(color: Colors.white),
          ),
          ElevatedButton(
            onPressed: () => AudioController().playAtURL(widget.controller.getAssetAt(widget.index)),
            child: Icon(Icons.play_arrow),
            style: ButtonStyle(
              minimumSize:MaterialStateProperty.resolveWith((states) => Size(/*20*/ _screenWidth/20.5, /*20*/ _screenWidth/20.5)),
              backgroundColor:  MaterialStateColor.resolveWith((states) => Colors.blueGrey),
            ),
          ),
        ],
      ),
    );
  }
}


//todo bisogna usare il metodo per il prelevamento delle informazioni che devono essere filtrate per estensione

class IOSGoogleDriveMenu extends StatelessWidget {

  final Key key;
  final SamplerController controller;

  const IOSGoogleDriveMenu({required this.controller, required this.key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    //Prelevamento della lista di  elementi
    controller.initIosGoogleDriveMenuList();

    return AlertDialog(
      content: Container(
        child: Column(
          children: [
            Text("Google Drive"),
            Container(
              child: ListView.separated(
                itemBuilder: (BuildContext context, int index) {

                  //todo prelevare elemento dalla lista e da lì il nome
                  String name = "";
                  return IOSGoogleDriveMenuItem(name: name, key: Key(name));
                },
                separatorBuilder: (BuildContext context, int index) => const MyDivider(),
                itemCount: controller.getIosGoogleDriveMenuListLength(),
              ),
            ),
          ],
        ),
      ),
    );


  }
}


class IOSGoogleDriveMenuItem extends StatelessWidget {

  final String name;
  final Key key;

  const IOSGoogleDriveMenuItem({required this.name, required this.key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(name),
      ],
    );
  }
}






















