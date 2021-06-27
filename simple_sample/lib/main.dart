import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:simple_sample/Controllers/SequencerController.dart';
import 'package:simple_sample/Models/Model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:overlay_support/overlay_support.dart';
import 'UI/MyBottomNavigationBar.dart';
import 'Utils/LocaleConstant.dart';
import 'Utils/AppLocalizationDelegate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  //for ultilanguage support
  static void setLocale(BuildContext context, Locale newLocale) {
    var state = context.findAncestorStateOfType<_MyAppState>();
    state!.setLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final Future<FirebaseApp> _firebaseApp = Firebase.initializeApp();


  //for multilanguage support
  Locale _locale = Locale("en");

  void setLocale(Locale locale) {
    print("chiamato setLocale");
    print(locale.toString());
    setState(() {
      _locale = locale;
      print(_locale.toString());
    });
  }

  @override
  void didChangeDependencies() async {
    getLocale().then((locale) {
      setState(() {
        _locale = locale;
        print(_locale.toString());
      });
    });
    super.didChangeDependencies();
  }

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
          ),
        locale: _locale,
        supportedLocales: [
          Locale('en', ''),
          Locale('it', ''),
        ],
        localizationsDelegates: [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale?.languageCode &&
                supportedLocale.countryCode == locale?.countryCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
      ),
    );


  }
}
