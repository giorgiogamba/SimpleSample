import 'package:flutter/material.dart';
import 'package:simple_sample/Model.dart';
import 'package:simple_sample/Sampler.dart';

import 'MyBottomNavigationBar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    Model();

    return MaterialApp(
      title: 'Simple Sample',
      home: Scaffold(
        body: MyBottomNavigationBar(),
      )
    );
  }
}