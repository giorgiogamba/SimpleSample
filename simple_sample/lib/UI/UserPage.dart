import 'dart:ui';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_sample/UI/Explorer.dart';
import 'package:simple_sample/Controllers/UserPageController.dart';
import 'package:simple_sample/Utils.dart';
import '../Controllers/AuthenticationController.dart';
import '../Controllers/CloudStorageController.dart';

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

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
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
              return Center(child: Text(snapshot.data.toString(), style: TextStyle(fontSize: 30, color: Colors.white)),);
            } else {
              return Center(child: Text("Username", style: TextStyle(fontSize: 30, color: Colors.white)),);
            }},
        ),
        Container( //prima era sized box
          width: 100,
          height: 100,
          child: FittedBox(
            fit: BoxFit.contain,
            child: ValueListenableBuilder(
                valueListenable: _userPageController.profileImagePath,
                builder: (context, value, _) {
                  return displayUserProfileImage(value.toString());
                }
            ),
          ),
          decoration: new BoxDecoration( //Rounded shape
            color: Colors.white,
            borderRadius: BorderRadius.all(const Radius.circular(50.0)),
            border: Border.all(color: const Color(0xFF28324E)),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(padding: EdgeInsets.only(left: 5)),
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
            FutureBuilder(
              future: _userPageController.getDownloadsNumber(),
              builder: (context, snapshot) {
                return Text("Downloads: "+snapshot.data.toString(), style: TextStyle(fontSize: 20, color: Colors.white));
              }
            ),
            Padding(padding: EdgeInsets.only(right: 5)),
          ],
        ),
        Column(
          children: [
            Text("SHARED SAMPLES", style: TextStyle(fontSize: 20, color: Colors.white),),
            Padding(padding: EdgeInsets.symmetric(vertical: 2)),
            Container(
              width: 380,
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder:  (BuildContext context, int index) {
                  return SquareListItem(
                    itemIndex: index,
                    key: Key(_userPageController.getUserSharedRecordsLength().toString()),
                    controller: _userPageController,
                    isFavourite: false,
                    callback: () {setState(() {});},
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
            Text("FAVOURITES", style: TextStyle(fontSize: 20, color: Colors.white),),
            Padding(padding: EdgeInsets.symmetric(vertical: 2)),
            Container(
              width: 380,
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder:  (BuildContext context, int index) {
                  return SquareListItem(
                    itemIndex: index,
                    key: Key(_userPageController.getFavouritesLength().toString()),
                    controller: _userPageController,
                    isFavourite: true,
                    callback: () { setState(() {});},
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
    return Container(
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

      child: Center(
        child: Container(
          width: 400,
          height: 430,
          child: AlertDialog(
              backgroundColor: Color.fromRGBO(20, 30, 48, 1),
              title: Center(
                child:  Text("You are not logged in", style: TextStyle(color: Colors.white)),
              ),
              elevation: 20,
              content: Column(
                children: [
                  TextField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.white, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.white, width: 2),
                      ),
                      labelText: 'email',
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    controller: _emailController,
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                  TextField(
                    style: TextStyle(color: Colors.white),
                    obscureText: true,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.white, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.white, width: 2),
                      ),
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    controller: _passwordController,
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _userPageController.createUserWithEmailAndPassword(
                            _emailController.text,
                            _passwordController.text,
                          ).then((value) {
                            print("VALUE< REGISTER $value");
                            if (value == "true") {
                              setState(() {
                                auth = true;
                              });
                            } else {
                              showDialog(context: context, builder: (builder) => AccessErrorPage(key: Key(value)));
                            }
                          });
                        },
                        child: Text("Register"),
                        style: ButtonStyle(backgroundColor:  MaterialStateColor.resolveWith((states) => Colors.blueGrey),),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _userPageController.signInWithEmailAndPassword(
                            _emailController.text,
                            _passwordController.text,
                          ).then((value) {
                            print("VLAUE USER PAGE; $value");
                            if (value == "true") {
                              setState(() {
                                auth = true;
                              });
                            } else {
                              showDialog(context: context, builder: (builder) => AccessErrorPage(key: Key(value)));
                            }
                          });
                        },
                        child: Text("Login"),
                        style: ButtonStyle(backgroundColor:  MaterialStateColor.resolveWith((states) => Colors.blueGrey),),
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
      ),
    );
  }


  Widget makeProgressBar() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {

    auth = _authenticationController.checkIfAuthorized();

    if (auth) {

      _userPageController.updateUserPage();

      return Container(
        child: ValueListenableBuilder(
          valueListenable: _userPageController.loaded,
          builder: (context, value, _) {
            if (value == true) {
              return makeUserPage();
            } else {
              return makeProgressBar();
            }
          },
        ),
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
  final VoidCallback callback;

  const SquareListItem({
    required this.itemIndex,
    required this.key,
    required this.controller,
    required this.isFavourite,
    required this.callback,
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
            color: Colors.white,
          ), onPressed: () => widget.controller.handleRemoveFromFavourites(widget.itemIndex).then((value) {
            setState(() {}); //inutile
            widget.callback();
          }))
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
                      Utils.wrapText(Utils.removeExtension(widget.controller.getUserSharedRecordAt(widget.itemIndex).getFilename()), 12),
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
      backgroundColor: Color.fromRGBO(36, 59, 85, 1),
      content: Container(
        width: 200,
        height: 100,
        child: ListView.separated(
          itemBuilder:  (BuildContext context, int index) {
            return ChooseImageOperationDialogItem(
              index: index,
              controller: widget.controller,
              key: Key(widget.controller.getElementsLength().toString()),
            );},
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
            child: Text(widget.controller.getElementAt(widget.index), style: TextStyle(color: Colors.white),),
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

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(padding: EdgeInsets.symmetric(vertical: 20)),
                Text("Settings", style: TextStyle(fontSize: 30, color: Colors.white ),),
                ElevatedButton(onPressed: () => showDialog(
                  context: context,
                  builder: (context) => ChooseImageOperationDialog(
                    controller: UserPageController(),
                    key: Key(1.toString()),
                  ),
                ),
                  child: Text("Set Profile Image"),
                  style: ButtonStyle(backgroundColor:  MaterialStateColor.resolveWith((states) => Colors.blueGrey),),
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => SetUsernameDialog(),
                    );
                  },
                  child: Text("Set username"),
                  style: ButtonStyle(backgroundColor:  MaterialStateColor.resolveWith((states) => Colors.blueGrey),),
                ),
                MyDivider(),
                ElevatedButton(
                  onPressed: () => UserPageController().disconnect().then((value) {
                    Navigator.pop(context);
                  }),
                  child: Text("Logout from Google"),
                  style: ButtonStyle(backgroundColor:  MaterialStateColor.resolveWith((states) => Colors.red),),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: Text("Disconnect from Drive"),
                  style: ButtonStyle(backgroundColor:  MaterialStateColor.resolveWith((states) => Colors.red),),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: Text("Disconnect from Dropbox"),
                  style: ButtonStyle(backgroundColor:  MaterialStateColor.resolveWith((states) => Colors.red),),
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => DeleteAccountWidget(
                        controller: widget.controller,
                        key: Key("CIAO"),
                      ),
                    );
                  },
                  child: Text("Delete User"),
                  style: ButtonStyle(backgroundColor:  MaterialStateColor.resolveWith((states) => Colors.red),),
                ),
                MyDivider(),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Back"),
                  style: ButtonStyle(backgroundColor:  MaterialStateColor.resolveWith((states) => Colors.blueGrey),),
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 20)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class SetUsernameDialog extends StatelessWidget {

  const SetUsernameDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    TextEditingController _textEditingController = TextEditingController();

    return AlertDialog(
      backgroundColor: Color.fromRGBO(36, 59, 85, 1),
      content: Container(
        width: 200,
        height: 170,
        child: Column(
          children: [
            Text(
              "Choose a new name for the Sampler",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 4),),
            TextField(
              controller: _textEditingController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: new BorderSide(color: Colors.white, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: new BorderSide(color: Colors.white, width: 2),
                ),
                labelText: "New Username",
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 4),),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(onPressed: () {
                  Navigator.pop(context);
                },
                  child: Text("Cancel"),
                  style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.blueGrey),)
                ),
                ElevatedButton(onPressed: () {
                  UserPageController().setUsername(_textEditingController.text).then((value) {
                    _textEditingController.text = ""; //resetting username field
                    Navigator.pop(context);
                    Navigator.pop(context);
                  });
                  },
                  child: Text("Submit"),
                  style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.blueGrey),),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



class DeleteAccountWidget extends StatefulWidget {

  final UserPageController controller;
  final Key key;

  const DeleteAccountWidget({required this.controller, required this.key}) : super(key: key);

  @override
  _DeleteAccountWidgetState createState() => _DeleteAccountWidgetState();
}

class _DeleteAccountWidgetState extends State<DeleteAccountWidget> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color.fromRGBO(36, 59, 85, 1),
      content: Container(
        width: 200,
        height: 100,
        child: Column(
          children: [
            Text(
              "Are you sure you want to delete your account?",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 4),),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(onPressed: () {
                  Navigator.pop(context);
                },
                  child: Text("No"),
                  style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.blueGrey),),
                ),
                ElevatedButton(onPressed: () {
                  widget.controller.deleteAccount().then((value) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  });
                },
                  child: Text("Yes"),
                  style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.blueGrey),),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class AccessErrorPage extends StatelessWidget {

  const AccessErrorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor:  Color.fromRGBO(36, 59, 85, 1),
      content: Container(
        width: 200,
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("ERROR DURING ACCESS",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red,
                fontSize: 20,
              ),
            ),
            Text(
              Utils.remove3(key.toString()),
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
              onPressed: () {Navigator.pop(context);},
              child: Text("Back"),
              style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.blueGrey),),
            ),
          ],
        ),
      ),
    );
  }
}












