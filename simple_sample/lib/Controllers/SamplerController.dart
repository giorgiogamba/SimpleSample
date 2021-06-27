import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

import '../Utils/Languages.dart';
import '../Models/Model.dart';
import '../Models/Record.dart';
import 'dart:io';

class SamplerController {

  static final SamplerController _instance = SamplerController._internal();

  SamplerController._internal() {}

  factory SamplerController() {
    return _instance;
  }

  bool _selectAnItem = false;
  String _selectedURL = "";
  bool _renameRunning = false;
  TextEditingController _textEditingController = TextEditingController();
  int? _selectedItemForRename;
  bool _renameSubmitted = false;
  bool _isSharingRunning = false;
  bool _isLoadingRunning = false;
  int? _selectedItemForSharing;
  String _operationInformationText = "";
  List<String> _assets = [];

  bool checkIfUserConnected() {
    return Model().isUserConnected();
  }

  ///Picks up an audio file from a filesystem and then saves it into the samples' location
  Future<String?> pickFile() async {
    List<String> ext = ["wav", "mp3"];
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ext);
    if (result != null) {
      String res = moveFile(result.paths.single.toString());
      return res;
    }
    return "";
  }

  ///Utility method that oved the file to the samples' location
  String moveFile(String path) {
    //Reading original file
    Uint8List readOriginalFile = File(path).readAsBytesSync();

    //Creating new path
    var splitted = path.split("/");
    String filename = splitted[splitted.length-1];
    String newPath = Model().getExtDocPath() + "/" + filename;

    //Writing read file in a file in the correct location
    File(newPath).writeAsBytesSync(readOriginalFile, mode: FileMode.write, flush:true);

    //Deleting old file
    File(path).deleteSync();

    return newPath;
  }

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

  void enableRenaming(BuildContext context) {
    _operationInformationText = Languages.of(context)!.renameInstructionsName;
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

  void enableSharing(BuildContext context) {
    _operationInformationText = Languages.of(context)!.shareInstructionsName;
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

  void enableLoading() {
    this._isLoadingRunning = true;
  }

  void disableLoading() {
    this._isLoadingRunning = false;
  }

  bool isLoadingRunning() {
    return this._isLoadingRunning;
  }

  void loadAssets() {
    this._assets = Model().getAssets();
  }

  String getAssetAt(int index) {
    return this._assets[index];
  }

  int getAssetsLength() {
    return this._assets.length;
  }

}