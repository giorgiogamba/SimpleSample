import 'package:simple_sample/Controllers/CloudStorageController.dart';
import 'AudioController.dart';
import '../Models/Model.dart';
import '../Models/Record.dart';

///Class for Share Dialog management

class ShareDialogController {
  static final ShareDialogController _instance = ShareDialogController._internal();
  List<Record> _entries = []; //list of records that can be shared
  Record? _selectedEntry; //if null next page cannot be reached
  List<String> _selectedTags = []; //list of tags to associated to the shared record

  ShareDialogController._internal() {}

  factory ShareDialogController() {
    return _instance;
  }

  void initElements() {
    _selectedEntry = null;
    _entries = Model().getAllCurrentRecords();
    _selectedTags = Model().getTagsList();
  }

  Record getEntryAt(int position) {
    return _entries[position];
  }

  Record? getSelectedEntry() {
    return this._selectedEntry;
  }

  Record? setSelectedEntry(Record? record) {
    this._selectedEntry = record;
    return null;
  }

  int getEntriesLength() {
    return this._entries.length;
  }

  ///Plays record at the given index
  void playRecord(int itemIndex) {
    Record toPlayRecord = getEntryAt(itemIndex);
    String URL = toPlayRecord.getUrl();
    AudioController().playAtURL(URL);
  }

  Future<bool> share(String newName) async {
    if (newName != "") {
      if (_selectedEntry != null) {
        bool res = await CloudStorageController().shareRecord(_selectedEntry!, _selectedTags, newName);
        _selectedTags = []; //resetting tags
        return res;
      } else {
        throw Exception ("ShareDialogController -- share method -- The element to be shared is null");
      }
    } else {
      throw Exception ("ShareDialogController -- share method -- the new name has not been inserted");
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

  List<String> getSelectedTags() {
    return this._selectedTags;
  }

}