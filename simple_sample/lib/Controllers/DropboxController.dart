import 'package:dropbox_client/dropbox_client.dart';

class DropboxController {
  static final DropboxController _instance = DropboxController._internal();

  DropboxController._internal() {
    print("Initializing DropboxController");
  }

  factory DropboxController() {
    return _instance;
  }

  Future<void> initDropboxController() async {
    //await Dropbox.init();
  }


}