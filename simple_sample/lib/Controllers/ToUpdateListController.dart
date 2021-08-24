import 'package:simple_sample/Controllers/AudioController.dart';
import 'package:simple_sample/Controllers/GoogleDriveController.dart';
import '../Models/Model.dart';
import '../Models/Record.dart';

///Class tha managed Upload Dialog using Drive

class ToUpdateListController{

  List<Record> _selectedElements = []; //List of elements to be loaded
  List<Record> _elements = []; //List of all the records into the default folder

  static final ToUpdateListController _instance = ToUpdateListController._internal();

  ToUpdateListController._internal() {}

  factory ToUpdateListController() {
    return _instance;
  }

  //Checks of user is logged in
  bool checkIfLoggedIn() { ///OK
    return Model().isUserConnected();
  }

  void getElementsList() { ///OK
    this._elements =  Model().getAllCurrentRecords();
  }

  void addElement(int index) { ///OK
    this._selectedElements.add(this._elements[index]);
  }

  void removeElement(int index) {  ///OK
    this._selectedElements.remove(index);
  }

  ///Uploads all the elements into the folder
  void uploadSelectedElements() {
    for (int i = 0; i < this._selectedElements.length; i ++) {
      GoogleDriveController().upload(this._selectedElements[i]);
    }
  }

  int getElementsListLength() { ///OK
    return this._elements.length;
  }

  Record getElementAt(int index) { ///OK
    return this._elements[index];
  }

  int getSelectedElementsListLength() { ///OK
    return this._selectedElements.length;
  }

  void playRecord(String URL) { ///OK
    AudioController().playAtURL(URL);
  }

}













