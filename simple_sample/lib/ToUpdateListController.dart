import 'package:simple_sample/CloudStorageController.dart';

import 'Model.dart';
import 'Record.dart';

class ToUpdateListController{

  List<Record> selectedElements = [];

  static final ToUpdateListController _instance = ToUpdateListController._internal();

  ToUpdateListController._internal() {}

  factory ToUpdateListController() {
    return _instance;
  }

  //Checks of user is logged in
  bool checkIfLoggedIn() {
    return Model().isUserConnected();
  }

  List<Record> getElementsList() {
    //Versione 1; preleva tutte le registrazioni presenti nel filesystem
    //return Model().getExtDirElementsList(); //preleva tutte le registrazioni presenti nel filesystem

    //Versione2: preleva tutti le registrazioni effettuate dall'avvio
    return Model().getAllCurrentRecords();
  }

  void addElement(Record elem) {
    selectedElements.add(elem);
  }

  void removeElement(Record elem) {
    selectedElements.remove(elem);
  }

  void uploadSelectedElements() {
    print("Method upoadSelectedElements -- Elements to be uploaded: ");
    for (int i = 0; i < selectedElements.length; i ++) {
      selectedElements[i].printRecordInfo();
      CloudStorageController().uploadRecord(selectedElements[i]);
    }
  }

}













