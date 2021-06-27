import 'package:flutter/cupertino.dart';

abstract class Languages {

  static Languages? of(BuildContext context) {
    return Localizations.of<Languages>(context, Languages);
  }

  String get settingsPageName;

  String get setProfileImageName;

  String get setUsernameName;

  String get changeLanguageName;

  String get logoutName;

  String get deleteUserName;

  String get backName;

  String get sharedSamplesName;

  String get favouritesName;

  String get filterByName;

  String get loadName;

  String get shareName;

  String get renameName;

  String get renameInstructionsName;

  String get shareInstructionsName;

  String get submitName;

  String get changeUsernameInstructionName;

  String get setProfileImageInstructions1;

  String get setProfileImageInstructions2;

  String get deleteSureName;

  String get cancelName;

  String get userNotConnected;

  String get signInWithGoogle;

  String get register;

  String get login;

  String get notLoggedIn;

  String get newUsername;

  String get newUsernameInstructions;

  String get yes;

  String get errorDuringAccess;

  String get nameName;

  String get filterBy;

  String get downloadCorrect;

  String get sampleSaved;

  String get selectButton;

  String get cannotSelect;

}