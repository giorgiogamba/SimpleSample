import 'package:flutter/material.dart';
import 'package:simple_sample/Controllers/CloudStorageController.dart';

import 'AudioController.dart';
import '../Models/Model.dart';
import '../Models/Record.dart';

class ShareDialogController {
  static final ShareDialogController _instance = ShareDialogController._internal();
  List<Record> _entries = [];
  Record? _selectedEntry; //if null non si può procedere alla pagina successiva
  List<String> _selectedTags = [];

  ShareDialogController._internal() {}

  factory ShareDialogController() {
    return _instance;
  }

  void initElements() {
    _selectedEntry = null;
    _entries = Model().getAllCurrentRecords();
    _selectedTags = Model().getTagsList();
    print("Eseguita inizializzazione elementi");
  }

  Record getEntryAt(int position) {
    print("Prelievo elemento alla posizione $position");
    return _entries[position];
  }

  Record? getSelectedEntry() {
    return this._selectedEntry;
  }

  Record? setSelectedEntry(Record? record) {
    print("Inserisco selectect entry con informazione: ");
    record?.printRecordInfo();
    this._selectedEntry = record;
  }

  int getEntriesLength() {
    return this._entries.length;
  }

  void playRecord(int itemIndex) {
    print("ShareDialogController: playRecord method");
    Record toPlayRecord = getEntryAt(itemIndex);
    String URL = toPlayRecord.getUrl();
    AudioController().playAtURL(URL);
  }

  Future<bool> share(String newName) {
    print("SgareDialogController -- share method");
    print("Selected tags: ");

    //_selectedEntry è l'elemento da cricare
    if (newName != "") {
      print("newname diverso da null");
      if (_selectedEntry != null) {
        print("selected entru diverso da null");
        print("ShareDialogController -- share Method: uploadign record with name $newName amd tags");
        for (int i = 0; i < _selectedTags.length; i ++) {
          print(_selectedTags[i]);
        }

        return CloudStorageController().shareRecord(_selectedEntry!, _selectedTags, newName);
      } else {
        throw Exception ("_selectedEntry è null");
      }
    } else {
      throw Exception ("newName non è stato inserito");
    }
  }

  int getTagsListLength() {
    return Model().getTagsList().length;
  }

  String getTagAt(int index) {
    return Model().getTagAt(index);
  }

  void addToSelectedTags(int index) {
    String selectedTag = getTagAt(index);
    _selectedTags.add(selectedTag);
  }

  void removeFromSelectedTags(int index) {
    String toRemove = getTagAt(index);
    _selectedTags.remove(toRemove);
  }

  void resetSelectedTags() {
    this._selectedTags = [];
  }

}