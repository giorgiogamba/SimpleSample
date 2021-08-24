import 'package:flutter/cupertino.dart';
import 'package:simple_sample/Controllers/AudioController.dart';
import 'package:simple_sample/Controllers/CloudStorageController.dart';
import '../Models/Record.dart';
import '../Models/Model.dart';

class ExplorerController { ///TESTED
  static final ExplorerController _instance = ExplorerController._internal();

  ExplorerController._internal() {
    getElementsList();
  }

  factory ExplorerController() {
    return _instance;
  }

  List<Record> _entries = []; //all the records displayed into explorer
  List<Record> _selectedEntries = []; //all the selected records into the explorer
  ValueNotifier<bool> loaded = ValueNotifier(true); //changed to false when page must be reloaded
  List<String> _favourites = []; //all user's favourites

  ///Downloads all the online records
  void getElementsList() async {
    loaded.value = false;
    getFavourites(); //downloads favourites in order to manage buttons operations
    List<Record> records = await CloudStorageController().getOnlineRecords();
    this._entries = records;
    this._selectedEntries = this._entries;
    loaded.value = true;
  }

  bool checkIfUserLogged() { ///OK
    return Model().isUserConnected();
  }

  void playRecord(Record record) { ///OK
    AudioController().playAtURL(record.getUrl());
  }

  Future<void> addToFavorites(Record record) async { ///OK
    await CloudStorageController().addToFavourites(record).then((value) => getFavourites(),);
  }

  Future<void> removeFromFavourites(Record record) async { ///OK
    await CloudStorageController().removeFromFavourites(record).then((value) => getFavourites(),);
  }

  Future<void> downloadRecord(Record record) async { ///OK
    CloudStorageController().downloadRecord(record);
  }

  Record getEntryAt(int index) { ///OK
    return this._entries[index];
  }

  int getEntriesLength() { ///OK
    return this._entries.length;
  }

  void addToSelectedEntries(int index) { ///TESTED
    Record toAdd = getEntryAt(index);
    this._selectedEntries.add(toAdd);
  }

  List<Record> getSelectedEntries() { ///OK
    return this._selectedEntries;
  }

  List<Record> getEntries() { ///OK
    return this._entries;
  }

  Record getSelectedEntryAt(int index) { ///OK
    return this._selectedEntries[index];
  }

  int getSelectedEntriesLength() { ///OK
    return this._selectedEntries.length;
  }

  void setSelectedEntries(List<Record> newEntries) { ///OK
    this._selectedEntries = newEntries;
  }

  void getFavourites() async { ///OK
    this._favourites = []; //resetting favourites
    List<Record> temp = await CloudStorageController().getFavouritesFromDB();
    for (int i = 0; i < temp.length; i ++) {
      this._favourites.add(temp[i].getUrl());
      print(temp[i].getFilename());
    }
    print("Updated favourites");
  }

  ///Manages "Favourites" action button depending on the state
  Future<void> manageFavouritesButton(Record record) async { ///TESTED
    String url = record.getUrl();
    if (this._favourites.contains(url)) { //is the record is saved as "favourite"
      await removeFromFavourites(record);
    } else { //if the record isn't favourite
      await addToFavorites(record);
    }
  }

  ///Changes favourites icon depending on the state
  bool manageFavouritesIcon(Record record) { ///OK
    String url = record.getUrl();
    if (this._favourites.contains(url)) {
      return true;
    } else {
      return false;
    }
  }

  void setEntries(List<Record> entries) { ///OK
    this._entries = entries;
  }

}