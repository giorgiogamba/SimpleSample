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

  HashMap<int, Record> _records = HashMap(); //It maintains a map representing the sampler buttons
  //If a new record is done on a full button, the record is replaced NB the old record should already be saved into filesystem
  int _counter = 0;
  String _docPath = "";
  String _extDocPath = "";
  int _bpm = 1;

  //Storage
  String _storageUploadPath = "uploads/";
  String _deviceToken = "";

  //Drive
  GoogleSignInAccount? _googleAccount;

  //Tags
  List<String> _tagsList = ["Dreamy", "HipHop", "SingleShot", "Pop", "Snare", "Kick", "HiHat", "RnB", "Rock", "Electronic", "Funk",
                            "Disco", "Biologic", "Natural", "Tech", "House"];


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
    this._counter = 0;
    this._docPath = await getDocFilePath();
    this._extDocPath = await getExternalStorageDoc();
    this._bpm = 60;

    print("*************** INIZIALIZZAZIONE MODELLO COMPLETATA ***********");
  }

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

  String getExtDocPath() {
    return this._extDocPath;
  }

  int getBPM() {
    return this._bpm;
  }

  void setBPM(int newBPM) {
    this._bpm = newBPM;
  }

  User? getUser() {
    return _user;
  }

  void setUser(User newUser) {
    this._user = newUser;
  }

  void clearUser() {
    _user = null;
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

  String getNewPath() {
    this._counter ++;
    //return docPath+"/"+counter.toString();
    String path = this._extDocPath + "/" + this._counter.toString() + ".wav";
    File file = new File(path);
    file.create();
    return path;
  }

  Future<String> getDocFilePath() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    return appDocumentsDirectory.absolute.path;
  }

  Future<String> getExternalStorageDoc() async {
    Directory? dir = await getExternalStorageDirectory();
    return dir!.absolute.path;
  }

  Future<void> loadAssets() async {
    //print(getA.toString());
  }

  List<String> getDirElementsList() {
    List<String> res = [];
    var dir = new Directory(this._docPath);
    List temp = dir.listSync();
    for (var elem in temp) {
      if (elem is File) {
        res.insert(0, elem.path);
      }
    }

    return res;
  }

  //Takes all the audio files into the externalDir
  List<String> getExtDirElementsList() {
    List<String> res = [];
    var dir = Directory(this._extDocPath);
    List temp = dir.listSync();
    for (var elem in temp) {
      if (elem is File) {
        res.insert(0, elem.path);
      }
    }

    return res;
  }

  //Returns all the
  List<Record> getAllCurrentRecords() {
    List<Record> res = [];
    for (Record r in _records.values) {
      res.add(r);
    }
    return res;
  }

  String getStorageUploadPath() {
    return this._storageUploadPath;
  }

  GoogleSignInAccount? getGoogleSignInAccount() {
    return this._googleAccount;
  }

  void setGoogleSignInAccount(GoogleSignInAccount? account) {
    this._googleAccount = account;
  }

  String createCloudStoragePath(String recordName) {
    //Non eseguo un controllo sulll'user perchè se uso questo comando è perchè l'utente è sicuramente connesso
    return this.getStorageUploadPath() + "/" + this.getUser()!.uid.toString() + "/" + recordName;
  }

  Record? getRecordWithPath(String path) {
    print("***** URL ANALIZZATI; ********");
    for (Record r in _records.values) {
      print(r.getUrl());
      if (r.getUrl() == path) {
        return r;
      }
    }
    return null;
  }

  String getFilesPath() {
    return this._extDocPath+"/files/";
  }

  List<String> getTagsList() {
    return this._tagsList;
  }

  String getTagAt(int index) {
    return this._tagsList[index];
  }

  bool isButtonFull(int index) {
    Record? record = _records[index];
    if (record == null) {
      return false;
    } else {
      return true;
    }
  }

  Future<void> renameRecord (int index, String name) async {
    print("Rename record");
    Record? toRename = getRecordAt(index);
    if (toRename != null) {
      File toRenameFile = File (toRename.getUrl());
      String newName = name + ".wav";
      File updatedFile = await changeFileNameOnly(toRenameFile, newName);
      toRename.setUrl(updatedFile.path);
      toRename.extractFilename();
    } else {
      print("The record to rename is null");
    }

  }

  Future<File> changeFileNameOnly(File file, String newFileName) {
    var path = file.path;
    var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
    var newPath = path.substring(0, lastSeparator + 1) + newFileName;
    return file.rename(newPath);
  }

  void setDeviceToken(String token) {
    this._deviceToken = token;
  }

  String getDeviceToken() {
    return this._deviceToken;
  }
}




















