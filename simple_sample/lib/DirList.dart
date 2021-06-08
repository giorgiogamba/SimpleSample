import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_sample/CloudStorageController.dart';
import 'package:simple_sample/StorageController.dart';

class DirList extends StatefulWidget {
  const DirList({Key? key}) : super(key: key);

  @override
  _DirListState createState() => _DirListState();
}

class _DirListState extends State<DirList> {

  CloudStorageController storageController = CloudStorageController();
  String test = "";

  List<Widget> getElementsList() {
    List<Widget> res = [];
    List<String> paths = StorageController().getElementsList();
    for (var p in paths) {
      test = p;
      res.insert(0, ListTile(
        title: Text(p, style: TextStyle(fontSize: 18)),
      ));
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          ListView(
            children: getElementsList(),
            scrollDirection: Axis.vertical,
          ),
        ],
      ),
    );
  }
}
