import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_sample/UI/Sampler.dart';
import 'package:simple_sample/UI/UserPage.dart';
import 'Explorer.dart';
import 'Sequencer.dart';

/// Class representing constant app nagivation Bar

class MyBottomNavigationBar extends StatefulWidget {
  const MyBottomNavigationBar({Key? key}) : super(key: key);

  @override
  _MyBottomNavigationBarState createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    final List<Widget> children = [Sampler(), Sequencer(), UserPage(), Explorer()];

    return Scaffold(
      body: PageTransitionSwitcher(
        transitionBuilder: (child, primaryAnimation, secondaryAnimation) =>
            FadeThroughTransition(
              animation: primaryAnimation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            ),
        child: children[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false, //for hiding BottonNavigationBarItem's labels
        showUnselectedLabels: false, //for hiding BottonNavigationBarItem's labels
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.apps_sharp,), label: "Sampler", ),
          BottomNavigationBarItem(icon: Icon(Icons.audiotrack,), label: "Sequencer"),
          BottomNavigationBarItem(icon: Icon(Icons.accessibility,), label: "User"),
          BottomNavigationBarItem(icon: Icon(Icons.all_inbox,), label: "Explorer"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );

  }
}