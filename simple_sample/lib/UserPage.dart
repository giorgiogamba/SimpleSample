import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_sample/Explorer.dart';
import 'package:simple_sample/UserPageController.dart';
import 'package:simple_sample/Utils.dart';
import 'AuthenticationController.dart';
import 'CloudStorageController.dart';

///Class representing the user Interface

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {

  CloudStorageController storageController = CloudStorageController();
  AuthenticationController _authenticationController = AuthenticationController();
  UserPageController _userPageController = UserPageController();
  bool auth = false;

  TextEditingController _emailConttoller = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    auth = _authenticationController.checkIfAuthorized();
    _userPageController.getUserSharedRecords();
    _userPageController.initFavourites();
    print("Chiamato initstate USERPAGE");
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

  Widget makeUserPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        FutureBuilder(
          future: _userPageController.getUsername(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Center(child: Text(snapshot.data.toString(), style: TextStyle(fontSize: 30)),);
            } else {
              return Center(child: Text("Username", style: TextStyle(fontSize: 30)),);
            }},
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 100,
              height: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SettingsPage(controller: _userPageController,)),
                      ).then((value) {
                        setState(() {});
                      });
                    },
                    child: Icon(Icons.settings),
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(13),
                      primary: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
            ),
            Container( //prima era sized box
              width: 100,
              height: 150,
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
            SizedBox(
              width: 150,
              height: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("DOWNLOADS: "),
                  Text("No"), //todo prelevare dal controller il numero totale
                ],
              ),
            ),
          ],
        ),
        Column(
          children: [
            Text("SHARED SAMPLES", style: TextStyle(fontSize: 20),),
            Padding(padding: EdgeInsets.symmetric(vertical: 2)),
            Container(
              width: 380,
              height: 100,
              /*decoration: BoxDecoration(
                border: Border.all(color: Colors.teal, width: 2),
              ),*/
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder:  (BuildContext context, int index) {
                  return SquareListItem(
                    itemIndex: index,
                    key: Key(_userPageController.getUserSharedRecordsLength().toString()),
                    controller: _userPageController,
                    isFavourite: false,
                  );
                },
                separatorBuilder:  (BuildContext context, int index) => MyDivider(),
                itemCount: _userPageController.getUserSharedRecordsLength(),
              ),
            ),
          ],
        ),
        Column(
          children: [
            Text("FAVOURITES", style: TextStyle(fontSize: 20),),
            Padding(padding: EdgeInsets.symmetric(vertical: 2)),
            Container(
              width: 380,
              height: 100,
              /*decoration: BoxDecoration(
                border: Border.all(color: Colors.teal, width: 2),
              ),*/
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder:  (BuildContext context, int index) {
                  return SquareListItem(
                    itemIndex: index,
                    key: Key(_userPageController.getFavouritesLength().toString()),
                    controller: _userPageController,
                    isFavourite: true,
                  );
                },
                separatorBuilder:  (BuildContext context, int index) => MyDivider(),
                itemCount: _userPageController.getFavouritesLength(),
              ),
            ),
          ],
        ),
        Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
      ],
    );
  }


  Widget makeAccessPage() {
    return Center(
      child: Container(
        width: 400,
        height: 430,
        child: AlertDialog(
            title: Center(
              child:  Text("You are not logged in"),
            ),
            elevation: 20,
            content: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'email',
                  ),
                ),
                Padding(padding: EdgeInsets.all(5)),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                ),
                Padding(padding: EdgeInsets.all(5)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () => _userPageController.createUserWithEmailAndPassword(
                        _emailConttoller.text,
                        _passwordController.text,
                      ),
                      child: Text("Register"),
                    ),
                    ElevatedButton(
                      onPressed: () => _userPageController.signInWithEmailAndPassword(
                        _emailConttoller.text,
                        _passwordController.text,
                      ),
                      child: Text("Login"),
                    ),
                  ],
                ),
                Padding(padding: EdgeInsets.all(5)),
                MyDivider(),
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
                              Container(
                                height: 30.0,
                                width: 30.0,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image:
                                      AssetImage('assets/google_logo.png'),
                                      fit: BoxFit.cover),
                                  shape: BoxShape.circle,
                                ),
                              ),
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
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (auth) {
      return Container(
        child: makeUserPage(),
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
            colors: [
              Color.fromRGBO(101, 78, 163, 1),
              Color.fromRGBO(234, 175, 200, 1),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
      );
    } else {
      return makeAccessPage();
    }
  }
}

