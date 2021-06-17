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
          labelText: "Search",
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
      List<Record> selectedEntries = _controller.getSelectedEntries();
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
      child: Row(
        children: [
          Text("Filter by: ", style: TextStyle(fontSize: 18),),
          DropdownButton<String>(
            value: dropdownValue,
            onChanged: (String? newValue) {
              setState(() {
                dropdownValue = newValue;
              });
            },
            items: [
              DropdownMenuItem<String>(value: "Tags", child: Text("Tags"))
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
    return Scaffold(
      appBar: AppBar(
        title: /*Center(
          child:  Text("Explorer"),
        ),*/ Text("Explorer"),
        backgroundColor: Colors.teal,
        leading: GestureDetector(
          onTap: () { /* Write listener code here */ },
          child: Icon(
            Icons.menu,  // add custom icons also
          ),
        ),
      ),
      body: chooseBody(),
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
      children: [
        Container(
          width: 180,
          child: Text(widget.item.getFilename(), style: TextStyle(fontSize: 20),),
        ),
        SizedBox(width: 15,),
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
          child: Icon(Icons.star, color: Colors.yellow,),
          style: getButtonStyle(),),
        SizedBox(width: 15,),
        ElevatedButton(
          onPressed: () {
            widget.controller.downloadRecord(widget.item);
            setState(() {});
          },
          child: Icon(Icons.arrow_circle_down, color: Colors.yellow,),
          style: getButtonStyle(),),
        SizedBox(width: 15,),
        ElevatedButton(
          onPressed: () => widget.controller.playRecord(widget.item),
          child:Icon(Icons.play_arrow, color: Colors.yellow,),
          style: getButtonStyle(), ),
      ],
    );
  }

  List<Widget> createTagWidget() {
    List<Widget> res = [];
    res.add(Text("Tags: "));
    res.add(SizedBox(width: 2));
    for (String tag in widget.item.getTagList()) {
      res.add(Text(tag+ ", "));
      res.add(SizedBox(width: 2,));
    }

    res.add(Text("Dwl: ${widget.item.getDownloadsNumber()}"));

    return res;
  }

  Widget makeSecondRow() {
    return Row(
      children: createTagWidget(),
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
