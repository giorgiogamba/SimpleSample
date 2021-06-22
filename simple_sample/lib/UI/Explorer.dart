import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_sample/Controllers/ExplorerController.dart';

import '../Models/Record.dart';
import '../Utils.dart';

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
  bool onFiltering = false;

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
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: new BorderSide(color: Colors.white, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: new BorderSide(color: Colors.white, width: 2),
          ),
          labelText: 'Search by name',
          labelStyle: TextStyle(color: Colors.white),
        ),
        onChanged: onItemChanged,
      ),
    );
  }

  onItemChanged(String value) {
    onFiltering = true;
    print("ObìnFiltering vale : $onFiltering");
    setState(() {
      List<Record> selectedEntries = _controller.getSelectedEntries();
      print("preso selectedEntries");
      selectedEntries = selectedEntries.where((record) => record.getFilename().toLowerCase().contains(value.toLowerCase())).toList();
      if (value == "") {
        List<Record> entries = _controller.getEntries();
        _controller.setSelectedEntries(entries);
      } else {
        _controller.setSelectedEntries(selectedEntries);
      }
    });
    onFiltering = false;
    print("ObìnFiltering vale : $onFiltering");
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
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: new BorderSide(color: Colors.white, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: new BorderSide(color: Colors.white, width: 2),
                    ),
                    labelText: 'Filter Value',
                    labelStyle: TextStyle(color: Colors.white),
                  ),
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
              child: Text("USER IS NOT LOGGED IN", style: TextStyle(color: Colors.white),),
            );
          } else {
            if (value == false) {
              return makeProgressBar();
            } else {
              return Column(
                children: [
                  Padding(padding: EdgeInsets.symmetric(vertical: 5)),
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

    if (!onFiltering) {
      _controller.getElementsList(); //updating elements
    }

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

  ButtonStyle getButtonStyle() {
    return ButtonStyle(
      backgroundColor: MaterialStateColor.resolveWith((states) => Colors.teal),
      elevation: MaterialStateProperty.resolveWith((states) => elevationValue),
      minimumSize: MaterialStateProperty.resolveWith((states) => Size(buttonSizeX, buttonSizeY)),
    );
  }

  Icon chooseIcon(Record record) {
    if (widget.controller.manageFavouritesIcon(record)) { //if it is in favourites
      return Icon(Icons.star, color: Colors.yellow);
    } else { //it is not into favourites
      return Icon(Icons.star_border_sharp, color: Colors.yellow,);
    }
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
          onPressed: () => widget.controller.manageFavouritesButton(widget.item).then((value) {
            setState(() {});
            Utils.showToast(context, "Sample saved into favourites");
          }),
          child: chooseIcon(widget.item),
          style: getButtonStyle(),
        ),
        ElevatedButton(
          onPressed: () {
            widget.controller.downloadRecord(widget.item).then((value) {
              Utils.showToast(context, "Download correctly executed");
            });
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

  ///Converts Record's tags list into a single row
  String createTagString() {
    String res = "Tags: ";
    for (String tag in widget.item.getTagList()) {
      res = res + tag + ", ";
    }
    return res;
  }

  ///Creates rows fro tags display
  Widget makeSecondRow() {

    int max = 40; //maximum number of characters for row

    String tagString = createTagString();
    int restLength = tagString.length;
    List<Widget> widgetList = [];
    if (tagString.length > max) { //tags must be placed in multiple rows
      //Determining the number of tag rows
      int nRows = tagString.length ~/ max;
      for (int i = 0; i < nRows; i ++) {
        if (i == 0) { //First Row
          Row first = Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tagString.substring(0, max), style: TextStyle(color: Colors.white)),
              Text("Downloads: " + widget.item.getDownloadsNumber().toString(), style: TextStyle(color: Colors.white)),
            ],
          );
          restLength -= max;
          widgetList.add(first);
        } else if (i == (nRows-1)) { //Last Row

          String rest = tagString.substring(i*max, i*max + restLength);
          Row newRow = Row(children: [Text(rest, style: TextStyle(color: Colors.white))],);
          widgetList.add(newRow);

        } else {
          Text newText = Text(tagString.substring(i * max, (i+1) * max), style: TextStyle(color: Colors.white));
          Row newRow = Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              newText
            ],
          );
          restLength -= max;
          widgetList.add(newRow);
        }
      }
    } else { //All the tags in one single row
      Row row = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(tagString, style: TextStyle(color: Colors.white),),
          Text("Downloads: " + widget.item.getDownloadsNumber().toString(), style: TextStyle(color: Colors.white)),
        ],
      );
      widgetList.add(row);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: widgetList,
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
      color: Colors.white,
      thickness: 2,
    );
  }
}
