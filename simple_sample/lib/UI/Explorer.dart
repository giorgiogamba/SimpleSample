import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_sample/Controllers/ExplorerController.dart';
import 'package:simple_sample/Utils/Languages.dart';
import '../Models/Record.dart';
import '../Utils.dart';

class Explorer extends StatefulWidget {
  const Explorer({Key? key}) : super(key: key);

  @override
  _ExplorerState createState() => _ExplorerState();
}

class _ExplorerState extends State<Explorer> {

  @override
  void initState() {
    _controller.getElementsList(); //updating elements
    super.initState();
  }

  ExplorerController _controller = ExplorerController();
  bool onFiltering = false;

  ///Creates explorer list
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

  ///Creates a circular progress bar when page is loading
  Widget makeProgressBar() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  ///Auxiliar method when filter is active
  onSearch(String value) {
    setState(() {
      onFiltering = true;
    });

    //Filtering using tags
    if (dropdownValue == "Tags") {
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

    //Filtering using filename
    } else if (dropdownValue == Languages.of(context)!.nameName) {
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
    setState(() {
      onFiltering = false;
    });
  }

  String? dropdownValue = "Tags";

  ///Creates buttons row for every explorer list entry
  Widget makeCommands() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            Text(Languages.of(context)!.filterBy, style: TextStyle(fontSize: 18, color: Colors.white),),
            DropdownButton<String>(
              value: dropdownValue,
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue;
                });
              },
              items: [
                DropdownMenuItem<String>(value: "Tags", child: Text("Tags", style: TextStyle(color: Colors.white))),
                DropdownMenuItem<String>(value: "Name", child: Text(Languages.of(context)!.nameName, style: TextStyle(color: Colors.white)))
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                child: TextField(
                  onChanged: onSearch,
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

  ///Auxiliar method in order to choose which widget to display depending on the system state
  Widget chooseBody() {
    if (!_controller.checkIfUserLogged()) { //User is not logged in, displaying a string
      return Center(
        child: Text(Languages.of(context)!.userNotConnected, style: TextStyle(color: Colors.white),),
      );
    } else { //user logged in
      return ValueListenableBuilder(
          valueListenable: _controller.loaded,
          builder: (context, value, _) {
            if (value == false) {
              return makeProgressBar(); //records still not downloaded
            } else { //records downloaded
              return Column(
                children: [
                  Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                  makeCommands(),
                  makeListView(),
                ],
              );
            }
          }
      );
    }
  }

  @override
  Widget build(BuildContext context) {

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

///Class representing list item
class ExplorerListItem extends StatefulWidget {

  final Key key;
  final Record item; //item to be displayed
  final ExplorerController controller;

  const ExplorerListItem({required this.item, required this.key, required this.controller}) : super(key: key);

  @override
  _ExplorerListItemState createState() => _ExplorerListItemState();
}

class _ExplorerListItemState extends State<ExplorerListItem> {

  double _screenHeight = 0;
  double _screenWidth = 0;

  ButtonStyle getButtonStyle() {
    return ButtonStyle(
      backgroundColor: MaterialStateColor.resolveWith((states) => Colors.teal),
      elevation: MaterialStateProperty.resolveWith((states) => /*10*/ _screenWidth/41),
      minimumSize: MaterialStateProperty.resolveWith((states) => Size(/*30*/ _screenWidth/13.7, /*15*/ _screenHeight/45.53)),
    );
  }

  Icon chooseIcon(Record record) {
    if (widget.controller.manageFavouritesIcon(record)) { //if it is in favourites
      return Icon(Icons.star, color: Colors.yellow);
    } else { //it is not into favourites
      return Icon(Icons.star_border_sharp, color: Colors.yellow,);
    }
  }

  ///Creates the first half of the row
  Widget makeFirstRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(padding: EdgeInsets.symmetric(horizontal: 4)),
        Container(
          width: /*180*/ _screenWidth/2.28,
          child: Text(
            Utils.wrapText(widget.item.getFilename(), 32),
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => widget.controller.manageFavouritesButton(widget.item).then((value) {
            setState(() {});
            Utils.showToast(context, Languages.of(context)!.sampleSaved);
          }),
          child: chooseIcon(widget.item),
          style: getButtonStyle(),
        ),
        ElevatedButton(
          onPressed: () {
            widget.controller.downloadRecord(widget.item).then((value) {
              Utils.showToast(context, Languages.of(context)!.downloadCorrect);
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
    if (widget.item.getTagList().length > 0) {
      for (String tag in widget.item.getTagList()) {
        res = res + tag + ", ";
      }
    }
    return res;
  }

  ///Creates rows for tags and diwnloads display
  Widget makeSecondRow() {

    int max = 40; //maximum number of characters for row

    String tagString = createTagString();
    int restLength = tagString.length;
    List<Widget> widgetList = [];
    if (tagString.length > max) { //tags must be placed in multiple rows
      int nRows = tagString.length ~/ max; //Determining the number of tag rows
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

        } else { //rows between the first and the last
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

    //Getting sceen's size
    _screenHeight = MediaQuery.of(context).size.height;
    _screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        makeFirstRow(),
        makeSecondRow(),
      ],
    );
  }
}

///Class representing list items divider
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
