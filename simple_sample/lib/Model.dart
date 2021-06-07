import 'dart:collection';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';

import 'Record.dart';

class Model {

  static final Model _instance = Model.internal();
  Model? _singleton;
  User? _user; //todo fare in modo che non possa essere cambiato a meno che non si faccia un login
  UserCredential? _userCredential;
  HashMap<int, Record> _records = HashMap(); //It maintains a map representing the sampler buttons
  //If a new record is done on a full button, the record is replaced NB the old record should already be saved into filesystem
  int counter = 0;
  String docPath = "";
  int bpm = 1;

  Model.internal() {
    print("Inizializzazione model");
    initModel();
  }

  factory Model() {
    return _instance;
  }

  //Called during initialization
  initModel() async {
    _records = HashMap();
    //this._user = new User();
    counter = 0;
    docPath = await getDocFilePath();
    bpm = 20;
    print("*************** INIZIALIZZAZIONE MODELLO COMPLETATA ***********");
    print("docPath vale: "+docPath);
  }

  void addRecord(Record newRecord, int index) {
    _records[index] = newRecord;
  }

  Record? getRecordAt(int index) {
    if (index > 15) {
      return null;
    }
    return _records[index];
  }

  /*Record? getRecordWithID(int ID) {
    for (int i = 0; i < _recordsList!.length; i ++) {
      Record temp = _recordsList![i];
      int tempID = temp.getID();
      if (tempID == ID) {
        return temp;
      }
    }
    return null;
  }*/

  int getBPM() {
    return this.bpm;
  }

  void setBPM(int newBPM) {
    this.bpm = newBPM;
  }

  void setUser(User newUser) {
    this._user = newUser;
  }

  void setUserCredentials(UserCredential cred) {
    this._userCredential = cred;
  }

  String getNewPath() {
    counter ++;
    return docPath+"/"+counter.toString();
  }

  Future<String> getDocFilePath() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    return appDocumentsDirectory.path;
  }
}