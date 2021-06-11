import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_sample/AudioController.dart';
import 'package:simple_sample/ExplorerController.dart';
import 'package:simple_sample/GoogleDriveController.dart';
import 'package:simple_sample/StorageController.dart';
import 'package:simple_sample/UserPageController.dart';

import 'AuthenticationController.dart';
import 'CloudStorageController.dart';
import 'Model.dart';
import 'Record.dart';

///Class representing the user Interface
///

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {

  //TEST
  CloudStorageController storageController = CloudStorageController();
  AuthenticationController _controller = AuthenticationController();
  UserPageController _userPageController = UserPageController();
  bool auth = false; //la mantengo così cambia la UI a seconda dello stato
  late File _imageFile;

  @override
  void initState() {
    auth = _controller.checkIfAuthorized();
    super.initState();
  }

  void setImageProfile() {

  }



  @override
  Widget build(BuildContext context) {

    bool val = true;

    if (auth) {
      return Column(
          children: [
            Center(child: Text("USERNAME", style: TextStyle(fontSize: 30))),
            SizedBox(
              width: 200,
              height: 200,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Image(
                  image: AssetImage('assets/userlogo.png'),
                ),
              ),
            ),
            SizedBox(height: 20),
            /*DropdownButton<String>(
              items: chooseImageSource(),
              value: val ? "Set Profile Image" : null,
              onChanged: (value) {},
            ),*/
            ElevatedButton(onPressed: () => showDialog(
                context: context,
                builder: (context) => ChooseImageOperationDialog(
                  controller: _userPageController,
                  key: Key(1.toString()),
                ),
              ),
                child: Text("Set Profile Image")),
            SizedBox(height: 20),
            Text("SHARED SAMPLES", style: TextStyle(fontSize: 30),),
            Expanded(
              child: ListView(

              ),
            ),
          ],
        );
    } else {
      return AlertDialog(
          title: Text("You are not logged in"),
          elevation: 20,
          content: Column(
            children: [
              InkWell(
                child: Container(
                    width: 200,
                    height: 30,
                    margin: EdgeInsets.only(top: 25),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color:Colors.black
                    ),
                    child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            /*Container( //todo aggiungere logo google
                              height: 30.0,
                              width: 30.0,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image:
                                    AssetImage('assets/google.jpg'),
                                    fit: BoxFit.cover),
                                shape: BoxShape.circle,
                              ),
                            ),*/
                            Text('Sign in with Google',
                              style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white
                              ),
                            ),
                          ],
                        )
                    )
                ),
                onTap: ()
                async{
                  _controller.signInWithGoogle().then((value) {
                    setState(() {
                      auth = true;
                    });
                  });
                },
              ),
            ],
          )
      );
    }
  }
}

class UserPageListItems extends StatefulWidget {

  final Record item;
  final Key key;
  final ExplorerController controller; //using ExplorerController beacuse I need few of its functionalities

  const UserPageListItems({required this.item, required this.key, required this.controller}) : super(key: key);

  @override
  _UserPageListItemsState createState() => _UserPageListItemsState();
}

class _UserPageListItemsState extends State<UserPageListItems> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(widget.item.getFilename()),
        ElevatedButton(onPressed: () => widget.controller.playRecord(widget.item), child: Icon(Icons.play_arrow)),
      ],
    );
  }
}


class ChooseImageOperationDialog extends StatefulWidget {

  final UserPageController controller;
  final Key key;

  const ChooseImageOperationDialog({required this.controller, required this.key}) : super(key: key);

  @override
  _ChooseImageOperationDialogState createState() => _ChooseImageOperationDialogState();
}

class _ChooseImageOperationDialogState extends State<ChooseImageOperationDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        width: 200,
        height: 100,
        child: ListView.separated(
            itemBuilder:  (BuildContext context, int index) {
              return ChooseImageOperationDialogItem(
                index: index,
                controller: widget.controller,
                key: Key(widget.controller.getElementsLength().toString()),
              );
            },
            separatorBuilder:  (BuildContext context, int index) => const Divider(),
            itemCount: widget.controller.getElementsLength(),
          ),
      ),
    );
  }
}

class ChooseImageOperationDialogItem extends StatefulWidget {

  final int index;
  final UserPageController controller;
  final Key key;

  const ChooseImageOperationDialogItem({required this.index, required this.controller, required this.key}) : super(key: key);

  @override
  _ChooseImageOperationDialogItemState createState() => _ChooseImageOperationDialogItemState();
}

class _ChooseImageOperationDialogItemState extends State<ChooseImageOperationDialogItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 40,
      child: Center(
        child: InkWell(
            child: Text(widget.controller.getElementAt(widget.index)),
            onTap: () {

            },
        ),
      ),
    );
  }
}













