import 'package:simple_sample/CloudStorageController.dart';

import 'Model.dart';
import 'Record.dart';

class ToUpdateListController{

  List<String> selectedElements = [];

  static final ToUpdateListController _instance = ToUpdateListController._internal();

  ToUpdateListController._internal() {}

  factory ToUpdateListController() {
    return _instance;
  }


  List<String> getElementsList() {
    return Model().getExtDirElementsList();
  }

  /*List<String> parseFilenames(List<String> paths) {
    List<String> res = List.filled(paths.length, "");
    for (int i = 0; i < paths.length; i ++) {
      var splitted = paths[i].split("/");
      res[i] = splitted[splitted.length-1];
      print(res[i]);
    }

    return res;
  }*/

  void addElement(String elem) {
    selectedElements.add(elem);
  }

  void removeElement(String elem) {
    selectedElements.remove(elem);
  }

  void uploadSelectedElements() {
    print("Method upoadSelectedElements -- Elements to be uploaded: ");
    for (int i = 0; i < selectedElements.length; i ++) {
      print(selectedElements[i]);
      Record? rec = Model().getRecordWithPath(selectedElements[i]);
      if (rec != null) {
        CloudStorageController().uploadRecord(rec);
      } else {
        throw Exception("Errore: la registrazione da caricare è nulla");
      }
    }
  }

}













