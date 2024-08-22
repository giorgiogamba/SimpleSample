import 'package:flutter/material.dart';
import 'package:simple_sample/Controllers/AudioController.dart';
import 'package:simple_sample/Controllers/AuthenticationController.dart';
import 'package:simple_sample/Controllers/SamplerController.dart';
import 'package:simple_sample/Controllers/ShareDialogController.dart';
import 'package:simple_sample/Controllers/ToUpdateListController.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:simple_sample/Utils/Languages.dart';
import 'Explorer.dart';
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
  double _screenHeight = 0;
  double _screenWidth = 0;

  @override
  void initState() {

    _audioController.initRecorder().then((value) {
      //Recording time initialization
      initializeDateFormatting();
      /*_recorderSubscription =*/ _audioController.getRecorder().onProgress!.listen((e) { //NOT EXECUTED ON IOS
        var date = DateTime.fromMillisecondsSinceEpoch(e.duration.inMilliseconds, isUtc: true);
        var txt = DateFormat('mm:ss:SS', 'en_GB').format(date);

        setState(() {
          _samplerController.setOperationInformationTxt(txt.substring(0, 8));
        });
      });

    });

    AuthenticationController(); //initializing
    _samplerController.disableItemSelection();
    super.initState();
  }

  @override
  void dispose() {
    print("*** sampler disposition ***");
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
      elevation: WidgetStateProperty.resolveWith((states) => elevationValue),
      shadowColor: WidgetStateProperty.resolveWith((states) => Colors.pinkAccent),
      enableFeedback: true,
      minimumSize: WidgetStateProperty.resolveWith((states) =>
           Size(/*70*/ _screenWidth/5.85, /*70*/ _screenWidth/5.85)),
    );
  }

  WidgetStateProperty<Color?>? getSamplerColor(int index) {
    if (_samplerController.checkIsButtonIsFull(index)) { //there is a record on this button
      return WidgetStateProperty.resolveWith((states) => Colors.pink);
    } else {
      return WidgetStateProperty.resolveWith((states) => Colors.teal);
    }
  }

  ///Creates a square sampler button
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
              if (!_samplerController.isEnabledItemSelection()) { //Item selection not enabled, playing record
                _audioController.play(index);
              } else { //Item selection enabled

                if (_samplerController.isLoadingRunning()) { //Loading
                  setState(() {
                    print("*** Associating button to record ***");
                    _samplerController.associateFileToButton(index);
                    _samplerController.disableItemSelection();
                    _samplerController.disableLoading();
                    _audioController.enablePlayback();
                    _samplerController.setOperationInformationTxt("");
                  });
                } else if (_samplerController.isRenameRunning()) { //Renaming
                  print("*** Associating button for renaming ***");
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
                          _samplerController.setOperationInformationTxt("");
                          setState(() {});
                        });
                      } else {
                        print("No selected item, rename is not possible");
                        setState(() {
                          _samplerController.disableRenaming();
                          _samplerController.disableItemSelection();
                          _samplerController.setOperationInformationTxt("");
                        });
                      }
                    });
                  } else {
                    Utils.showToast(context, Languages.of(context)!.cannotSelect);
                  }
                } else if (_samplerController.isSharingRunning()) { //sharing
                  print("*** Associating button for sharing ***");
                  setState(() {});

                  Record? toShare = _samplerController.getSelectedItemForSharing(index);
                  _samplerController.disableItemSelection();
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) => SharingDialog(record: toShare!, key: Key(toShare.getFilename())),
                  ).then((value) {
                    setState(() {
                      _samplerController.disableSharing();
                      _samplerController.setOperationInformationTxt("");
                    });
                  });

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
      return Text(Languages.of(context)!.cancelName);
    } else {
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
      return ButtonStyle(backgroundColor: WidgetStateProperty.resolveWith((states) => Colors.red),);
    } else {
      return ButtonStyle(backgroundColor: WidgetStateProperty.resolveWith((states) => Colors.blueGrey),);
    }
  }

  ButtonStyle getSharingButtonStyle() {
    if (_samplerController.isSharingRunning()) {
      return ButtonStyle(backgroundColor: WidgetStateProperty.resolveWith((states) => Colors.red),);
    } else {
      return ButtonStyle(backgroundColor: WidgetStateProperty.resolveWith((states) => Colors.blueGrey),);
    }
  }

  ButtonStyle getLoadingButtonStyle() {
    if (_samplerController.isLoadingRunning()) {
      return ButtonStyle(backgroundColor: WidgetStateProperty.resolveWith((states) => Colors.red),);
    } else {
      return ButtonStyle(backgroundColor: WidgetStateProperty.resolveWith((states) => Colors.blueGrey),);
    }
  }


  ///Creates a sampler Row
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
                  style: TextStyle(fontSize: 20, color: Colors.white),
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
            Row( //Creates a row of service buttons
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
                          throw("Sampler -- Loading: the selected URL is null");
                        }
                      });
                    } else {
                      print("Sampler -- Loading: no element has been selected");
                    }

                  } else {
                    print("Sampler -- Loading: Another operation is running");
                  }
                },
                  child: getLoadButtonName(),
                  style: getLoadingButtonStyle(),
                ),
                Padding(padding: EdgeInsets.symmetric(horizontal: /*10*/ _screenWidth/41)),
                ElevatedButton(onPressed: () { //UPLOAD ON DRIVE BUTTON
                  if (_samplerController.checkIfUserConnected() && _samplerController.checkIfGoogleConnected()) {
                    if (!_samplerController.isSharingRunning() &&
                        !_samplerController.isRenameRunning()) {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) => ToUploadList(),
                      );
                    } else {
                      print("Sampler -- Upload on Drive: Another operation is running");
                    }
                  } else {
                    Utils.showToast(context, Languages.of(context)!.userNotConnected);
                  }
                },
                  child: Icon(Icons.add_to_drive),
                  style: ButtonStyle(backgroundColor:  WidgetStateProperty.resolveWith((states) => Colors.blueGrey),),
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
                          setState(() {
                            _samplerController.disableSharing();
                            _samplerController.disableItemSelection();
                          });
                        }
                      });
                    } else {
                      print("Sampler -- Share: Another operation is running");
                    }
                  } else { //user is not connected
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
                    print("Sampler -- Rename: Another operation is running");
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

///Class which creates the Sample Sharing Dialog
class SharingDialog extends StatefulWidget {

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
            Text(Languages.of(context)!.insertSampleInfo, style: TextStyle(color: Colors.white)),
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
                labelText: Languages.of(context)!.newSampleName,
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),
            Text(Languages.of(context)!.chooseTags, style: TextStyle(color: Colors.white)),
            makeTagList(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(Languages.of(context)!.cancelName),
                  style: ButtonStyle(backgroundColor: WidgetStateProperty.resolveWith((states) => Colors.red),),
                ),
                ElevatedButton(
                  onPressed: () => _controller.share(_textFieldController.text).then((value) => Navigator.pop(context)),
                  child: Text(Languages.of(context)!.shareName),
                  style: ButtonStyle(backgroundColor: WidgetStateProperty.resolveWith((states) => Colors.blueGrey),),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  ///Creates a list containing all the listed tags
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

///Represents a Tag list entry
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

  //Changes color depending on state
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

///Class representing sample rename dialog
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
              style: TextStyle(color: Colors.white),
              controller: samplerController.getTextEditingController(),
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: new BorderSide(color: Colors.white, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: new BorderSide(color: Colors.white, width: 2),
                ),
                labelText: Languages.of(context)!.newSampleName,
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
                  style: ButtonStyle(backgroundColor: WidgetStateProperty.resolveWith((states) => Colors.red),),
                ),
                ElevatedButton(onPressed: () {
                  samplerController.setRenameSubmitted(true);
                  Navigator.pop(context);
                },
                  child: Text(Languages.of(context)!.submitName),
                  style: ButtonStyle(backgroundColor: WidgetStateProperty.resolveWith((states) => Colors.blueGrey),),),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

///Class that represents upload on Drive dialog
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

  ///Returns filename from path
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
                child: Text(Languages.of(context)!.cancelName),
                style: ButtonStyle(backgroundColor:  WidgetStateProperty.resolveWith((states) => Colors.red),),
              ),
              Padding(padding: EdgeInsets.all(_screenWidth/82)),
              ElevatedButton(
                onPressed: () {
                  if (_toUpdateListController.getElementsListLength() >0) {
                    _toUpdateListController.uploadSelectedElements();
                    Navigator.pop(context);
                  };
                },
                child: Text(Languages.of(context)!.uploadSelectedElements),
                style: ButtonStyle(backgroundColor:  WidgetStateProperty.resolveWith((states) => Colors.blueGrey),)
              ),
            ],
          ),
        ],
      ),
    );
  }
}

