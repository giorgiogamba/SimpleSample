import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
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

  late ExplorerController _controller;
  List<Record> entries = [];
  List<Record> selectedEntries = [];

  @override
  void initState() {
    _controller = ExplorerController();
    initEntries();
    super.initState();
  }

  void initEntries() async {
    List<Record> temp = await _controller.getElementsList();
    setState(() {
      entries = temp;
    });
  }

  Widget makeListView() {
    return ListView.separated(
      padding: const EdgeInsets.all(5),
      itemCount: entries.length,
      itemBuilder: (BuildContext context, int index) {
        return ExplorerListItem(
          item: entries[index],
          isSelected: (bool value) {
            setState(() {
              if (value) {
                selectedEntries.add(entries[index]); //inutile
              } else {
                selectedEntries.remove(entries[index]); //inutile
              }
            });
          },
          key: Key(entries[index].toString()),
          controller: _controller,
        );
      },
      separatorBuilder: (BuildContext context, int index) => const MyDivider(),
    );
  }

  Widget makeProgressBar() {
    return CircularProgressIndicator();
  }

  Widget chooseBody() {
    if (!_controller.checkIfUserLogged()) {
      return Center(
        child: Text("USER IS NOT LOGGED IN"),
      );
    } else {
      if (entries == []) {
        return makeProgressBar();
      } else {
        return makeListView();
      }
    }
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
  final ValueChanged<bool> isSelected;
  final ExplorerController controller;

  const ExplorerListItem({required this.item, required this.isSelected, required this.key, required this.controller}) : super(key: key);

  @override
  _ExplorerListItemState createState() => _ExplorerListItemState();
}

class _ExplorerListItemState extends State<ExplorerListItem> {

  bool isSelected = false;

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
          onPressed: () => widget.controller.addToFavorites(),
          child: Icon(Icons.star, color: Colors.yellow,),
          style: getButtonStyle(),),
        SizedBox(width: 15,),
        ElevatedButton(
          onPressed: () => widget.controller.downloadRecord(widget.item),
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
    return res;
  }

  Widget makeSecondRow() {
    return Row(
      children: createTagWidget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          isSelected = !isSelected;
          widget.isSelected(isSelected);
        });
      },
      child: Column(
        children: [
          makeFirstRow(),
          makeSecondRow(),
        ],
      ),
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
