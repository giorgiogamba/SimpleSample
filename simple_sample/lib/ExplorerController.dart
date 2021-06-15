import 'package:flutter/cupertino.dart';
import 'package:simple_sample/AudioController.dart';
import 'package:simple_sample/CloudStorageController.dart';
import 'package:simple_sample/GoogleDriveController.dart';
import 'Record.dart';
import 'Model.dart';

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

  void getElementsList() async {
    loaded.value = false;
    List<Record> records = await CloudStorageController().getOnlineRecords();
    this._entries = records;
    this._selectedEntries = this._entries;
    loaded.value = true;
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

  void addToFavorites() {
    print("ExplorerController: addToFavorites");
  }

  void downloadRecord(Record record) {
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

}