///Class representing an upload list entry
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
  // ignore: unused_field
  double _screenHeight = 0.0;
  double _screenWidth = 0.0;

  @override
  Widget build(BuildContext context) {

    //Getting sceen's size
    this._screenHeight = MediaQuery.of(context).size.height;
    this._screenWidth = MediaQuery.of(context).size.width;

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
              minimumSize:WidgetStateProperty.resolveWith((states) => Size(/*20*/ _screenWidth/20.5, /*20*/ _screenWidth/20.5)),
              backgroundColor:  WidgetStateProperty.resolveWith((states) => Colors.blueGrey),
            ),
          ),
          Stack(
            children: [
              isSelected ? Center(
                child: Container(
                    width: /*30*/ _screenWidth/13.7,
                    height: /*30*/ _screenWidth/13.7,
                    child: Align(
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

///Class representing Loading list dialog
class LoadingDialog extends StatelessWidget {

  final SamplerController controller;
  final Key key;

  LoadingDialog({required this.controller, required this.key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    //Getting sceen's size
    double _screenHeight = MediaQuery.of(context).size.height;
    double _screenWidth = MediaQuery.of(context).size.width;

    final List<String> titles = [
      Languages.of(context)!.loadFromFilesystem,
      Languages.of(context)!.loadBuiltIn,
      Languages.of(context)!.loadFromDocuments,
    ];

    return AlertDialog(
      backgroundColor: Color.fromRGBO(36, 59, 85, 1),
      content: Container(
        width: /*200*/ _screenWidth/2,
        height: _screenHeight/3,
        child: Column(
          children: [
            Container(
              width: /*200*/ _screenWidth/2,
              height: _screenHeight/4,
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
            Padding(padding: EdgeInsets.symmetric(vertical: 4)),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, "NO SELECTION"),
              child: Text(Languages.of(context)!.cancelName),
              style: ButtonStyle(backgroundColor: WidgetStateProperty.resolveWith((states) => Colors.red),),
            ),
          ],
        ),
      ),
    );
  }
}

///Class representing Loading Dialog list item
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
            Navigator.pop(context, value); //returning selection result
          });
        } else if (index == 1){ //loading assets

          var result = await showDialog(
            barrierDismissible: false,
            context: context,
            builder: (builder) => AssetsLoadingDialog(
              controller: controller,
              key: Key("key"),
            ),
          );
          Navigator.pop(context, result);

        } else if (index == 2) { //loading from documents folder
          var result = await showDialog(
            barrierDismissible: false,
            context: context,
            builder: (builder) => DocumentsLoadingDialog(
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

///Class representing assets loading dialog
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
            Text(
              Languages.of(context)!.assetsLoading,
              style: TextStyle(color: Colors.white, fontSize: 20,),
              textAlign: TextAlign.center,),
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
              style: ButtonStyle(backgroundColor: WidgetStateProperty.resolveWith((states) => Colors.red),),),
          ],
        ),

      ),
    );

  }
}


