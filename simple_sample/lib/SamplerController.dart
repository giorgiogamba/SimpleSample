import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Model.dart';
import 'Record.dart';
import 'dart:io';

class SamplerController {

  static final SamplerController _instance = SamplerController._internal();

  SamplerController._internal() {}

  factory SamplerController() {
    return _instance;
  }

  bool checkIfUserConnected() {
    return Model().isUserConnected();
  }


  //Per ora metto qua il codice per il file èocking dal filesystem, poi vedere come fare
  Future<String?> pickFile() async {
    List<String> ext = [".wav", ".mp3"];
    //Todo è anche possibile user FileType.audio, ,ma bisogna fare un controllo incrociato con
    //il player e il recorder per capire quali estensioni sono supportate
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ext);
    if (result != null) {
      String res = result.paths.single.toString();
      print("RESULT; "+res );
      return res;
    }
    return "";
  }


  bool _selectAnItem = false;
  String _selectedURL = "";

  bool isEnabledItemSelection() {
    return this._selectAnItem;
  }

  void enableItemSelection() {
    this._selectAnItem = true;
  }

  void disableItemSelection() {
    this._selectAnItem = false;
  }

  void setSelectedURL(String newURL) {
    this._selectedURL = newURL;
    print("Selected URL vale: "+this._selectedURL);
  }

  void resetSelectedURL() {
    this._selectedURL = "";
  }

  void associateFileToButton(int index) {
    Record newRecord = Record(this._selectedURL);
    User? user = Model().getUser();
    if (user != null) {
      newRecord.setRecordOwnerID(user.uid);
    }
    newRecord.setPosition(index);
    Model().addRecord(newRecord, index);
    print("SamplerController -- associate File to button \n ${newRecord.getUrl()} -- ${newRecord.getPosition()}");
  }

}