import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_sample/Controllers/AuthenticationController.dart';
import 'package:simple_sample/Models/Record.dart';
import 'package:simple_sample/Utils.dart';
import 'package:simple_sample/Utils/LocaleConstant.dart';

import 'AudioController.dart';
import 'CloudStorageController.dart';
import '../Models/Model.dart';

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

  List<String> _languagesList = ["English", "Italiano", "Francais"];
  List<String> _languagesCode = ["en", "it", "fr"];

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
    //String? toUpdate = await CloudStorageController().getFieldValue("toUpdateUserPage");
    //if ( toUpdate != null && toUpdate == "true") {
      await CloudStorageController().downloadUserSharedRecords().then((value) {
        _userSharedRecords = value;
        //CloudStorageController().updateUserField("toUpdateUserPage", false.toString());
      });
    //} //else the page has not to be updated
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

  Future<void> disconnect() async {
    await AuthenticationController().signOut();
    Model().clearUser();
  }

  Future<void> initFavourites() async {
    List<Record> favs = await CloudStorageController().getFavouritesFromDB();
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

  Future<void> deleteAccount() async {
    print("Method delete account");
    AuthenticationController().signOutGoogle();
    AuthenticationController().signOut();

    //Deleting from firebase
    await CloudStorageController().deleteUserDocument();

    //Deleting from Firebase Authentication
    await AuthenticationController().deleteUserAccount();
    print("Account correctly deleted");
  }

  Future<String> signInWithEmailAndPassword(String email, String password) async {
    return await AuthenticationController().signInWithEmailAndPassword(email, password);
  }

  Future<String> createUserWithEmailAndPassword(String email, String password) async {
    return await AuthenticationController().createUserWithEmailAndPassword(email, password);
  }

  void updateUserPage() async {
    print("Updating user page");
    loaded.value = false;
    await getUserSharedRecords();
    await initFavourites();
    loaded.value = true;
  }

  Future<int> getDownloadsNumber() async {
    int value = await CloudStorageController().getDownloadsNumber();
    return value;
  }

  Future<void> handleRemoveFromFavourites(int index) async {
    Record record = this._favourites[index];
    await CloudStorageController().removeFromFavourites(record);
    print("UserPageController -- fine handleRemvoeFromFavourites");
    this._favourites.remove(record);
  }

  ValueNotifier getModelAuth () {
    return Model().getAuth();
  }

  void handleChangeLanguage(BuildContext context, String key) {
    changeLanguage(context, Utils.remove3(key));
  }

  String getLanguageName(int index) {
    return this._languagesList[index];
  }

  String getLanguagesCode(int index) {
    return this._languagesCode[index];
  }

  int getLanguagesListLength() {
    return this._languagesList.length;
  }

}