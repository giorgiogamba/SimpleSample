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

  CloudStorageController storageController = CloudStorageController();
  AuthenticationController _authenticationController = AuthenticationController();
  UserPageController _userPageController = UserPageController();
  bool auth = false; //la mantengo così cambia la UI a seconda dello stato


  @override
  void initState() {
    auth = _authenticationController.checkIfAuthorized();
    _userPageController.getUserSharedRecords();
    super.initState();
  }

  Widget displayUserProfileImage(String path) {
    var splitted = path.split("/");
    if (splitted[0] == "assets") { //image is the asset one
      return Image(image: AssetImage(path),);
    } else { //image is user's one
      return Image.file(File(_userPageController.profileImagePath.value));
    }
  }

  @override
  Widget build(BuildContext context) {

    if (auth) {
      return Column(
          children: [
            SizedBox(height: 20,),
            Center(child: Text("USERNAME", style: TextStyle(fontSize: 30))),
            SizedBox(
              width: 200,
              height: 200,
              child: FittedBox(
                fit: BoxFit.contain,
                child: ValueListenableBuilder(
                  valueListenable: _userPageController.profileImagePath,
                  builder: (context, value, _) {
                    return displayUserProfileImage(value.toString());
                  }
                ),
              ),
            ),
            SizedBox(height: 10),
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
            SizedBox(height: 10),
            Container(
              width: 380,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.teal, width: 2),
              ),
              child: ListView.separated(
                itemBuilder:  (BuildContext context, int index) {
                  return UserPageListItems(
                      itemIndex: index, //record
                      key: Key(_userPageController.getUserSharedRecordsLength().toString()),
                      controller: _userPageController,
                  );
                },
                separatorBuilder:  (BuildContext context, int index) => const Divider(
                  color: Colors.black,
                  thickness: 3,
                ),
                itemCount: _userPageController.getUserSharedRecordsLength(),
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
                  _authenticationController.signInWithGoogle().then((value) {
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

  final int itemIndex;
  final Key key;
  final UserPageController controller;

  const UserPageListItems({required this.itemIndex, required this.key, required this.controller}) : super(key: key);

  @override
  _UserPageListItemsState createState() => _UserPageListItemsState();
}

class _UserPageListItemsState extends State<UserPageListItems> {

  TextStyle getTextStyle() {
    return TextStyle(
        fontSize: 20
    );
  }

  ButtonStyle getButtonStyle() {
    return ButtonStyle(
      backgroundColor: MaterialStateColor.resolveWith((states) => Colors.teal),
      minimumSize: MaterialStateProperty.resolveWith((states) => Size(5, 10)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(widget.controller.getUserSharedRecordAt(widget.itemIndex).getFilename(), style: getTextStyle(),),
        SizedBox(width: 20,),
        ElevatedButton(onPressed: () => widget.controller.playRecordAt(widget.itemIndex), child: Icon(Icons.play_arrow), style: getButtonStyle(),),
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
            onTap: () async {
              PickedFile? pickedImage = await widget.controller.executeOperation(widget.index);
              setState(() {
                if (pickedImage != null) {
                  print("Pickedimage non è nulla, top"); //ci si arriva
                  widget.controller.setProfileImagePath(pickedImage.path);
                } else {
                  print("Null picked image");
                }
              });
            },
        ),
      ),
    );
  }
}













