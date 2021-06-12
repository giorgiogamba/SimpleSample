import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_sample/Record.dart';

import 'AudioController.dart';
import 'CloudStorageController.dart';

class UserPageController {

  static final UserPageController _instance = UserPageController._internal();

  UserPageController._internal() {
    print("Initializing UserPageController");
  }

  factory UserPageController() {
    return _instance;
  }

  List<String> _elements = ["Select image from Gallery", "Select image from Camera"];

  List<Record> _userSharedRecords = [];

  ValueNotifier profileImagePath = ValueNotifier("assets/userlogo.png"); //!!! NON PRIVATIZZARE

  String getElementAt(int index) {
    return this._elements[index];
  }

  int getElementsLength() {
    return this._elements.length;
  }

  Future<PickedFile?> pickImageFromCamera() async {
    print("UserPageController -- pickImageFromCamera");
    ImagePicker picker = ImagePicker();
    PickedFile? pickedImage = await picker.getImage(source: ImageSource.camera, imageQuality: 100);
    if (pickedImage != null) {
      setProfileImagePath(pickedImage.path);
      CloudStorageController().uploadProfileImage(pickedImage.path);
    }
    return pickedImage;
  }

  Future<PickedFile?> pickImageFromGallery() async {
    print("UserPageController -- pickImageFromGallery");
    ImagePicker picker = ImagePicker();
    PickedFile? pickedImage = await picker.getImage(source: ImageSource.gallery, imageQuality: 100);
    if (pickedImage != null) {
      setProfileImagePath(pickedImage.path);
      CloudStorageController().uploadProfileImage(pickedImage.path);
    }

    return pickedImage;
  }


  Future<PickedFile?> executeOperation(int index) async {
    if (index == 0) {
      PickedFile? image = await pickImageFromGallery();
      return image;
    } else if (index == 1) {
      PickedFile? image = await pickImageFromCamera();
      return image;
    }
  }

  //Gets all the records shared by the user in order to display them into user page
  void getUserSharedRecords() {
    //todo implementare
    _userSharedRecords = CloudStorageController().downloadUserSharedRecords();
  }

  int getUserSharedRecordsLength() {
    return this._userSharedRecords.length;
  }

  Record getUserSharedRecordAt(int index) {
    return this._userSharedRecords[index];
  }

  void playRecordAt(int index) {
    print("ExplorerController: playRecord");
    Record record = getUserSharedRecordAt(index);
    AudioController().playAtURL(record.getUrl());
  }

  void setProfileImagePath(String path) {
    profileImagePath.value = path;
  }

}