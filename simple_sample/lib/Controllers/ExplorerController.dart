import 'package:flutter/cupertino.dart';
import 'package:simple_sample/Controllers/AudioController.dart';
import 'package:simple_sample/Controllers/CloudStorageController.dart';
import 'package:simple_sample/Controllers/GoogleDriveController.dart';
import '../Models/Record.dart';
import '../Models/Model.dart';

class ExplorerController {
  static final ExplorerController _instance = ExplorerController._internal();

  ExplorerController._internal() {
    getElementsList();
  }

  factory ExplorerController() {
    return _instance;
  }

  List<Record> _entries = [];
  List<Record> _selectedEntries = [];
  ValueNotifier<bool> loaded = ValueNotifier(true);
  List<String> _favourites = [];
  //bool _isToUpdate = false;

  ///Downloads all the online records
  void getElementsList() async {
    //isToUpdate();
    //print(this._isToUpdate);
    //if (this._isToUpdate) {
      loaded.value = false;
      getFavourites(); //downloads favourites in order to manage buttons operations
      List<Record> records = await CloudStorageController().getOnlineRecords();
      this._entries = records;
      this._selectedEntries = this._entries;
      loaded.value = true;
      //updateCompleted();
    //}
  }

  bool checkIfUserLogged() {
    return Model().isUserConnected();
  }

  void playRecord(Record record) {
    print("ExplorerController: playRecord");
    AudioController().playAtURL(record.getUrl());
  }

  void addToDrive(Record record) { //NON SERVE
    print("ExplorerController: addToDrive");
    GoogleDriveController().upload(record);
  }

  Future<void> addToFavorites(Record record) async {
    print("ExplorerController: addToFavorites");
    await CloudStorageController().addToFavourites(record).then((value) => getFavourites(),);
  }

  Future<void> removeFromFavourites(Record record) async {
    print("ExplorerController: removeFromFavorites");
    await CloudStorageController().removeFromFavourites(record).then((value) => getFavourites(),);
  }

  Future<void> downloadRecord(Record record) async {
    print("ExplorerController: downloadRecord");
    CloudStorageController().downloadRecord(record);
  }

  Record getEntryAt(int index) {
    return this._entries[index];
  }

  int getEntriesLength() {
    return this._entries.length;
  }

  void addToSelectedEntries(int index) {
    Record toAdd = getEntryAt(index);
    this._selectedEntries.add(toAdd);
  }

  List<Record> getSelectedEntries() {
    return this._selectedEntries;
  }

  List<Record> getEntries() {
    return this._entries;
  }

  Record getSelectedEntryAt(int index) {
    return this._selectedEntries[index];
  }

  int getSelectedEntriesLength() {
    return this._selectedEntries.length;
  }

  void setSelectedEntries(List<Record> newEntries) {
    this._selectedEntries = newEntries;
  }

  void getFavourites() async {
    this._favourites = []; //resetting favourites
    List<Record> temp = await CloudStorageController().getFavouritesFromDB();
    for (int i = 0; i < temp.length; i ++) {
      this._favourites.add(temp[i].getUrl());
      print(temp[i].getFilename());
    }
    print("Updated favourites");
  }

  ///Manages "Favourites" action button
  Future<void> manageFavouritesButton(Record record) async { //test, provo ad aggiungere async
    String url = record.getUrl();
    if (this._favourites.contains(url)) {
      await removeFromFavourites(record);
    } else {
      await addToFavorites(record);
    }
    //CloudStorageController().updateUserField("toUpdateUserPage" , true.toString());
  }

  bool manageFavouritesIcon(Record record) {
    String url = record.getUrl();
    if (this._favourites.contains(url)) {
      return true;
    } else {
      return false;
    }
  }

  /*void isToUpdate() async {
    String? val = await CloudStorageController().getFieldValue("toUpdateExplorer");
    this._isToUpdate = val == "true";
  }

  void updateCompleted() async {
    CloudStorageController().updateUserField("toUpdateExplorer", false.toString());
  }*/

}