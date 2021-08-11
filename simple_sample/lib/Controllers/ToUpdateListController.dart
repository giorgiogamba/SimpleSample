import 'package:simple_sample/Controllers/AudioController.dart';
import 'package:simple_sample/Controllers/CloudStorageController.dart';
import 'package:simple_sample/Controllers/GoogleDriveController.dart';

import '../Models/Model.dart';
import '../Models/Record.dart';

class ToUpdateListController{

  List<Record> _selectedElements = [];
  List<Record> _elements = [];

  static final ToUpdateListController _instance = ToUpdateListController._internal();

  ToUpdateListController._internal() {}

  factory ToUpdateListController() {
    return _instance;
  }

  //Checks of user is logged in
  bool checkIfLoggedIn() {
    return Model().isUserConnected();
  }

  void getElementsList() {
    this._elements =  Model().getAllCurrentRecords();
    print("ToUpdateListController: numero tot elmeenti: ${this._elements.length}");
  }

  void addElement(int index) {
    this._selectedElements.add(this._elements[index]);
  }

  void removeElement(int index) {
    this._selectedElements.remove(index);
  }

  void uploadSelectedElements() {
    print("Method upoadSelectedElements -- Elements to be uploaded: ");
    for (int i = 0; i < this._selectedElements.length; i ++) {
      this._selectedElements[i].printRecordInfo();
      //CloudStorageController().uploadRecord(this._selectedElements[i]);
      GoogleDriveController().upload(this._selectedElements[i]);
    }
  }

  int getElementsListLength() {
    return this._elements.length;
  }

  Record getElementAt(int index) {
    return this._elements[index];
  }

  int getSelectedElementsListLength() {
    return this._selectedElements.length;
  }

  void playRecord(String URL) {
    AudioController().playAtURL(URL);
  }

}













