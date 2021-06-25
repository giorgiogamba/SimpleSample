import 'package:flutter/material.dart';
import 'package:simple_sample/Controllers/SequencerController.dart';
import 'package:simple_sample/Models/Model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:overlay_support/overlay_support.dart';
import 'UI/MyBottomNavigationBar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  final Future<FirebaseApp> _firebaseApp = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {

    Model();

    return OverlaySupport( //for notificaiton test
      child: MaterialApp(
        title: 'Simple Sample',
        home: FutureBuilder(
          future: _firebaseApp,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print("Error: ${snapshot.error.toString()}");
              return Text("Something ent wrong");
            } else if (snapshot.hasData) {
              return Scaffold(
                body:
                new Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: Color.fromRGBO(20, 30, 48, 1),
                  ),
                  child: MyBottomNavigationBar(),
                ),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        )
      ),
    );
  }
}