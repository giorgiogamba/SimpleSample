import 'package:simple_sample/Model.dart';

class StorageController {

  static final StorageController _instance = StorageController._internal();

  factory StorageController() {
    return _instance;
  }

  StorageController._internal() {
    print("Inizializzazione Storage Controller");
  }

  List<String> getElementsList() {
    return Model().getExtDirElementsList();
  }

}