class SquareListItem extends StatefulWidget {

  final int itemIndex;
  final Key key;
  final UserPageController controller;
  final bool isFavourite;

  const SquareListItem({
    required this.itemIndex,
    required this.key,
    required this.controller,
    required this.isFavourite,
  }) : super(key: key);

  @override
  _SquareListItemState createState() => _SquareListItemState();
}

class _SquareListItemState extends State<SquareListItem> {

  Widget createSecondPart() {
    if (widget.isFavourite) { //this widget will be used to display a favpurite record
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: Icon(
            Icons.play_arrow,
            color: Colors.white,
          ), onPressed: () => widget.controller.playRecordAt(widget.itemIndex)),
          IconButton(icon: Icon(
            Icons.star,
            color: Colors.white, //todo implementare rimozione da favs
          ), onPressed: () => widget.controller.playRecordAt(widget.itemIndex))
        ],
      );

    } else {
      return IconButton(
        icon: Icon(Icons.play_arrow, color: Colors.white),
        onPressed: () => widget.controller.playRecordAt(widget.itemIndex),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: 100,
        height: 50,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                      Utils.removeExtension(widget.controller.getUserSharedRecordAt(widget.itemIndex).getFilename()),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      )
                  ),
                )
              ),
              createSecondPart(),
            ],
          ),
        ),
        decoration: BoxDecoration(
          color: Colors.teal,
          border: Border.all(color: Colors.black, width: 1),
        ),
      ),
    );

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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          child: Text(Utils.removeExtension(widget.controller.getUserSharedRecordAt(widget.itemIndex).getFilename()), style: getTextStyle(),),
          height: 20,
        ),
        //SizedBox(width: 20,),
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
            separatorBuilder:  (BuildContext context, int index) => const MyDivider(),
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
                  print("Pickedimage non è nulla, top");
                  widget.controller.setProfileImagePath(pickedImage.path);
                  Navigator.pop(context);
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


class SettingsPage extends StatefulWidget {

  final UserPageController controller;

  const SettingsPage({required this.controller, Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  TextEditingController _textEditingController = TextEditingController();

  ButtonStyle getButtonStyle() {
    return ButtonStyle(
      backgroundColor:  MaterialStateColor.resolveWith((states) => Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Settings", style: TextStyle(fontSize: 30),),
              Padding(padding: EdgeInsets.all(10)),
              Container(
                width: 300,
                height: 50,
                child: TextField(
                  controller: _textEditingController,
                  decoration: InputDecoration(
                    labelText: "New Username",
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.all(10)),
              ElevatedButton(onPressed: () => Navigator.pop(context), child: Text("Back")),
              ElevatedButton(onPressed: () => showDialog(
                context: context,
                builder: (context) => ChooseImageOperationDialog(
                  controller: UserPageController(),
                  key: Key(1.toString()),
                ),
              ), child: Text("Set Profile Image")),
              ElevatedButton(
                onPressed: () => UserPageController().disconnect(),
                child: Text("Logout from Google"),
                style: getButtonStyle(),
              ),
              ElevatedButton(
                onPressed: () {
                  UserPageController()
                      .setUsername(_textEditingController.text)
                      .then((value) {
                        _textEditingController.text = ""; //resetting username field
                        Navigator.pop(context);
                      }
                      );},
                child: Text("Set username"),
                style: getButtonStyle(),
              ),
              ElevatedButton(
                onPressed: () {},
                child: Text("Disconnect from Drive"),
                style: getButtonStyle(),
              ),
              ElevatedButton(
                onPressed: () {},
                child: Text("Disconnect from Dropbox"),
                style: getButtonStyle(),
              ),
              ElevatedButton(
                onPressed: () => widget.controller.deleteAccount,
                child: Text("Delete User"),
                style: getButtonStyle(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}














