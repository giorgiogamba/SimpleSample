import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_sample/AuthenticationController.dart';
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
  List<Record> _favourites = [];

  ValueNotifier profileImagePath = ValueNotifier("assets/userlogo_white.png"); //!!! NON PRIVATIZZARE
  ValueNotifier<bool> loaded = ValueNotifier(false);

  String getElementAt(int index) {
    return this._elements[index];
  }

  int getElementsLength() {
    return this._elements.length;
  }

  Future<PickedFile?> pickImageFromCamera() async {
    ImagePicker picker = ImagePicker();
    PickedFile? pickedImage = await picker.getImage(source: ImageSource.camera, imageQuality: 100);
    if (pickedImage != null) {
      setProfileImagePath(pickedImage.path);
      CloudStorageController().uploadProfileImage(pickedImage.path);
    }
    return pickedImage;
  }

  Future<PickedFile?> pickImageFromGallery() async {
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
  Future<void> getUserSharedRecords() async {
    print("UserPageController -- getUserSharedController method");
    await CloudStorageController().downloadUserSharedRecords().then((value) {
      _userSharedRecords = value;
    });
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

  void disconnect() {
    AuthenticationController().signOut();
  }

  Future<void> initFavourites() async {
    List<Record> favs = await CloudStorageController().getFavouritesFromDB();
    print("DOWNLOADED FAVS: ");
    for (int i = 0; i < favs.length; i++) {
      favs[i].printRecordInfo();
    }
    this._favourites = favs;
  }

  List<Record> getFavourites() {
    return this._favourites;
  }

  Record getFavouriteAt(int index) {
    return this._favourites[index];
  }

  int getFavouritesLength() {
    return this._favourites.length;
  }

  Future<void> setUsername(String newUsername) async {
    print("newUsername: "+newUsername);
    await CloudStorageController().setUsername(newUsername);
  }

  Future<String> getUsername() async {
    return await CloudStorageController().getUsername();
  }

  void deleteAccount() {
    //todo listare tutte le cose da scollegare
  }

  void signInWithEmailAndPassword(String email, String password) {
    AuthenticationController().signInWithEmailAndPassword(email, password);
  }

  void createUserWithEmailAndPassword(String email, String password) {
    print("USerPageController: metodo create User");
    AuthenticationController().createUserWithEmailAndPassword(email, password);
  }

  void updateUserPage() async {
    print("Updating user page");
    loaded.value = false;
    await getUserSharedRecords();
    await initFavourites();
    loaded.value = true;
  }

}