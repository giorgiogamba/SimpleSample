import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_sample/AudioController.dart';
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
      shadowColor: MaterialStateProperty.resolveWith((states) => Colors.pinkAccent),
      enableFeedback: true,
      minimumSize: MaterialStateProperty.resolveWith((states) => Size(buttonSize, buttonSize)),
    );
  }

  MaterialStateProperty<Color?>? getSamplerColor(int index) {
    if (_samplerController.checkIsButtonIsFull(index)) { //there is a record on this button
      return MaterialStateColor.resolveWith((states) => Colors.pink);
    } else {
      return MaterialStateColor.resolveWith((states) => Colors.teal);
    }
  }

  Widget createButton(int index) {
    return Stack(
      children: [
        GestureDetector(
          onLongPress: () => !_samplerController.isEnabledItemSelection() ? _audioController.record(index) : {},
          onLongPressUp: () {
            _audioController.stopRecorder();
            setState(() {});
          },
          child: ElevatedButton(
            child: Text(_samplerController.getButtonName(index)),
            onPressed: () {
              if (!_samplerController.isEnabledItemSelection()) {
                _audioController.play(index);
              } else {
                  if (!_samplerController.isRenameRunning()) {
                    setState(() {
                      print("Associating button to record");
                      _samplerController.associateFileToButton(index);
                      _samplerController.disableItemSelection();
                      _audioController.enablePlayback();
                    });
                  } else {
                    print("Associating button for renaming");
                    _samplerController.setSelectedItemForRename(index);
                    showDialog(
                        context: context,
                        builder: (context) => RenamePage(samplerController: _samplerController,)
                    ).then((value) {
                      _samplerController.renameRecord().then((value) {
                        _samplerController.disableRenaming();
                        _samplerController.disableItemSelection();
                        setState(() {});
                      });
                    });
                  }
              }},
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
      resizeToAvoidBottomInset: true, //to avoid keyboard overflow
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: () => _samplerController.pickFile().then((value) {
                /*showDialog(
                  context: context,
                  builder: (context) => LoadDialog(),
                );*/
                setState(() {
                  _samplerController.enableItemSelection();
                  print("*** Ho cambiato lo stato, itemSelection vale: "+_samplerController.isEnabledItemSelection().toString());
                  if (value != null && value != "") {
                    _samplerController.setSelectedURL(value);
                    print("Ho impostato URL");
                  } else {
                    print("ERROR: the selected URL is null");
                  }
                });
              }), child: Text("Load")),
              SizedBox(width: 20),
              ElevatedButton(onPressed: () => _samplerController.checkIfUserConnected() ? showDialog(
                context: context,
                builder: (context) => ToUploadList(),
              ) : null, child: Text("Upload")),
              SizedBox(width: 20),
              ElevatedButton(onPressed: () => _samplerController.checkIfUserConnected() ? showDialog(
                context: context,
                builder: (context) => SharePage(),
              ) : null, child: Text("Share")),
              SizedBox(width: 20),
              ElevatedButton(onPressed: () {
                setState(() {
                  _samplerController.enableItemSelection();
                  _samplerController.enableRenaming();
                  //todo selezione tasto
                  //todo apertura dialogo
                });
              }, child: Text("Rename")),
            ],
          ),
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
                    item: /*parseFilename(entries[index])*/ entries[index].getFilename(),
                    isSelected: (bool value) {
                      setState(() {
                        if (value) {
                          print("Sampler List build: Index to upload "+entries[index].toString());
                          selectedEntries.add(entries[index]);
                          //Aggiunta al controller
                          _toUpdateListController.addElement(entries[index]);
                        } else {
                          selectedEntries.remove(entries[index]);
                          _toUpdateListController.removeElement(entries[index]);
                        }
                      });
                    },
                    key: Key(entries.length.toString()));
              },
              separatorBuilder: (BuildContext context, int index) => const Divider(),
            ),
          ),
          ElevatedButton(
              onPressed: () { _toUpdateListController.uploadSelectedElements(); },
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


class SharePage extends StatefulWidget {
  const SharePage({Key? key}) : super(key: key);

  @override
  _SharePageState createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {

  int _currentPage = 0;
  ShareDialogController _controller = ShareDialogController();
  TextEditingController _textFieldController = TextEditingController();

  @override
  void initState() {
    _controller.initElements();
    _controller.resetSelectedTags();
    _textFieldController.text = "";
    super.initState();
  }

  void goToNextStep() {
    print("Method go to next step");
    if (_controller.getSelectedEntry() != null) {
      print("Controller is not null");
      setState(() {
        _currentPage ++;
      });
    } else {
      print("Non è stato selezionato neitne, non si può procedere");
      setState(() {
        print("Non ho selezionato niente, apro il dialogo di allerta");
        _currentPage = 2;
      });
    }
  }

  void backToPageOne() {
    setState(() {
      _currentPage = 0;
    });
  }

  Widget makeFirstPage() {
    return AlertDialog(
      content: Column(
        children: [
          Container(
            width: 200,
            height: 500,
            child: ListView.separated(
              padding: const EdgeInsets.all(0), //porre a 0 se si vuole che riempa tutto lo spazion padre
              physics: ClampingScrollPhysics(),
              itemCount: _controller.getEntriesLength(),
              itemBuilder: (BuildContext context, int index) {
                return ShareDialogListItem(
                  itemIndex: index,
                  key: Key(_controller.getEntriesLength().toString()),
                  isSelected: (value) {
                    setState(() {
                      if (value) { //if selected
                        _controller.setSelectedEntry(_controller.getEntryAt(index));
                      } else {
                        _controller.setSelectedEntry(null);
                      }
                    });},
                  controller: _controller,
                );
              },
              separatorBuilder: (BuildContext context, int index) => MyDivider(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
              ElevatedButton(onPressed: () => goToNextStep(), child: Text("Next")),
            ],
          ),
        ],
      ),
    );
  }

  Widget makeSecondPage() {
    return AlertDialog (
      content: Column(
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
          ElevatedButton(onPressed: () => _controller.share(_textFieldController.text).then((value) => Navigator.pop(context)), child: Text("Share")),
        ],
      ),
    );
  }

  Widget makeTagList() {
    return Container(
      width: 120,
      height: 200,
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

  Widget makeNoSelectionAlertDialog() {
    return AlertDialog(
      content: Container(
        width: 200,
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("No item selected, come back"),
            ElevatedButton(onPressed: backToPageOne, child: Text("OK")),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPage == 0) {
      return makeFirstPage();
    } else if (_currentPage == 1) {
      return makeSecondPage();
    } else {
      return makeNoSelectionAlertDialog();
    }
  }
}


class ShareDialogListItem extends StatefulWidget {

  final int itemIndex;
  final Key key;
  final ValueChanged<bool> isSelected;
  final ShareDialogController controller;

  const ShareDialogListItem({required this.itemIndex, required this.key, required this.isSelected, required this.controller}) : super(key: key);

  @override
  _ShareDialogListItemState createState() => _ShareDialogListItemState();
}

class _ShareDialogListItemState extends State<ShareDialogListItem> {

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
      child: Row(
        children: [
          Text(widget.controller.getEntryAt(widget.itemIndex).getFilename()),
          SizedBox(width: 10,),
          ElevatedButton(
              onPressed: () => widget.controller.playRecord(widget.itemIndex),
              child: Text("Play")
          ),
          SizedBox(width: 20),
          isSelected ? Container(
              width: 40,
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
          ) : Container(width: 40, height: 10),
        ],
      ),
    );


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
    /*return Container(
      child: ListView.separated(
          itemBuilder: itemBuilder,
          separatorBuilder: (BuildContext context, int index) => const Divider(
            color: Colors.black,
            thickness: 3,
          ),
          itemCount: itemCount
      ),
    );*/
    //List<File> files = await FilePicker.getMultiFile();
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
    return AlertDialog(
      content: Column(
        children: [
          Text("Choose a new name for the Sampler"),
          Padding(padding: EdgeInsets.symmetric(vertical: 4),),
          TextField(
            controller: samplerController.getTextEditingController(),
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 4),),
          ElevatedButton(onPressed: () {
            Navigator.pop(context);
          }, child: Text("Submit")),
        ],
      ),
    );
  }
}

















