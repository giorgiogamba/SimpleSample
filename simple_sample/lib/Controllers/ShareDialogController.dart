import 'package:simple_sample/Controllers/CloudStorageController.dart';
import 'AudioController.dart';
import '../Models/Model.dart';
import '../Models/Record.dart';

class ShareDialogController { ///TESTED
  static final ShareDialogController _instance = ShareDialogController._internal();
  List<Record> _entries = [];
  Record? _selectedEntry; //if null non si può procedere alla pagina successiva
  List<String> _selectedTags = [];

  ShareDialogController._internal() {}

  factory ShareDialogController() {
    return _instance;
  }

  void initElements() { ///OK
    _selectedEntry = null;
    _entries = Model().getAllCurrentRecords();
    _selectedTags = Model().getTagsList();
  }

  Record getEntryAt(int position) { ///OK
    return _entries[position];
  }

  Record? getSelectedEntry() { ///OK
    return this._selectedEntry;
  }

  Record? setSelectedEntry(Record? record) { ///OK
    this._selectedEntry = record;
  }

  int getEntriesLength() { ///OK
    return this._entries.length;
  }

  void playRecord(int itemIndex) { ///OK
    Record toPlayRecord = getEntryAt(itemIndex);
    String URL = toPlayRecord.getUrl();
    AudioController().playAtURL(URL);
  }

  Future<bool> share(String newName) async {
    //_selectedEntry è l'elemento da cricare
    if (newName != "") {
      if (_selectedEntry != null) {
        print("ShareDialogController -- share Method: uploadign record with name $newName");
        bool res = await CloudStorageController().shareRecord(_selectedEntry!, _selectedTags, newName);
        _selectedTags = [];
        return res;
      } else {
        throw Exception ("ShareDialogController -- share method -- The element to be shared is null");
      }
    } else {
      throw Exception ("ShareDialogController -- share method -- the new name has not been inserted");
    }
  }

  int getTagsListLength() { ///OK
    return Model().getTagsList().length;
  }

  String getTagAt(int index) { ///OK
    return Model().getTagAt(index);
  }

  void addToSelectedTags(int index) { ///TESTED
    String selectedTag = getTagAt(index);
    _selectedTags.add(selectedTag);
  }

  void removeFromSelectedTags(int index) { ///TESTED
    String toRemove = getTagAt(index);
    _selectedTags.remove(toRemove);
  }

  void resetSelectedTags() { ///OK
    this._selectedTags = [];
  }

  List<String> getSelectedTags() { ///OK
    return this._selectedTags;
  }

}