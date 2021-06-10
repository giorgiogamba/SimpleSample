import 'package:simple_sample/AudioController.dart';
import 'package:simple_sample/CloudStorageController.dart';
import 'package:simple_sample/GoogleDriveController.dart';
import 'Record.dart';
import 'Model.dart';

class ExplorerController {
  static final ExplorerController _instance = ExplorerController._internal();

  ExplorerController._internal() {}

  factory ExplorerController() {
    return _instance;
  }

  Future<List<Record>> getElementsList() async {
    //CloudStorageController().downloadURL("uploads/example.wav");
    List<Record> records = await CloudStorageController().getOnlineRecords();
    if (records.length > 0) {
      return records;
    } else {
      return [];
    }

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

}