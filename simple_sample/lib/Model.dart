import 'dart:collection';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'Record.dart';

class Model {

  static final Model _instance = Model.internal();

  //Authorization variables
  //They == null if user not logged in
  User? _user; //todo fare in modo che non possa essere cambiato a meno che non si faccia un login
  UserCredential? _userCredential;

  HashMap<int,
      Record> _records = HashMap(); //It maintains a map representing the sampler buttons
  //If a new record is done on a full button, the record is replaced NB the old record should already be saved into filesystem
  int counter = 0;
  String docPath = "";
  String? extDocPath;
  int bpm = 1;

  //Sequencer
  //static HashMap<int, HashMap<int, bool>>? _sequencerMap = HashMap(); //mappa con 16 righe e 8 colonne. La mappa esterna contiene colonne, la seconda righe

  //Storage
  String storageUploadPath = "uploads/";

  //Drive
  GoogleSignInAccount? googleAccount;


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
    extDocPath = await getExternalStorageDoc();
    bpm = 20;

    //initSequencerMap();

    print("*************** INIZIALIZZAZIONE MODELLO COMPLETATA ***********");
    print("extDocPath: " + extDocPath!);
  }

  /*void initSequencerMap() {
    for (int i = 0; i < 8; i ++) {
      HashMap<int, bool>? newMap = HashMap();
      for (int j = 0; j < 16; j ++) {
        newMap.putIfAbsent(j, () => false);
      }
      _sequencerMap?.putIfAbsent(i, () => newMap);
    }
    //printSequencerMap();
  }

  static HashMap<int, HashMap<int, bool>>? getSequencerMap() {
    return _sequencerMap;
  }*/

  void addRecord(Record newRecord, int index) {
    //Adding User's Unique ID
    User? currentUser = this.getUser();
    if (currentUser != null) {
      newRecord.setRecordOwnerID(currentUser.uid);
    }
    _records[index] = newRecord;
    print("addRecord: added new record to: " + newRecord.getUrl());
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

  String? getExtDocPath() {
    return this.extDocPath;
  }

  int getBPM() {
    return this.bpm;
  }

  void setBPM(int newBPM) {
    this.bpm = newBPM;
  }

  User? getUser() {
    return _user;
  }

  void setUser(User newUser) {
    this._user = newUser;
  }

  void clearUser() {
    _user = null;
    _userCredential = null;
  }

  bool isUserConnected() {
    if (_user == null) {
      return false;
    } else {
      return true;
    }
  }

  void printUserInfos() {
    print("USER IN MODEL INFOS:");
    print(_user?.email);
    print(_user?.displayName);
  }

  void setUserCredentials(UserCredential cred) {
    this._userCredential = cred;
  }

  String getNewPath() {
    counter ++;
    //return docPath+"/"+counter.toString();
    String path = extDocPath! + "/" + counter.toString() + ".wav";
    File file = new File(path);
    file.create();
    return path;
  }

  Future<String> getDocFilePath() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    return appDocumentsDirectory.absolute.path;
  }

  Future<String?> getExternalStorageDoc() async {
    Directory? dir = await getExternalStorageDirectory();
    return dir?.absolute.path;
  }

  Future<void> loadAssets() async {
    //print(getA.toString());
  }

  List<String> getDirElementsList() {
    List<String> res = [];
    var dir = new Directory(docPath);
    List temp = dir.listSync();
    for (var elem in temp) {
      if (elem is File) {
        res.insert(0, elem.path);
      }
    }

    return res;
  }

  List<String> getExtDirElementsList() {
    List<String> res = [];
    var dir = Directory(extDocPath!);
    List temp = dir.listSync();
    for (var elem in temp) {
      if (elem is File) {
        res.insert(0, elem.path);
      }
    }

    return res;
  }

  String getStorageUploadPath() {
    return storageUploadPath;
  }

  GoogleSignInAccount? getGoogleSignInAccount() {
    return this.googleAccount;
  }

  void setGoogleSignInAccount(GoogleSignInAccount? account) {
    this.googleAccount = account;
  }

  String createCloudStoragePath(String recordName) {
    //Non eseguo un controllo sulll'user perchè se uso questo comando è perchè l'utente è sicuramente connesso
    return this.getStorageUploadPath() + "/" + this.getUser()!.uid.toString() +
        "/" + recordName;
  }

  Record? getRecordWithPath(String path) {
    for (Record r in _records.values) {
      if (r.getUrl() == path) {
        return r;
      }
    }
    return null;
  }

  String getFilesPath() {
    return this.extDocPath!+"/files/";
  }
}




















