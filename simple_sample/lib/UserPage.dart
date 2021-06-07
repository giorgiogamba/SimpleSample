import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///Class representing the user Interface
///

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("User Page"),
      ),
    );
  }
}
