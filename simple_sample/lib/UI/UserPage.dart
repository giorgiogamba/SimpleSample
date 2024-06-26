import 'dart:ui';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_sample/UI/Explorer.dart';
import 'package:simple_sample/Models/Model.dart';
import 'package:simple_sample/Controllers/UserPageController.dart';
import 'package:simple_sample/Utils.dart';
import 'package:simple_sample/Utils/Languages.dart';
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

  double _screenWidth = 0;
  double _screenHeight = 0;

  @override
  void initState() {
    _userPageController.getUserSharedRecords();
    _userPageController.initFavourites();
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

  ///Creates user page for after login
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
          width: _screenWidth/3,
          height: _screenHeight/6,
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
        Column( //Creating shared samples list
          children: [
            Text(Languages.of(context)!.sharedSamplesName, style: TextStyle(fontSize: 20, color: Colors.white),),
            Padding(padding: EdgeInsets.symmetric(vertical: 2)),
            Container(
              width: /*380*/ _screenWidth/1.08,
              height: /*100*/ _screenHeight/6,
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
        Column( //Creating favourites list
          children: [
            Text(Languages.of(context)!.favouritesName, style: TextStyle(fontSize: 20, color: Colors.white),),
            Padding(padding: EdgeInsets.symmetric(vertical: 2)),
            Container(
              width: /*380*/ _screenWidth/1.08,
              height: /*100*/ _screenHeight/6,
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

  ///Creates access page
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
          width: /*400*/ _screenWidth/1.1,
          height: /*450*/ _screenHeight/1.6,
          child: AlertDialog(
              backgroundColor: Color.fromRGBO(20, 30, 48, 1),
              title: Center(
                child:  Text(Languages.of(context)!.notLoggedIn, style: TextStyle(color: Colors.white)),
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
                      labelText: 'Email',
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
                            if (value == "true") { //if authorization successfully executed
                              setState(() {
                                auth = true;
                              });
                            } else { //if error during access
                              showDialog(barrierDismissible: false, context: context, builder: (builder) => AccessErrorPage(key: Key(value)));
                            }
                          });
                        },
                        child: Text(Languages.of(context)!.register),
                        style: ButtonStyle(backgroundColor:  MaterialStateColor.resolveWith((states) => Colors.blueGrey),),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _userPageController.signInWithEmailAndPassword(
                            _emailController.text,
                            _passwordController.text,
                          ).then((value) {
                            if (value == "true") { //if authorization successfully executed
                              setState(() {
                                auth = true;
                              });
                            } else { //if error during registration
                              showDialog(barrierDismissible: false, context: context, builder: (builder) => AccessErrorPage(key: Key(value)),);
                            }
                          });
                        },
                        child: Text(Languages.of(context)!.login),
                        style: ButtonStyle(backgroundColor:  MaterialStateColor.resolveWith((states) => Colors.blueGrey),),
                      ),
                    ],
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                  MyDivider(),
                  InkWell(
                    child: Container(
                        width: /*200*/ _screenWidth/2,
                        height: /*30*/ _screenHeight/22.76,
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
                                  height: /*30*/ _screenHeight/22.76,
                                  width: /*30*/ _screenWidth/13.7,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image:
                                        AssetImage('assets/google_logo.png'),
                                        fit: BoxFit.cover),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Text(Languages.of(context)!.signInWithGoogle,
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

    _screenHeight = MediaQuery.of(context).size.height;
    _screenWidth = MediaQuery.of(context).size.width;

    return ValueListenableBuilder(
      valueListenable: _userPageController.getModelAuth(),
      builder: (context, value, _) {
        if (_userPageController.getModelAuth().value == true) {
          _userPageController.updateUserPage(); //updating user's datas

          print("******* GOOGLE ACCOUNT NULLO? ${Model().getGoogleSignInAccount() == null}");

          return Container(
            child: ValueListenableBuilder(
              valueListenable: _userPageController.loaded,
              builder: (context, value, _) {
                if (value == true) { //if load completed
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
      },
    );

  }
}


///Class representing list item into user's page
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
    if (widget.isFavourite) { //this widget will be used to display a favourite record
      return Row(
        children: [
          IconButton(
            icon: Icon(Icons.play_arrow, color: Colors.white,),
            onPressed: () => widget.controller.playFavouriteRecordAt(widget.itemIndex),
          ),
          IconButton(
            icon: Icon( Icons.star, color: Colors.white,),
            onPressed: () => widget.controller.handleRemoveFromFavourites(widget.itemIndex).then((value) {
              widget.callback();
            }),
          ),
        ],
      );
    } else { //this widget will be used to display a shared record
      return Row(
        children: [
          IconButton(
            icon: Icon(Icons.play_arrow, color: Colors.white),
            onPressed: () => widget.controller.playRecordAt(widget.itemIndex),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            onPressed: () => widget.controller.handleRemoveFromSharedSamples(widget.itemIndex).then((value) {
              if (value) {
                Utils.showToast(context, Languages.of(context)!.sampleCorrectlyRemoved);
              } else {
                Utils.showToast(context, Languages.of(context)!.sampleNotCorrectlyRemoved);
              }
              widget.callback();
            }),
          ),
        ],
      );
    }
  }

  String getSquareName() {
    if (widget.isFavourite) {
      return Utils.wrapText(Utils.removeExtension(widget.controller.getFavouriteAt(widget.itemIndex).getFilename()), 9);
    } else {
      return Utils.wrapText(Utils.removeExtension(widget.controller.getUserSharedRecordAt(widget.itemIndex).getFilename()), 9);
    }
  }

  @override
  Widget build(BuildContext context) {

    double _screenHeight = MediaQuery.of(context).size.height;
    double _screenWidth = MediaQuery.of(context).size.width;

    return Card(
      child: Container(
        width: /*100*/ _screenWidth/4.11,
        height: /*50*/ _screenHeight/13.66,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    getSquareName(),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
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


///Dialog for profile image setup
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

    double _screenHeight = MediaQuery.of(context).size.height;
    double _screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      backgroundColor: Color.fromRGBO(36, 59, 85, 1),
      content: Container(
        width: /*200*/ _screenWidth/2,
        height: /*100*/ _screenHeight/6.83,
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


//Class representing profile image choose operation list item
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

    //Getting sceen's size
    double _screenHeight = MediaQuery.of(context).size.height;
    double _screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: /*100*/ _screenWidth/4.11,
      height: /*40*/ _screenHeight/17.075,
      child: Center(
        child: InkWell(
            child: Text(widget.controller.getElementAt(widget.index), style: TextStyle(color: Colors.white),),
            onTap: () async {
              PickedFile? pickedImage = await widget.controller.executeOperation(widget.index);
              setState(() {
                if (pickedImage != null) {
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


///Class representing settings screen
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
                Text( Languages.of(context)!.settingsPageName, style: TextStyle(fontSize: 30, color: Colors.white ),),
                ElevatedButton(onPressed: () => showDialog(
                  context: context,
                  builder: (context) => ChooseImageOperationDialog(
                    controller: UserPageController(),
                    key: Key(1.toString()),
                  ),
                ),
                  child: Text(Languages.of(context)!.setProfileImageName),
                  style: ButtonStyle(backgroundColor:  MaterialStateColor.resolveWith((states) => Colors.blueGrey),),
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => SetUsernameDialog(),
                    );
                  },
                  child: Text(Languages.of(context)!.setUsernameName),
                  style: ButtonStyle(backgroundColor:  MaterialStateColor.resolveWith((states) => Colors.blueGrey),),
                ),
                ElevatedButton(onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => ChangeLanguageDialog(controller: widget.controller,),
                  );},
                  child: Text(Languages.of(context)!.changeLanguageName),
                  style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.blueGrey),),
                ),
                MyDivider(),
                ElevatedButton(
                  onPressed: () => UserPageController().disconnect().then((value) {
                    Navigator.pop(context);
                  }),
                  child: Text(Languages.of(context)!.logoutName),
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
                  child: Text(Languages.of(context)!.deleteUserName),
                  style: ButtonStyle(backgroundColor:  MaterialStateColor.resolveWith((states) => Colors.red),),
                ),
                MyDivider(),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(Languages.of(context)!.backName),
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


///Class representing username setup dialog
class SetUsernameDialog extends StatelessWidget {

  const SetUsernameDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    TextEditingController _textEditingController = TextEditingController();
    //Getting sceen's size
    double _screenHeight = MediaQuery.of(context).size.height;
    double _screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      backgroundColor: Color.fromRGBO(36, 59, 85, 1),
      content: Container(
        width: /*200*/ _screenWidth/2,
        height: /*180*/ _screenHeight/4.1,
        child: Column(
          children: [
            Text(
              Languages.of(context)!.newUsernameInstructions,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 4),),
            TextField(
              style: TextStyle(color: Colors.white),
              controller: _textEditingController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: new BorderSide(color: Colors.white, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: new BorderSide(color: Colors.white, width: 2),
                ),
                labelText: Languages.of(context)!.newUsername,
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
                  child: Text(Languages.of(context)!.cancelName),
                  style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.blueGrey),)
                ),
                ElevatedButton(onPressed: () {
                  UserPageController().setUsername(_textEditingController.text).then((value) {
                    _textEditingController.text = ""; //resetting username field
                    Navigator.pop(context);
                    Navigator.pop(context);
                  });
                  },
                  child: Text(Languages.of(context)!.submitName),
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


///Class representing username deletion confirm widget
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

    //Getting sceen's size
    double _screenHeight = MediaQuery.of(context).size.height;
    double _screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      backgroundColor: Color.fromRGBO(36, 59, 85, 1),
      content: Container(
        width: /*200*/ _screenWidth/2,
        height: /*100*/ _screenHeight/6.83,
        child: Column(
          children: [
            Text(
              Languages.of(context)!.deleteSureName,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 6),),
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
                  child: Text(Languages.of(context)!.yes),
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


///Class representing access error page
class AccessErrorPage extends StatelessWidget {

  const AccessErrorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    //Getting sceen's size
    double _screenHeight = MediaQuery.of(context).size.height;
    double _screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      backgroundColor:  Color.fromRGBO(36, 59, 85, 1),
      content: Container(
        width: /*200*/ _screenWidth/2,
        height: /*150*/ _screenHeight/4.55,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(Languages.of(context)!.errorDuringAccess,
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
              child: Text(Languages.of(context)!.backName),
              style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.blueGrey),),
            ),
          ],
        ),
      ),
    );
  }
}


///Class representing language change
class ChangeLanguageDialog extends StatelessWidget {

  final UserPageController controller;

  const ChangeLanguageDialog({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    //Getting sceen's size
    double _screenHeight = MediaQuery.of(context).size.height;
    double _screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      backgroundColor:  Color.fromRGBO(36, 59, 85, 1),
      content: Container(
        width: /*200*/ _screenWidth/2,
        height: /*150*/ _screenHeight/4.55,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: /*180*/ _screenWidth/2.28,
              height: /*100*/ _screenHeight/6.83,
              child: ListView.separated(
                itemBuilder: (BuildContext context, int index) {
                  return ChangeLanguageDialogListItem(
                    key: Key(controller.getLanguagesCode(index)),
                    controller: controller,
                    index: index,
                  );
                },
                separatorBuilder: (BuildContext context, int index) => const MyDivider(),
                itemCount: controller.getLanguagesListLength(),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context), child: Text(Languages.of(context)!.cancelName),
              style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.red),),
            ),
          ],
        ),
      ),
    );
  }
}


///Class representing language change dialog
class ChangeLanguageDialogListItem extends StatelessWidget {

  final Key key;
  final UserPageController controller;
  final int index;

  const ChangeLanguageDialogListItem({required this.key, required this.controller, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        controller.handleChangeLanguage(context, key.toString());
        Navigator.pop(context);
      },
      child: Row(
        children: [
          Text(controller.getLanguageName(index), textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),
        ],
      ),
    );
  }
}