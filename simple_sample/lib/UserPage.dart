import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'AuthenticationController.dart';

///Class representing the user Interface
///

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {

  AuthenticationController _controller = AuthenticationController();
  bool auth = false; //la mantengo così cambia la UI a seconda dello stato

  @override
  void initState() {
    auth = _controller.checkIfAuthorized();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (auth) {
      return Center(
        child: Column(
          children: [
            Text("User logged in"),
            SizedBox(height: 20,),
            ElevatedButton(onPressed: _controller.signOutGoogle, child: Text("Sign out")),
          ],
        ),
      );
    } else {
      return AlertDialog(
          title: Text("You are not logged in"),
          elevation: 20,
          content: Column(
            children: [
              /*ElevatedButton(onPressed: () async {
                _controller.signInWithGoogle();
              }, child: Text("Login")),*/
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
                  _controller.signInWithGoogle();
                },
              ),
            ],
          )
      );
    }
  }
}
