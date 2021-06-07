import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_sample/StorageController.dart';

class DirList extends StatefulWidget {
  const DirList({Key? key}) : super(key: key);

  @override
  _DirListState createState() => _DirListState();
}

class _DirListState extends State<DirList> {

  List<Widget> getElementsList() {
    List<Widget> res = [];
    List<String> paths = StorageController().getElementsList();
    for (var p in paths) {
      res.insert(0, ListTile(
        title: Text(p, style: TextStyle(fontSize: 18)),
      ));
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        children: getElementsList(),
        scrollDirection: Axis.vertical,
      ),
    );
  }
}
