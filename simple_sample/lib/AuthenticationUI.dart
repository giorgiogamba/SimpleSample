import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_sample/AuthenticationController.dart';

///Class representing Authentication Page

class AuthenticationUI extends StatefulWidget {
  const AuthenticationUI({Key? key}) : super(key: key);

  @override
  _AuthenticationUIState createState() => _AuthenticationUIState();
}

class _AuthenticationUIState extends State<AuthenticationUI> {

  AuthenticationController _controller = AuthenticationController();
  bool auth = false; //la mantengo così cambia la UI a seconda dello stato

  @override
  void initState() {
    auth = _controller.checkIfAuthorized();
    super.initState();
  }

  Widget buildPage() {
    if (auth) {
      return Center(
        child: Text("User logged in"),
      );
    } else {
      /*return Center(
        child: Column(
          children: [
            Text("You are not authorized"),
            ElevatedButton(onPressed: () {}, child: Text("Authorize")),
          ],
        ),
      );*/
      return AlertDialog(
        title: Text("You are not logged in"),
        content: Column(
          children: [
            TextField(

            ),
            ElevatedButton(onPressed: () {}, child: Text("Login")) //todo richiamare operazione sign in
          ],
        );
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildPage(),
    );
  }
}
