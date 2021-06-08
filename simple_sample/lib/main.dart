import 'package:flutter/material.dart';
import 'package:simple_sample/Model.dart';
import 'package:simple_sample/Sampler.dart';
import 'package:firebase_core/firebase_core.dart';

import 'MyBottomNavigationBar.dart';

Future<void> main() async {
  //Inizializzazione preventiva firebase
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  final Future<FirebaseApp> _firebaseApp = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {

    Model();

    return MaterialApp(
      title: 'Simple Sample',
      home: FutureBuilder(
        future: _firebaseApp,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print("Error: ${snapshot.error.toString()}");
            return Text("Something ent wrong");
          } else if (snapshot.hasData) {
            return Scaffold(
              body: MyBottomNavigationBar(),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      )
    );
  }
}