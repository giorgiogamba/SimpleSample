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

  Widget buildPage() {
    return Column(
      children: [
        ElevatedButton(onPressed: AuthenticationController.signInWithGoogle, child: Text("Sign in with Google")),
        ElevatedButton(onPressed: AuthenticationController.signInWithFacebook, child: Text("Sign in with Facebook")),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildPage(),
    );
  }
}