///Class representing Assets loading list item
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
              minimumSize:WidgetStateProperty.resolveWith((states) => Size(/*20*/ _screenWidth/20.5, /*20*/ _screenWidth/20.5)),
              backgroundColor:  WidgetStateProperty.resolveWith((states) => Colors.blueGrey),
            ),
          ),
        ],
      ),
    );
  }
}


///Class representing loading from documents dialog
class DocumentsLoadingDialog extends StatefulWidget {

  final SamplerController controller;
  final Key key;

  const DocumentsLoadingDialog({required this.controller, required this.key}) : super(key: key);

  @override
  _DocumentsLoadingDialogState createState() => _DocumentsLoadingDialogState();
}

class _DocumentsLoadingDialogState extends State<DocumentsLoadingDialog> {

  @override
  Widget build(BuildContext context) {

    double _screenWidth = MediaQuery.of(context).size.width;
    double _screenHeight = MediaQuery.of(context).size.height;

    widget.controller.loadDocumentsFile();

    return AlertDialog(
      backgroundColor: Color.fromRGBO(36, 59, 85, 1),
      content: Container(
        width: /*200*/ _screenWidth/2,
        height: /*450*/ _screenHeight/1.51,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(Languages.of(context)!.fileLoading, style: TextStyle(color: Colors.white, fontSize: 20),),
            Container(
              height: /*300*/ _screenHeight/2.27,
              child: ListView.separated(
                itemBuilder: (BuildContext context, int index) {
                  return DocumentsLoadingDialogListItem(
                    itemName: widget.controller.getDocumentFileAt(index),
                    index: index,
                    key: Key(index.toString()),
                    controller: widget.controller,
                  );
                },
                separatorBuilder: (BuildContext context, int index) => const MyDivider(),
                itemCount: widget.controller.getDocumentsFileLength(),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, "NO SELECTION"),
              child: Text(Languages.of(context)!.cancelName),
              style: ButtonStyle(backgroundColor: WidgetStateProperty.resolveWith((states) => Colors.red),),),
          ],
        ),

      ),
    );

  }
}


///Class representing documents loading list item dialog
class DocumentsLoadingDialogListItem extends StatefulWidget {

  final String itemName;
  final int index;
  final Key key;
  final SamplerController controller;

  const DocumentsLoadingDialogListItem({required this.itemName, required this.index, required this.key, required this.controller}) : super(key: key);

  @override
  _DocumentsLoadingDialogListItemState createState() => _DocumentsLoadingDialogListItemState();
}

class _DocumentsLoadingDialogListItemState extends State<DocumentsLoadingDialogListItem> {

  @override
  Widget build(BuildContext context) {

    double _screenWidth = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: () {
        Navigator.pop(context, widget.itemName);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            Utils.wrapText(Utils.removeExtension(Utils.getFilenameFromURL(widget.itemName)), 15),
            textAlign: TextAlign.center, style: TextStyle(color: Colors.white),
          ),
          ElevatedButton(
            onPressed: () => AudioController().playAtURL(widget.controller.getDocumentFileAt(widget.index)),
            child: Icon(Icons.play_arrow),
            style: ButtonStyle(
              minimumSize:WidgetStateProperty.resolveWith((states) => Size(/*20*/ _screenWidth/20.5, /*20*/ _screenWidth/20.5)),
              backgroundColor:  WidgetStateProperty.resolveWith((states) => Colors.blueGrey),
            ),
          ),
        ],
      ),
    );
  }
}