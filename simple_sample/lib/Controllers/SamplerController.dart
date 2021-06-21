import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../Models/Model.dart';
import '../Models/Record.dart';
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
  bool _renameRunning = false;
  TextEditingController _textEditingController = TextEditingController();
  int? _selectedItemForRename;
  bool _renameSubmitted = false;
  bool _isSharingRunning = false;
  int? _selectedItemForSharing;
  String _operationInformationText = "";


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

  bool checkIsButtonIsFull(int index) {
    return Model().isButtonFull(index);
  }

  String getButtonName(int index) {
    Record? record = Model().getRecordAt(index);
    if (record != null) {
      return record.getFilename();
    } else {
      return "Bt$index";
    }
  }

  bool isRenameRunning() {
    return this._renameRunning;
  }

  void enableRenaming() {
    _operationInformationText = "Choose a Record to Rename";
    this._renameRunning = true;
  }

  void disableRenaming() {
    _operationInformationText = "";
    this._renameRunning = false;
  }

  TextEditingController getTextEditingController() {
    return this._textEditingController;
  }

  void setSelectedItemForRename(int index) {
    this._selectedItemForRename = index;
  }

  ///Returns true iff record at position index has non-null filename
  bool isRenamePossible(int index) {
    Record? record = Model().getRecordAt(index);
    if (record != null) {
      if(record.getFilename() != null) {
        return true;
      }
      return false;
    }
    return false;
  }

  Future<void> renameRecord() async {
    if (this._selectedItemForRename != null) {
      await Model().renameRecord(this._selectedItemForRename!, _textEditingController.text);
      //resetting TextEditingController
      _textEditingController.text = "";
    } else {
      print("Item selected is null");
    }
  }

  bool getRenameSubmitted() {
    return this._renameSubmitted;
  }

  void setRenameSubmitted(bool value) {
    this._renameSubmitted = value;
  }

  void enableSharing() {
    _operationInformationText = "Choose a Record to Share";
    this._isSharingRunning = true;
  }

  void disableSharing() {
    _operationInformationText = "";
    this._isSharingRunning = false;
  }

  bool isSharingRunning() {
    return this._isSharingRunning;
  }

  void setSelectedItemForSharing(int index) {
    this._selectedItemForSharing = index;
  }

  Record? getSelectedItemForSharing(int index) {
    return Model().getRecordAt(index);
  }

  String getOperationInformationText() {
    return this._operationInformationText;
  }

  void setOperationInformationTxt(String text) {
    this._operationInformationText = text;
  }
}