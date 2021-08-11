import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/cloudsearch/v1.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Utils.dart';
import 'Record.dart';

class Model { ///TESTING COMPLETED

  static final Model _instance = Model.internal();

  //Authorization variables
  //They == null if user not logged in
  User? _user;
  ValueNotifier<bool> auth = ValueNotifier(false);

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

  //Built-in assets
  List<String> _assets = [
    "assets/sounds/Clap.wav",
    "assets/sounds/Crash.wav",
    "assets/sounds/Hat.wav",
    "assets/sounds/High Tom.wav",
    "assets/sounds/Kick 1.wav",
    "assets/sounds/Kick 2.wav",
    "assets/sounds/Low Tom.wav",
    "assets/sounds/Mid Tom.wav",
    "assets/sounds/Open Hat.wav",
    "assets/sounds/Ride.wav",
    "assets/sounds/Rim Job.wav",
    "assets/sounds/Snare.wav",
  ];

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
    //this._counter = 0;
    initCounter();
    this._docPath = await getDocFilePath();
    this._extDocPath = await getExternalStorageDoc();
    this._bpm = 60;

    writeAssetsIntoFilesystem();

    print("*************** INIZIALIZZAZIONE MODELLO COMPLETATA ***********");
  }

  void addRecord(Record newRecord, int index) { ///TESTED
    //Adding User's Unique ID
    User? currentUser = this.getUser();
    if (currentUser != null) {
      newRecord.setRecordOwnerID(currentUser.uid);
    }
    _records[index] = newRecord;
    print("addRecord: added new record to: " + newRecord.getUrl());
  }

  Record? getRecordAt(int index) { ///TESTED
    if (index > 15) {
      return null;
    }
    return _records[index];
  }

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
    this.auth.value = true;
  }

  void clearUser() {
    _user = null;
    this.auth.value = false;
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

  String getNewPath() { ///TESTED
    this._counter ++;
    String path = this._extDocPath + "/" + this._counter.toString() + ".wav";
    File file = new File(path);
    file.create();
    updateSharedPreferences();
    return path;
  }

  Future<String> getDocFilePath() async { ///TESTED
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    return appDocumentsDirectory.absolute.path;
  }

  Future<String> getExternalStorageDoc() async { ///TESTED
    Directory? dir = await getExternalStorageDirectory();
    return dir!.absolute.path;
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

  ///Takes all the audio files into the externalDir
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

  ///Returns a list containing all the records currently into the sampler map
  List<Record> getAllCurrentRecords() { ///TESTED
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

  Record? getRecordWithPath(String path) { ///TESTED
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

  bool isButtonFull(int index) { ///TESTED
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

  List<String> getAssets() {
    return this._assets;
  }

  void writeAssetsIntoFilesystem() async {
    for (int i = 0; i < this._assets.length; i ++) {
      final encryptedByteData = await rootBundle.load(this._assets[i]);
      Uint8List bytes = encryptedByteData.buffer.asUint8List();
      String filename = Utils.getFilenameFromURL(this._assets[i]);
      String newPath = this._extDocPath+"/"+filename;
      File(newPath).writeAsBytesSync(bytes, mode: FileMode.write, flush: true);
      this._assets[i] = newPath; //verwriting the new path
    }
  }

  ValueNotifier getAuth() {
    return this.auth;
  }

  int getCounter() {
    return this._counter;
  }

  void initCounter() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.getInt("counter");
    bool exists = sharedPreferences.containsKey("counter");
    if (exists) {
      this._counter = sharedPreferences.getInt("counter")!;
    } else {
      this._counter = 0;
      sharedPreferences.setInt("counter", 0);
    }
  }

  void updateSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt("counter", this._counter);
  }

}




















