import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_sample/ExplorerController.dart';

import 'Record.dart';

const double elevationValue = 10;
const double buttonSizeX = 30;
const double buttonSizeY = 15;

class Explorer extends StatefulWidget {
  const Explorer({Key? key}) : super(key: key);

  @override
  _ExplorerState createState() => _ExplorerState();
}

class _ExplorerState extends State<Explorer> {

  ExplorerController _controller = ExplorerController();
  TextEditingController _textEditingController = TextEditingController();

  Widget makeListView() {
    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.all(5),
        itemCount: _controller.getSelectedEntriesLength(),
        itemBuilder: (BuildContext context, int index) {
          return ExplorerListItem(
            item: _controller.getSelectedEntryAt(index),
            key: Key(_controller.getSelectedEntryAt(index).toString()),
            controller: _controller,
          );
        },
        separatorBuilder: (BuildContext context, int index) => const MyDivider(),
      ),
    );
  }

  Widget makeProgressBar() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget makeSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextField(
        controller: _textEditingController,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: "Search by name",
        ),
        onChanged: onItemChanged,
      ),
    );
  }

  onItemChanged(String value) {
    setState(() {
      List<Record> selectedEntries = _controller.getSelectedEntries();
      selectedEntries = selectedEntries.where((record) => record.getFilename().toLowerCase().contains(value.toLowerCase())).toList();
      if (value == "") {
        List<Record> entries = _controller.getEntries();
        _controller.setSelectedEntries(entries);
      } else {
        _controller.setSelectedEntries(selectedEntries);
      }
    });
  }

  onFilterChanged(String value) {
    setState(() {
      List<Record> selectedEntries = _controller.getEntries();
      List<Record> newList = [];
      for (Record rec in selectedEntries) {
        List<String> tags = rec.getTagList();
        for (String tag in tags) {
          if (tag.toLowerCase().contains(value.toLowerCase())) {
            newList.add(rec);
            break;
          }
        }
      }
      selectedEntries = newList;

      if (value == "") {
        List<Record> entries = _controller.getEntries();
        _controller.setSelectedEntries(entries);
      } else {
        _controller.setSelectedEntries(selectedEntries);
      }
    });
  }

  String? dropdownValue = "Tags";

  Widget makeCommands() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            Text("Filter by: ", style: TextStyle(fontSize: 18, color: Colors.white),),
            DropdownButton<String>(
              value: dropdownValue,
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue;
                });
              },
              items: [
                DropdownMenuItem<String>(value: "Tags", child: Text("Tags", style: TextStyle(color: Colors.white)))
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                child: TextField(
                  onChanged: onFilterChanged,
                ),
              ),
            ),
          ],
        ),
      )
    );
  }

  Widget chooseBody() {
    return ValueListenableBuilder (
        valueListenable: _controller.loaded,
        builder: (context, value, _) {
          if (!_controller.checkIfUserLogged()) {
            return Center(
              child: Text("USER IS NOT LOGGED IN"),
            );
          } else {
            if (value == false) {
              return makeProgressBar();
            } else {
              return Column(
                children: [
                  makeCommands(),
                  makeSearchBar(),
                  makeListView(),
                ],
              );
            }
          }
        }
        );
  }

  @override
  Widget build(BuildContext context) {

    _controller.getElementsList(); //updating elements

    return Scaffold(
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
        child: chooseBody(),
      ),
    );
  }
}

class ExplorerListItem extends StatefulWidget {

  final Key key;
  final Record item;
  final ExplorerController controller;

  const ExplorerListItem({required this.item, required this.key, required this.controller}) : super(key: key);

  @override
  _ExplorerListItemState createState() => _ExplorerListItemState();
}

class _ExplorerListItemState extends State<ExplorerListItem> {

  bool add = true;

  ButtonStyle getButtonStyle() {
    return ButtonStyle(
      backgroundColor: MaterialStateColor.resolveWith((states) => Colors.teal),
      elevation: MaterialStateProperty.resolveWith((states) => elevationValue),
      minimumSize: MaterialStateProperty.resolveWith((states) => Size(buttonSizeX, buttonSizeY)),
    );
  }

  Widget makeFirstRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(padding: EdgeInsets.symmetric(horizontal: 4)),
        Container(
          width: 180,
          child: Text(
            widget.item.getFilename(),
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (add) {
              widget.controller.addToFavorites(widget.item).then((value) {
                setState(() {
                  add = false;
                });
              });
            } else {
              widget.controller.removeFromFavourites(widget.item).then((value) {
                setState(() {
                  add = true;
                });
              });
            }
          },
          child: Icon(Icons.star, color: Colors.white,),
          style: getButtonStyle(),
        ),
        ElevatedButton(
          onPressed: () {
            widget.controller.downloadRecord(widget.item);
            setState(() {});
          },
          child: Icon(Icons.arrow_circle_down, color: Colors.white,),
          style: getButtonStyle(),),
        ElevatedButton(
          onPressed: () => widget.controller.playRecord(widget.item),
          child:Icon(Icons.play_arrow, color: Colors.white,),
          style: getButtonStyle(),
        ),
        Padding(padding: EdgeInsets.symmetric(horizontal: 4)),
      ],
    );
  }

  String createTagString() {
    String res = "Tags: ";
    for (String tag in widget.item.getTagList()) {
      res = res + tag + ", ";
    }
    return res;
  }

  Widget makeSecondRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(createTagString(), style: TextStyle(color: Colors.white)),
        Text("Downloads: " + widget.item.getDownloadsNumber().toString(), style: TextStyle(color: Colors.white)),
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        makeFirstRow(),
        makeSecondRow(),
      ],
    );
  }
}

class MyDivider extends StatelessWidget {
  const MyDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: Colors.black,
      thickness: 2,
    );
  }
}
